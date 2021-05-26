#!/usr/bin/wish

# ZetCode Tcl/Tk tutorial
#
# This program creates a quit
# button. When we press the button,
# the application terminates. 
#
# Author: Jan Bodnar
# Website: www.zetcode.com


button .hell -text "Quit" -command { exit }
place .hell -x 50 -y 50 


wm title . "Quit button" 
wm geometry . 350x250+300+300

puts "yay"

set com {

    if {$idSel1 <= $mid} {
      if {[regexp {^DA} $name1] } {
        dict for {id info} $selectList {
        if {[regexp {^DT} $id]} {
          append stc [split $info "\ "]
          append stc "\ "
        }
      }
      
      if {[lsearch -exact $stc $match] >= 0 && $match > $mid } {
        $w.distG.resSel.resIdBase2 set $match 
        dict for {id info} $selectList {
          if {[lsearch -exact $info $match] >= 0} {
            $w.distG.resSel.resNameBase2 set $id
            break
          }
        }
      } else {
          $w.distG.resSel.resIdBase2 set "-1"
        }
      }

      if {[regexp {^DT} $name1]} {
          
        dict for {id info} $selectList {
        if {[regexp {^DA} $id]} {
          append stc [split $info "\ "]
          append stc "\ "
        }
      }
      
      if {[lsearch -exact $stc $match] >= 0 && $match > $mid } {
        $w.distG.resSel.resIdBase2 set $match 
        dict for {id info} $selectList {
          if {[lsearch -exact $info $match] >= 0} {
            $w.distG.resSel.resNameBase2 set $id
            break
          }
        }
      } else {
          $w.distG.resSel.resIdBase2 set "-1"
        }
      }

      if {[regexp {^DC} $name1]} {
        
        dict for {id info} $selectList {
        if {[regexp {^DG} $id]} {
          append stc [split $info "\ "]
          append stc "\ "
        }
      }

      puts $stc 
      
      if {[lsearch -exact $stc $match] >= 0 && $match > $mid } {
        $w.distG.resSel.resIdBase2 set $match 
        dict for {id info} $selectList {
          if {[lsearch -exact $info $match] >= 0} {
            $w.distG.resSel.resNameBase2 set $id
            break
          }
        }
      } else {
          $w.distG.resSel.resIdBase2 set "-1"
        }
      }

      if {[regexp {^DG} $name1]} {
        
        dict for {id info} $selectList {
          if {[regexp {^DC} $id]} {
            append stc [split $info "\ "]
            append stc "\ "
          }
        }

      if {[lsearch -exact $stc $match] >= 0 && $match > $mid } {
        $w.distG.resSel.resIdBase2 set $match 
        dict for {id info} $selectList {
          if {[lsearch -exact $info $match] >= 0} {
            $w.distG.resSel.resNameBase2 set $id
            break
          }
        }
      } else {
          $w.distG.resSel.resIdBase2 set "-1"
        }
      }
    }
    

    #dict for {id info} $selectList {
    #  if {$id eq $name} {
    #     
    #  }
    #}
  }
  
  
  
  #####################################################################################
    set COMMENT {
    #################################
    
    #dropdown list for using the first base resname
    grid [ttk::combobox $w.distG.resSel.resNameBase1] -row 1 -column 0
    #button to add the list of resid values
    grid [button $w.distG.resSel.getName1 -text "Use this resName"  -command "::curvespackage::selectWithList 0"] -row 1 -column 1
    #dropdown list for the resid of the first base 
    grid [ttk::combobox $w.distG.resSel.resIdBase1] -row 1 -column 2

    ###############################
    #seconde base
    #dropdown list for the second bases resname
    grid [ttk::combobox $w.distG.resSel.resNameBase2] -row 2 -column 0
    #button to add the list of resid values
    grid [button $w.distG.resSel.getName2 -text "Use this resName"  -command "::curvespackage::selectWithList 1"] -row 2 -column 1
    #dropdown list for the resid of the second base
    grid [ttk::combobox $w.distG.resSel.resIdBase2] -row 2 -column 2

    ###############################

    #button for calling the matching of bases
    grid [button $w.distG.resSel.btnMatch -text "Match this resId to get the facing resId" -command "::curvespackage::matchList"] -row 3 -columnspan 3
    
    ###############################

    #third base 
    #dropdown list for the third bases resname
    grid [ttk::combobox $w.distG.resSel.resNameMatch1] -row 4 -column 0
    #button to add the list of resid values
    grid [button $w.distG.resSel.getName3 -text "Use this resName"  -command "::curvespackage::selectWithList 2"] -row 4 -column 1
    #dropdown list for the resid of the third base
    grid [ttk::combobox $w.distG.resSel.resIdMatch1] -row 4 -column 2
    
    ###############################

    #fourth base
    #dropdown list for the fourth bases resname
    grid [ttk::combobox $w.distG.resSel.resNameMatch2] -row 5 -column 0
    #button to add the list of resid values
    grid [button $w.distG.resSel.getName4 -text "Use this resName"  -command "::curvespackage::selectWithList 3"] -row 5 -column 1
    #dropdown list for the resid of the fourth base
    grid [ttk::combobox $w.distG.resSel.resIdMatch2] -row 5 -column 2

    }
    #####################################################################################
    
    #####################################################################################
    set COMMENT {
    grid [label $w.distG.resSel.labelComp -text "Select the atom groups to compare"] -row 4 -columnspan 3
    grid [ttk::combobox $w.distG.resSel.resNameComp1] -row 5 -column 0
    grid [button $w.distG.resSel.getName3 -text "Use this resName"  -command "::curvespackage::selectWithList 2"] -row 5 -column 1
    grid [ttk::combobox $w.distG.resSel.resIdComp1] -row 5 -column 2
    grid [ttk::combobox $w.distG.resSel.resNameComp2] -row 6 -column 0
    grid [button $w.distG.resSel.getName4 -text "Use this resName"  -command "::curvespackage::selectWithList 3"] -row 6 -column 1
    grid [ttk::combobox $w.distG.resSel.resIdComp2] -row 6 -column 2
    grid [button $w.distG.resSel.valSel -text "Plot the angles between the base and the other atoms" -command "::curvespackage::plotAngleVectors"] -row 7 -columnspan 3
    }
    #####################################################################################
    #####################################################################################
    set COMMENT {
    "distB" {
      set lDist {}
      for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
        $res1 frame $i
	$res2 frame $i
	$res3 frame $i
	$res4 frame $i
	$res1 update
	$res2 update
	$res3 update
	$res4 update
	set xyzA1 [split [string range [$res1 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res2 get {x y z}] 1 end-1] "\ "]
	set vect1 [vecsub $xyzA1 $xyzA2]
	set xyzA1 [split [string range [$res3 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res4 get {x y z}] 1 end-1] "\ "]
	set vect2 [vecsub $xyzA1 $xyzA2]
	set dist [vecdist $vect1 $vect2]
	lappend lDist $dist
      }
      return $lDist
    }
  }
  #####################################################################################
  #####################################################################################
set COMMENT {
proc ::curvespackage::plotOther {} {
  puts $::curvespackage::e
  set res [split $::curvespackage::e "x"]
  set f " "
  set i 0
  foreach s $res {
    incr i
    if {[expr {$i != [llength $res]}]} {
      append f $s
      append f {$x}
    }
  }
  set xlist {}
  set ylist {}
  for {set x -10} {$x <= 10} {set x [expr {$x + 1}]} {
    if {$x != 0} {
      lappend xlist $x
      lappend ylist [expr {[expr $f]*1.0}]
      puts [expr {[expr $f]*1.0}]
    }
  }
  puts [lindex ylist 15]
  set plothandle [multiplot -x $xlist -y $ylist \
                -xlabel "x" -ylabel "$::curvespackage::e" -title "Function $::curvespackage::e" \
                -lines -linewidth 1 -linecolor red \
                -marker none -legend "Function $::curvespackage::e" -plot];
}
}
#####################################################################################
#####################################################################################
set COMMENT {
proc ::curvespackage::plotAngleVectors {} {
  variable w
  variable frameStart
  variable frameEnd
  variable step
  
  set startBase [$w.distG.resSel.resIdBase1 get]
  set endBase [$w.distG.resSel.resIdBase2 get]
  set startComp [$w.distG.resSel.resIdComp1 get]
  set endComp [$w.distG.resSel.resIdComp2 get]
  
  if { $startBase ne "" && $endBase ne "" && $startComp ne "" && $endComp ne ""} {
    set startBase [expr int($startBase)]
    set endBase [expr int($endBase)]
    set startComp [expr int($startComp)]
    set endComp [expr int($endComp)]
    
    set res1 [atomselect top "resid $startBase"]
    set res2 [atomselect top "resid $endBase"]
    set res3 [atomselect top "resid $startComp"]
    set res4 [atomselect top "resid $endComp"]
    
    set lAngl [::curvespackage::computeFrames "angV" $res1 $res2 $res3 $res4]
    
    $res1 delete
    $res2 delete
    $res3 delete
    $res4 delete
    
    if {$frameStart eq ""} {
      set frameStart 0
    } else {
      set frameStart [expr int($frameStart)]
    }
    if {$frameEnd eq ""} {
      set frameEnd [molinfo top get numframes]
    } else {
      set frameEnd [expr int($frameEnd)]
    }
    if {$step eq ""} {
      set step 1
    } else {
      set step [expr int($step)]
    }
  
    set xlist {}
  
    for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
      lappend xlist $i
    }
  
    set plothandle [multiplot -x $xlist -y $lAngl \
                  -xlabel "Frame" -ylabel "Angle" -title "Angle between the groups" \
                  -lines -linewidth 1 -linecolor red \
                  -marker none -legend "Angle" -plot];
  } else {
    puts "Error, some fields are empty"
  }
}
}
#####################################################################################
