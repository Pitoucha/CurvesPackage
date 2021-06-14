##
## NucleicAnalysor 0.1
##
## A VMD plugin used to plot data for double helix and G-Quadruplex DNA
##
## Authors: Emilia Goeury-Mayo ; Guillaume Schmit
##
## Id: NucleicAnalysor.tcl, v0.1 2021/05/26 17:19
##

package ifneeded NucleicAnalysor 0.1 [list source [file join $dir NucleicAnalysor.tcl]]

global env 
set env(NUCLEICANALYSOR_PATH) $dir
