# README

This directory contains the Dockerfile for building an image usable to test the OFL
development environment under **Fedora**. In particular with this image is possible to check:

- project setup;
- documentation generation;
- functional tests execution.

The image is also maintained and publicly available on DockerHub as
**ggabbiani/ofl:fedora**, so it is  always possible to check the same things
without the need of a local build.

## Local image

### Local image build

    $ cd <this directory>
    $
    $ docker build -t ofl:fedora .

### Project setup and documentation generation (with local image)

    $ cd <OFL root directory>
    $
    $ make -s clean
    $
    $ docker run -v ./:/import:Z  -it --rm ofl:fedora

### Functional tests execution (with local image)

    $ cd <OFL root directory>
    $
    $ docker run -v ./:/import:Z  -it --rm ofl:fedora tests/runs
    $ docker run -v ./:/import:Z  -it --rm ofl:fedora examples/runs

## Public image

### Project setup and documentation generation (with public image)

    $ cd <OFL root directory>
    $
    $ make -s clean
    $
    $ docker run -v ./:/import:Z  -it --rm ggabbiani/ofl:fedora

### Functional tests execution (with public image)

    $ cd <OFL root directory>
    $
    $ docker run -v ./:/import:Z  -it --rm ggabbiani/ofl:fedora tests/runs
    $ docker run -v ./:/import:Z  -it --rm ggabbiani/ofl:fedora examples/runs
