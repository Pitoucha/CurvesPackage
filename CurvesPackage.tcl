##
## CurvesPackage 0.1
##
## A VMD plugin used to plot data for double helix and G-Quadruplex DNA
##
## Authors: Emilia Goeury-Mayo ; Guillaume Schmit
##
## Id: CurvesPackage.tcl, v0.1 2021/05/26 17:19
##

package provide CurvesPackage 0.1
package require Tk
package require multiplot

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

namespace eval ::curvespackage:: {
  namespace export curvespackage

  variable version 1.0

  variable w 
  
  variable atom1
  variable atom2
  variable lAtoms1
  variable lAtoms2
  variable selectList
  variable frameStart
  variable frameEnd
  variable step
  variable maxDNA
  variable minDNA
  variable mid
  variable atomsDNA
  set atomsDNA [dict create DA {C1' N6} DT {C1' O4} DC {C1' N4} DG {C1' N1}]
  variable plotColors {black red green blue magenta orange OliveDrab2 cyan maroon gold2 yellow gray60 SkyBlue2 orchid3 ForestGreen PeachPuff LightSlateBlue}

  variable CURVESPACKAGE_PATH $env(CURVESPACKAGE_PATH)
  variable PACKAGE_PATH "$CURVESPACKAGE_PATH"
  variable PACKAGEPATH "$CURVESPACKAGE_PATH"
}


proc ::curvespackage::packageui {} {
  variable w

  global env 

  if [winfo exists .packageui] {
    wm deiconify .packageui
    return
  }
  
  set w [toplevel .packageui]
  wm title $w "CURVES+"
  
  grid [frame $w.menubar -relief raised -bd 2] -row 0 -column 0 -padx 1 -sticky ew;
  pack $w.menubar -padx 1 -fill x
  
  menubutton $w.menubar.file -text File -underline 0 -menu $w.menubar.file.menu
  menu $w.menubar.file.menu -tearoff no
  
  menubutton $w.menubar.edit -text Load -underline 0 -menu $w.menubar.edit.menu
  menu $w.menubar.edit.menu -tearoff no
  
  $w.menubar.file.menu add command -label "Quit" -command "destroy $w"
  $w.menubar.edit.menu add command -label "Load new Mol" -command ::curvespackage::chargement
  $w.menubar.edit.menu add command -label "Load new trajectory" -command ::curvespackage::trajectLoad
  $w.menubar.edit.menu add command -label "test exec ls" -command ::curvespackage::testLs
  $w.menubar.edit.menu add command -label "GNUplot" -command ::curvespackage::gnuPlotTest
  $w.menubar.file config -width 5
  $w.menubar.edit config -width 5
  grid $w.menubar.file -row 0 -column 0 -sticky w
  grid $w.menubar.edit -row 0 -column 1 -sticky e
  
  pack $w.menubar
  
  return $w
}


proc ::curvespackage::gnuPlotTest {} {
  variable CURVESPACKAGE_PATH
  cd $CURVESPACKAGE_PATH
  cd "GNU_Script"

  set file [open "outdist1.dat" w]
  set listP [::curvespackage::plotBases dist 1]
  for { set i 0 } { $i <= [llength $listP] } { incr i } {
    puts $file [lindex $listP $i]
  }
  close $file

  set file [open "outangl1.dat" w]
  set listP [::curvespackage::plotBases angl 1]
  for { set i 0 } { $i <= [llength $listP] } { incr i } {
    puts $file [lindex $listP $i]
  }
  close $file
}

proc ::curvespackage::testLs {} {
  variable CURVESPACKAGE_PATH
  cd $CURVESPACKAGE_PATH
  cd "GNU_Script"

  set path "distGNUScript.plt"
 # set output [tk_chooseDirectory]

  set foo "This is some text."

  toplevel .t
  pack [button .t.file -text "choose the output directory" -command tk_getOpenFile]

  pack [entry .t.e -textvar $foo]
  pack [button .t.b -text "OK" -command {destroy .t}]
  bind .t <Return> {.t.b invoke}
  focus .t.e
  tkwait window .t

  puts "The variable contains '$foo'"

  puts [exec pwd]
  #gnuplot -c distGNUScript.plt angle_apo_WT.dat
  set test "exec gnuplot -c $path outdist1.dat 0.10 $output"
  eval $test
}

#load a new molecule
proc ::curvespackage::chargement {} {
  variable w
  variable plotColors
  
  #deletes all others molecules present  
  mol delete all 

  #get path file to open
  set newMol [tk_getOpenFile]

  #verifie que le chemin a bien été pris en compte
  if {$newMol != ""} {
    #load the mol 
    mol new $newMol

    #delete the represention in use 
    mol delrep 0 [molinfo 0 get id]
    
    #creates a new representation and adds it 
    mol representation CPK
    mol addrep [molinfo 0 get id]
    
    #Label frame for Helix
    grid [labelframe $w.helix -text "In case you're working on a single double helix of DNA" -bd 2]
    
    #Label frame for the first base 
    grid [labelframe $w.helix.resBase1 -text "Select the first base to match"] -row 0 -columnspan 2
    
    #first base
    grid [ttk::combobox $w.helix.resBase1.resNameBase1] -row 0 -column 0 -columnspan 2
    grid [ttk::combobox $w.helix.resBase1.resIdBase1] -row 2 -column 0 -columnspan 2
    
    grid [label $w.helix.resBase1.lab -text ""] -row 0 -column 2
    
    #first match
    grid [ttk::combobox $w.helix.resBase1.resNameMatch1 -state readonly] -row 0 -column 3 -columnspan 2
    grid [ttk::combobox $w.helix.resBase1.colorB1 -values $plotColors -state readonly] -row 0 -column 5 -columnspan 2 -rowspan 3
    grid [ttk::combobox $w.helix.resBase1.resIdMatch1 -state readonly] -row 2 -column 3 -columnspan 2
    
    #button for calling the matching of bases
    grid [button $w.helix.btnMatch -text "Match these resId to get the facing resId" -command "::curvespackage::matchList"] -row 1 -columnspan 2
    
    #Label frame for the second base
    grid [labelframe $w.helix.resBase2 -text "Select the second base to match (optional)"] -row 2 -columnspan 2
    
    #second base
    grid [ttk::combobox $w.helix.resBase2.resNameBase2] -row 0 -column 0 -columnspan 2
    grid [ttk::combobox $w.helix.resBase2.resIdBase2] -row 2 -column 0 -columnspan 2
    
    grid [label $w.helix.resBase2.lab2 -text ""] -row 0 -column 2
    
    #second match
    grid [ttk::combobox $w.helix.resBase2.resNameMatch2 -state readonly] -row 0 -column 3 -columnspan 2
    grid [ttk::combobox $w.helix.resBase2.colorB2 -values $plotColors -state readonly] -row 0 -column 5 -columnspan 2 -rowspan 3
    grid [ttk::combobox $w.helix.resBase2.resIdMatch2 -state readonly] -row 2 -column 3 -columnspan 2
    
    #plotting buttons
    grid [button $w.helix.distSel -text "Plot the distance variation between these two bases" -command "::curvespackage::plotBases {dist}"] -row 3 -columnspan 2
    grid [button $w.helix.angVal -text "Plot the angle variation between these two bases" -command "::curvespackage::plotBases {angl}"] -row 4 -columnspan 2
    grid [button $w.helix.distVal -text "Plot the distance between the two pairs of bases " -command "::curvespackage::plotBases {4dist}" -state disabled] -row 5 -column 0
    grid [label $w.helix.labelColorPair -text "Plotting color of the pairs"] -row 5 -column 1
    grid [ttk::combobox $w.helix.colorPair -values $plotColors -state disabled] -row 6 -column 1
    grid [button $w.helix.angleVal -text "Plot the angle between the two pairs of bases " -command "::curvespackage::plotBases {4angl}" -state disabled] -row 6 -column 0
  
    # Labelframe for the G-Quadruplex section
    grid [labelframe $w.gQuad -text "In case you're working on G-Quadruplex DNA" -bd 2]
    
    #First quartet
    grid [labelframe $w.gQuad.qua1 -text "First Quartet"]
    
    # First base
    grid [label $w.gQuad.qua1.labelRes1 -text "First base"] -row 0 -column 0
    grid [ttk::combobox $w.gQuad.qua1.resName1] -row 1 -column 0
    grid [ttk::combobox $w.gQuad.qua1.resId1] -row 2 -column 0
    
    # Second base
    grid [label $w.gQuad.qua1.labelRes2 -text "Second base"] -row 0 -column 1
    grid [ttk::combobox $w.gQuad.qua1.resName2] -row 1 -column 1
    grid [ttk::combobox $w.gQuad.qua1.resId2] -row 2 -column 1
    
    # Third base
    grid [label $w.gQuad.qua1.labelRes3 -text "Third base"] -row 3 -column 0
    grid [ttk::combobox $w.gQuad.qua1.resName3] -row 4 -column 0
    grid [ttk::combobox $w.gQuad.qua1.resId3] -row 5 -column 0
    
    # Fourth base
    grid [label $w.gQuad.qua1.labelRes4 -text "Fourth base"] -row 3 -column 1
    grid [ttk::combobox $w.gQuad.qua1.resName4] -row 4 -column 1
    grid [ttk::combobox $w.gQuad.qua1.resId4] -row 5 -column 1
    
    #Second quartet
    grid [labelframe $w.gQuad.qua2 -text "First Quartet"]
    
    # First base
    grid [label $w.gQuad.qua2.labelRes1 -text "First base"] -row 0 -column 0
    grid [ttk::combobox $w.gQuad.qua2.resName1] -row 1 -column 0
    grid [ttk::combobox $w.gQuad.qua2.resId1] -row 2 -column 0
    
    # Second base
    grid [label $w.gQuad.qua2.labelRes2 -text "Second base"] -row 0 -column 1
    grid [ttk::combobox $w.gQuad.qua2.resName2] -row 1 -column 1
    grid [ttk::combobox $w.gQuad.qua2.resId2] -row 2 -column 1
    
    # Third base
    grid [label $w.gQuad.qua2.labelRes3 -text "Third base"] -row 3 -column 0
    grid [ttk::combobox $w.gQuad.qua2.resName3] -row 4 -column 0
    grid [ttk::combobox $w.gQuad.qua2.resId3] -row 5 -column 0
    
    # Fourth base
    grid [label $w.gQuad.qua2.labelRes4 -text "Fourth base"] -row 3 -column 1
    grid [ttk::combobox $w.gQuad.qua2.resName4] -row 4 -column 1
    grid [ttk::combobox $w.gQuad.qua2.resId4] -row 5 -column 1
  
    #Frame selections for the plotting
    grid [labelframe $w.frames -text "Frames to study"]
    grid [label $w.frames.frameLab -text "Choose the starting and ending frames to plot, and the step (leave empty for all frames and a step of 1)"] -row 6 -columnspan 6
    grid [label $w.frames.frameSLab -text "First frame :"] -row 7 -column 0
    grid [entry $w.frames.frameStart -textvar ::curvespackage::frameStart] -row 7 -column 1
    grid [label $w.frames.frameELab -text "Last frame :"] -row 7 -column 2
    grid [entry $w.frames.frameEnd -textvar ::curvespackage::frameEnd] -row 7 -column 3
    grid [label $w.frames.stepLab -text "Step :"] -row 7 -column 4
    grid [entry $w.frames.step -textvar ::curvespackage::step] -row 7 -column 5
  
    pack $w.helix $w.gQuad $w.frames
    
    
    #call the function which create the list of resnames and resids 
    ::curvespackage::listeResname

    #bind the selection of an element in the combobox with a function that puts the list 
    #of resids for the resname
    bind $w.helix.resBase1.resNameBase1 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 0
    }

    bind $w.helix.resBase1.resNameMatch1 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 2
    }

    bind $w.helix.resBase2.resNameBase2 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 1
    }

    bind $w.helix.resBase2.resNameMatch2 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 3
    }

    bind $w.gQuad.qua1.resName1 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 4

    }
    bind $w.gQuad.qua1.resName2 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 5

    }
    bind $w.gQuad.qua1.resName3 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 6

    }
    bind $w.gQuad.qua1.resName4 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 7

    }
    bind $w.gQuad.qua2.resName1 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 8

    }
    bind $w.gQuad.qua2.resName2 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 9

    }
    bind $w.gQuad.qua2.resName3 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 10

    }
    bind $w.gQuad.qua2.resName4 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 11

    }

    #binding with a function that reacts to a selection of the combobox
    #enable the function plot if at least two bases are selected (next one same)
    bind $w.helix.resBase1.resIdBase1 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 0
      ::curvespackage::enableCommand 0
    
    }

    bind $w.helix.resBase2.resIdBase2 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 1
      ::curvespackage::enableCommand 1
    }

    bind $w.gQuad.qua1.resId1 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 2
    }

    bind $w.gQuad.qua1.resId2 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 3
    }

    bind $w.gQuad.qua1.resId3 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 4
    }

    bind $w.gQuad.qua1.resId4 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 5
    }
  }
}

#enable the function call when the two bases are correctly filled
#receive parameter b wich is the id of the dropdown list that called the Function
  #through binding 
proc ::curvespackage::enableCommand {b} {
  variable w

  #determine which dropdown list has called
  switch $b {
    0 {
    # case $w.helix.resBase1.resIdBase1
      #get the opposed resid in the dropdown list 
      set test [$w.helix.resBase2.resIdBase2 get]

      #verify that the selection is not empty 
      if {$test != ""} {

        #set the state to normal which allow the user to call the plotting function
        $w.helix.distVal configure -state normal
        $w.helix.angleVal configure -state normal
        $w.helix.colorPair configure -state readonly
      } else {

        #if the event is a supression the button is disabled
        $w.helix.distVal configure -state disabled
        $w.helix.angleVal configure -state disabled
        $w.helix.colorPair configure -state disabled
      }
    } 
    1 {
    #case $w.helix.resBase2.resIdBase2
      set test [$w.helix.resBase1.resIdBase1 get]
      
      #verify that the selection is not empty 
      if {$test != ""} {

        #set the state to normal which allow the user to call the plotting function
        $w.helix.distVal configure -state normal
        $w.helix.angleVal configure -state normal
        $w.helix.colorPair configure -state readonly
      } else {

        #if the event is a supression the button is disabled
        $w.helix.distVal configure -state disabled
        $w.helix.angleVal configure -state disabled
        $w.helix.colorPair configure -state disabled
      }
    }
    
    default {
      puts "you can't"
    }
  }
}


#Load a new trajectory for the loaded mol
proc ::curvespackage::trajectLoad {} {
  #get the path of the trajectory
  set newTrajectory [tk_getOpenFile]
  
  #verify that the path exist 
  if {$newTrajectory != ""} {
    #add the trajectory for the mol already opened 
    mol addfile $newTrajectory
    pbc unwrap -sel "all not water"
  }
}

#Create the list of resname/resid used for the UI
proc ::curvespackage::listeResname {} {
  #declaration of the global variable used (in order)
    #window for the UI
    #max resid for the DNA contained
    #min resid for the DNA contained
    #resid at the middle of the DNA chain
    #dictonary for the resname/resid 
  variable w
  variable maxDNA
  variable minDNA
  variable mid 
  variable selectList

  #we get all the components of the mol loaded
  set sel [atomselect top "all"]

  #create the dict 
  set selectList [dict create]

  #get the resname/resid couples from the selection
  set names [$sel get {resname resid}]

  #delete the doubles 
  set names [lsort -unique $names]
  
  #list for DNA residues
  set stc [list]
  set stcId [list]

  #list for Guanine
  set stcQuad [list]
  set stcQuadId [list]

  foreach name $names  {
      #get resname and resid
      set rsn [split $name "\ "]
      set rsi [lindex $rsn 1]
      set rsn [lindex $rsn 0]

      #added the couple in the dict with the syntax {{"RESNAME":"id1" "id2"}{"RESNAME2":"id3" "id4"}}
      if {![dict exist $selectList $rsn]} {
        dict set ::curvespackage::selectList $rsn $rsi 
      } else {
        dict lappend ::curvespackage::selectList $rsn $rsi 
      }

      #fill our DNA lists 
      if {[regexp {^DA} $rsn] || [regexp {^DT} $rsn] || [regexp {^DC} $rsn] || [regexp {^DG} $rsn] || [regexp {^RA} $rsn] || [regexp {^RU} $rsn] || [regexp {^RC} $rsn] || [regexp {^RG} $rsn]} {
        lappend stc $rsn
        lappend stcId $rsi
        if {[regexp {^DG} $rsn] || [regexp {^RG} $rsn]} {
          lappend stcQuad $rsn
          lappend stcQuadId $rsi
        }
      }
    }

    #get all the nucleic residues 
    set selNucleic [atomselect top "nucleic"]
    #gets the resid for those residues
    set listNucleic [$selNucleic get resid]
    #calculate the max resid for our DNA
    set maxDNA [tcl::mathfunc::max {*}$listNucleic]
    #calculate the min resid for our DNA
    set minDNA [tcl::mathfunc::min {*}$listNucleic]
    #calculate the resid at the middle of the DNA chain
    set mid [expr ($maxDNA - ($minDNA -1))/2]
    $selNucleic delete
    
    #delete the double 
    set stc [lsort -unique $stc]
    set stcId [lsort -integer $stcId]
    set stcQuad [lsort -unique $stcQuad]
    set stcQuadId [lsort -integer $stcQuadId]    

    #set the values for all the dropdown lists 
      #resname
    $w.helix.resBase1.resNameBase1 configure -values $stc
    $w.helix.resBase1.resNameMatch1 configure -values $stc
    $w.helix.resBase2.resNameBase2 configure -values $stc
    $w.helix.resBase2.resNameMatch2 configure -values $stc
    
    $w.gQuad.qua1.resName1 configure -values $stcQuad
    $w.gQuad.qua1.resName2 configure -values $stcQuad
    $w.gQuad.qua1.resName3 configure -values $stcQuad
    $w.gQuad.qua1.resName4 configure -values $stcQuad
    $w.gQuad.qua2.resName1 configure -values $stcQuad
    $w.gQuad.qua2.resName2 configure -values $stcQuad
    $w.gQuad.qua2.resName3 configure -values $stcQuad
    $w.gQuad.qua2.resName4 configure -values $stcQuad

      #resid
    $w.helix.resBase1.resIdBase1 configure -values $stcId
    $w.helix.resBase2.resIdBase2 configure -values $stcId
    
    $w.gQuad.qua1.resId1 configure -values $stcQuadId
    $w.gQuad.qua1.resId2 configure -values $stcQuadId
    $w.gQuad.qua1.resId3 configure -values $stcQuadId
    $w.gQuad.qua1.resId4 configure -values $stcQuadId
    $w.gQuad.qua2.resId1 configure -values $stcQuadId
    $w.gQuad.qua2.resId2 configure -values $stcQuadId
    $w.gQuad.qua2.resId3 configure -values $stcQuadId
    $w.gQuad.qua2.resId4 configure -values $stcQuadId
    
    $sel delete
}

#set the list of resid which goes with the resname b passed in parameters
proc ::curvespackage::selectWithResname {b} {
  variable w

  #get the resname selected 
  switch $b {
    0 {
      set name [$w.helix.resBase1.resNameBase1 get]
    }
    1 {
      set name [$w.helix.resBase2.resNameBase2 get]
    }
    2 {
      set name [$w.helix.resBase1.resNameMatch1 get]
    }
    3 {
      set name [$w.helix.resBase2.resNameMatch2 get]
    }
    4 {
      set name [$w.gQuad.qua1.resName1 get]
    }
    5 {
      set name [$w.gQuad.qua1.resName2 get]
    }
    6 {
      set name [$w.gQuad.qua1.resName3 get]
    }
    7 {
      set name [$w.gQuad.qua1.resName4 get]
    }
    8 {
      set name [$w.gQuad.qua2.resName1 get]
    }
    9 {
      set name [$w.gQuad.qua2.resName2 get]
    }
    10 {
      set name [$w.gQuad.qua2.resName3 get]
    }
    11 {
      set name [$w.gQuad.qua2.resName4 get]
    }
    default {
      puts "there is a problem, call us!" 
    }
  }
  
  #get the list of resid from the resname if a resname was choosen
  if {$name != ""} {
    set list stc

    dict for {id info} $::curvespackage::selectList {
      if {$id eq $name} {
        set stc [split $info "\ "]
        break 
      }
    }
    #sort the list in ascending order
    set stc [lsort -integer $stc]
    
    #set the values of the associated dropdown list 
    switch $b {
    0 {
      $w.helix.resBase1.resIdBase1 configure -values $stc
    }
    1 {
      $w.helix.resBase2.resIdBase2 configure -values $stc
    }
    2 {
      $w.helix.resBase1.resIdMatch1 configure -values $stc
    }
    3 {
      $w.helix.resBase2.resIdMatch2 configure -values $stc
    }
    4 {
      $w.gQuad.qua1.resId1 configure -values $stc 
    }
    5 {
      $w.gQuad.qua1.resId2 configure -values $stc 
    }
    6 {
      $w.gQuad.qua1.resId3 configure -values $stc 
    }
    7 {
      $w.gQuad.qua1.resId4 configure -values $stc 
    }
    8 {
      $w.gQuad.qua2.resId1 configure -values $stc 
    }
    9 {
      $w.gQuad.qua2.resId2 configure -values $stc 
    }
    10 {
      $w.gQuad.qua2.resId3 configure -values $stc 
    }
    11 {
      $w.gQuad.qua2.resId4 configure -values $stc 
    }
    default {
        puts "there is a problem, call us!" 
      }
    }
  } else {
    #prompts the user to make a choice if the name is empty 
    tk_messageBox -message "Please make a selection"
  } 
}

#set the resname which goes with the resid b passed in parameters
proc ::curvespackage::selectWithResid {b} {
  variable w 
  variable selectList
  
  #get the resid input 
  switch $b {
    0 {
      set stcId [$w.helix.resBase1.resIdBase1 get]
    }
    1 {
      set stcId [$w.helix.resBase2.resIdBase2 get]
    }
    2 {
      set stcId [$w.gQuad.qua1.resId1 get]
    }
    3 {
      set stcId [$w.gQuad.qua1.resId2 get]
    }
    4 {
      set stcId [$w.gQuad.qua1.resId3 get]
    }
    5 {
      set stcId [$w.gQuad.qua1.resId4 get]
    }
    default {
      set stcId ""
    }
  }

  if {$stcId != ""} {
    dict for {id info} $selectList {
      #test if the resname is one from a DNA residue 
      if {[regexp {^DA} $id] || [regexp {^DT} $id] || [regexp {^DC} $id] || [regexp {^DG} $id] || [regexp {^RA} $id] || [regexp {^RU} $id] || [regexp {^RC} $id] || [regexp {^RG} $id]} {
        if {[lsearch -exact $info $stcId] >= 0} {
          switch $b {
            0 {
                $w.helix.resBase1.resNameBase1 set $id
              }
            1 {
                $w.helix.resBase2.resNameBase2 set $id
            }
            2 {
                $w.gQuad.qua1.resName1 set $id 
            }
            3 {
                $w.gQuad.qua1.resName2 set $id 
            }
            4 {
                $w.gQuad.qua1.resName3 set $id 
            }
            5 {
                $w.gQuad.qua1.resName4 set $id 
            }
            default {
              puts "W.T.F ?"
            }
          }
          break
        }
      }
    }
  }
}

#Match the resname and resid for a base
proc ::curvespackage::matchList {} {
   #declaration of the global variable used (in order)
    #dictonary for the resname/resid 
    #window for the UI
    #max resid for the DNA contained
    #min resid for the DNA contained
    #resid at the middle of the DNA chain
  variable selectList
  variable w
  variable maxDNA
  variable minDNA
  variable mid 

  #part with the first and second bases
    #get the name and the resid of the base
  set name1 [$w.helix.resBase1.resNameBase1 get]
  set idSel1 [$w.helix.resBase1.resIdBase1 get]

  #if the resid is inferior to the mid and the resname and resid aren't empty we continue
  if {$idSel1 <= $mid && $name1 != "" && $idSel1 != ""} {
    
    set diff [expr {$mid - [expr {int($idSel1)}]}]
    set match [expr {$mid + 1 + $diff}]
    
    #verifies that the resname is one from a DNA residue
    if {[regexp {^DA} $name1] || [regexp {^DT} $name1] || [regexp {^DC} $name1] || [regexp {^DG} $name1] || [regexp {^RA} $name1] || [regexp {^RU} $name1] || [regexp {^RC} $name1] || [regexp {^RG} $name1]} {
      dict for {id info} $selectList {
        if {[regexp {^DA} $id] || [regexp {^DT} $id] || [regexp {^DC} $id] || [regexp {^DG} $id] || [regexp {^RA} $id] || [regexp {^RU} $id] || [regexp {^RC} $id] || [regexp {^RG} $id]} {
          append stc [split $info "\ "]
          append stc "\ "
        }
      }
    if {[lsearch -exact $stc $match] >= 0 && $match > $mid } {
      $w.helix.resBase1.resIdMatch1 set $match 
        dict for {id info} $selectList {
          if {[lsearch -exact $info $match] >= 0 } {
            if {[regexp {^DA} $name1] && [regexp {^DT} $id] } {
              $w.helix.resBase1.resNameMatch1 set $id
            } elseif {[regexp {^DT} $name1] && [regexp {^DA} $id]} {
                $w.helix.resBase1.resNameMatch1 set $id
            } elseif {[regexp {^DC} $name1] && [regexp {^DG} $id]} {
                $w.helix.resBase1.resNameMatch1 set $id
            } elseif {[regexp {^DG} $name1] && [regexp {^DC} $id]} {
                $w.helix.resBase1.resNameMatch1 set $id
            } elseif {[regexp {^RA} $name1] && [regexp {^RU} $id]} {
                $w.helix.resBase1.resNameMatch1 set $id
            } elseif {[regexp {^RU} $name1] && [regexp {^RA} $id]} {
                $w.helix.resBase1.resNameMatch1 set $id
            } elseif {[regexp {^RC} $name1] && [regexp {^RG} $id]} {
                $w.helix.resBase1.resNameMatch1 set $id
            } elseif {[regexp {^RG} $name1] && [regexp {^RC} $id]} {
                $w.helix.resBase1.resNameMatch1 set $id
            } else {
                $w.helix.resBase1.resIdMatch1 set -1
                $w.helix.resBase1.resNameMatch1 set "NO MATCH"
                tk_messageBox -message "No match, your DNA is damaged"
            }
            break
          }
        }
      } else {
          $w.helix.resBase1.resIdMatch1 set -1
          $w.helix.resBase1.resNameMatch1 set "NO MATCH"
          tk_messageBox -message "No match, your DNA is damaged"
      }
    }
  } 
  #else {
   #   $w.helix.resBase1.resIdMatch1 set -1
    #  $w.helix.resBase1.resNameMatch1 set "NO MATCH"
     # tk_messageBox -message "Select something on the first strand (See mid to determine this)"
    #}

  #part with the third and fourth bases 
   #$w.helix.resNameMatch1 configure -values $stc
    #$w.helix.resNameMatch2 configure -values $stc
    
  set name1 [$w.helix.resBase2.resNameBase2 get]
  set idSel1 [$w.helix.resBase2.resIdBase2 get]

  if {$idSel1 <= $mid && $name1 != "" && $idSel1 != ""} {
    
    set diff [expr {$mid - [expr {int($idSel1)}]}]
    set match [expr {$mid + 1 + $diff}]
    
    #verifies that the resname is one from a DNA residue
    if {[regexp {^DA} $name1] || [regexp {^DT} $name1] || [regexp {^DC} $name1] || [regexp {^DG} $name1] || [regexp {^RA} $name1] || [regexp {^RU} $name1] || [regexp {^RC} $name1] || [regexp {^RG} $name1]} {
      dict for {id info} $selectList {
        if {[regexp {^DA} $id] || [regexp {^DT} $id] || [regexp {^DC} $id] || [regexp {^DG} $id] || [regexp {^RA} $id] || [regexp {^RU} $id] || [regexp {^RC} $id] || [regexp {^RG} $id]} {
          append stc [split $info "\ "]
          append stc "\ "
        }
      }
    if {[lsearch -exact $stc $match] >= 0 && $match > $mid } {
      $w.helix.resBase2.resIdMatch2 set $match 
        dict for {id info} $selectList {
          if {[lsearch -exact $info $match] >= 0 } {
            if {[regexp {^DA} $name1] && [regexp {^DT} $id] } {
              $w.helix.resBase2.resNameMatch2 set $id
            } elseif {[regexp {^DT} $name1] && [regexp {^DA} $id]} {
                $w.helix.resBase2.resNameMatch2 set $id
            } elseif {[regexp {^DC} $name1] && [regexp {^DG} $id]} {
                $w.helix.resBase2.resNameMatch2 set $id
            } elseif {[regexp {^DG} $name1] && [regexp {^DC} $id]} {
                $w.helix.resBase2.resNameMatch2 set $id
            } elseif {[regexp {^RA} $name1] && [regexp {^RU} $id]} {
                $w.helix.resBase1.resNameMatch2 set $id
            } elseif {[regexp {^RU} $name1] && [regexp {^RA} $id]} {
                $w.helix.resBase1.resNameMatch2 set $id
            } elseif {[regexp {^RC} $name1] && [regexp {^RG} $id]} {
                $w.helix.resBase1.resNameMatch2 set $id
            } elseif {[regexp {^RG} $name1] && [regexp {^RC} $id]} {
                $w.helix.resBase1.resNameMatch2 set $id
            } else {
                $w.helix.resBase2.resIdMatch2 set -1
                $w.helix.resBase2.resNameMatch2 set "NO MATCH"
                tk_messageBox -message "No match, your DNA is damaged"
              }
            break
          }
        }
      } else {
          $w.helix.resBase2.resIdMatch2 set -1
          $w.helix.resBase2.resNameMatch2 set "NO MATCH"
          tk_messageBox -message "No match, your DNA is damaged"
      }
    }
  } 
  #else {
   #   $w.helix.resBase2.resIdMatch2 set -1
    #  $w.helix.resBase2.resNameMatch2 set "NO MATCH"
     # tk_messageBox -message "Select something on the first strand (See mid to determine this)"
    #}
}

# Procedure that plots the angle and distance between selected pairs
proc ::curvespackage::plotBases { type {hist 0} } {
  # Variable used to get the window
  variable w
  # Variable used as dictionary to store the different atoms used depending on the pair
  variable atomsDNA
  # Set of variables determining the start, end and step of the plotting
  variable frameStart
  variable frameEnd
  variable step
  
  # Set of variables used to get the resnames and resids of the pairs to plot
  set base1 [$w.helix.resBase1.resNameBase1 get]
  set idBase1 [$w.helix.resBase1.resIdBase1 get]
  set base2 [$w.helix.resBase2.resNameBase2 get]
  set idBase2 [$w.helix.resBase2.resIdBase2 get]
  set match1 [$w.helix.resBase1.resNameMatch1 get]
  set idMatch1 [$w.helix.resBase1.resIdMatch1 get]
  set match2 [$w.helix.resBase2.resNameMatch2 get]
  set idMatch2 [$w.helix.resBase2.resIdMatch2 get]
  # Set of variables used to get the colors of the base plotting
  set color1 [$w.helix.resBase1.colorB1 get]
  set color2 [$w.helix.resBase2.colorB2 get]
  set colorPair [$w.helix.colorPair get]
  
  # If the colors are not set, switching to default coloring
  if { $color1 eq "" } {
    set color1 red
  }
  
  if {$color2 eq "" } {
    set color2 green
  }
  
  if { $colorPair eq "" } {
    set colorPair red
  }
  
  
  set res1 ""
  set res2 ""
  set res3 ""
  set res4 ""
  
  # We check if all the necessary fields for the first pair are filled
  if {$base1 ne "" && $match1 ne "" && $idBase1 ne "" && $idMatch1 ne ""} {
  
    # If the frame parameters are empty, we switch to default values, else we convert their values to integer
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
    
    if { $frameStart == $frameEnd } {
      tk_messageBox -message "Error, only one frame selected, graphing impossible"
      return
    }
    
    # We create the list used for the abscissa of the graphes
    set xlist {}
    for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
      lappend xlist $i
    }
    
    # If what we want is an angle, we create the selections (res) to use on our pair
    if { [regexp {angl$} $type] } {
    
      # We select the atoms according to the base type for the first base of the pair
      if {[regexp {^DA} $base1]} {
          set atoms [split [dict get $atomsDNA {DA}] "\ "]
          set atom1 [lindex $atoms 0]
          set atom2 [lindex $atoms 1]
          set res1 [atomselect top "resid $idBase1 and name $atom1"]
          set res2 [atomselect top "resid $idBase1 and name $atom2"]
        } elseif {[regexp {^DT} $base1]} {
          set atoms [split [dict get $atomsDNA {DT}] "\ "]
          set atom1 [lindex $atoms 0]
          set atom2 [lindex $atoms 1]
          set res1 [atomselect top "resid $idBase1 and name $atom1"]
          set res2 [atomselect top "resid $idBase1 and name $atom2"]
        } elseif {[regexp {^DC} $base1]} {
          set atoms [split [dict get $atomsDNA {DC}] "\ "]
          set atom1 [lindex $atoms 0]
          set atom2 [lindex $atoms 1]
          set res1 [atomselect top "resid $idBase1 and name $atom1"]
          set res2 [atomselect top "resid $idBase1 and name $atom2"]
        } elseif {[regexp {^DG} $base1]} {
          set atoms [split [dict get $atomsDNA {DG}] "\ "]
          set atom1 [lindex $atoms 0]
          set atom2 [lindex $atoms 1]
          set res1 [atomselect top "resid $idBase1 and name $atom1"]
          set res2 [atomselect top "resid $idBase1 and name $atom2"]
        }
	
	# We select the atoms according to the base type for the second base of the pair
        if {[regexp {^DA} $match1]} {
          set atoms [split [dict get $atomsDNA {DA}] "\ "]
          set atom1 [lindex $atoms 0]
          set atom2 [lindex $atoms 1]
          set res3 [atomselect top "resid $idMatch1 and name $atom1"]
          set res4 [atomselect top "resid $idMatch1 and name $atom2"]
        } elseif {[regexp {^DT} $match1]} {
          set atoms [split [dict get $atomsDNA {DT}] "\ "]
          set atom1 [lindex $atoms 0]
          set atom2 [lindex $atoms 1]
          set res3 [atomselect top "resid $idMatch1 and name $atom1"]
          set res4 [atomselect top "resid $idMatch1 and name $atom2"]
        } elseif {[regexp {^DC} $match1]} {
          set atoms [split [dict get $atomsDNA {DC}] "\ "]
          set atom1 [lindex $atoms 0]
          set atom2 [lindex $atoms 1]
          set res3 [atomselect top "resid $idMatch1 and name $atom1"]
          set res4 [atomselect top "resid $idMatch1 and name $atom2"]
        } elseif {[regexp {^DG} $match1]} {
          set atoms [split [dict get $atomsDNA {DG}] "\ "]
          set atom1 [lindex $atoms 0]
          set atom2 [lindex $atoms 1]
          set res3 [atomselect top "resid $idMatch1 and name $atom1"]
          set res4 [atomselect top "resid $idMatch1 and name $atom2"]
        }

    # If what we want is a distance, we create the selections (res) to use on our pair
    } elseif { [regexp {dist$} $type] } {
      set res1 [atomselect top "resid $idBase1"]
      set res2 [atomselect top "resid $idMatch1"]
    }
    
    # If there's nothing in the fields of the second pair, graphing only the first one
    if {$base2 eq ""} {
      
      # Case if we want to plot an angle
      if { $type eq "angl" } {
      
        # Calling computeFrames on our selection for an angle between the two bases of the selected pair
        set listP [::curvespackage::computeFrames "angB" $res1 $res2 $res3 $res4]
	
	if { $hist != 0 } {
	  return $listP
	}
	
	# Deleting all our selections
  $res1 delete
	$res2 delete
	$res3 delete
	$res4 delete
	
	# Creating and plotting the multiplot for the calculated list
	set plothandle [multiplot -x $xlist -y $listP \
                      -xlabel "Frame" -ylabel "Angle" -title "Angle between the bases" \
                      -lines -linewidth 1 -linecolor $color1 \
                      -marker none -legend "Angle" -plot];
      
      # Case if we want to plot a distance
      } elseif { $type eq "dist" } {
      
        # Calling computeFrames on our selection for a distance between the two bases of the selected pair
        set listP [::curvespackage::computeFrames "dist" $res1 $res2]
	
	if { $hist != 0 } {
	  return $listP
	}
	
	# Deleting all our selections
	$res1 delete
	$res2 delete
	
	# Creating and plotting the multiplot for the calculated list
	set plothandle [multiplot -x $xlist -y $listP \
                      -xlabel "Frame" -ylabel "Distance" -title "Distance between the bases" \
                      -lines -linewidth 1 -linecolor $color1 \
                      -marker none -legend "Distance" -plot];
      }
    
    # In case the fields are not empty for the second pair
    } else {
      set res5 ""
      set res6 ""
      set res7 ""
      set res8 ""
      
      # Checking if the fields for the second pair are all set
      if {$base2 ne "" && $match2 ne "" && $idBase2 ne "" && $idMatch2 ne ""} {
      
        # If what we want is an angle, we create the selections (res) to use on our pair
        if {[regexp {angl$} $type]} {
	  
	  # We select the atoms according to the base type for the first base of the pair
	  if {[regexp {^DA} $base2]} {
            set atoms [split [dict get $atomsDNA {DA}] "\ "]
            set atom1 [lindex $atoms 0]
            set atom2 [lindex $atoms 1]
            set res5 [atomselect top "resid $idBase2 and name $atom1"]
            set res6 [atomselect top "resid $idBase2 and name $atom2"]
          } elseif {[regexp {^DT} $base2]} {
            set atoms [split [dict get $atomsDNA {DT}] "\ "]
            set atom1 [lindex $atoms 0]
            set atom2 [lindex $atoms 1]
            set res5 [atomselect top "resid $idBase2 and name $atom1"]
            set res6 [atomselect top "resid $idBase2 and name $atom2"]
          } elseif {[regexp {^DC} $base2]} {
            set atoms [split [dict get $atomsDNA {DC}] "\ "]
            set atom1 [lindex $atoms 0]
            set atom2 [lindex $atoms 1]
            set res5 [atomselect top "resid $idBase2 and name $atom1"]
            set res6 [atomselect top "resid $idBase2 and name $atom2"]
          } elseif {[regexp {^DG} $base2]} {
            set atoms [split [dict get $atomsDNA {DG}] "\ "]
            puts "DG : $atoms"
            set atom1 [lindex $atoms 0]
            set atom2 [lindex $atoms 1]
            set res5 [atomselect top "resid $idBase2 and name $atom1"]
            set res6 [atomselect top "resid $idBase2 and name $atom2"]
          }
	  
	  # We select the atoms according to the base type for the second base of the pair
          if {[regexp {^DA} $match2]} {
            set atoms [split [dict get $atomsDNA {DA}] "\ "]
            set atom1 [lindex $atoms 0]
            set atom2 [lindex $atoms 1]
            set res7 [atomselect top "resid $idMatch2 and name $atom1"]
            set res8 [atomselect top "resid $idMatch2 and name $atom2"]
          } elseif {[regexp {^DT} $match2]} {
            set atoms [split [dict get $atomsDNA {DT}] "\ "]
            set atom1 [lindex $atoms 0]
            set atom2 [lindex $atoms 1]
            set res7 [atomselect top "resid $idMatch2 and name $atom1"]
            set res8 [atomselect top "resid $idMatch2 and name $atom2"]
          } elseif {[regexp {^DC} $match2]} {
            set atoms [split [dict get $atomsDNA {DC}] "\ "]
            set atom1 [lindex $atoms 0]
            set atom2 [lindex $atoms 1]
            set res7 [atomselect top "resid $idMatch2 and name $atom1"]
            set res8 [atomselect top "resid $idMatch2 and name $atom2"]
          } elseif {[regexp {^DG} $match2]} {
            set atoms [split [dict get $atomsDNA {DG}] "\ "]
            set atom1 [lindex $atoms 0]
            set atom2 [lindex $atoms 1]
            set res7 [atomselect top "resid $idMatch2 and name $atom1"]
            set res8 [atomselect top "resid $idMatch2 and name $atom2"]
          }
	  
	# If what we want is a distance, we create the selections (res) to use on our pair
	} elseif {[regexp {dist$} $type]} {
	  set res3 [atomselect top "resid $idBase2"]
          set res4 [atomselect top "resid $idMatch2"]
	}
	
	# Case if we want to plot an angle
	if { $type eq "angl" } {
	  
	  # Calling computeFrames on our selection for an angle between the two bases of the first selected pair
	  set listP1 [::curvespackage::computeFrames "angB" $res1 $res2 $res3 $res4]
	  
	  # Calling computeFrames on our selection for an angle between the two bases of the second selected pair
	  set listP2 [::curvespackage::computeFrames "angB" $res5 $res6 $res7 $res8]
	  
	  # Deleting all our selections
          $res1 delete
	  $res2 delete
	  $res3 delete
	  $res4 delete
	  $res5 delete
	  $res6 delete
	  $res7 delete
	  $res8 delete
	  
	  # Creating the multiplot for the first calculated list
	  set plothandle [multiplot -x $xlist -y $listP1 \
                      -xlabel "Frame" -ylabel "Angle" -title "Angle between the bases" \
                      -lines -linewidth 1 -linecolor $color1 \
                      -marker none -legend "Angle between the first bases"];
	  
	  # Adding the second calculated list and plotting
	  $plothandle add $xlist $listP2 -lines -linewidth 1 -linecolor $color2 -marker none -legend "Angle between the second bases" -plot
	  
	# Case if we want to plot a distance
	} elseif { $type eq "dist" } {
	
	  # Calling computeFrames on our selection for a distance between the two bases of the first selected pair
	  set listP1 [::curvespackage::computeFrames "dist" $res1 $res2]
	  
	  # Calling computeFrames on our selection for a distance between the two bases of the second selected pair
	  set listP2 [::curvespackage::computeFrames "dist" $res3 $res4]
	  
	  # Deleting all our selections
	  $res1 delete
	  $res2 delete
	  $res3 delete
	  $res4 delete
	  
	  # Creating the multiplot for the first calculated list
	  set plothandle [multiplot -x $xlist -y $listP1 \
                      -xlabel "Frame" -ylabel "Distance" -title "Distance between the bases" \
                      -lines -linewidth 1 -linecolor $color1 \
                      -marker none -legend "Distance between the first bases"];

	  # Adding the second calculated list and plotting
	  $plothandle add $xlist $listP2 -lines -linewidth 1 -linecolor $color2 -marker none -legend "Distance between the second bases" -plot
	  
	# Case if we want to plot the angle difference between two pairs
	} elseif { $type eq "4angl" } {
	
	  # Calling computeFrames on our selection for an angle between the two selected pairs
	  set listP [::curvespackage::computeFrames "ang4" $res1 $res2 $res3 $res4 $res5 $res6 $res7 $res8]
	  
	  # Deleting all our selections
	  $res1 delete
	  $res2 delete
	  $res3 delete
	  $res4 delete
	  $res5 delete
	  $res6 delete
	  $res7 delete
	  $res8 delete
	  
	  # Creating and plotting the multiplot for the calculated list
	  set plothandle [multiplot -x $xlist -y $listP \
                      -xlabel "Frame" -ylabel "Angle" -title "Angle between the sets of bases" \
                      -lines -linewidth 1 -linecolor $colorPair \
                      -marker none -legend "Angle between the sets of bases" -plot];
		      
	# Case if we want to plot the distance between two pairs
	} elseif { $type eq "4dist" } {
	
	  # Calling computeFrames on our selection for a distance between the two selected pairs
	  set listP [::curvespackage::computeFrames "dist4" $res1 $res2 $res3 $res4]
	  
	  # Deleting all our selections
	  $res1 delete
	  $res2 delete
	  $res3 delete
	  $res4 delete
	  
	  # Creating and plotting the multiplot for the calculated list
	  set plothandle [multiplot -x $xlist -y $listP \
                      -xlabel "Frame" -ylabel "Distance" -title "Distance between the sets of bases" \
                      -lines -linewidth 1 -linecolor $colorPair \
                      -marker none -legend "Distance between the sets of bases" -plot];
	}
      
      # If the fields for the second pair are not properly filled
      } else {
        tk_messageBox -message "Error, some fields are empty"
      }
    }
    
  # If the fields for the first pair are not properly filled
  } else {
    tk_messageBox -message "Error, some fields are empty"
  }
}

# Procedure that calculates a predifined formula for a certain selection for each selected frame
proc ::curvespackage::computeFrames { type res1 res2 {res3 0} {res4 0} {res5 0} {res6 0} {res7 0} {res8 0} } {
  
  # Set of variables determining the start, end and step of the calculations
  variable frameStart
  variable frameEnd
  variable step
  
  # If the frame parameters are empty, we switch to default values, else we convert their values to integer
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
  
  # We check which type of calculus we are supposed to do
  switch $type {
    "dist" {
    # Case in which we want to calculate a distance between two selections
    
      # Creating the list that will be returned
      set lDist {}
      
      # For each selected frame
      for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
        
	# Updating the selections for the frame i
	$res1 frame $i
	$res2 frame $i
	$res1 update
	$res2 update
	
	# Calculating the center of mass of each selection
	set com1 [measure center $res1]
        set com2 [measure center $res2]
	
	# Calculating the distance between each center of mass and adding it to the list
	lappend lDist [vecdist $com1 $com2]
      }
      
      # Returns the list
      return $lDist
    }
    "angB" {
    # Case in which we calculate the angle between two bases using two predifined atoms from each base
    
      # Creating the list that will be returned
      set lAngl {}
      
      #For each selected frame from the loaded trajectory
      for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
        
	# Updating the selections for the frame i
        $res1 frame $i
	$res2 frame $i
	$res3 frame $i
	$res4 frame $i
	$res1 update
	$res2 update
	$res3 update
	$res4 update
	
	# Get the x, y and z positions as vectors of the two atoms used in the first base
	set xyzA1 [split [string range [$res1 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res2 get {x y z}] 1 end-1] "\ "]
	
	# Calculating the vector between the two atoms of the first base
	set vect1 [vecsub $xyzA1 $xyzA2]
	
	# Get the x, y and z positions as vectors of the two atoms used in the second base
	set xyzA1 [split [string range [$res3 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res4 get {x y z}] 1 end-1] "\ "]
	
	# Calculating the vector between the two atoms of the second base
	set vect2 [vecsub $xyzA1 $xyzA2]
	
	# Calculating the length of the two vectors calculated previously
	set lenV1 [veclength $vect1]
	set lenV2 [veclength $vect2]
	
	# Calculating the scalar dot product between the two vectors
	set dotprod [vecdot $vect1 $vect2]
	
	# Correcting the scalar dot product by dividing it by the multiplication of the lengths of the 2 vectors
	set dotprodcor [vecnorm $dotprod]
	
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
    "ang4" {
    # Case in which we calculate the angle between two pairs of bases using two predefined atoms from each base
    
      # Creating the list that will be returned
      set lAngl {}
      
      # For each selected frame from the loaded trajectory 
      for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
        
	# Updating the selections for the frame i
        $res1 frame $i
	$res2 frame $i
	$res3 frame $i
	$res4 frame $i
	$res5 frame $i
	$res6 frame $i
	$res7 frame $i
	$res8 frame $i
	$res1 update
	$res2 update
	$res3 update
	$res4 update
	$res5 update
	$res6 update
	$res7 update
	$res8 update
	
	# Get the x, y and z positions as vectors of the two atoms used in the first base of the first pair
	set xyzA1 [split [string range [$res1 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res2 get {x y z}] 1 end-1] "\ "]
	
	# Calculating the vector between the two atoms of the first base of the first pair
	set vectB1 [vecsub $xyzA1 $xyzA2]
	
	# Get the x, y and z positions as vectors of the two atoms used in the second base of the first pair
	set xyzA1 [split [string range [$res3 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res4 get {x y z}] 1 end-1] "\ "]
	
	# Calculating the vector between the two atoms of the second base of the first pair
	set vectB2 [vecsub $xyzA1 $xyzA2]
	
	# Calculating the vector that represents the first pair
	set vect1 [vecsub $vectB2 $vectB1]
	
	# Get the x, y and z positions as vectors of the two atoms used in the first base of the second pair
	set xyzA1 [split [string range [$res5 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res6 get {x y z}] 1 end-1] "\ "]
	
	# Calculating the vector between the two atoms of the first base of the second pair
	set vectB1 [vecsub $xyzA1 $xyzA2]
	
	# Get the x, y and z positions as vectors of the two atoms used in the second base of the second pair
	set xyzA1 [split [string range [$res7 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res8 get {x y z}] 1 end-1] "\ "]
	
	# Calculating the vector between the two atoms of the second base of the second pair
	set vectB2 [vecsub $xyzA1 $xyzA2]
	
	# Calculating the vector that represents the second pair
	set vect2 [vecsub $vectB2 $vectB1]
	
	# Calculating the lengths of the pair vectors
	set lenV1 [veclength $vect1]
	set lenV2 [veclength $vect2]
	
	# Calculating the scalar dot product between the two vectors
	set dotprod [vecdot $vect1 $vect2]
	
	# Correcting the scalar dot product by dividing it by the multiplication of the lengths of the 2 vectors
	set dotprodcor [expr $dotprod / ($lenV1 * $lenV2)]
	
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
    "dist4" {
    # Case in which we calculate the distance between two pairs of bases using two predefined atoms from each base
    
      # Creating the list that will be returned
      set lDist {}
      
      # For each selected frame from the loaded trajectory
      for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
        
	# Updating the selections for each frame
        $res1 frame $i
	$res2 frame $i
	$res3 frame $i
	$res4 frame $i
	$res1 update
	$res2 update
	$res3 update
	$res4 update
	
	# Calculating the center of mass of the first base of the first pair
	set center1 [measure center $res1]
	
	# Calculating the center of mass of the second base of the first base
	set center2 [measure center $res2]
	
	# Creating a vector between these two centers of mass
	set vect1 [vecsub $center2 $center1]
	
	# Calculating the center of mass of the first base of the second pair
	set center1 [measure center $res3]
	
	# Calculating the center of mass of the second base of the second pair
	set center2 [measure center $res4]
	
	# Creating a vector between these two centers of mass
	set vect2 [vecsub $center2 $center1]
	
	# Calculating the distance between the two vectors and adding it to the returned list
	lappend lDist [vecdist $vect1 $vect2]
      }
      
      # Returns the list
      return $lDist
    }
    default {
      puts "Nothing here... yet."
    }
  }
}

proc curvespackage_tk {} {
  ::curvespackage::packageui
}
