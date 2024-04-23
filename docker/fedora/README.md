# README

This directory contains the Dockerfile for building an OpenSCAD test environment
for OFL under Fedora.

## Build

    $ cd <this directory>
    $ podman build -t ofl:fedora .

## Execution

    $ cd <OFL root directory>
    $ podman run -v ./:/import:Z  -it ofl:fedora
