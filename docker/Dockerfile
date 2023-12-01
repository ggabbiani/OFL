FROM fedora:39
LABEL org.opencontainers.image.authors="Giampiero Gabbiani (giampiero@gabbiani.org)"

ARG libs=/root/.local/share/OpenSCAD/libraries
ARG nop_ver=v21.8.0
###############################################################################
# system pre requisites
RUN dnf install -y openscad git which make python3-dotenv python3-termcolor
###############################################################################
# directory structure setup
RUN mkdir -p ${libs}
###############################################################################
# libraries pre requisites
WORKDIR ${libs}
RUN git clone https://github.com/nophead/NopSCADlib.git && cd NopSCADlib && git checkout tags/${nop_ver}
RUN git clone https://github.com/openscad/scad-utils.git
COPY TOUL.scad .
###############################################################################
# entrypoint
ENTRYPOINT [ "/usr/bin/make", "-s", "-C", "/import", "tests/runs" ]
