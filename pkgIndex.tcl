package ifneeded testPackage 0.1 [list source [file join $dir testPackage.tcl]]

global env 
set env(TESTPACKAGE_PATH) $dir