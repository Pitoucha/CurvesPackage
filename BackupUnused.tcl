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
set COMMENT {
  grid [labelframe $w.func  -text "Function plotting" -bd 2] -columnspan 6
  grid [radiobutton $w.func.sinBtn -text "sin(x)" -variable func -value "sin" -command "::curvespackage::setselected {sin}"] -row 0 -column 0
  grid [radiobutton $w.func.cosBtn -text "cos(x)" -variable func -value "cos" -command "::curvespackage::setselected {cos}"] -row 0 -column 1
  grid [radiobutton $w.func.tanBtn -text "tan(x)" -variable func -value "tan" -command "::curvespackage::setselected {tan}"] -row 0 -column 2
  #grid [radiobutton $w.func.other -text "other (var is x)" -variable func -value "other" -command "::curvespackage::setselected {other} $w"] -row 1 -column 0
  #grid [entry $w.func.otherFunc -textvar ::curvespackage::e] -row 1 -column 1
  grid [button $w.func.selectBtn -text "Plot this function" -command "::curvespackage::plotting {sin}"] -row 2 -columnspan 3
  $w.func.sinBtn select
  
  
    grid [label $w.distG.labelG1 -text "First group of atoms to select (index,index,...) : "] -row 0 -column 0 -columnspan 3
    grid [entry $w.distG.atom1 -textvar ::curvespackage::lAtoms1] -row 0 -column 3 -columnspan 3
    grid [label $w.distG.labelG2 -text "Second group of atoms to select (index,index,...) : "] -row 1 -column 0 -columnspan 3
    grid [entry $w.distG.atom2 -textvar ::curvespackage::lAtoms2] -row 1 -column 3 -columnspan 3
    grid [button $w.distG.plotG -text "Plot the distance between two groups of atoms"] -row 3 -columnspan 6
    grid [button $w.distG.angleG -text "Plot the angles between two groups of atoms"] -row 4 -columnspan 6 used "ang"

proc ::curvespackage::setselected {rad} {
  variable w
  switch $rad {
    "sin" {
      $w.func.selectBtn configure -command "::curvespackage::plotting {sin}"
    }
    "cos" {
      $w.func.selectBtn configure -command "::curvespackage::plotting {cos}"
    }
    "tan" {
      $w.func.selectBtn configure -command "::curvespackage::plotting {tan}"
    }
    "other" {
      $w.func.selectBtn configure -command "::curvespackage::plotOther"
    }
    default {
      $w.func.selectBtn configure -command "::curvespackage::plotting {sin}"
    }
  }
}
proc ::curvespackage::plotting {func} { 
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

}

set COMMENT {

#crée les buttons correspondants 
    grid [labelframe $w.dist2 -text "Plot the distance between two atoms" -bd 2] -columnspan 6
    grid [label $w.dist2.labelA1 -text "First atom to select (index) : "] -row 0 -column 0
    grid [entry $w.dist2.atom1 -textvar ::curvespackage::atom1] -row 0 -column 1
    grid [label $w.dist2.labelA2 -text "Second atom to select (index) : "] -row 1 -column 0
    grid [entry $w.dist2.atom2 -textvar ::curvespackage::atom2] -row 1 -column 1
    grid [button $w.dist2.plot2 -text "Plot the distance between two atoms" -command "::curvespackage::plotAtoms"] -columnspan 2
    #grid [button $w.dist2.plot2Visu -text "Plot the distance between two atoms selected onscreen" -command "::curvespackage::plotAtoms"]
    
    grid [labelframe $w.distG -text "Plot the distance between two groups of atoms" -bd 2] -columnspan 6
    grid [label $w.distG.labelG1 -text "First group of atoms to select (index,index,...) : "] -row 0 -column 0 -columnspan 3
    grid [entry $w.distG.atom1 -textvar ::curvespackage::lAtoms1] -row 0 -column 3 -columnspan 3
    grid [label $w.distG.labelG2 -text "Second group of atoms to select (index,index,...) : "] -row 1 -column 0 -columnspan 3
    grid [entry $w.distG.atom2 -textvar ::curvespackage::lAtoms2] -row 1 -column 3 -columnspan 3
    grid [button $w.distG.plotG -text "Plot the distance between two groups of atoms" -command "::curvespackage::plotAtomsGroups"] -row 3 -columnspan 6
    grid [button $w.distG.angleG -text "Plot the angles between two groups of atoms" -command "::curvespackage::plotAngleGroups"] -row 4 -columnspan 6
    #grid [button $w.distG.plotGVisu -text "Plot the distance between two groups of atoms selected onscreen" -command "::curvespackage::plotAtomsGroups"]

#takes the index not the id of the atom
proc ::curvespackage::plotAtoms {} {
  set sel [atomselect top "resid $::curvespackage::atom1  $::curvespackage::atom2"]
  set listDist [measure bond [list $::curvespackage::atom1 $::curvespackage::atom2] molid [molinfo 0 get id] frame all]
  
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
  $sel delete
}

proc ::curvespackage::plotAtomsGroups {} {
  variable frameStart
  variable frameEnd
  variable step
  
  set list1 [split $::curvespackage::lAtoms1 ,]
  set list2 [split $::curvespackage::lAtoms2 ,]


  set l1 "resid\ "
  append l1 $list1
  set res1 [atomselect top $l1]


  set l2 "resid\ "
  append l2 $list2
  set res2 [atomselect top $l2]
  
  set lDist [::curvespackage::computeFrames "dist" $res1 $res2]

  $res1 delete
  $res2 delete
  
  set xlist {}
  
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
  
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    lappend xlist $i
  }
  
  set plothandle [multiplot -x $xlist -y $lDist \
                -xlabel "Frame" -ylabel "Distance" -title "Distance between the groups" \
                -lines -linewidth 1 -linecolor red \
                -marker none -legend "Distance" -plot];
}



proc ::curvespackage::plotAngleGroups {} {
  variable frameStart
  variable frameEnd
  variable step
  
  set list1 [split $::curvespackage::lAtoms1 ,]
  set list2 [split $::curvespackage::lAtoms2 ,]
  
  set l1 "resid\ "
  append l1 $list1
  set res1 [atomselect top $l1]


  set l2 "resid\ "
  append l2 $list2
  set res2 [atomselect top $l2]
  
  set lAngl [::curvespackage::computeFrames "ang" $res1 $res2]

  $res1 delete
  $res2 delete
  
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
                -xlabel "Frame" -ylabel "Angle (degrees)" -title "Angle between the groups" \
                -lines -linewidth 1 -linecolor red \
                -marker none -legend "Angle" -plot];
}


    "ang" {
    # Case in which we calculate the angle between two selection's centers of mass
    
      # Creating the list that will be returned 
      set lAngl {}
      
      # For each selected frame from the loaded trajectory
      for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
      
        # Updating the selections for the frame i
        $res1 frame $i
	$res2 frame $i
	$res1 update
	$res2 update
	
	# Calculating the center of mass of each selection
	set com1 [measure center $res1]
        set com2 [measure center $res2]
	
	# Calculating the length of each center of mass vector
	set len1 [veclength $com1]
	set len2 [veclength $com2]
	
	# Calculating the scalar dot product between the two center of mass vectors
	set dotprod [vecdot $com1 $com2]
	
	# Correcting the scalar dot product by dividing it by the multiplication of the two vector lengths
	set dotprodcor [expr $dotprod / ($len1 * $len2)]
	
	# Calculating the angle in degrees from the scalar dot product
	set ang [expr {57.2958 * [::tcl::mathfunc::acos $dotprodcor]}]
	
	# Adding the angle to the returned list
	lappend lAngl $ang
      }
      
      # Returns the list
      return $lAngl
    }


    "angV" {
    # Case in which we calculate the angle between two pairs of selection's mass centers
    
      # Creating the list that will be returned 
      set lAngl {}
      
      # For each selected frame from the loaded trajectory
      for {set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
        
	# Updating the selections for the frame i
        $res1 frame $i
	$res2 frame $i
	$res3 frame $i
	$res4 frame $i
	$res1 update
	$res2 update
	$res3 update
	$res4 update
	
	# Calculating the centers of mass of the first pair selected
	set com1 [measure center $res1]
	set com2 [measure center $res2]
	
	# Calculating the vector between the first pair of bases
	set vectBase [vecsub $com2 $com1]
	
	# Calculating the centers of mass of the second pair selected
	set com1 [measure center $res3]
	set com2 [measure center $res4]
	
	# Calculating the vector between the second pair of bases
	set vectComp [vecsub $com2 $com1]
	
	# Calculating the length of the base vector
	set lenB [veclength $vectBase]
	
	# Calculating the length of the compared vector
	set lenC [veclength $vectComp]
	
	# Calculating the scalar dot product between the base and comparated vector
	set dotprod [vecdot $vectBase $vectComp]
	
	# Correcting the scalar dot product by dividing it by the multiplication of the lengths of the 2 vectors
	set dotprodcor [expr $dotprod / ($lenB * $lenC)]
	
	# Correcting the scalar dot product (in case of bad rounding)
	if {$dotprodcor > 1.0} {
	  set dotprodcor 1.0
	}
	if {$dotprodcor < -1.0} {
	  set dotprodcor -1.0
	}
	
	# Calculating the angle in degrees from the scalar dot product
	set ang [expr {57.2958 * [::tcl::mathfunc::acos $dotprodcor]}]
	
	# Adding the angle to the returned list
	lappend lAngl $ang
      }
      
      # Returns the list
      return $lAngl
    }


}
