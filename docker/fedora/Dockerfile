#
# Dockerfile for testing project development and tests under Fedora distros.
# NOTE: The built image runs in a uv managed python virtual environment
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
FROM fedora:43
LABEL org.opencontainers.image.authors="Giampiero Gabbiani (giampiero@gabbiani.org)"
ARG ODOX_VERSION=1.2.2
ARG ODOX_RELEASE=${ODOX_VERSION}-19.fc39
###############################################################################
# system pre requisites
RUN dnf install -y \
    git \
    graphviz \
    ImageMagick \
    make \
    openscad \
    wget \
    which \
    xorg-x11-server-Xvfb
# orthodocs must be downloaded
# https://github.com/ggabbiani/orthodocs/releases/download/v1.2.1/orthodocs-1.2.1-0.fc36.x86_64.rpm
RUN wget https://github.com/ggabbiani/orthodocs/releases/download/v${ODOX_VERSION}/orthodocs-${ODOX_RELEASE}.$(uname -m).rpm \
    && dnf install -y ./orthodocs-${ODOX_RELEASE}.$(uname -m).rpm

# Python virtual environment: interpreter and packages are managed by uv, so
# the Python version is pinned by the repo .python-version and doesn't depend
# on the distro one.
COPY --from=ghcr.io/astral-sh/uv:0.13.5 /uv /uvx /usr/local/bin/
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python \
    UV_PYTHON_PREFERENCE=only-managed \
    UV_NO_CACHE=1
WORKDIR /opt/uv
COPY .python-version requirements.txt ./
RUN uv venv /venv \
    && VIRTUAL_ENV=/venv uv pip install -r requirements.txt
WORKDIR /
COPY docker/fedora/make-import.sh /usr/local/sbin/
RUN chmod +x /usr/local/sbin/make-import.sh

# this command is mandatory for the 'git checkout' from inside the container
RUN git config --global --add safe.directory "$GITHUB_WORKSPACE"
###############################################################################
# entrypoint
ENTRYPOINT [ "/usr/local/sbin/make-import.sh" ]
CMD [ "all" ]
