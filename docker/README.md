# Niryo docker
Docker file of the Niryo NED software 

## Prerequisites
- [Docker](https://docs.docker.com/engine/install/ubuntu/)
- [Rocker](https://github.com/osrf/rocker)  
- If you plan to allow docker acces nvidia card you need to install [_nvidia-container-toolkit_](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## Installation
0. Move to docker dir
1. Build the docker image

```
docker build -t niryo .
```

## Use
To start the app:
```
rocker --x11 --nvidia  --privileged --user niryo:latest
```
Description of the parameters: 
* **--x11**: Allows X11 connections. Obligatory
* **--nvidia**: Uses the nvidia drivers.
* **--privileged**: Allows to execute _NiryoStudio_
* **--user**: Creates a user and a home folder with the host username, and starts the docker container with that user
