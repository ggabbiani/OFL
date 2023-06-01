# General TODOs

* implement module fl_frame() for 3d frames;
* remove fl_director() and fl_rotor() properties. In place of them use default native coordinate system [+Z,+X];
* transform some of the special global constants into special module parameters manageable through common API:

    \$FL\_DEBUG ⇒ function fl_parm_DEBUG() = is_undef($debug) ? false : $debug;


