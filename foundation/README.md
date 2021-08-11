# OpenSCAD Foundation Library

## Type

A Type is a key/value list like the following:

    type = [
      ["first property name", "this is a string"],  // a string property
      ["second property name", -3.5],               // a number propery
      ["a flag name"],                              // a flag
    ];

**Note**: usage of long, auto-esplicative string keys is encouraged. The 'prolixity' of the key is surpassed through the definition of more concise function getters, while defined properties are auto documented.

## 3D placement concepts and definitions

OFL is based on the following concepts:

* **Bounding Box** - is the **rectangular cuboid consistent with the Cartesian axes** enclosing 3D objects. Boundig Box is a *Type* feature defined through constructors;
* **Direction** - corresponds to an axis plus a rotation around it. Direction determines the bounding box and as such is an *Type* characteristic passed as input to constructors. Due to the limitations in use for the Bounding Box, the definable directions are all and only the 8 Cartesian semi-axes. Internally the resulting direction is evaluated in two vectors, the symmetry axis (usually +Z) and its orthogonal axis (usually +X). Each *Type* has a default direction.
* **Placement** - indicates the octant in which the object is displayed. Since it depends on the bounding box of the object, it is not implemented in specific rendering engines, but by generic primitive applied to objects. Placement is therefore NOT a *Type* feature but a simplified layout applied to a single Type.

## Provided APIs

All the provided APIs belongs to one of the following categories:

1. **contructors** - OpenSCAD function returning a *Type* eventually from one of the prototypes provided in an inventory list;
2. **getters** - OpenSCAD function helper retrieving a value from a *Type*;
3. **engine** - OpenSCAD module responding to a set of predefined *Verbs* applied to a *Type*;
4. **primitive** - any other OpenSCAD function or module not leveraging a *Type*.

### Naming convention

In an attempt to avoid name collision between OFL and any other library, every API name is 'namespaced', i.e. prefixed *at least* with **'fl_'** while the rest of the API will be
- **in Camel Case for constructors**
- **in mixed case** with the first letter lowercase and with the first letter of each internal word capitalised for **rest of the APIs**.


The only exception for this are APIs used internally a file (i.e. not to be used by clients) that must be prefixed and terminated by **'__'**. In this case any eventual name collision *externally* the file is not a problem.


For similar reasons all global constants used in OFL are prefixed with **'FL_'** while the rest of the name must be in **UPPER CASE**.

## File name convention

*Type* definitions must always be contained in a file named like the corresponding namespace introduced. For a file introducing the namespace **'test'** the corresponding filename will be **tests.scad**

**Please note the plural.**

**Type definition file must be 'included'** not 'used'.

An example for a definition files named **symbols.scad**

    include <lib.scad>

    // Exported Type instance (aka Object) used as prototype by constructors defined in the implementation file 
    // Note that the 'namespace' in this case is given by the global 'FL_' plus a local namespace 'SYM_'
    FL_SYM_OBJ1 = [
      ["name",    "Example test #1"],
    ];
    
    FL_SYM_OBJ2 = [
      ["name",    "Example test #2"],
    ];

    // dictionary
    FL_SYM_DICTIONARY = [FL_SYM_OBJ1,FL_SYM_OBJ2];

    use <symbol.scad>
    
The corresponding **implementation file name is always declined in sungular form** and must contain an embedded test module (completed with customizer definitions) named __test__() that must be invoked as default.

**Implementation file are always 'used'** not 'included' from clients. 

The corresponding implementation file for the previous example will be named **symbol.scad** and can be:

    include <symbols.scad>

    /* customizer part */

    /* [Hidden] */

    // test part
    module __test__() {
      ...
    }

    // constructor from prototype
    function fl_Symbol(proto,...) = ... 
    // name getter from Symbol type as built by fl_Symbol()
    // Note that the 'namespace' in this case is given by the global 'fl_' plus a local namespace 'sym_'
    function fl_sym_name(type)    = ... 

    // implementation module
    module fl_symbol(verbs,type,...) {
      ...
    }
    
    __test__();

As a rule of thumb: plural declinated files must be INCLUDED, singulars must be USED.
