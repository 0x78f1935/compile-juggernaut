FROM ubuntu:22.04 as base

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y
RUN apt install software-properties-common apt-transport-https wget -y

FROM base as architecture_support
RUN dpkg --add-architecture i386

FROM architecture_support as wine_gpg_key
RUN wget -O- https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor | tee /usr/share/keyrings/winehq.gpg
RUN echo deb [signed-by=/usr/share/keyrings/winehq.gpg] http://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main | tee /etc/apt/sources.list.d/winehq.list
RUN apt update

# Fetch wine version: [wine-stable, winehq-staging, winehq-devel]
#   # winehq-staging: this is the most recent testing wine version.
#   # wine-stable: this is the current stable wine version (probably the one you should install)
#   # winehq-devel: this package is used to provide development headers, mostly used by third party software compilation.
ARG WINE_VERSION=wine-stable

FROM wine_gpg_key as wine
RUN apt install $WINE_VERSION --install-recommends -y

FROM wine as winetricks
RUN wget -nv https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN chmod +x winetricks
RUN mv winetricks /usr/local/bin

FROM winetricks as pre_winetricks
# RUN winetricks win10
RUN apt-get clean
# wine settings
ENV WINEARCH win64
ENV WINEDEBUG fixme-all
ENV WINEPREFIX /wine

# Latest version from https://www.python.org/ftp/python/
ARG PYTHON_VERSION=3.9.9
ENV PYTHON_VERSION 3.9.9

FROM pre_winetricks as python
RUN for msifile in `echo core dev doc exe launcher lib path pip tcltk test tools ucrt`; do \
    echo $msifile; \
    wget -nv "https://www.python.org/ftp/python/${PYTHON_VERSION}/amd64/${msifile}.msi"; \
    /usr/bin/wine msiexec /i "${msifile}.msi" /qb TARGETDIR=C:/Python; \
    rm ${msifile}.msi; \
done

FROM python as pip
RUN wine cmd 'C:\Python\python.exe' > /usr/bin/python
RUN wine cmd 'C:\Python\Scripts\easy_install.exe' > /usr/bin/easy_install
RUN wine cmd 'C:\Python\Scripts\pip.exe' > /usr/bin/pip
RUN wine cmd 'C:\Python\Scripts\pyinstaller.exe' > /usr/bin/pyinstaller
RUN wine cmd 'C:\Python\Scripts\pyupdater.exe' > /usr/bin/pyupdater
RUN echo 'assoc .py=PythonScript' | wine cmd
RUN echo 'ftype PythonScript=c:\Python\python.exe "%1" %*' | wine cmd
RUN while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done
RUN chmod +x /usr/bin/python /usr/bin/easy_install /usr/bin/pip /usr/bin/pyinstaller /usr/bin/pyupdater
RUN (pip install -U pip --upgrade pip || true)
RUN rm -rf /tmp/.wine-*

FROM pip as build_requirements
# PYPI repository location
ENV PYPI_URL=https://pypi.python.org/
# PYPI index location
ENV PYPI_INDEX_URL=https://pypi.python.org/simple
# Requirements
ARG PYINSTALLER_VERSION=5.3
RUN wine cmd /c pip install pyinstaller==$PYINSTALLER_VERSION

FROM build_requirements as source_mount
# Put flask-install in the src folder inside wine
RUN mkdir /src/ && ln -s /src /wine/drive_c/src

FROM source_mount as entrypoint
COPY ./windows/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
