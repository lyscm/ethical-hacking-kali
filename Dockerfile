# [Required] Extensions
FROM --platform=$BUILDPLATFORM ghcr.io/lyscm/environments/kali/extensions as extensions

# [Required] Python ecosystem
FROM --platform=$BUILDPLATFORM python as settings

ARG TARGETPLATFORM
ARG SCRIPT_NAME=".initiate-scripts.py"
WORKDIR /lyscm/$TARGETPLATFORM

# Install pip requirements
COPY ${SCRIPT_NAME} .
COPY .devcontainer/ ./.devcontainer/
COPY --from=extensions ./ ./extensions

RUN python $SCRIPT_NAME

RUN cd ./extensions && unzip extensions.zip && rm -rf extensions.zip && cd -

# Note: You can use any Debian/Ubuntu based image you want. 
FROM ghcr.io/lyscm/environments/kali/base

ARG TARGETPLATFORM
ARG OWNER="lyscm"
ARG REPOSITORY_NAME="ethical-hacking-kali"

LABEL org.opencontainers.image.source https://github.com/${OWNER}/${REPOSITORY_NAME}

# [Required] Setup settings and extensions
ARG VSCODE_SERVER_PATH=/root/.vscode-server
COPY --from=settings /lyscm/$TARGETPLATFORM/extensions/ ${VSCODE_SERVER_PATH}/extensions/
COPY --from=settings /lyscm/$TARGETPLATFORM/.vscode-configurations/ ${VSCODE_SERVER_PATH}/data/Machine/

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access 
# to the Docker socket. The script will also execute CMD as needed.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD git config --global user.email "no-reply@lyscm.github.com" \
    && git config --global user.name "lyscm" \
    && sleep "infinity"