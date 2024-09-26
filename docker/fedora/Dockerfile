#
# Dockerfile for testing project development and tests under Fedora distros.
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
FROM fedora:39
LABEL org.opencontainers.image.authors="Giampiero Gabbiani (giampiero@gabbiani.org)"
ARG ODOX_VERSION=1.2.2
ARG ODOX_RELEASE=${ODOX_VERSION}-19.fc36
###############################################################################
# system pre requisites
RUN dnf install -y \
    openscad \
    git \
    which \
    make \
    python3 \
    xorg-x11-server-Xvfb \
    wget \
    ImageMagick
# orthodocs must be downloaded
# https://github.com/ggabbiani/orthodocs/releases/download/v1.2.1/orthodocs-1.2.1-0.fc36.x86_64.rpm
RUN wget https://github.com/ggabbiani/orthodocs/releases/download/v${ODOX_VERSION}/orthodocs-${ODOX_RELEASE}.$(uname -m).rpm \
    && dnf install -y ./orthodocs-${ODOX_RELEASE}.$(uname -m).rpm
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
