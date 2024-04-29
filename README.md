# OpenSCAD Foundation Library

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/ggabbiani/OFL/tests.yml?label=tests&style=square)

![Cover](docs/800x600/cover.png)

**O**penSCAD **F**oundation **L**ibrary (OFL) is a foundation library for OpenSCAD integrating concepts not included natively in the OpenSCAD language and providing an extendible standardized API base.

## Pre-reqs

The following libraries are used and distributed internally with OFL:

* [NopSCADlib Release v21.10.0](https://github.com/nophead/NopSCADlib/releases/tag/v21.10.0)
* [Round-Anything v1.0.4](https://github.com/Irev-Dev/Round-Anything/releases/tag/1.0.4)
* [scad-utils](https://github.com/openscad/scad-utils)

Each of them can be found in the __lib/__ project directory together with the
release and LICENSE notes provided originally.

## Usage

1. download and expand the library
2. modify the OPENSCADPATH Environment Variable to point the __lib/__ directory of this repo as described in [OpenSCAD Library Folder](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries#Library_Locations)
3. include the needed library file(s) in your OpenSCAD code like in the following example:

    include \<OFL/foundation/core.scad\>

## Library documentation

OFL comes with three major components:

* [foundation](docs/foundation/README.md) - the core part re-implementing some of the OpenSCAD native 2d/3d modules while adding new ones;
* [vitamins](docs/vitamins/README.md) - client vitamin modules leveraging the foundation.
* [artifacts](docs/artifacts/README.md) - printable artifacts built on top of [foundation components](docs/foundation/README.md) and [vitamins parts](docs/vitamins/README.md);

## Architecture

Every library component is accessed through a set of verb-based APIs (Common API Template), even third part libraries eventually used internally.

![OFL architecture](docs/architecture.png)
