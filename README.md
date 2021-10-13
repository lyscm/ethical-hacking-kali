# KALI ENVIRONMENT BUILDER - REPOSITORY <h1> 
 
[![build](https://img.shields.io/github/workflow/status/lyscm/ethical-hacking-kali/environment-kali%20-%20ci?logo=github)](https://github.com/lyscm/ethical-hacking-kali/blob/master/.github/workflows/build-action.yml)
[![repo size](https://img.shields.io/github/repo-size/lyscm/ethical-hacking-kali?logo=github)](https://github.com/lyscm/ethical-hacking-kali)
[![package](https://img.shields.io/static/v1?label=package&message=kali&color=yellowgreen&logo=github)](https://github.com/lyscm/ethical-hacking-kali/pkgs/container/ethical%2hacking%2kali)

## Initiate package(s): <h2> 

Set parameters:

***Bash:***
```bash
OWNER=lyscm
CONTAINER_NAME=kali
TAG=ghcr.io/lyscm/environments/kali
```

***Powershell:***
```powershell
$OWNER="lyscm"
$CONTAINER_NAME="kali"
$TAG="ghcr.io/lyscm/environments/kali"
```

Remove any existing container:

```bash
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
docker pull $TAG
```

Run container:

***Bash:***
```bash
docker run \
    -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    --net=host \
    $TAG
```

***Powershell:***
```powershell
docker run `
    -d `
    --name $CONTAINER_NAME `
    --restart unless-stopped `
    --net=host `
    $TAG
```