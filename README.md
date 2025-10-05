# Niryo docker
Dockerfiles and images that include all required Niryo NED software for the course "IR2120 - Manipulació robótica" at [**Universtat Jaume I**](https://www.uji.es)

- [Niryo docker](#niryo-docker)
  - [Prerequisites](#prerequisites)
  - [Donwloading prebuild images](#donwloading-prebuild-images)
  - [Building images](#building-images)
  - [Executing images with _docker compose_](#executing-images-with-docker-compose)
  - [Executing images with _docker run_](#executing-images-with-docker-run)
  - [Use with rocker](#use-with-rocker)
  - [Removing efficiently images and containers](#removing-efficiently-images-and-containers)

There are several ways to use the contents on this repository:

1. Downloading the prebuilt images.
2. Cloning the repository and building the images locally. 
## Prerequisites
- [Docker](https://docs.docker.com/engine/install/ubuntu/)
- [_nvidia-container-toolkit_](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) if you plan to allow docker access nvidia-compatible graphics card
- [Rocker](https://github.com/osrf/rocker) if you prefer it instead of standard **docker** commands. _Please note that Rocker is a customized home-made script, and its compatibility with upcoming versions of docker and long-term support is not guaranteed_.

## Donwloading prebuild images
This is the easiest way to get the necessary images. The packages section on github repo contains up-to-date fully functional images. There are two available images:

- [ghcr.io/moralesuji/ir2120_docker/niryo:nvidia](https://github.com/moralesUJI/IR2120_docker/pkgs/container/ir2120_docker%2Fniryo) that includes the necessary libraries to use host computer woth compatible nvidia graphics card. 
- [ghcr.io/moralesuji/ir2120_docker/niryo:base](https://github.com/moralesUJI/IR2120_docker/pkgs/container/ir2120_docker%2Fniryo/488081437?tag=base), in case the host computer does not have an nvidia compatible graphics card.

Both of them can be downloaded respectively using the commands
```
  docker pull ghcr.io/moralesuji/ir2120_docker/niryo:nvidia
```
or 
```
  docker pull ghcr.io/moralesuji/ir2120_docker/niryo:base
```


## Building images

In case you want to build the images locally you must first clone this repository and then follow the instructions on this section. 

Depending on the intended use of the nvidia drivers/rocker script different images and configuration files are available.

| | _DOCKERFILE_ | _TAG_ | _IMAGE_NAME_ | _COMPOSE_FILE_ |
| --- | --- | --- | --- | --- | 
| No NVIDIA driver | `Dockerfile` | `base` | `ghcr.io/moralesuji/ir2120_docker/niryo:base`|  `niryo_base.yaml` |
| NVIDIA driver | `Dockerfile` | `nvidia` | `ghcr.io/moralesuji/ir2102_docker/niryo:nvidia` | `niryo_nvidia.yaml` |
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

## Executing images with _docker compose_
Once the images has been built they can be launched with de _compose_ command.

Before, if not exists, a folder named _niryo_ws_ should be created on the user home. This folder will be shared between the host and the container, and allows to store permanent data between docker sessions.

```
cd $HOME
mkdir -p  niryo_ws
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

__Warning__: If X graphics cannot be used make sure to execute the following command on the terminal before launching: the _exec_ command

```
xhost +
``` 

It will launch  a bash shell inside the container. From there you can launch all the Niryo applications. You can also launch as many terminals as needed. 

To terminate, type **Ctrl-C** on the terminal where the compose was executed. 

## Executing images with _docker run_
Images can also be executed with a single _docker run_ command. The difference with the _compose_ approach described above is that only a single command or terminal can be executed. This can be useful to connect to a real robot trough a ip connection, but not so useful to work with simulation.

As in the section above a shared folder might be necessary, though the name and locations can change. Also, the _xhost_ command might also be necessary. 

In the case of nvidia image the command would be: 

```
docker run -it --rm   --env DISPLAY=$DISPLAY   --env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR   --env QT_X11_NO_MITSHM=1   --network host   --privileged   --security-opt seccomp=unconfined   --security-opt apparmor=unconfined   --gpus all   -v /dev:/dev   -v /tmp/.X11-unix:/tmp/.X11-unix   -v ~/niryo_ws:/home/niryo/niryo_ws   --device /dev/dri:/dev/dri   ghcr.io/moralesuji/ir2120_docker/niryo:nvidia
```
The _-v_ parameter can be used to specify a different shared folder. 

This command will launch a _bash shell_ from where launch other commands. If a specific command wants to be executed on the container just simply append the command at the end of the whole string above.

Finally, in case that the non-nvidia image:
```
docker run -it --rm   --name niryo-base-compose   --env DISPLAY=$DISPLAY   --env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR   --env QT_X11_NO_MITSHM=1   --network host   --privileged   --security-opt seccomp=unconfined   --security-opt apparmor=unconfined   -v /dev:/dev   -v /tmp/.X11-unix:/tmp/.X11-unix   -v ~/niryo_ws:/home/niryo/niryo_ws   --device /dev/dri:/dev/dri   ghcr.io/moralesuji/ir2120_docker/niryo:base 
```

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
During the development process is common to create images and containers that remain _defunct_ or _hidden_. 

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

