package provide testPackage 0.1
package require Tk
package require multiplot

set TESTPACKAGE_PATH $env(TESTPACKAGE_PATH)
set PACKAGE_PATH "$TESTPACKAGE_PATH"
set PACKAGEPATH "$TESTPACKAGE_PATH"

variable platform $tcl_platform(platform)

switch $platform {
  unix {
      set TMPDIR "/tmp" ;  # or even $::env(TMPDIR), at times.
  } macintosh {
      set TMPDIR $::env(TRASH_FOLDER)  ;# a better place?
  } default {
      set TMPDIR [pwd]
      catch {set TMPDIR $::env(TMP)}
      catch {set TMPDIR $::env(TEMP)}
  }
}
puts "setup"

namespace eval ::testpackagepy:: {
  namespace export testpackagepy

  variable version 1.0

  variable w 
  
  variable e
}


proc ::testpackagepy::packageui {} {
  variable w

  global env 

  if [winfo exists .packageui] {
    wm deiconify .packageui
    return
  }
  
  set w [toplevel .packageui]
  wm title $w "CARV+"
  
  grid [frame $w.menubar -relief raised -bd 2] -row 0 -column 0 -padx 1 -sticky ew;
  pack $w.menubar -padx 1 -fill x
  menubutton $w.menubar.file -text File -underline 0 -menu $w.menubar.file.menu
  menu $w.menubar.file.menu -tearoff no
  menubutton $w.menubar.edit -text Edit -underline 0 -menu $w.menubar.edit.menu
  menu $w.menubar.edit.menu -tearoff no
  $w.menubar.file.menu add command -label "Hello" -command  ::testpackagepy::hello
  $w.menubar.file.menu add command -label "Hello but in python" -command ::testpackagepy::hellopy
  $w.menubar.edit.menu add command -label "Load new Mol" -command ::testpackagepy::chargement
  $w.menubar.edit.menu add command -label "Load new trajectory" -command ::testpackagepy::trajectLoad
  $w.menubar.file.menu add command -label "Quit" -command "destroy $w"
  $w.menubar.file config -width 5
  $w.menubar.edit config -width 5
  grid $w.menubar.file -row 0 -column 0 -sticky w
  grid $w.menubar.edit -row 0 -column 1 -sticky e
  
  grid [frame $w.func]
  grid [label $w.label1  -text "Function to plot"]
  grid [radiobutton $w.func.sinBtn -text "sin(x)" -variable func -value "sin" -command "::testpackagepy::setselected {sin} $w"] -row 0 -column 0
  grid [radiobutton $w.func.cosBtn -text "cos(x)" -variable func -value "cos" -command "::testpackagepy::setselected {cos} $w"] -row 0 -column 1
  grid [radiobutton $w.func.tanBtn -text "tan(x)" -variable func -value "tan" -command "::testpackagepy::setselected {tan} $w"] -row 0 -column 2
  grid [radiobutton $w.func.other -text "other (var is x)" -variable func -value "other" -command "::testpackagepy::setselected {other} $w"] -row 1 -column 0
  grid [entry $w.func.otherFunc -textvar ::testpackagepy::e] -row 1 -column 1
  grid [button $w.func.selectBtn -text "Plot this function" -command "::testpackagepy::plotting {sin}"] -row 2 -column 1
  $w.func.sinBtn select
  
  grid [frame $w.dist]
  grid [button $w.dist.plot -text "Plot the distance between two atoms" -command "::testpackagepy::plotAtoms"] -row 0 -column 0
  
  pack $w.menubar $w.label1 $w.func $w.dist
  
  return $w
}

proc ::testpackagepy::hello {} {
  puts "Hello world"
}

proc ::testpackagepy::hellopy {} {
  set pyprefix {gopython}
  puts "[$pyprefix "hello.py"]"
  puts "[$pyprefix -command helloworld()]"
}

proc ::testpackagepy::setselected {rad w} {
  switch $rad {
    "sin" {
      $w.func.selectBtn configure -command "::testpackagepy::plotting {sin}"
    }
    "cos" {
      $w.func.selectBtn configure -command "::testpackagepy::plotting {cos}"
    }
    "tan" {
      $w.func.selectBtn configure -command "::testpackagepy::plotting {tan}"
    }
    "other" {
      $w.func.selectBtn configure -command "::testpackagepy::plotOther"
    }
    default {
      $w.func.selectBtn configure -command "::testpackagepy::plotting {sin}"
    }
  }
}

proc ::testpackagepy::plotting {func} { 
  puts "plotting $func\(x)"
  set xlist {}
  set ylist {}
  for {set x -10} {$x <= 10} {set x [expr ($x + 0.01)]} {
    switch $func {
      "sin" {
        lappend xlist $x
  	lappend ylist [::tcl::mathfunc::sin $x]
      }
      "cos" {
        lappend xlist $x
  	lappend ylist [::tcl::mathfunc::cos $x]
      }
      "tan" {
        lappend xlist $x
  	lappend ylist [::tcl::mathfunc::tan $x]
      }
    }
  }
  set plothandle [multiplot -x $xlist -y $ylist \
                -xlabel "x" -ylabel "$func\(x)" -title "Function $func" \
                -lines -linewidth 1 -linecolor red \
                -marker none -legend "Function $func" -plot];
}



proc ::testpackagepy::trajectLoad {} {
  set newTrajectory [tk_getOpenFile]
  mol addfile $newTrajectory
  pbc unwrap -all 

}

proc ::testpackagepy::chargement {} {
  mol delete all 

  set newMol [tk_getOpenFile]
  puts $newMol
  mol new $newMol

  mol representation CPK
  mol addrep [molinfo 0 get id]

  mol delrep 0 [molinfo 0 get id]

  #set traject [mol addfile [tk_getOpenFile]]

}
#-molid [molinfo 0 get id]
proc ::testpackagepy::plotAtoms {} {
  set sel [atomselect top "resid 48 76 and name CA"]
  #set listDist [measure bond {{48 [molinfo 0 get id]} {76 [molinfo 0 get id]}} -frame all]
  set listDist [measure bond {770 1242} molid [molinfo 0 get id] frame all]

  puts $listDist
  set i 0
  set xlist {}
  foreach d $listDist {
    lappend xlist $i
    incr i
  }
  set plothandle [multiplot -x $xlist -y $listDist \
                -xlabel "time" -ylabel "Distance" -title "Distance between " \
                -lines -linewidth 1 -linecolor red \
                -marker none -legend "Distance" -plot];
}

proc ::testpackagepy::plotOther {} {
  puts $::testpackagepy::e
  set res [split $::testpackagepy::e "x"]
  set f " {"
  set i 0
  foreach s $res {
    incr i
    if {[expr {$i != [llength $res]}]} {
      append f $s
      append f {$x}
    }
  }
  append f "}"
  set xlist {}
  set ylist {}
  for {set x -10} {$x <= 10} {set x [expr ($x + 0.01)]} {
    lappend xlist $x
    lappend ylist [expr $f]
  }
  set plothandle [multiplot -x $xlist -y $ylist \
                -xlabel "x" -ylabel "$::testpackagepy::e" -title "Function $::testpackagepy::e" \
                -lines -linewidth 1 -linecolor red \
                -marker none -legend "Function $::testpackagepy::e" -plot];
  puts [lindex ylist 15]
}

proc testpackage_tk {} {

  ::testpackagepy::packageui
  puts "yaya"
}
