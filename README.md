# OpenSCAD Foundation Library

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/ggabbiani/OFL/CI?label=tests&style=square)

![Cover](docs/cover.png)

**O**penSCAD **F**oundation **L**ibrary (OFL) is a foundation library for OpenSCAD integrating concepts not included natively in the OpenSCAD language and providing an extendible standardized API base.

## Pre-reqs

The following libraries are used and must be installed for using all the OFL features:

* [NopSCADlib](https://github.com/nophead/NopSCADlib)
* [scad-utils](https://github.com/openscad/scad-utils)
* [TOUL: The OpenScad Useful Library](https://www.thingiverse.com/thing:1237203)

## Usage

1. download and expand the library in the [OpenSCAD Library Folder](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries#Library_Locations)
2. include the needed library file(s) in your OpenSCAD code like in the following example:

    include \<OFL/foundation/2d.scad\>

## Library documentation

OFL comes with two major components:

* [foundation](foundation/README.md) - the core part re-implementing some of the OpenSCAD native 2d/3d modules while adding many new ones;
* [vitamins](vitamins/README.md) - a number of client vitamin modules leveraging the foundation.
