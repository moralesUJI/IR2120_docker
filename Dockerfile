FROM osrf/ros:melodic-desktop-full AS base

LABEL name="Niryo Docker for IR2120"

# Create a new user and add to sudoers
RUN useradd -ms /bin/sh niryo && \
    echo "niryo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/niryo

RUN apt-get update \
    && apt-get install -y \
    wget \ 
    unzip \ 
    libxtst6 \
    ffmpeg \
    mesa-utils \
    libcanberra-gtk-module libcanberra-gtk3-module \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Root user installation 
WORKDIR /opt/niryo
RUN wget -U firefox https://s3-niryo-public.s3.eu-west-3.amazonaws.com/niryo_studio/v4.1.2/NiryoStudio-linux-x64_v4.1.2.zip
RUN unzip NiryoStudio-linux-x64_v4.1.2.zip
RUN mv dist-app/NiryoStudio-linux-x64 /opt/niryo/NiryoStudio
RUN sudo chmod 4755 NiryoStudio/chrome-sandbox
RUN sudo ln -s /opt/niryo/NiryoStudio/NiryoStudio /usr/bin/NiryoStudio
RUN rmdir dist-app

# Install graphics software
RUN sudo apt-get update \
    && sudo apt-get -q -y upgrade \
    && sudo apt-get install -y -qq --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

# Installing required ros Niryo NED packages
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' 
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - \
    && apt update -y

RUN apt install -y \
    sqlite3 \
    ffmpeg \ 
    build-essential \
    ros-melodic-moveit \
    ros-melodic-control-* \
    ros-melodic-controller-* \
    ros-melodic-tf2-web-republisher \
    ros-melodic-rosbridge-server \
    ros-melodic-joint-state-publisher 

RUN apt install python-catkin-pkg -y \ 
    python-pymodbus \
    python-rosdistro \
    python-rospkg \
    python-rosdep \
    python-rosinstall \ 
    python-rosinstall-generator \ 
    python-wstool \
    python-pip
    
# Set the working directory to the user's home
USER niryo
WORKDIR /home/niryo
RUN /usr/bin/gazebo -v; sed -i 's/ignitionfuel/ignitionrobotics/g' ~/.ignition/fuel/config.yaml 


RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc 
RUN rosdep update --rosdistro melodic

# Installing NED ROS Stack
WORKDIR catkin_ws_niryo_ned
RUN git clone https://github.com/NiryoRobotics/ned_ros src
RUN cd src && git checkout tags/v4.0.1
RUN pip2 install -r src/requirements_ned2.txt
RUN rosdep update --rosdistro melodic && rosdep install --from-paths src --ignore-src --default-yes --rosdistro melodic --skip-keys "python-rpi.gpio"

RUN /bin/bash -c "source /opt/ros/melodic/setup.bash && catkin_make"
RUN echo "source $(pwd)/devel/setup.bash" >> ~/.bashrc
WORKDIR /home/niryo

# Installing pyniryo for python3
RUN sudo apt install -y python3-pip
RUN pip3 install --upgrade pip
RUN pip3 install -v numpy
RUN pip3 install -v opencv-python
RUN pip3 install pyniryo==1.1.1
RUN pip3 install pyniryo2
RUN sudo apt-get install nano

FROM base AS nvidia

USER root

# Env vars for the nvidia-container-runtime.
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute
ENV QT_X11_NO_MITSHM=1

USER niryo
WORKDIR /home/niryo
