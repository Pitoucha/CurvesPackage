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

namespace eval ::testpackagepy:: {
  namespace export testpackagepy

  variable version 1.0

  variable w 
  
  variable atom1
  variable atom2
  variable lAtoms1
  variable lAtoms2
  variable selectList
}


proc ::testpackagepy::packageui {} {
  variable w

  global env 

  if [winfo exists .packageui] {
    wm deiconify .packageui
    return
  }
  
  set w [toplevel .packageui]
  wm title $w "CURV+"
  
  grid [frame $w.menubar -relief raised -bd 2] -row 0 -column 0 -padx 1 -sticky ew;
  pack $w.menubar -padx 1 -fill x
  
  menubutton $w.menubar.file -text File -underline 0 -menu $w.menubar.file.menu
  menu $w.menubar.file.menu -tearoff no
  
  menubutton $w.menubar.edit -text Edit -underline 0 -menu $w.menubar.edit.menu
  menu $w.menubar.edit.menu -tearoff no

  $w.menubar.file.menu add command -label "Hello" -command  ::testpackagepy::hello
  $w.menubar.file.menu add command -label "Hello but in python" -command ::testpackagepy::hellopy 
  $w.menubar.file.menu add command -label "Quit" -command "destroy $w"
  $w.menubar.edit.menu add command -label "Load new Mol" -command ::testpackagepy::chargement
  $w.menubar.edit.menu add command -label "Load new trajectory" -command ::testpackagepy::trajectLoad
  $w.menubar.file config -width 5
  $w.menubar.edit config -width 5
  grid $w.menubar.file -row 0 -column 0 -sticky w
  grid $w.menubar.edit -row 0 -column 1 -sticky e
  
  
  grid [labelframe $w.func  -text "Function plotting" -bd 2]
  grid [radiobutton $w.func.sinBtn -text "sin(x)" -variable func -value "sin" -command "::testpackagepy::setselected {sin}"] -row 0 -column 0
  grid [radiobutton $w.func.cosBtn -text "cos(x)" -variable func -value "cos" -command "::testpackagepy::setselected {cos}"] -row 0 -column 1
  grid [radiobutton $w.func.tanBtn -text "tan(x)" -variable func -value "tan" -command "::testpackagepy::setselected {tan}"] -row 0 -column 2
  #grid [radiobutton $w.func.other -text "other (var is x)" -variable func -value "other" -command "::testpackagepy::setselected {other} $w"] -row 1 -column 0
  #grid [entry $w.func.otherFunc -textvar ::testpackagepy::e] -row 1 -column 1
  grid [button $w.func.selectBtn -text "Plot this function" -command "::testpackagepy::plotting {sin}"] -row 2 -column 1
  $w.func.sinBtn select
  
  
  grid [labelframe $w.dist2 -text "Plot the distance between two atoms" -bd 2]
  grid [label $w.dist2.labelA1 -text "First atom to select (index) : "] -row 0 -column 0
  grid [entry $w.dist2.atom1 -textvar ::testpackagepy::atom1] -row 0 -column 1
  grid [label $w.dist2.labelA2 -text "Second atom to select (index) : "] -row 1 -column 0
  grid [entry $w.dist2.atom2 -textvar ::testpackagepy::atom2] -row 1 -column 1
  grid [button $w.dist2.plot2 -text "Plot the distance between two atoms" -command "::testpackagepy::plotAtoms"]
  #grid [button $w.dist2.plot2Visu -text "Plot the distance between two atoms selected onscreen" -command "::testpackagepy::plotAtoms"]
  
  
  grid [labelframe $w.distG -text "Plot the distance between two groups of atoms" -bd 2]
  grid [label $w.distG.labelG1 -text "First group of atoms to select (index,index,...) : "] -row 0 -column 0
  grid [entry $w.distG.atom1 -textvar ::testpackagepy::lAtoms1] -row 0 -column 1
  grid [label $w.distG.labelG2 -text "Second group of atoms to select (index,index,...) : "] -row 1 -column 0
  grid [entry $w.distG.atom2 -textvar ::testpackagepy::lAtoms2] -row 1 -column 1
  grid [labelframe $w.distG.resSel -text "Select the resnames and resids to be selected" -bd 2] -row 2
  grid [ttk::combobox $w.distG.resSel.resName1] -row 0 -column 0
  grid [button $w.distG.plotG -text "Plot the distance between two groups of atoms" -command "::testpackagepy::plotAtomsGroups"]
  grid [button $w.distG.angleG -text "Plot the angles between two groups of atoms" -command "::testpackagepy::plotAngleGroups"]
  #grid [button $w.distG.plotGVisu -text "Plot the distance between two groups of atoms selected onscreen" -command "::testpackagepy::plotAtomsGroups"]
  
  pack $w.menubar $w.func $w.dist2 $w.distG
  
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

proc ::testpackagepy::setselected {rad} {
  variable w
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

  ::testpackagepy::listeResname
  ::testpackagepy::selectWithList "HOH"
}

proc ::testpackagepy::listeResname {} {
  variable w

  set sel [atomselect top "all"]

  set ::testpackagepy::selectList [dict create]

  set names [$sel get {resname resid}]
  set names [lsort -unique $names]

  foreach name $names  {
      #recupère resname et resid
      set rsn [split $name "\ "]
      set rsi [lindex $rsn 1]
      set rsn [lindex $rsn 0]

      #ajout dans un dict sous la forme {{"RESNAME":"id1" "id2"}{"RESNAME2":"id3" "id4"}}
      if {![dict exist $::testpackagepy::selectList $rsn]} {
        puts $rsn
        puts $rsi 
        dict set ::testpackagepy::selectList $rsn $rsi 
      } else {
        dict lappend ::testpackagepy::selectList $rsn $rsi 
        puts $rsn
        puts $rsi 
      }
    }

    dict for {id info} $::testpackagepy::selectList {
      puts "resname = $id"
      puts "resid = $info" 
    }
    
    set names [$sel get resname]
    set names [lsort -unique $names]
    
    $w.distG.resName1 configure -values $names
    
    $sel delete
}

proc ::testpackagepy::selectWithList {name} {
  puts $::testpackagepy::selectList
  dict for {id info} $::testpackagepy::selectList {
    puts "resname = $id"
    puts "resid = $info" 
    if {$id eq $name} {
      set selIds $info
    }
  }

  if {[string trim $selIds] != ""} {
    set sel [atomselect top "resid $selIds"]  
    mol representation NewCartoon
    mol addrep [molinfo 0 get id]
  } else {
    puts "uhoh"
  }
}

#takes the index not th id of the atom
proc ::testpackagepy::plotAtoms {} {
  set sel [atomselect top "resid $::testpackagepy::atom1  $::testpackagepy::atom2"]
  set listDist [measure bond [list $::testpackagepy::atom1 $::testpackagepy::atom2] molid [molinfo 0 get id] frame all]

  #puts $listDist
  set i 0
  set xlist {}
  foreach d $listDist {
    lappend xlist $i
    incr i
  }
  set plothandle [multiplot -x $xlist -y $listDist \
                -xlabel "Frame" -ylabel "Distance" -title "Distance between the atoms" \
                -lines -linewidth 1 -linecolor red \
                -marker none -legend "Distance" -plot];
}

proc ::testpackagepy::plotAtomsGroups {} {
  set list1 [split $::testpackagepy::lAtoms1 ,]
  set list2 [split $::testpackagepy::lAtoms2 ,]


  set l1 "resid\ "
  append l1 $list1
  set res1 [atomselect top $l1]


  set l2 "resid\ "
  append l2 $list2
  set res2 [atomselect top $l2]
  
  set lDist [::testpackagepy::computeFrames "dist" $res1 $res2]
  
  set xlist {}
  set nFrames [molinfo top get numframes]
  for { set i 0 } { $i < $nFrames } { incr i } {
    lappend xlist $i
  }
  
  set plothandle [multiplot -x $xlist -y $lDist \
                -xlabel "Frame" -ylabel "Distance" -title "Distance between the groups" \
                -lines -linewidth 1 -linecolor red \
                -marker none -legend "Distance" -plot];
}

proc ::testpackagepy::plotAngleGroups {} {
  set list1 [split $::testpackagepy::lAtoms1 ,]
  set list2 [split $::testpackagepy::lAtoms2 ,]
  
  set l1 "resid\ "
  append l1 $list1
  set res1 [atomselect top $l1]


  set l2 "resid\ "
  append l2 $list2
  set res2 [atomselect top $l2]
  
  set lAngl [::testpackagepy::computeFrames "ang" $res1 $res2]
  
  set xlist {}
  
  set nFrames [molinfo top get numframes]
  for { set i 0 } { $i < $nFrames } { incr i } {
    lappend xlist $i
  }
  
  set plothandle [multiplot -x $xlist -y $lAngl \
                -xlabel "Frame" -ylabel "Distance" -title "Distance between the groups" \
                -lines -linewidth 1 -linecolor red \
                -marker none -legend "Distance" -plot];
}

proc ::testpackagepy::computeFrames { type res1 res2 } {
  set nFrames [molinfo top get numframes]
  switch $type {
    "dist" {
      set lDist {}
      for { set i 0 } { $i < $nFrames } { incr i } {
	$res1 frame $i
	$res2 frame $i
	$res1 update
	$res2 update
	set com1 [measure center $res1]
        set com2 [measure center $res2]
	lappend lDist [vecdist $com1 $com2]
      }
      return $lDist
    }
    "ang" {
      set lAngl {}
      for { set i 0 } { $i < $nFrames } { incr i } {
        $res1 frame $i
	$res2 frame $i
	$res1 update
	$res2 update
	set com1 [measure center $res1]
        set com2 [measure center $res2]
	set len1 [veclength $com1]
	set len2 [veclength $com2]
	puts "com1 = $com1"
	puts "com2 = $com2"
	set dotprod [vecdot $com1 $com2]
	set dotprodcor [expr $dotprod / ($len1 * $len2)]
	set ang [expr {57.2958 * [::tcl::mathfunc::acos $dotprodcor]}]
	lappend lAngl $ang
      }
      return $lAngl
    }
  }
}

#proc ::testpackagepy::plotOther {} {
#  puts $::testpackagepy::e
#  set res [split $::testpackagepy::e "x"]
#  set f " "
#  set i 0
#  foreach s $res {
#    incr i
#    if {[expr {$i != [llength $res]}]} {
#      append f $s
#      append f {$x}
#    }
#  }
#  set xlist {}
#  set ylist {}
#  for {set x -10} {$x <= 10} {set x [expr {$x + 1}]} {
#    if {$x != 0} {
#      lappend xlist $x
#      lappend ylist [expr {[expr $f]*1.0}]
#      puts [expr {[expr $f]*1.0}]
#    }
#  }
#  puts [lindex ylist 15]
#  set plothandle [multiplot -x $xlist -y $ylist \
#                -xlabel "x" -ylabel "$::testpackagepy::e" -title "Function $::testpackagepy::e" \
#                -lines -linewidth 1 -linecolor red \
#                -marker none -legend "Function $::testpackagepy::e" -plot];
#}

proc testpackage_tk {} {
  ::testpackagepy::packageui
}
