package provide testPackage 0.1
package require Tk 

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
  
  frame $w.menubar -relief raised -bd 2;
  pack $w.menubar -padx 1 -fill x
  menubutton $w.menubar.file -text File -underline 0 -menu $w.menubar.file.menu
  menu $w.menubar.file.menu -tearoff no
  $w.menubar.file.menu add command -label "Hello" -command  ::testpackagepy::hello
  $w.menubar.file.menu add command -label "Hello but in python" -command ::testpackagepy::hellopy
  $w.menubar.file.menu add command -label "Loading mol" -command ::testpackagepy::chargement
  $w.menubar.file config -width 5
  pack $w.menubar.file
  
  grid [frame $w.func]
  grid [label $w.label1  -text "Fonction à plotter"]
  grid [radiobutton $w.func.sinBtn -text "sin(x)" -variable func -value "sin" -command "setselected {sin} $w"] -row 1 -column 1
  grid [radiobutton $w.func.cosBtn -text "cos(x)" -variable func -value "cos" -command "setselected {cos} $w"] -row 1 -column 2
  grid [radiobutton $w.func.tanBtn -text "tan(x)" -variable func -value "tan" -command "setselected {tan} $w"] -row 1 -column 3
  grid [button $w.func.selectBtn -text "Plotter cette fonction" -command "plotting {sin}"] -row 2 -column 2
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
  puts $func
}

proc ::testpackagepy::changement {} {
  set crystal [atomselect top "all"] 
  $crystal set beta 0  
  set sel [atomselect top "hydrophobic"]
  $sel set beta 1 

}
proc ::testpackagepy::chargement {} {
  mol delete all 

  set newMol [tk_getOpenFile]
  puts $newMol
  mol new $newMol
}

proc testpackage_tk {} {

  ::testpackagepy::packageui
  puts "yaya"
}
