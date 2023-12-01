# README

This directory contains the Dockerfile for building an OpenSCAD test environment
for OFL.

## Build

    $ cd <this directory>
    $ podman build -t ofl:latest .

## Execution

    $ cd <OFL root directory>
    $ podman run -v ./:/import:Z  -it ofl:latest
