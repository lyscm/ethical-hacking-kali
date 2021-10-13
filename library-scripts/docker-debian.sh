#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/docker.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./docker-debian.sh [enable non-root docker socket access flag] [source socket] [target socket] [non-root user] [use moby]

ENABLE_NONROOT_DOCKER=${1:-"true"}
SOURCE_SOCKET=${2:-"/var/run/docker-host.sock"}
TARGET_SOCKET=${3:-"/var/run/docker.sock"}
USER_NAME=${4:-"automatic"}
USE_MOBY=${5:-"true"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Determine the appropriate non-root user
if [ "${USER_NAME}" = "auto" ] || [ "${USER_NAME}" = "automatic" ]; then
    USER_NAME=""
    POSSIBLE_USERS=("non-root" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in ${POSSIBLE_USERS[@]}; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USER_NAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USER_NAME}" = "" ]; then
        USER_NAME=root
    fi
elif [ "${USER_NAME}" = "none" ] || ! id -u ${USER_NAME} > /dev/null 2>&1; then
    USER_NAME=root
fi

# Function to run apt-get if needed
apt-get-update-if-needed()
{
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# Install apt-transport-https, curl, lsb-release, gpg if missing
if ! dpkg -s apt-transport-https curl ca-certificates lsb-release > /dev/null 2>&1 || ! type gpg > /dev/null 2>&1; then
    apt-get-update-if-needed
    apt-get -y install --no-install-recommends apt-transport-https curl ca-certificates lsb-release gnupg2 
fi

# Install Docker / Moby CLI if not already installed
DISTRO=$(grep -oP '(?<=ID_LIKE=).*' /etc/os-release)
CODENAME='buster'
if type docker > /dev/null 2>&1; then
    echo "Docker / Moby CLI already installed."
else
    if [ "${USE_MOBY}" = "true" ]; then
        curl -s https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(apt-key add - 2>&1) || echo $OUT)
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-${DISTRO}-${CODENAME}-prod ${CODENAME} main" > /etc/apt/sources.list.d/microsoft.list
        apt-get update
        apt-get -y install --no-install-recommends moby-cli moby-buildx
    else
        curl -fsSL https://download.docker.com/linux/${DISTRO}/gpg | (OUT=$(apt-key add - 2>&1) || echo $OUT)
        echo "deb [arch=amd64] https://download.docker.com/linux/${DISTRO} ${CODENAME} stable" | tee /etc/apt/sources.list.d/docker.list
        apt-get update
        apt remove -y docker docker-engine docker.io
        apt install docker-ce -y
    fi
fi

# Install Docker Compose if not already installed 
if type docker-compose > /dev/null 2>&1; then
    echo "Docker Compose already installed."
else
    LATEST_COMPOSE_VERSION=$(basename "$(curl -fsSL -o /dev/null -w "%{url_effective}" https://github.com/docker/compose/releases/latest)")
    curl -fsSL "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# By default, make the source and target sockets the same
if [ "${SOURCE_SOCKET}" != "${TARGET_SOCKET}" ]; then
    touch "${SOURCE_SOCKET}"
    ln -s "${SOURCE_SOCKET}" "${TARGET_SOCKET}"
fi

# If enabling non-root access and specified user is found, setup socat and add script
chown -h "${USER_NAME}":root "${TARGET_SOCKET}"        
if ! dpkg -s socat > /dev/null 2>&1; then
    apt-get-update-if-needed
    apt-get -y install socat
fi

echo "Done!"