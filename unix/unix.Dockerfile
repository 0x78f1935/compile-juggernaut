FROM python:3.9.9-slim-buster as base

ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt upgrade -y

FROM base as base_requirements
RUN apt install -y binutils

FROM base_requirements as requirements
RUN pip install --upgrade pip
# Requirements
ARG PYINSTALLER_VERSION=5.3
RUN pip install pyinstaller==$PYINSTALLER_VERSION

FROM requirements as entrypoint
COPY ./unix/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
