# aligned with github runner version at 23/4/2024
FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="Giampiero Gabbiani (giampiero@gabbiani.org)"
ARG ODOX_VERSION=1.2.1
ARG DRAWIO_VERSION=24.2.5
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
        xvfb \
    && apt clean
# orthodocs must be downloaded
RUN wget https://github.com/ggabbiani/orthodocs/releases/download/v${ODOX_VERSION}/orthodocs_${ODOX_VERSION}_amd64.deb \
    && apt install -y ./orthodocs_${ODOX_VERSION}_amd64.deb
# draw.io must be downloaded
RUN wget https://github.com/jgraph/drawio-desktop/releases/download/v${DRAWIO_VERSION}/drawio-amd64-${DRAWIO_VERSION}.deb \
    && apt install -y ./drawio-amd64-${DRAWIO_VERSION}.deb
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
