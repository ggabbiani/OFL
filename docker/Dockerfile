FROM fedora:34
LABEL org.opencontainers.image.authors="Giampiero Gabbiani (giampiero@gabbiani.org)"

ARG libs=$HOME/.local/share/OpenSCAD/libraries
###############################################################################
# system pre requisites
RUN dnf install -y openscad git
###############################################################################
# directory structure setup
RUN mkdir -p $libs
###############################################################################
# libraries pre requisites
WORKDIR $libs
RUN git clone https://github.com/nophead/NopSCADlib.git
RUN git clone https://github.com/openscad/scad-utils.git
###############################################################################
# entrypoint
COPY entry-point.sh /usr/bin/entry-point
RUN chmod +x /usr/bin/entry-point
ENTRYPOINT [ "/usr/bin/entry-point" ]
