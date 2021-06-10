##
## CurvesPackage 0.1
##
## A VMD plugin used to plot data for double helix and G-Quadruplex DNA
##
## Authors: Emilia Goeury-Mayo ; Guillaume Schmit
##
## Id: CurvesPackage.tcl, v1.0 2021/06/10 16:03
##
##analyse et visualisation

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

  variable nameAtomsGQuad "name N1 C2 N2 N3 C4 C5 C6 O6 N7 C8 N9"
  variable quaNum
  variable numQuartets 2
  variable mainQua
  variable secQua

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
  #$w.menubar.edit.menu add command -label "test exec ls" -command ::curvespackage::testLs
  #$w.menubar.edit.menu add command -label "GNUplot" -command ::curvespackage::gnuPlotTest
  $w.menubar.file config -width 5
  $w.menubar.edit config -width 5
  grid $w.menubar.file -row 0 -column 0 -sticky w
  grid $w.menubar.edit -row 0 -column 1 -sticky e
  
  pack $w.menubar
  
  return $w
}


proc ::curvespackage::HistogramsAtoms {b atm1 atm2 nbAtm1 nbAtm2} {
  if {![file exist "Ouput_Dat"] } {
     exec mkdir "Ouput_Dat"
  }

  #case 0 - distance variation between two atom of a base (base 1 / base 2)
  #case 1 - angle variation between two atom of a base (base 1 / base 2)
  
  #case 2 - distance variation between two atom of a base (base 3 / base 4)
  #case 3 - angle variation between two atom of a base (base 3 / base 4)

  #case 4 - distance variation between the two pair of bases (b1b2 / b3b4)
  #case 5 - angle variation between the two pair of bases (b1b2 / b3b4)

  switch $b {
    0 {
      set name "Ouput_Dat/distVar_$atm1(nbAtm1)_$atm2(nbAtm2).dat"
      set file [open $name w]
      set listP [::curvespackage::plotBases dist 1]
      for { set i 0 } { $i <= [llength $listP] } { incr i } {
        puts $file [lindex $listP $i]
      }
      close $file
      ::curvespackage::gnuPlotting $name "distVar_$atm1(nbAtm1)_$atm2(nbAtm2)"
    }
    1 {
      set name "Ouput_Dat/outangl1.dat"
      set file [open $name w]
      set listP [::curvespackage::plotBases angl 1]
      for { set i 0 } { $i <= [llength $listP] } { incr i } {
        puts $file [lindex $listP $i]
      }
      close $file
      ::curvespackage::gnuPlotting $name "outangl1"
    }
    2 {

    }
    3 {}
    4 {}
    5 {}
  }
}

proc ::curvespackage::gnuPlotting {nameDat name} {
  set path [pwd]
  append path "/" 
  append path $nameDat 
  
  set savePath [pwd]

  variable CURVESPACKAGE_PATH
  cd $CURVESPACKAGE_PATH
  cd "GNU_Script"
    
  set rounding [::curvespackage::callRoundingChooser]
  set test "exec gnuplot -c distGNUScript.plt $rounding $savePath $path $name"
                            #ARG0             #ARG1     #ARG2     #ARG3 #ARG4
  #eval $test
  if [catch eval $test] {
    puts ""
  }
  cd $savePath
}

proc ::curvespackage::callRoundingChooser {} {
  set w [toplevel .[clock seconds]]
  wm resizable $w 0 0
  wm title $w "Value request"
  label  $w.l -text "Please choose a rounding"
  entry  $w.e -textvar $w -bg white
  bind $w.e <Return> {set done 1}
  button $w.ok     -text OK     -command {set done 1}
  button $w.c      -text Clear  -command "set $w {}"
  button $w.cancel -text Cancel -command "set $w {}; set done 1"
  grid $w.l  -    -        -sticky news
  grid $w.e  -    -        -sticky news
  grid $w.ok $w.c $w.cancel
  vwait done
  destroy $w
  set ::$w
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
    grid [labelframe $w.gQuad.qua1 -text "First Quartet"] -row 0 -column 0
    
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
    grid [labelframe $w.gQuad.qua2 -text "Second Quartet"] -row 0 -column 1
    
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
    
    # Calculating the guanines' planarity compared to the quartet's perpendicular axis
    grid [labelframe $w.gQuad.oneQua] -row 1 -columnspan 2
    grid [button $w.gQuad.oneQua.planGuaAxis -text "Planarity of the guanines compared to the quartets' perpendicular axis" -command "curvespackage::guaPlanForQuaAxis"] -row 0 -column 0
    grid [labelframe $w.gQuad.oneQua.selGua -text "Which quartet's guanines ?"] -row 0 -column 1 -rowspan 5
    grid [entry $w.gQuad.oneQua.selGua.quaSel -textvar ::curvespackage::quaNum]
    
    # Calculating the guanines' planarity between themselves
    grid [button $w.gQuad.oneQua.planGua -text "Planarity of the guanins compared to each other" -command "curvespackage::guaPlan"] -row 1 -column 0
    
    # Calculating the quartet bending lengthwise
    grid [button $w.gQuad.oneQua.lenBendB -text "Lengthwise quartet bending" -command "curvespackage::lenBend"] -row 2 -column 0
    
    # Calculating the angle between the guanines' axis
    grid [button $w.gQuad.oneQua.guaAngles -text "Angles between the guanins' axis of the selected quartet" -command "curvespackage::guaAxisAngle"] -row 3 -column 0
    
    # Calculating the distance between the COMs of O6 and N9 squares on a quartet
    grid [button $w.gQuad.oneQua.quaCom -text "Distance between CoM(O6) and CoM(N9)" -command "curvespackage::comO6N9"] -row 4 -column 0
    
    # Calculating the twist angles
    grid [labelframe $w.gQuad.noQua] -row 2 -columnspan 2
    grid [button $w.gQuad.noQua.twist -text "Twist angles" -command "curvespackage::twistAngle"] -row 0
    
    # Calculating the gyration radii
    grid [button $w.gQuad.noQua.gyr -text "Gyration radii" -command "curvespackage::gyrationRadii"] -row 1
    
    # Calculating the distance between the CoM of guanines and [the CoM of their quartet ; the CoM of the 2 quartets (simulating the emplacement of the metallic ion)]
    grid [labelframe $w.gQuad.twoQua] -row 3 -columnspan 2
    grid [button $w.gQuad.twoQua.comDistancesGua -text "Distances between guanines and multiple centers of mass" -command "curvespackage::guaCoMDistances"] -row 0 -column 0
    grid [labelframe $w.gQuad.twoQua.selQua -text "From which quartets ?"] -row 0 -column 1 -rowspan 2
    grid [label $w.gQuad.twoQua.selQua.mainLab -text "Main quartet"] -row 0 -column 0
    grid [entry $w.gQuad.twoQua.selQua.main -textvar ::curvespackage::mainQua] -row 0 -column 1
    grid [label $w.gQuad.twoQua.selQua.secLab -text "Other quartet (CoM calculated between the main and this one)"] -row 1 -column 0
    grid [entry $w.gQuad.twoQua.selQua.sec -textvar ::curvespackage::secQua] -row 1 -column 1
    
    # Calculating the distance between the CoM of the quartets
    grid [button $w.gQuad.twoQua.comDistances -text "Distance between the CoM of the quartets" -command "curvespackage::comQua"] -row 1 -column 0

    #Frame selections for the plotting
    grid [labelframe $w.frames -text "Frames to study"]
    grid [label $w.frames.frameLab -text "Choose the starting and ending frames to plot, and the step (leave empty for all frames and a step of 1)"] -row 6 -columnspan 6
    grid [label $w.frames.frameSLab -text "First frame :"] -row 7 -column 0
    grid [entry $w.frames.frameStart -textvar ::curvespackage::frameStart] -row 7 -column 1
    grid [label $w.frames.frameELab -text "Last frame :"] -row 7 -column 2
    grid [entry $w.frames.frameEnd -textvar ::curvespackage::frameEnd] -row 7 -column 3
    grid [label $w.frames.stepLab -text "Step :"] -row 7 -column 4
    grid [entry $w.frames.step -textvar ::curvespackage::step] -row 7 -column 5
    
    checkbutton $w.histogram -text "Histogram" -command "::curvespackage::Histograms {0}"
    
    pack $w.helix $w.gQuad $w.frames $w.histogram
    
    
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
    
    bind $w.gQuad.qua2.resId1 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 6
    }

    bind $w.gQuad.qua2.resId2 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 7
    }

    bind $w.gQuad.qua2.resId3 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 8
    }

    bind $w.gQuad.qua2.resId4 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 9
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
    6 {
      set stcId [$w.gQuad.qua2.resId1 get]
    }
    7 {
      set stcId [$w.gQuad.qua2.resId2 get]
    }
    8 {
      set stcId [$w.gQuad.qua2.resId3 get]
    }
    9 {
      set stcId [$w.gQuad.qua2.resId4 get]
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
            6 {
                $w.gQuad.qua2.resName1 set $id 
            }
            7 {
                $w.gQuad.qua2.resName2 set $id 
            }
            8 {
                $w.gQuad.qua2.resName3 set $id 
            }
            9 {
                $w.gQuad.qua2.resName4 set $id 
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
		      
        if { $hist != 0 } {
	  return $listP
	}
      
      # Case if we want to plot a distance
      } elseif { $type eq "dist" } {
      
        # Calling computeFrames on our selection for a distance between the two bases of the selected pair
        set listP [::curvespackage::computeFrames "dist" $res1 $res2]
	
	# Deleting all our selections
	$res1 delete
	$res2 delete
	
	# Creating and plotting the multiplot for the calculated list
	set plothandle [multiplot -x $xlist -y $listP \
                      -xlabel "Frame" -ylabel "Distance" -title "Distance between the bases" \
                      -lines -linewidth 1 -linecolor $color1 \
                      -marker none -legend "Distance" -plot];
	
	if { $hist != 0 } {
	  return $listP
	}
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

proc curvespackage::guaPlanForQuaAxis {} {
  global M_PI
  variable w
  variable nameAtomsGQuad
  variable quaNum
  variable numQuartets
  
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
  
  if { $frameStart == $frameEnd } {
    tk_messageBox -message "Error, only one frame selected, graphing impossible"
    return
  }
  
  # We create the list used for the abscissa of the graphes
  set xlist {}
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    lappend xlist $i
  }
  
  if {$quaNum eq ""} {
    set quaNum 1
  } else {
    set quaNum [expr int($quaNum)]
  }
  
  for { set i 1 } { $i <= $numQuartets } { incr i } {
    foreach j {1 2 3 4} {
      set r[set i][set j] [$w.gQuad.qua[set i].resId$j get]
    }
  }
  
  for { set i 1 } { $i <= $numQuartets } {incr i } {
    set selq$i [atomselect top "resid [set r[set i]1] [set r[set i]2] [set r[set i]3] [set r[set i]4] and $nameAtomsGQuad"]
  }
  
  foreach i {1 2 3 4} {
    #puts "resid \[set r[set quaNum][set i]\] and name N9"
    set selx[set i]N9 [atomselect top "resid [set r[set quaNum][set i]] and name N9"]
    set selx[set i]N2 [atomselect top "resid [set r[set quaNum][set i]] and name N2"]
    set selx[set i]O6 [atomselect top "resid [set r[set quaNum][set i]] and name O6"]

    set listP$i {}

    for { set j $frameStart } { $j < $frameEnd } { set j [expr {$j + $step}] } {
      $selq1 frame $j
      $selq2 frame $j
      $selq1 update
      $selq2 update
	  
      [set selx[set i]N9] frame $j
      [set selx[set i]N2] frame $j
      [set selx[set i]O6] frame $j
      [set selx[set i]N9] update
      [set selx[set i]N2] update
      [set selx[set i]O6] update
	  
      set q1 [measure center $selq1 weight mass]
      set q2 [measure center $selq2 weight mass]
	  
      set axis [vecnorm [vecsub $q1 $q2]]
	
      set rxxN9 [measure center [set selx[set i]N9] weight mass]
      set rxxN2 [measure center [set selx[set i]N2] weight mass]
      set rxxO6 [measure center [set selx[set i]O6] weight mass]
	  
      set vectN9N2 [vecsub $rxxN9 $rxxN2]
      set vectN9O6 [vecsub $rxxN9 $rxxO6]
	  
      set vectAngle [vecnorm [veccross $vectN9N2 $vectN9O6]]
	  
      set angleRad [vecdot $vectAngle $axis]
	  
      set angle [expr acos($angleRad)/$M_PI * 180]
      
      lappend listP[set i] $angle
    }
	
    [set selx[set i]N9] delete
    [set selx[set i]N2] delete
    [set selx[set i]O6] delete
    
    set COMMENT {
    set plothandle [multiplot -x $xlist -y [set listP$i] \
                      -xlabel "Frame" -ylabel "Angle" -title "Planarity of the guanin $i of the quartet $quaNum" \
                      -lines -linewidth 1 -linecolor blue \
                      -marker none -legend "Planarity of the guanin $i" -plot];
    }
    
  }
  for { set i 1 } { $i <= $numQuartets } {incr i } {
    [set selq$i] delete
  }
  
  # Creating the multiplot for the first calculated list
  set plothandle [multiplot -x $xlist -y $listP1 \
                    -xlabel "Frame" -ylabel "Angle" -title "Planarity of the guanins of the quartet $quaNum compared to the quartets' axis" \
                    -lines -linewidth 1 -linecolor blue \
                    -marker none -legend "Planarity of the first guanin"];

  # Adding the second calculated list
  $plothandle add $xlist $listP2 -lines -linewidth 1 -linecolor red -marker none -legend "Planarity of the second guanin"
  $plothandle add $xlist $listP3 -lines -linewidth 1 -linecolor green -marker none -legend "Planarity of the third guanin"
  $plothandle add $xlist $listP4 -lines -linewidth 1 -linecolor black -marker none -legend "Planarity of the fourth guanin" -plot
  
}

proc curvespackage::guaPlan {} {
  global M_PI
  variable w
  variable quaNum
  variable numQuartets
  
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
  
  if { $frameStart == $frameEnd } {
    tk_messageBox -message "Error, only one frame selected, graphing impossible"
    return
  }
  
  # We create the list used for the abscissa of the graphes
  set xlist {}
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    lappend xlist $i
  }
  
  if {$quaNum eq ""} {
    set quaNum 1
  } else {
    set quaNum [expr int($quaNum)]
  }
  
  foreach i {1 2 3 4} {
    set r[set quaNum][set i] [$w.gQuad.qua[set quaNum].resId$i get]
  }
  
  foreach i {1 2 3} {
    
    set selx[set i]N9 [atomselect top "resid [set r[set quaNum][set i]] and name N9"]
    set selx[set i]N2 [atomselect top "resid [set r[set quaNum][set i]] and name N2"]
    set selx[set i]O6 [atomselect top "resid [set r[set quaNum][set i]] and name O6"]
    
    for { set j [expr $i + 1] } { $j < 5 } { incr j } {
    
      set selx[set j]N9 [atomselect top "resid [set r[set quaNum][set j]] and name N9"]
      set selx[set j]N2 [atomselect top "resid [set r[set quaNum][set j]] and name N2"]
      set selx[set j]O6 [atomselect top "resid [set r[set quaNum][set j]] and name O6"]
      
      set listP[set i]$j {}
      
      for { set k $frameStart } { $k < $frameEnd } { set k [expr {$k + $step}] } {
        [set selx[set i]N9] frame $k
	[set selx[set i]N2] frame $k
	[set selx[set i]O6] frame $k
	
	[set selx[set j]N9] frame $k
	[set selx[set j]N2] frame $k
	[set selx[set j]O6] frame $k
	
        [set selx[set i]N9] update
	[set selx[set i]N2] update
	[set selx[set i]O6] update
	
	[set selx[set j]N9] update
	[set selx[set j]N2] update
	[set selx[set j]O6] update
	
	set rx[set i]N9 [measure center [set selx[set i]N9] weight mass]
	set rx[set i]N2 [measure center [set selx[set i]N2] weight mass]
	set rx[set i]O6 [measure center [set selx[set i]O6] weight mass]
	
	set rx[set j]N9 [measure center [set selx[set j]N9] weight mass]
	set rx[set j]N2 [measure center [set selx[set j]N2] weight mass]
	set rx[set j]O6 [measure center [set selx[set j]O6] weight mass]
	
	set vect[set i]N9N2 [vecsub [set rx[set i]N9] [set rx[set i]N2]]
        set vect[set i]N9O6 [vecsub [set rx[set i]N9] [set rx[set i]O6]]
	
	set vect[set j]N9N2 [vecsub [set rx[set j]N9] [set rx[set j]N2]]
        set vect[set j]N9O6 [vecsub [set rx[set j]N9] [set rx[set j]O6]]
	
	set vectAngle$i [vecnorm [veccross [set vect[set i]N9N2] [set vect[set i]N9O6]]]
	
	set vectAngle$j [vecnorm [veccross [set vect[set j]N9N2] [set vect[set j]N9O6]]]
	
	set angleRad [vecdot [set vectAngle$i] [set vectAngle$j]]
	
	set angle [expr acos($angleRad)/$M_PI * 180]
	
	lappend listP[set i]$j $angle
      }
      
      #puts "listP[set i]$j : [set listP[set i]$j"
      
      [set selx[set j]N9] delete
      [set selx[set j]N2] delete
      [set selx[set j]O6] delete
      
    }
    
    [set selx[set i]N9] delete
    [set selx[set i]N2] delete
    [set selx[set i]O6] delete
    
  }
  
  # Creating the multiplot for the first calculated list
  set plothandle [multiplot -x $xlist -y $listP12 \
                    -xlabel "Frame" -ylabel "Angle" -title "Planarity of the guanins of the quartet $quaNum compared to each other" \
                    -lines -linewidth 1 -linecolor blue \
                    -marker none -legend "Planarity between the guanin 1 & 2"];

  # Adding the other calculated lists
  $plothandle add $xlist $listP13 -lines -linewidth 1 -linecolor red -marker none -legend "Planarity between the guanin 1 & 3"
  $plothandle add $xlist $listP14 -lines -linewidth 1 -linecolor green -marker none -legend "Planarity between the guanin 1 & 4"
  $plothandle add $xlist $listP23 -lines -linewidth 1 -linecolor magenta -marker none -legend "Planarity between the guanin 2 & 3"
  $plothandle add $xlist $listP24 -lines -linewidth 1 -linecolor orange -marker none -legend "Planarity between the guanin 2 & 4"
  $plothandle add $xlist $listP34 -lines -linewidth 1 -linecolor black -marker none -legend "Planarity between the guanin 3 & 4" -plot
  
}

proc curvespackage::lenBend {} {
  global M_PI
  variable w
  variable quaNum
  variable nameAtomsGQuad
  
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
  
  if { $frameStart == $frameEnd } {
    tk_messageBox -message "Error, only one frame selected, graphing impossible"
    return
  }
  
  # We create the list used for the abscissa of the graphes
  set xlist {}
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    lappend xlist $i
  }
  
  if {$quaNum eq ""} {
    set quaNum 1
  } else {
    set quaNum [expr int($quaNum)]
  }
  
  foreach i {1 2 3 4} {
    set r[set quaNum][set i] [$w.gQuad.qua[set quaNum].resId$i get]
  }
  
  foreach i { 0 1 } {
  
    set ip [expr $i + 1]
    foreach j { 1 2 3 } {
      set listP[set j]$ip {}
    }
    
    foreach j { 0 1 2 3 } {
      set guaX [expr {(($j + $i) % 4) + 1}]
      
      set id1 [expr {$j + 1}]
      set id2 [expr { ($id1) % 4 + 1 }]
      
      set selrx[set id1][set id2] [atomselect top "resid [set r[set quaNum]$guaX] and $nameAtomsGQuad"]
      set selrx[set id1][set id2]N1 [atomselect top "resid [set r[set quaNum]$guaX] and name N1"]
      
      if { $j == 0 || $j == 2 } {
        set selx[set id1][set id2]C8 [atomselect top "resid [set r[set quaNum]$guaX] and name C8"]
	#puts "C8 -> $guaX , indice $id1$id2 ; i = $i"
      } else {
        set selx[set id1][set id2]C2 [atomselect top "resid [set r[set quaNum]$guaX] and name C2"]
        set selx[set id1][set id2]N9 [atomselect top "resid [set r[set quaNum]$guaX] and name N9"]
	#puts "C2,N9 -> $guaX , indice $id1$id2 ; i = $i"
      }
      
      #puts $id1$id2
    }
    
    for { set j $frameStart } { $j < $frameEnd } { set j [expr {$j + $step}] } {
      foreach k { 0 1 2 3 } {
        set id1 [expr {$k + 1}]
        set id2 [expr { ($id1) % 4 + 1 }]
	
	[set selrx[set id1][set id2]] frame $j
	[set selrx[set id1][set id2]N1] frame $j
	[set selrx[set id1][set id2]] update
	[set selrx[set id1][set id2]N1] update
	
	set rx[set id1][set id2] [measure center [set selrx[set id1][set id2]] weight mass]
	set rx[set id1][set id2]N1 [measure center [set selrx[set id1][set id2]] weight mass]
	
	if { $k == 0 || $k == 2 } {
	  [set selx[set id1][set id2]C8] frame $j
	  [set selx[set id1][set id2]C8] update
	  
	  set rx[set id1][set id2]C8 [measure center [set selx[set id1][set id2]C8] weight mass]
	  
	  #puts rx[set id1][set id2]C8
	  
	} else {
	  [set selx[set id1][set id2]C2] frame $j
          [set selx[set id1][set id2]N9] frame $j
	  [set selx[set id1][set id2]C2] update
          [set selx[set id1][set id2]N9] update
	  
	  set rx[set id1][set id2]C2 [measure center [set selx[set id1][set id2]C2] weight mass]
	  set rx[set id1][set id2]N9 [measure center [set selx[set id1][set id2]N9] weight mass]
	  
	  #puts "rx[set id1][set id2]C2 + N9"
	}
      }
      
      
      set vect12_23_C8C2 [vecsub $rx12C8 $rx23C2]
      set vect12_23_C8N9 [vecsub $rx12C8 $rx23N9]
      
      set vectAngl12_23_C8C2_C8N9 [vecnorm [veccross $vect12_23_C8C2 $vect12_23_C8N9]]
      
      set vect34_41_C8C2 [vecsub $rx34C8 $rx41C2]
      set vect34_41_C8N9 [vecsub $rx34C8 $rx41N9]
      
      set vectAngl34_41_C8C2_C8N9 [vecnorm [veccross $vect34_41_C8C2 $vect34_41_C8N9]]
      
      # Angle between 12 & 34 then 23 & 41
      set angl1223_3441_rad [vecdot $vectAngl12_23_C8C2_C8N9 $vectAngl34_41_C8C2_C8N9]
      
      set angl1223_3441 [expr acos($angl1223_3441_rad) / $M_PI * 180]
      
      lappend listP1$ip $angl1223_3441
      
      #puts listP1$ip
      #puts listP2$ip
      #puts listP3$ip
      
      
      set vect23_12 [vecsub $rx23 $rx12]
      set vect23_34 [vecsub $rx23 $rx34]
      
      set vectAngl23_1234 [vecnorm [veccross $vect23_12 $vect23_34]]
      
      set vect41_34 [vecsub $rx41 $rx34]
      set vect41_12 [vecsub $rx41 $rx12]
      
      set vectAngl41_3412 [vecnorm [veccross $vect41_34 $vect41_12]]
      
      # Angle between [ Angle between ( 23 -> 12 ) & ( 23 -> 34 ) ] & [ Angle between ( 41 -> 34 ) & ( 41 -> 12 ) ]
      set angl123234_341412_rad [vecdot $vectAngl23_1234 $vectAngl41_3412]
      
      set angl123234_341412 [expr acos($angl123234_341412_rad) / $M_PI * 180]
      
      lappend listP2$ip $angl123234_341412
      
      
      set vect23_12_N1 [vecsub $rx23N1 $rx12N1]
      set vect23_34_N1 [vecsub $rx23N1 $rx34N1]
      
      set vectAngl23_1234_N1 [vecnorm [veccross $vect23_12_N1 $vect23_34_N1]]
      
      set vect41_34_N1 [vecsub $rx41N1 $rx34N1]
      set vect41_12_N1 [vecsub $rx41N1 $rx12N1]
      
      set vectAngl41_3412_N1 [vecnorm [veccross $vect41_34_N1 $vect41_12_N1]]
      
      # Angle between [ Angle between ( 23 -> 12 ) & ( 23 -> 34 ) ] & [ Angle between ( 41 -> 34 ) & ( 41 -> 12 ) ] for the atom N1
      set angl123234_341412_N1_rad [vecdot $vectAngl23_1234_N1 $vectAngl41_3412_N1]
      
      set angl123234_341412_N1 [expr acos($angl123234_341412_N1_rad)  / $M_PI * 180]
      
      lappend listP3$ip $angl123234_341412_N1
    }
    
    foreach j { 0 1 2 3 } {
      set id1 [expr {$j + 1}]
      set id2 [expr { ($id1) % 4 + 1 }]
	
      [set selrx[set id1][set id2]] delete
      [set selrx[set id1][set id2]N1] delete
	
      if { $j == 0 || $j == 2 } {
	[set selx[set id1][set id2]C8] delete
      } else {
	[set selx[set id1][set id2]C2] delete
        [set selx[set id1][set id2]N9] delete
      }
    }
  }
  # Creating the multiplot for the first calculated list
  set plothandle [multiplot -x $xlist -y $listP11 \
                    -xlabel "Frame" -ylabel "Angle" -title "Lengthwise quartet bending" \
                    -lines -linewidth 1 -linecolor blue \
                    -marker none -legend "\u03b8(Triad(g1,g2) ; Triad(g3,g4))"];

  # Adding the other calculated lists
  $plothandle add $xlist $listP12 -lines -linewidth 1 -linecolor red -marker none -legend "\u03b8(Triad(g2,g3) ; Triad(g4,g1))"
  $plothandle add $xlist $listP21 -lines -linewidth 1 -linecolor green -marker none -legend "\u03b8((->(g2,g1).->(g2,g3)) ; (->(g4,g3).->(g4,g1)))"
  $plothandle add $xlist $listP22 -lines -linewidth 1 -linecolor magenta -marker none -legend "\u03b8((->(g3,g2).->(g3,g4)) ; (->(g1,g4).->(g1,g2)))"
  $plothandle add $xlist $listP31 -lines -linewidth 1 -linecolor orange -marker none -legend "\u03b8((->(g2,g1).->(g2,g3)) ; (->(g4,g3).->(g4,g1))) using N1"
  $plothandle add $xlist $listP32 -lines -linewidth 1 -linecolor black -marker none -legend "\u03b8((->(g3,g2).->(g3,g4)) ; (->(g1,g4).->(g1,g2))) using N1" -plot
}

proc curvespackage::twistAngle {} {
  global M_PI
  variable w
  variable numQuartets
  variable plotColors
  
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
  
  if { $frameStart == $frameEnd } {
    tk_messageBox -message "Error, only one frame selected, graphing impossible"
    return
  }
  
  # We create the list used for the abscissa of the graphes
  set xlist {}
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    lappend xlist $i
  }
  
  for { set i 1 } { $i <= $numQuartets } { incr i } {
    foreach j {1 2 3 4} {
      set r[set i][set j] [$w.gQuad.qua[set i].resId$j get]
      #puts r[set i][set j]
    }
  }
  
  for { set i 1 } { $i < $numQuartets } { incr i } {
    for { set j [expr $i + 1] } { $j <= $numQuartets } { incr j } {
      foreach k { 1 2 3 4 } {
        set sel[set i][set k]N9 [atomselect top "resid [set r[set i]$k] and name N9"]
	set sel[set j][set k]N9 [atomselect top "resid [set r[set j]$k] and name N9"]
      }
      set listP[set i]$j {}
      for { set k $frameStart } { $k < $frameEnd } { set k [expr {$k + $step}] } {
        foreach l { 1 2 3 4 } {
	  set id1 $l
	  set id2 [expr $id1 % 4 + 1]
	  [set sel[set i][set id1]N9] frame $k
	  [set sel[set i][set id2]N9] frame $k
	  [set sel[set j][set id1]N9] frame $k
	  [set sel[set j][set id2]N9] frame $k
	  [set sel[set i][set id1]N9] update
	  [set sel[set i][set id2]N9] update
	  [set sel[set j][set id1]N9] update
	  [set sel[set j][set id2]N9] update
	  
	  set r[set i]$id1 [measure center [set sel[set i][set id1]N9] weight mass]
	  set r[set i]$id2 [measure center [set sel[set i][set id2]N9] weight mass]
	  set r[set j]$id1 [measure center [set sel[set j][set id1]N9] weight mass]
	  set r[set j]$id2 [measure center [set sel[set j][set id2]N9] weight mass]
	  
	  set vect[set i][set id1]$id2 [vecnorm [vecsub [set r[set i]$id1] [set r[set i]$id2]]]
	  set vect[set j][set id1]$id2 [vecnorm [vecsub [set r[set j]$id1] [set r[set j]$id2]]]
	  
	  set angle[set i][set j][set id1][set id2]_rad [vecdot [set vect[set i][set id1]$id2] [set vect[set j][set id1]$id2]]
	  if {[set angle[set i][set j][set id1][set id2]_rad] > 1.0} {
	    set angle[set i][set j][set id1][set id2]_rad 1.0
	  }
	  if {[set angle[set i][set j][set id1][set id2]_rad] < -1.0} {
	    set angle[set i][set j][set id1][set id2]_rad -1.0
	  }
	  set angle[set i][set j][set id1][set id2] [expr acos([set angle[set i][set j][set id1][set id2]_rad]) / $M_PI * 180]
	}
	
	set twist [vecscale 0.25 [vecadd [set angle[set i][set j]12] [set angle[set i][set j]23] [set angle[set i][set j]34] [set angle[set i][set j]41]]]
	
	lappend listP[set i]$j $twist
      }
      foreach k { 1 2 3 4 } {
	[set sel[set i][set k]N9] delete
	[set sel[set j][set k]N9] delete
      }
    }
  }
  # Creating the multiplot for the first calculated list
  set plothandle [multiplot -x $xlist -y $listP12 \
                    -xlabel "Frame" -ylabel "Angle" -title "Twist Angles" \
                    -lines -linewidth 1 -linecolor black \
                    -marker none -legend "Twist angle between the quartets 1 & 2" -plot];
  for { set i 1 } { $i <= $numQuartets } { incr i } {
    for { set j [expr $i + 1] } { $j <= $numQuartets } { incr j } {
      if { $i != 1 && $j != 2 } {
        set plotColor [lindex $plotColors [expr $i + $j - 1]]
        $plothandle add $xlist [set listP[set i]$j] -lines -linewidth 1 -linecolor plotColor -marker none -legend "Twist angle between the quartets $i and $j" -replot
       }
    }
  }
  #$plothandle -plot
}

proc curvespackage::guaCoMDistances {} {
  global M_PI
  variable w
  variable nameAtomsGQuad
  variable mainQua
  variable secQua
  
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
  
  if { $frameStart == $frameEnd } {
    tk_messageBox -message "Error, only one frame selected, graphing impossible"
    return
  }
  
  if {$mainQua eq ""} {
    set mainQua 1
  } else {
    set mainQua [expr int($mainQua)]
  }
  if {$secQua eq ""} {
    set secQua 2
  } else {
    set secQua [expr int($secQua)]
  }
  
  # We create the list used for the abscissa of the graphes
  set xlist {}
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    lappend xlist $i
  }
  
  foreach j { 1 2 3 4 } {
    set r[set mainQua][set j] [$w.gQuad.qua[set mainQua].resId$j get]
    set r[set secQua][set j] [$w.gQuad.qua[set secQua].resId$j get]
  }
  
  foreach i { 1 2 3 4 } {
    set selr[set mainQua]$i [atomselect top "resid [set r[set mainQua]$i] and $nameAtomsGQuad"]
    set listPr[set mainQua]$j {}
    set listP[set mainQua]r[set mainQua]$j {}
  }
  
  set selq [atomselect top "resid [set r[set mainQua]1] [set r[set mainQua]2] [set r[set mainQua]3] [set r[set mainQua]4] [set r[set secQua]1] [set r[set secQua]2] [set r[set secQua]3] [set r[set secQua]4] and $nameAtomsGQuad"]
  
  set selq$mainQua [atomselect top "resid [set r[set mainQua]1] [set r[set mainQua]2] [set r[set mainQua]3] [set r[set mainQua]4] and $nameAtomsGQuad"]
  
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    
    $selq frame $i
    [set selq$mainQua] frame $i
    $selq update
    [set selq$mainQua] update
    
    set q [measure center $selq weight mass]
    set q$mainQua [measure center [set selq$mainQua] weight mass]
    
    foreach j { 1 2 3 4 } {
      
      [set selr[set mainQua]$j] frame $i
      [set selr[set mainQua]$j] update
      
      set r[set mainQua]$j [measure center [set selr[set mainQua]$j] weight mass]
      set qr[set mainQua]$j [veclength [vecsub $q [set r[set mainQua]$j]]]
      set q[set mainQua]r[set mainQua]$j [veclength [vecsub [set q$mainQua] [set r[set mainQua]$j]]]
      
      lappend listPr[set mainQua]$j [set qr[set mainQua]$j]
      lappend listP[set mainQua]r[set mainQua]$j [set q[set mainQua]r[set mainQua]$j]
    }
  }
  
  foreach i { 1 2 3 4 } {
    [set selr[set mainQua]$i] delete
  }
  
  $selq delete
  [set selq$mainQua] delete
  
  # Creating the multiplot for the first calculated list
  set plothandle [multiplot -x $xlist -y $listPr11 \
                    -xlabel "Frame" -ylabel "Distance" -title "Distances between guanins CoM and \[the CoM of their quartet ; the CoM of quartets $mainQua and $secQua\]" \
                    -lines -linewidth 1 -linecolor blue \
                    -marker none -legend "Distance between G1 and CoM(Q$mainQua;Q$secQua)"];

  # Adding the other calculated lists
  $plothandle add $xlist $listPr12 -lines -linewidth 1 -linecolor red -marker none -legend "Distance between G2 and CoM(Q$mainQua;Q$secQua)"
  $plothandle add $xlist $listPr13 -lines -linewidth 1 -linecolor green -marker none -legend "Distance between G3 and CoM(Q$mainQua;Q$secQua)"
  $plothandle add $xlist $listPr14 -lines -linewidth 1 -linecolor magenta -marker none -legend "Distance between G4 and CoM(Q$mainQua;Q$secQua)"
  $plothandle add $xlist [set listP[set mainQua]r11] -lines -linewidth 1 -linecolor orange -marker none -legend "Distance between G1 and CoM(Q$mainQua)"
  $plothandle add $xlist [set listP[set mainQua]r12] -lines -linewidth 1 -linecolor OliveDrab2 -marker none -legend "Distance between G2 and CoM(Q$mainQua)"
  $plothandle add $xlist [set listP[set mainQua]r13] -lines -linewidth 1 -linecolor cyan -marker none -legend "Distance between G3 and CoM(Q$mainQua)"
  $plothandle add $xlist [set listP[set mainQua]r14] -lines -linewidth 1 -linecolor maroon -marker none -legend "Distance between G4 and CoM(Q$mainQua)" -plot
}

proc curvespackage::comQua {} {
  global M_PI
  variable w
  variable nameAtomsGQuad
  variable mainQua
  variable secQua
  
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
  
  if { $frameStart == $frameEnd } {
    tk_messageBox -message "Error, only one frame selected, graphing impossible"
    return
  }
  
  if {$mainQua eq ""} {
    set mainQua 1
  } else {
    set mainQua [expr int($mainQua)]
  }
  if {$secQua eq ""} {
    set secQua 2
  } else {
    set secQua [expr int($secQua)]
  }
  
  # We create the list used for the abscissa of the graphes
  set xlist {}
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    lappend xlist $i
  }

  foreach i { 1 2 3 4 } {
    set r[set mainQua]$i [$w.gQuad.qua[set mainQua].resId$i get]
    set r[set secQua]$i [$w.gQuad.qua[set secQua].resId$i get]
  }
  
  set selq$mainQua [atomselect top "resid [set r[set mainQua]1] [set r[set mainQua]2] [set r[set mainQua]3] [set r[set mainQua]4] and $nameAtomsGQuad"]
  set selq$secQua [atomselect top "resid [set r[set secQua]1] [set r[set secQua]2] [set r[set secQua]3] [set r[set secQua]4] and $nameAtomsGQuad"]
  
  set listP {}
  
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    [set selq$mainQua] frame $i
    [set selq$secQua] frame $i
    [set selq$mainQua] update
    [set selq$secQua] update
    
    set q$mainQua [measure center [set selq$mainQua] weight mass]
    set q$secQua [measure center [set selq$secQua] weight mass]
    
    set dist [veclength [vecsub [set q$mainQua] [set q$secQua]]]
    
    lappend listP $dist
  }
  
  [set selq$mainQua] delete
  [set selq$secQua] delete
  
  # Creating the multiplot for the first calculated list
  set plothandle [multiplot -x $xlist -y $listP \
                    -xlabel "Frame" -ylabel "Distance" -title "Distance between CoM(Q$mainQua) and CoM(Q$secQua)" \
                    -lines -linewidth 1 -linecolor blue \
                    -marker none -legend "Distance between CoM(Q$mainQua) and CoM(Q$secQua)" -plot];
}

proc curvespackage::gyrationRadii {} {
  variable w
  variable nameAtomsGQuad
  variable numQuartets
  variable plotColors
  
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
  
  if { $frameStart == $frameEnd } {
    tk_messageBox -message "Error, only one frame selected, graphing impossible"
    return
  }
  
  # We create the list used for the abscissa of the graphes
  set xlist {}
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    lappend xlist $i
  }
  
  set residQ "resid "
  
  for { set i 1 } { $i <= $numQuartets } { incr i } {
    foreach j { 1 2 3 4 } {
      set r[set i]$j [$w.gQuad.qua[set i].resId$j get]
      append residQ "[set r[set i]$j] "
    }
    set selq$i [atomselect top "resid [set r[set i]1] [set r[set i]2] [set r[set i]3] [set r[set i]4] and $nameAtomsGQuad"]
  }
  
  set selq [atomselect top $residQ]
  
  set listP {}
  
  for { set i 1 } { $i <= $numQuartets } { incr i } {
    set listP$i {}
  }
  
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
  
    $selq frame $i
    $selq update
    
    set q [measure rgyr $selq]
    
    lappend listP $q
    
    for { set j 1 } { $j <= $numQuartets } { incr j } {
      
      [set selq$j] frame $i
      [set selq$j] update
      
      set q$j [measure rgyr [set selq$j]]
      
      lappend listP$j [set q$j]
    }
  }
  
  $selq delete
  for { set i 1 } { $i <= $numQuartets } { incr i } {
    [set selq$i] delete
  }
  
  # Creating the multiplot for the first calculated list
  set plothandle [multiplot -x $xlist -y $listP \
                    -xlabel "Frame" -ylabel "Radii" -title "Gyration Radii " \
                    -lines -linewidth 1 -linecolor black \
                    -marker none -legend "Gyration radii of all the quartets" -plot];
  
  for { set i 1 } { $i <= $numQuartets } { incr i } {
    set plotColor [lindex $plotColors [expr $i]]
    $plothandle add $xlist [set listP$i] -lines -linewidth 1 -linecolor $plotColor -marker none -legend "Gyration radii of the quartet $i" -plot
  }
  
}

proc curvespackage::guaAxisAngle {} {
  global M_PI
  variable w
  variable quaNum
  variable nameAtomsGQuad
  
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
  
  if { $frameStart == $frameEnd } {
    tk_messageBox -message "Error, only one frame selected, graphing impossible"
    return
  }
  
  if {$quaNum eq ""} {
    set quaNum 1
  } else {
    set quaNum [expr int($quaNum)]
  }
  
  # We create the list used for the abscissa of the graphes
  set xlist {}
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    lappend xlist $i
  }
  
  foreach i { 1 2 3 4 } {
    set rx$i [$w.gQuad.qua[set quaNum].resId$i get]
    set selrx[set i]C8 [atomselect top "resid [set rx$i] and name C8"]
    set selrx[set i]C4C5 [atomselect top "resid [set rx$i] and name C4 C5"]
    for { set j [expr $i + 1] } { $j <= 4 } { incr j } {
      set listP[set i]$j {}
    }
  }
  
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    
    foreach j { 1 2 3 4 } {
      [set selrx[set j]C8] frame $i
      [set selrx[set j]C4C5] frame $i
      [set selrx[set j]C8] update
      [set selrx[set j]C4C5] update
      
      set rx[set j]C8 [measure center [set selrx[set j]C8] weight mass]
      set rx[set j]C4C5 [measure center [set selrx[set j]C4C5] weight mass]
      
      set vectrx$j [vecnorm [vecsub [set rx[set j]C8] [set rx[set j]C4C5]]]
      
    }
    
    foreach j { 1 2 3 4 } {
      for { set k [expr $j + 1] } { $k <= 4 } { incr k } {
	
	set rx[set j]rx[set k]C4C5_C8_rad [vecdot [set vectrx$j] [set vectrx$k]]
	
	set rx[set j]rx[set k]C4C5_C8 [expr acos([set rx[set j]rx[set k]C4C5_C8_rad]) / $M_PI * 180]
	
	lappend listP[set j]$k [set rx[set j]rx[set k]C4C5_C8]
      }
    }
  }
  
  foreach i { 1 2 3 4 } {
    [set selrx[set i]C8] delete
    [set selrx[set i]C4C5] delete
  }
  
  # Creating the multiplot for the first calculated list
  set plothandle [multiplot -x $xlist -y $listP12 \
                    -xlabel "Frame" -ylabel "Angle" -title "Angle between between the guanines' axes on the quartet $quaNum" \
                    -lines -linewidth 1 -linecolor blue \
                    -marker none -legend "Angle between the guanines 1 & 2"];

  # Adding the other calculated lists
  $plothandle add $xlist $listP13 -lines -linewidth 1 -linecolor red -marker none -legend "Angle between the guanines 1 & 3"
  $plothandle add $xlist $listP14 -lines -linewidth 1 -linecolor green -marker none -legend "Angle between the guanines 1 & 4"
  $plothandle add $xlist $listP23 -lines -linewidth 1 -linecolor magenta -marker none -legend "Angle between the guanines 2 & 3"
  $plothandle add $xlist $listP24 -lines -linewidth 1 -linecolor orange -marker none -legend "Angle between the guanines 2 & 4"
  $plothandle add $xlist $listP34 -lines -linewidth 1 -linecolor OliveDrab2 -marker none -legend "Angle between the guanines 3 & 4" -plot
  
}

proc curvespackage::comO6N9 {} {
  global M_PI
  variable w
  variable quaNum
  variable nameAtomsGQuad
  
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
  
  if { $frameStart == $frameEnd } {
    tk_messageBox -message "Error, only one frame selected, graphing impossible"
    return
  }
  
  if {$quaNum eq ""} {
    set quaNum 1
  } else {
    set quaNum [expr int($quaNum)]
  }
  
  # We create the list used for the abscissa of the graphes
  set xlist {}
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
    lappend xlist $i
  }
  
  foreach i { 1 2 3 4 } {
    set rx$i [$w.gQuad.qua[set quaNum].resId$i get]
  }
  
  set selO6 [atomselect top "resid $rx1 $rx2 $rx3 $rx4 and name O6"]
  set selN9 [atomselect top "resid $rx1 $rx2 $rx3 $rx4 and name N9"]
  
  set listP {}
  
  for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
  
    $selO6 frame $i
    $selN9 frame $i
    $selO6 update
    $selN9 update
    
    set O6 [measure center $selO6 weight mass]
    set N9 [measure center $selN9 weight mass]
    
    set vectN9O6 [vecsub $N9 $O6]
    
    set dist [veclength $vectN9O6]
    
    lappend listP $dist
  
  }
  
  $selO6 delete
  $selN9 delete
  
  set plothandle [multiplot -x $xlist -y $listP \
                    -xlabel "Frame" -ylabel "Distance" -title "Distance between the CoM of the O6 \"square\" and the CoM of the N9 \"square\" of the quartet $quaNum" \
                    -lines -linewidth 1 -linecolor blue \
                    -marker none -legend "Distance between the CoMs" -plot];
  
}

proc curvespackage_tk {} {
  ::curvespackage::packageui
}
