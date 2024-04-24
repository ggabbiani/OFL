# README

This directory contains the Dockerfile for building an OpenSCAD test environment
for OFL under Ubuntu.

## Project setup and documentation generation

    $ cd <OFL root directory>
    $ podman run -v ./:/import:Z  -it --rm ofl:ubuntu

## Tests execution

    $ cd <OFL root directory>
    $ podman run -v ./:/import:Z  -it --rm ofl:ubuntu tests/runs
