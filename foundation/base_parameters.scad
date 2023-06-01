/*!
 * Common parameter helpers
 *
 * Copyright © 2021, Giampiero Gabbiani (giampiero@gabbiani.org)
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

//**** Global getters *********************************************************

/*!
 * When true fl_assert() is enabled
 *
 * TODO: remove since deprecated.
 */
function fl_asserts() = is_undef($fl_asserts) ? false : assert(is_bool($fl_asserts)) $fl_asserts;

//! When true debug statements are turned on
function fl_debug() = is_undef($fl_debug)
? /* echo("**DEBUG** false")  */ false
: assert(is_bool($fl_debug),$fl_debug) /* echo(str("**DEBUG** ",$fl_debug)) */ $fl_debug;

//! Default color for printable items (i.e. artifacts)
function fl_filament() = is_undef($fl_filament)
? "DodgerBlue"
: assert(is_string($fl_filament)) $fl_filament;

//**** Common parameters ******************************************************

//! constructor for debug context parameter
function fl_parm_Debug(
  //! when true, labels to symbols are assigned and displayed
  labels  = false,
  //! when true symbols are displayed
  symbols = false
) = [labels,symbols];

//! When true debug labels are turned on
function fl_parm_labels(debug) = is_undef(debug) ? false : assert(is_bool(debug[0])) debug[0];

//! When true debug symbols are turned on
function fl_parm_symbols(debug) = is_undef(debug) ? false : assert(is_bool(debug[1])) debug[1];
