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
  
  variable title [list "this is a selection"\
"hey"\
"I'm"\
"testing"\
"your patience"]

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
  $w.menubar.file config -width 5
  pack $w.menubar.file -side left
  
  frame $w.mainframe
  tk_optionm
  
  pack $w.menubar $w.mainframe
  
  #set wif [frame $w.interface_frame]
  #tk_optionMenu $wif.list ::testpackagepy::which_mode
  #$wif.list.menu delete 0
  #$wif.list.menu add radiobutton -label [lindex $titles 0] \
    -variable ::testpackagepy::which_mode \
    -command {::testpackagepy::Switch_mode "selection"} 
  #$wif.list.menu add radiobutton -label [lindex $titles 1] \
    -variable ::testpackagepy::which_mode \
    -command {::testpackagepy::Switch_mode "selection"} 

  #set mf [frame $w.main_frame]

  #pack $wif.list -side left -expand 1 -fill x
  #pack $wif -pady 2 -expand 1 -fill x
  
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


proc testpackage_tk {} {

  ::testpackagepy::packageui
  #set ::druggability::which_mode [lindex $::druggability::titles [lsearch $::druggability::interfaces $::druggability::interface]]
  #::druggability::Switch_mode $::druggability::interface
  #return $::druggability::w
  puts "yaya"
}
