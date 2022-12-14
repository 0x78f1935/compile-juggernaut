# Compile Juggernaut ~ For Python
Aims to compile python applications cross platform, requires docker and docker-compose to be installed. [Get Docker](https://docs.docker.com/get-docker/) on their official website.

Inspired by [cdrx/pyinstaller-windows](https://hub.docker.com/r/cdrx/pyinstaller-windows)

Compiles `Python 3.9.9` for **Unix** and **Windows** with `PyInstaller`

## Quickstart

In your project which you would like to compile, create a `docker-compose.yml` file. 

An example could be something like:
```yml
version: "3.9"
services:

  windows:
    image: annihilator708/compile-juggernaut-windows:latest
    volumes:
      - ".:/src/"
    environment:
      - SPEC_FILENAME=main.spec

  unix:
    image: annihilator708/compile-juggernaut-unix:latest
    volumes:
      - ".:/src/"
    environment:
      - SPEC_FILENAME=main.spec
```
**Note:** *It's very important to volume mount your project into the* ***`/src/`*** *folder*

**SPEC_FILENAME:** *Can be generated with `pyi-makespec` and has different output depending on your project, for more info see the docs for [pyi-makespec](https://pyinstaller.org/en/stable/man/pyi-makespec.html)*

**Tip:** *When generating your spec file, add the option `--add-data /src/*;./*`* to add your source code.

With the `docker-compose.yml` file, use `docker-compose up --build` to start building!

## Output

Two folders are generated when compiling.
- `build` -> Contains files needed when compiling
- `dist` -> Contains the final product

## Project Requirements

The project which is volume mounted can contain two `requirements.txt` files.
- `requirements.txt` -> Contains *[pip freeze](https://pip.pypa.io/en/stable/cli/pip_freeze/https://pip.pypa.io/en/stable/cli/pip_freeze/)* requirements of your application
- `build_requirements.txt` -> Contains pip libraries which are required to compile the application

## Sources
- github -> [source code](https://github.com/0x78f1935/compile-juggernaut)
- dockerhub -> [compile-juggernaut-unix](https://hub.docker.com/repository/docker/annihilator708/compile-juggernaut-unix)
- dockerhub -> [compile-juggernaut-windows](https://hub.docker.com/repository/docker/annihilator708/compile-juggernaut-windows)