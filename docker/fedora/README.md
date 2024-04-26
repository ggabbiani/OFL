# README

This directory contains the Dockerfile for building an OFL test environment on
Fedora.

## Build

    $ cd <this directory>
    $ docker build -t ofl:fedora .

## Project setup and documentation generation

    $ cd <OFL root directory>
    $ docker run -v ./:/import:Z  -it --rm ofl:fedora

## Tests execution

    $ cd <OFL root directory>
    $ docker run -v ./:/import:Z  -it --rm ofl:fedora tests/runs
