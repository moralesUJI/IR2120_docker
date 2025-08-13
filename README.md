# Niryo docker
Docker file of the Niryo NED software 

## Prerequisites
- [Docker](https://docs.docker.com/engine/install/ubuntu/)
- [Rocker](https://github.com/osrf/rocker) _Please note that Rocker is a customized home-made script, and its compaticility with upcoming versions of docker and long-term support is not guaranted_.
- If you plan to allow docker acces nvidia card you need to install [_nvidia-container-toolkit_](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
- [XQuartz](https://www.xquartz.org) X Windows System. If you plan to run the images on a _MacOs_ system.

## Building images

Depending on wether you use nvidia driver or not you build a different image and use a differente compose file.

| | _DOCKERFILE_ | _IMAGE_NAME_ | _CONTAINER_NAME_ | _COMPOSE_FILE_ |
| --- | --- | --- | --- | --- | 
| No NVIDIA driver | `Dockerfile.compose` | `niryo` | `nyrio_comopose`|  `niryo.yaml` |
| NVIDIA driver | `Dockerfile.compose.nvidia` | `niryo.nvida` | `niryo.nvidia.compose` | `niryo-nvida.yaml` |
| Rocker | `Dockerfile.rocker` | `niryo.rocker` |

You must substitute in the commands of the following sections the options you prefer for the names in CAPS.

### Use with docker compose

#### Build the docker image
```
docker build -t IMAGE_NAME -f DOCKERFILE .
```

If not exists a folder named _niryo_ws_ should be created on the base users account. This folder will shared between the host and the container, and allows to store permanent data between docker sessions.

```
cd $HOME
mkdir-p  niryio_ws
```

To start the app:
```
docker compose -f compose/COMPOSE_FILE up
```

This starts a container with name _IMAGE_NAME_. 

After this open a new terminal and type. 
```
docker exec -it IMAGE_NAME /bin/bash
```



__Warning__: If X grahics cannot be used make sure to execute the following command on the terminal before launching: the _exec_ command

```
xhost +
``` 

It will launch  a bash shell inside the conteiner. From there you can launch all the Niryo applicattions. You can also launch as menay terminals as needed. 

To terminate, type **Ctrl-C** on the terminal where the compose was exectued. 

### Use with rocker
 Build the docker image
```
docker build -t niryo-rocker -f Dockerfile.rocker 
```
To start the app:
```
rocker --x11 --nvidia  --privileged --user niryo:latest
```
Description of the parameters: 
* **--x11**: Allows X11 connections. Obligatory
* **--nvidia**: Uses the nvidia drivers.
* **--privileged**: Allows to execute _NiryoStudio_
* **--user**: Creates a user and a home folder with the host username, and starts the docker container with that user

## Remove efficiently images and containers
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

