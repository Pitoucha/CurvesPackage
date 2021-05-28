##
## CurvesPackage 0.1
##
## A VMD plugin used to plot data for double helix and G-Quadruplex DNA
##
## Authors: Emilia Goeury-Mayo ; Guillaume Schmit
##
## Id: CurvesPackage.tcl, v0.1 2021/05/26 17:19
##

package ifneeded CurvesPackage 0.1 [list source [file join $dir CurvesPackage.tcl]]

global env 
set env(CURVESPACKAGE_PATH) $dir
