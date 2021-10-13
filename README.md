# RUST ENVIRONMENT BUILDER - REPOSITORY <h1> 
 
[![build](https://img.shields.io/github/workflow/status/lyscm/environments-rust/environment-rust%20-%20ci?logo=github)](https://github.com/lyscm/environments-rust/blob/master/.github/workflows/build-action.yml)
[![repo size](https://img.shields.io/github/repo-size/lyscm/environments-rust?logo=github)](https://github.com/lyscm/environments-rust)
[![package](https://img.shields.io/static/v1?label=package&message=rust&color=yellowgreen&logo=github)](https://github.com/lyscm/environments-rust/pkgs/container/environments%2Frust)

## Initiate package(s): <h2> 

Set parameters:

***Bash:***
```bash
OWNER=lyscm
CONTAINER_NAME=rust
TAG=ghcr.io/lyscm/environments/rust
```

***Powershell:***
```powershell
$OWNER="lyscm"
$CONTAINER_NAME="rust"
$TAG="ghcr.io/lyscm/environments/rust"
```

Remove any existing container:

```bash
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
docker pull $TAG
```

Run container:

```bash
docker run \
    -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker-host.sock \
    --net=host \
    --cap-add=SYS_PTRACE \
    --security-opt seccomp:unconfined \
    --privileged \
    $TAG
```