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
  
  variable funcVal "sin"

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
  
  grid [frame $w.menubar -relief raised -bd 2] -row 0 -column 0 -padx 1 -sticky ew
  pack $w.menubar -fill x
  menubutton $w.menubar.file -text File -underline 0 -menu $w.menubar.file.menu
  menubutton $w.menubar.edit -text Edit -underline 0 -menu $w.menubar.edit.menu
  menu $w.menubar.file.menu -tearoff no
  menu $w.menubar.edit.menu -tearoff no
  $w.menubar.file.menu add command -label "Hello" -command  ::testpackagepy::hello
  $w.menubar.file.menu add command -label "Hello but in python" -command ::testpackagepy::hellopy
  $w.menubar.edit.menu add command -label "Loading mol" -command ::testpackagepy::chargement
  $w.menubar.file.menu add command -label "Quit" -command "destroy $w"
  $w.menubar.file config -width 5
  $w.menubar.edit config -width 5
  grid $w.menubar.file -row 0 -column 0 -sticky w
  grid $w.menubar.edit -row 0 -column 1 -sticky e
  #pack $w.menubar.file $w.menubar.edit
  
  grid [frame $w.func]
  grid [label $w.label1  -text "Fonction à plotter"]
  grid [radiobutton $w.func.sinBtn -text "sin(x)" -variable func -value "sin" -command "setselected {sin} $w"] -row 0 -column 0
  grid [radiobutton $w.func.cosBtn -text "cos(x)" -variable func -value "cos" -command "setselected {cos} $w"] -row 0 -column 1
  grid [radiobutton $w.func.tanBtn -text "tan(x)" -variable func -value "tan" -command "setselected {tan} $w"] -row 0 -column 2
  grid [button $w.func.selectBtn -text "Plotter cette fonction" -command "plotting {sin}"] -row 1 -column 1
  $w.func.sinBtn select
  
  pack $w.menubar $w.label1 $w.func
  
  set testMenu [frame $w.interface_frame]
  
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

proc setselected {rad w} {
  switch $rad {
    "sin" {
      $w.func.selectBtn configure -command "plotting {sin}"
    }
    "cos" {
      $w.func.selectBtn configure -command "plotting {cos}"
    }
    "tan" {
      $w.func.selectBtn configure -command "plotting {tan}"
    }
    default {
    }
  }
}

proc plotting {func} { 
  puts "plotting $func\(x)"
  #set plothandle [multiplot reset]
  set xlist {}
  set ylist {}
  for {set x -10} {$x <= 10} {set x [expr ($x + 0.01)]} {
    switch $func {
      "sin" {
        lappend xlist $x
  lappend ylist [::tcl::mathfunc::sin $x]
        #$plothandle add $x [::tcl::mathfunc::sin $x]
      }
      "cos" {
        lappend xlist $x
  lappend ylist [::tcl::mathfunc::cos $x]
        #$plothandle add $x [::tcl::mathfunc::cos $x]
      }
      "tan" {
        lappend xlist $x
  lappend ylist [::tcl::mathfunc::tan $x]
        #$plothandle add $x [::tcl::mathfunc::tan $x]
      }
    }
  }
  #puts "liste x : $xlist"
  #puts "liste y : $ylist"
  set plothandle [multiplot -x $xlist -y $ylist \
                -xlabel "x" -ylabel "$func\(x)" -title "Fonction $func" \
                -lines -linewidth 1 -linecolor red \
                -marker none -legend "Fonction $func" -plot];
}


proc ::testpackagepy::chargement {} {
  mol delete all 

  set newMol [tk_getOpenFile]
  puts $newMol
  mol new $newMol

  mol representation CPK
  mol addrep [molinfo 0 get id]

  #set traject [mol addfile [tk_getOpenFile]]

}

proc testpackage_tk {} {

  ::testpackagepy::packageui
  puts "yaya"
}
