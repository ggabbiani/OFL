# OpenSCAD Foundation Library

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/ggabbiani/OFL/tests.yml?label=tests&style=square)

![Cover](pics/800x600/cover.png)

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

OFL comes with three major components:

* [foundation](lib/OFL/foundation/README.md) - the core part re-implementing some of the OpenSCAD native 2d/3d modules while adding new ones;
* [vitamins](lib/OFL/vitamins/README.md) - client vitamin modules leveraging the foundation.
* [artifacts](lib/OFL/artifacts/README.md) - printable artifacts built on top of [foundation components](foundation/README.md) and [vitamins parts](vitamins/README.md);

## Architecture

Every library component is accessed through a set of verb-based APIs (Common API Template), even third part libraries eventually used internally.

![OFL architecture](docs/architecture.png)
