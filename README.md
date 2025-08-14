# Niryo docker
Docker file of the Niryo NED software
docker
- [Niryo docker](#niryo-docker)
  - [Prerequisites](#prerequisites)
  - [Building images](#building-images)
  - [Executing images with compose](#executing-images-with-compose)
  - [Use with rocker](#use-with-rocker)
  - [Removing efficiently images and containers](#removing-efficiently-images-and-containers)


## Prerequisites
- [Docker](https://docs.docker.com/engine/install/ubuntu/)
- If you plan to allow docker access nvidia card you need to install [_nvidia-container-toolkit_](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
- [Rocker](https://github.com/osrf/rocker) _Please note that Rocker is a customized home-made script, and its compatibility with upcoming versions of docker and long-term support is not guaranteed_.

## Building images

Depending on the intended use of the nvidia drivers/rocker script different images and configuration files are available.

| | _DOCKERFILE_ | _TAG_ | _IMAGE_NAME_ | _COMPOSE_FILE_ |
| --- | --- | --- | --- | --- | 
| No NVIDIA driver | `Dockerfile` | `base` | `niryo:base`|  `niryo_base.yaml` |
| NVIDIA driver | `Dockerfile` | `nvidia` | `niryo:nvidia` | `niryo_nvidia.yaml` |
| Rocker Script | `Dockerfile.rocker`| `rocker` | `niryo:rocker`

Substitute in the commands of the following sections the options you prefer for the names in CAPS.

Images can be build simultaneously or separately. To build them both at the same time 
```
docker compose -f compose/niryo_build.yaml build
```
To build the images separately 

```
docker build --target _TAG_ -t IMAGE_NAME .
```

## Executing images with compose
Once the images has been built they can be launched with de _compose_ command.

Before, if not exists a folder named _niryo_ws_ should be created on the base users account. This folder will shared between the host and the container, and allows to store permanent data between docker sessions.

```
cd $HOME
mkdir-p  niryo_ws
```

To start the app:
```
docker compose -f compose/COMPOSE_FILE up
```
This starts a container with name _IMAGE_NAME_. 

After this open a new terminal and type: 
```
docker exec -it IMAGE_NAME /bin/bash
```

__Warning__: If X grahics cannot be used make sure to execute the following command on the terminal before launching: the _exec_ command

```
xhost +
``` 

It will launch  a bash shell inside the container. From there you can launch all the Niryo applications. You can also launch as many terminals as needed. 

To terminate, type **Ctrl-C** on the terminal where the compose was executed. 

## Use with rocker
 Build the docker image
```
docker build -t niryo:rocker -f Dockerfile.rocker .
```
To start the app:
```
rocker --x11 --nvidia  --privileged --user niryo:rocker
```
Description of the parameters: 
* **--x11**: Allows X11 connections. Obligatory
* **--nvidia**: Uses the nvidia drivers.
* **--privileged**: Allows to execute _NiryoStudio_
* **--user**: Creates a user and a home folder with the host username, and starts the docker container with that user

## Removing efficiently images and containers
During the dvelopment process is common to create images and containers that remain _defunct_ or _hidden_. 

To remove al dead or hidden containers only, execute:

```
docker rm $(docker ps -aq)
```

To remove dead images: 
```
docker image prune -a
``` 


Finally , in order to remove all of them deade or alive efficiently use the following command.

```
docker system prune -a
```

After this images should be rebuilt or prune. 

