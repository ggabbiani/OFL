#
# Dockerfile for testing project development and tests under Ubuntu distros.
#
# NOTE: The entry-point will activate a python3 virtual environment suitable
# for running the tests
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
# Defaulting the github workspace for manual container runs. I expect this
# value to be overridden when triggered through github actions
ENV GITHUB_WORKSPACE="/import"
###############################################################################
# system pre requisites
RUN apt update \
    && apt upgrade -y \
    && apt install -y apt-utils \
        git \
        graphviz \
        imagemagick \
        make \
        openscad \
        python3-venv \
        wget \
        which \
        xvfb \
    && apt clean
# orthodocs must be downloaded
RUN wget https://github.com/ggabbiani/orthodocs/releases/download/v${ODOX_VERSION}/${ODOX_PACKAGE} \
    && apt install -y ./${ODOX_PACKAGE}

COPY pyreqs.txt .
RUN python3 -m venv /venv \
    && /venv/bin/pip install --upgrade pip \
    && /venv/bin/pip install -r pyreqs.txt
COPY make-import.sh /usr/local/sbin/
RUN chmod +x /usr/local/sbin/make-import.sh

# this command is mandatory for the 'git checkout' from inside the container
RUN git config --global --add safe.directory "$GITHUB_WORKSPACE"
###############################################################################
# entrypoint
ENTRYPOINT [ "/usr/local/sbin/make-import.sh" ]
CMD [ "all" ]
