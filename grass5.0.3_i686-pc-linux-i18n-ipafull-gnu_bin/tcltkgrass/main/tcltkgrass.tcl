#!/bin/sh
# the next line restarts using wish \
exec "$1" "$0" "$@"

if ![info exists env(GISBASE)] {
    puts stderr {
The TCLTKGRASS shell must be run (in the background) from the GRASS shell.
    }
    exit 1
}

set env(TCLTKGRASSBASE) DIR

append regexp .* $env(GISBASE) {[^:]*}
regsub -- $regexp $env(PATH) "&:$env(TCLTKGRASSBASE)/script" env(PATH)

source $env(TCLTKGRASSBASE)/main/gui.tcl
source $env(TCLTKGRASSBASE)/main/menu.tcl
