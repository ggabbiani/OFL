#
# Dockerfile for testing project development and tests under Ubuntu distros.
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
FROM ubuntu:24.04
LABEL org.opencontainers.image.authors="Giampiero Gabbiani (giampiero@gabbiani.org)"
ARG ODOX_VERSION=1.2.2
ARG ODOX_RELEASE=0ubuntu19
ARG ODOX_PACKAGE=orthodocs_${ODOX_VERSION}-${ODOX_RELEASE}_amd64.deb
###############################################################################
# system pre requisites
RUN apt update \
    && apt upgrade -y \
    && apt install -y apt-utils \
        openscad \
        git \
        graphviz \
        imagemagick \
        make \
        python3-venv \
        wget \
        which \
        xvfb \
    && apt clean
# orthodocs must be downloaded
RUN wget https://github.com/ggabbiani/orthodocs/releases/download/v${ODOX_VERSION}/${ODOX_PACKAGE} \
    && apt install -y ./${ODOX_PACKAGE}
COPY pyreqs.txt .
RUN python3 -m venv .venv \
    && . .venv/bin/activate \
    && pip install --upgrade pip \
    && pip install -r pyreqs.txt
COPY make-import.sh /usr/local/sbin/
# this command is mandatory for the 'git checkout' from inside the container
RUN git config --global --add safe.directory /import
###############################################################################
# entrypoint
ENTRYPOINT [ "/usr/local/sbin/make-import.sh" ]
CMD [ "all" ]
