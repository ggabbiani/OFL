# README

This directory contains the Dockerfile for locally building and run an OFL test
environment for Fedora and Ubuntu.

The local build is not mandatory and it is possible to use the public Docker
images available ones on DockerHub.

The following examples leverage the Fedora test environment, for Ubuntu test
environment just change the image tag from **fedora** to **ubuntu**.

## Locally built image test

### Build

    $ cd <this directory>
    <this directory> $
    <this directory> $ docker build -t ofl:fedora .

### Project setup and documentation generation

    $ cd <OFL root directory>
    <OFL root directory> $
    <OFL root directory> $ docker run -v ./:/import:Z  -it --rm ofl:fedora

### Tests execution

    $ cd <OFL root directory>
    <OFL root directory> $
    <OFL root directory> $ docker run -v ./:/import:Z  -it --rm ofl:fedora tests/runs

## Public available image test

    $ cd <OFL root directory>
    <OFL root directory> $
    <OFL root directory> $ docker run -v ./:/import:Z  -it --rm ggabbiani/ofl:fedora tests/runs
