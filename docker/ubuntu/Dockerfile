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
ARG ODOX_VERSION=1.2.1
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
RUN wget https://github.com/ggabbiani/orthodocs/releases/download/v${ODOX_VERSION}/orthodocs_${ODOX_VERSION}_amd64.deb \
    && apt install -y ./orthodocs_${ODOX_VERSION}_amd64.deb
COPY pyreqs.txt .
RUN python3 -m venv .venv \
    && . .venv/bin/activate \
    && pip install --upgrade pip \
    && pip install -r pyreqs.txt
COPY make-import.sh /usr/local/sbin/
###############################################################################
# entrypoint
ENTRYPOINT [ "/usr/local/sbin/make-import.sh" ]
CMD [ "all" ]
