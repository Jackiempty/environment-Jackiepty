# syntax=docker/dockerfile:1
FROM ubuntu:24.04 AS base

# update system
RUN apt-get update && apt-get upgrade -y

# install bash and python
RUN apt-get install -y bash && apt-get install -y python3 python3-pip

# set default shell as bash
CMD ["/bin/bash"]