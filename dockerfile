# syntax=docker/dockerfile:1
FROM ubuntu:24.04 AS base

# set as non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# set time zone env var
ENV TZ=Asia/Taipei

# update system
RUN apt-get update && apt-get upgrade -y

# install bash and python
RUN apt-get install -y bash && apt-get install -y python3 python3-pip

# set default shell as bash
CMD ["/bin/bash"]

# create UID/GID for non-root user
ARG USERNAME=myuser
ARG UID=1001
ARG GID=1001

RUN groupadd --gid $GID $USERNAME && \
    useradd --uid $UID --gid $GID --create-home --shell /bin/bash $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# switch to non-root user
USER $USERNAME

# set default working directory
WORKDIR /home/$USERNAME
