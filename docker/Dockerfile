FROM fedora:39
LABEL org.opencontainers.image.authors="Giampiero Gabbiani (giampiero@gabbiani.org)"

ARG libs=/root/.local/share/OpenSCAD/libraries
ARG nop_ver=v21.10.1
###############################################################################
# system pre requisites
RUN dnf install -y openscad git which make python3-dotenv python3-termcolor gettext-envsubst
###############################################################################
# directory structure setup
RUN mkdir -p ${libs}
###############################################################################
# libraries pre requisites
WORKDIR ${libs}
RUN git clone https://github.com/nophead/NopSCADlib.git && cd NopSCADlib && git checkout tags/${nop_ver}
RUN git clone https://github.com/openscad/scad-utils.git
###############################################################################
# entrypoint
ENTRYPOINT [ "/usr/bin/make", "-s", "-C", "/import", "tests/runs" ]
