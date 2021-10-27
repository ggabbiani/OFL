# OpenSCAD Foundation Library

OFL stands for **O**penSCAD **F**oundation **L**ibrary. In brief it is an attempt to write a foundation library for OpenSCAD, introducing some concepts not included in the OpenSCAD language.

Every library item has been prefixed in the following way:

* **FL_** for constants
* **fl_** for APIs

This was done for minimizing the risk of overlapping with any other API or global constant coming from other eventually used libraries.

## Pre-reqs

The following libraries are used and must be installed for using all the OFL features:

* [dotSCAD](https://justinsdk.github.io/dotSCAD/)
* [NopSCADlib](https://github.com/nophead/NopSCADlib)
* [scad-utils](https://github.com/openscad/scad-utils)
* [TOUL: The OpenScad Useful Library](https://www.thingiverse.com/thing:1237203)

## Usage

1. download and expand the library in the [OpenSCAD Library Folder](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries#Library_Locations)
2. include the following statement in your OpenSCAD code:

    include <OFL/foundation/incs.scad>

## Library documentation

See [foundation/README.md](foundation/README.md) for further documentation.