# based on OSRF ROS 2 images
FROM osrf/ros:humble-desktop-full-jammy

# no prompts from apt-get
ARG DEBIAN_FRONTEND=noninteractive

# use bash as primary shell for RUN commands
SHELL [ "/bin/bash", "-c" ]

# switch to a Dallas mirror if download speed is low
# RUN cp /etc/apt/sources.list /etc/apt/sources.list.original && \
#     sed -i -r 's,http://(.*).ubuntu.com,http://mirror.us-tx.kamatera.com,' /etc/apt/sources.list

# installing initial setup packages
RUN apt-get update && apt-get -y --no-install-recommends install \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    lsb-release \
    gnupg \
    gnupg2 \
    locales \
    software-properties-common \
    && apt-get -y autoremove \
    && apt-get clean

# install network diagnostic tools
RUN apt-get update && apt-get -y --no-install-recommends install \
    net-tools \
    iputils-ping \
    netcat \
    && apt-get -y autoremove \
    && apt-get clean

# make sure we always use Python 3
RUN apt-get update && apt-get -y --no-install-recommends install \
    python3-dev \
    python3-pip \
    python-is-python3 \
    && apt-get -y autoremove \
    && apt-get clean

# install Gazebo Fortress for simulation
RUN wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    apt-get update && \
    apt-get -y install \
    ignition-fortress \
    ros-humble-turtlebot4-simulator \
    ros-humble-gazebo-* \
    ros-humble-cartographer \
    ros-humble-cartographer-ros \
    ros-humble-navigation2 \
    ros-humble-nav2-bringup \
    ros-humble-dynamixel-sdk \
    ros-humble-turtlebot3-msgs \
    ros-humble-turtlebot3 \
    ros-humble-velodyne \
    ros-humble-velodyne-simulator

# ---------------------------------------------------------------------------- #
#                           GPU SPECIFIC INSTRUCTIONS                          #
# ---------------------------------------------------------------------------- #

RUN apt update && apt install -y \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    mesa-utils \
    mesa-utils-extra

ENV MESA_D3D12_DEFAULT_ADAPTER_NAME=Intel

# ---------------------------------------------------------------------------- #
#                      WORKSPACE AND ENVIRONMENT CREATION                      #
# ---------------------------------------------------------------------------- #

ENV ROS_DISTRO humble
ENV QT_X11_NO_MITSHM 1
ENV TERM xterm-256color
ENV HOME /root
ENV BOAT_WS /root/roboboat_ws
ENV BOAT_SRC /root/roboboat_ws/src

RUN mkdir -p ${BOAT_SRC} && \
    cd ${BOAT_WS} && \
    git clone --progress -b humble-devel https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git

RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    cd ${BOAT_WS} && \
    rosdep update --include-eol-distros && \
    rosdep install --from-paths src -y --ignore-src && \
    colcon build --symlink-install

# always source the default ROS setup.bash
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ${HOME}/.bashrc && \
    echo "source ${BOAT_WS}/install/setup.bash" >> ${HOME}/.bashrc && \
    echo "cd ${BOAT_WS}" >> ${HOME}/.bashrc
