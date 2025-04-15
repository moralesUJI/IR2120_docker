FROM osrf/ros:melodic-desktop-full

LABEL name="Niryo Docker for IR2120"

# Create a new user and add to sudoers
RUN useradd -ms /bin/sh niryo && \
    echo "niryo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/niryo

RUN apt-get update \
    && apt-get install -y wget unzip libxtst6 ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory to the user's home
WORKDIR /opt/niryo
RUN wget -U firefox  https://archive-docs.niryo.com/download/NiryoStudio/v4.1.2/Linux/NiryoStudio-linux-x64_v4.1.2.zip
RUN unzip NiryoStudio-linux-x64_v4.1.2.zip
RUN mv dist-app/NiryoStudio-linux-x64 /opt/niryo/NiryoStudio
RUN sudo chmod 4755 NiryoStudio/chrome-sandbox
RUN sudo ln -s /opt/niryo/NiryoStudio/NiryoStudio /usr/bin/NiryoStudio
RUN rmdir dist-app

USER niryo
WORKDIR /home/niryo
COPY --chown=niryo post_install.sh post_install.sh
RUN chmod +x post_install.sh
RUN ./post_install.sh
RUN rm ./post_install.sh

WORKDIR /home/niryo

