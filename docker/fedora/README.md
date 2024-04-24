# README

This directory contains the Dockerfile for building an OpenSCAD test environment
for OFL under Fedora.

## Build

    $ cd <this directory>
    $ podman build -t ofl:fedora .

## Project setup and documentation generation

    $ cd <OFL root directory>
    $ podman run -v ./:/import:Z  -it --rm ofl:fedora

## Tests execution

    $ cd <OFL root directory>
    $ podman run -v ./:/import:Z  -it --rm ofl:fedora tests/runs
