package provide CurvesPackage 0.1
package require Tk
package require multiplot

set CURVESPACKAGE_PATH $env(CURVESPACKAGE_PATH)
set PACKAGE_PATH "$CURVESPACKAGE_PATH"
set PACKAGEPATH "$CURVESPACKAGE_PATH"

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

  $w.menubar.file.menu add command -label "Hello" -command  ::curvespackage::hello
  $w.menubar.file.menu add command -label "Hello but in python" -command ::curvespackage::hellopy 
  $w.menubar.file.menu add command -label "Quit" -command "destroy $w"
  $w.menubar.edit.menu add command -label "Load new Mol" -command ::curvespackage::chargement
  $w.menubar.edit.menu add command -label "Load new trajectory" -command ::curvespackage::trajectLoad
  $w.menubar.file config -width 5
  $w.menubar.edit config -width 5
  grid $w.menubar.file -row 0 -column 0 -sticky w
  grid $w.menubar.edit -row 0 -column 1 -sticky e
  
  
  grid [labelframe $w.func  -text "Function plotting" -bd 2] -columnspan 6
  grid [radiobutton $w.func.sinBtn -text "sin(x)" -variable func -value "sin" -command "::curvespackage::setselected {sin}"] -row 0 -column 0
  grid [radiobutton $w.func.cosBtn -text "cos(x)" -variable func -value "cos" -command "::curvespackage::setselected {cos}"] -row 0 -column 1
  grid [radiobutton $w.func.tanBtn -text "tan(x)" -variable func -value "tan" -command "::curvespackage::setselected {tan}"] -row 0 -column 2
  #grid [radiobutton $w.func.other -text "other (var is x)" -variable func -value "other" -command "::curvespackage::setselected {other} $w"] -row 1 -column 0
  #grid [entry $w.func.otherFunc -textvar ::curvespackage::e] -row 1 -column 1
  grid [button $w.func.selectBtn -text "Plot this function" -command "::curvespackage::plotting {sin}"] -row 2 -columnspan 3
  $w.func.sinBtn select
  
  pack $w.menubar $w.func
  
  return $w
}

proc ::curvespackage::chargement {} {
  variable w
  
  #supprime 
  mol delete all 

  #on recup?e le fichier ?charger
  set newMol [tk_getOpenFile]

  #verifie que le chemin a bien été pris en compte
  if {$newMol != ""} {
    #chargement
    mol new $newMol

    #supprime la representation actuelle 
    mol delrep 0 [molinfo 0 get id]
    
    #crée une nouvelle representation et l'ajoute
    mol representation CPK
    mol addrep [molinfo 0 get id]

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
    
    #grid for the selection of two bases
    grid [labelframe $w.distG.resSel -text "Select the resnames and resids to be selected" -bd 2] -row 5 -columnspan 6
    
    #-command "::curvespackage::selectWithResname 0"
    #-command "::curvespackage::selectWithResname 2"
    # -command "::curvespackage::selectWithResname 1"
    #-command "::curvespackage::selectWithResname 3"
    grid [labelframe $w.distG.resSel.resBase1 -text "Select the first base to match"] -row 0
    
    #first base
    grid [ttk::combobox $w.distG.resSel.resBase1.resNameBase1] -row 0 -column 0 -columnspan 2
    #grid [button $w.distG.resSel.resBase1.getName1 -text "Use this resname"] -row 1 -column 0 -columnspan 2 
    grid [ttk::combobox $w.distG.resSel.resBase1.resIdBase1] -row 2 -column 0 -columnspan 2
    
    grid [label $w.distG.resSel.resBase1.lab -text ""] -row 0 -column 2
    
    #first match
    grid [ttk::combobox $w.distG.resSel.resBase1.resNameMatch1] -row 0 -column 3 -columnspan 2
    grid [ttk::combobox $w.distG.resSel.resBase1.colorB1] -row 0 -column 5 -columnspan 2 -rowspan 3
    grid [ttk::combobox $w.distG.resSel.resBase1.resIdMatch1] -row 2 -column 3 -columnspan 2
    
    #button for calling the matching of bases
    grid [button $w.distG.resSel.btnMatch -text "Match these resId to get the facing resId" -command "::curvespackage::matchList"] -row 1
    
    grid [labelframe $w.distG.resSel.resBase2 -text "Select the second base to match (optional)"] -row 2
    
    #second base
    grid [ttk::combobox $w.distG.resSel.resBase2.resNameBase2] -row 0 -column 0 -columnspan 2
    #grid [button $w.distG.resSel.resBase2.getName2 -text "Use this resname"] -row 1 -column 0 -columnspan 2
    grid [ttk::combobox $w.distG.resSel.resBase2.resIdBase2] -row 2 -column 0 -columnspan 2
    
    grid [label $w.distG.resSel.resBase2.lab2 -text ""] -row 0 -column 2
    
    #second match
    grid [ttk::combobox $w.distG.resSel.resBase2.resNameMatch2] -row 0 -column 3 -columnspan 2
    grid [ttk::combobox $w.distG.resSel.resBase2.colorB2] -row 0 -column 5 -columnspan 2 -rowspan 3
    grid [ttk::combobox $w.distG.resSel.resBase2.resIdMatch2] -row 2 -column 3 -columnspan 2
    
    grid [button $w.distG.resSel.distSel -text "Plot the distance variation between these two bases" -command "::curvespackage::plotBases {dist}"] -row 3
    grid [button $w.distG.resSel.angVal -text "Plot the angle variation between these two bases" -command "::curvespackage::plotBases {angl}"] -row 4
    grid [button $w.distG.resSel.distVal -text "Plot the distance between the two sets of bases " -command "::curvespackage::plotBases {4dist}" -state disabled] -row 5
    grid [button $w.distG.resSel.angleVal -text "Plot the angle between the two sets of bases " -command "::curvespackage::plotBases {4angl}" -state disabled] -row 6
  
    grid [label $w.distG.frameLab -text "Choose the starting and ending frames to plot, and the step (leave empty for all frames and a step of 1)"] -row 6 -columnspan 6
    grid [label $w.distG.frameSLab -text "First frame :"] -row 7 -column 0
    grid [entry $w.distG.frameStart -textvar ::curvespackage::frameStart] -row 7 -column 1
    grid [label $w.distG.frameELab -text "Last frame :"] -row 7 -column 2
    grid [entry $w.distG.frameEnd -textvar ::curvespackage::frameEnd] -row 7 -column 3
    grid [label $w.distG.stepLab -text "Step :"] -row 7 -column 4
    grid [entry $w.distG.step -textvar ::curvespackage::step] -row 7 -column 5
  
    pack $w.dist2 $w.distG

    #appelle la creation de la liste des resnames disponibles 
    ::curvespackage::listeResname

    #bind the selection of an element in the combobox with a function that puts the list 
    #of resids for the resname (repeat for the next three)
    bind $w.distG.resSel.resBase1.resNameBase1 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 0
    }

    bind $w.distG.resSel.resBase1.resNameMatch1 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 2
    }

    bind $w.distG.resSel.resBase2.resNameBase2 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 1
    }

    bind $w.distG.resSel.resBase2.resNameMatch2 <<ComboboxSelected>> {
      ::curvespackage::selectWithResname 3
    }

    #binding with a function that reacts to a selection of the combobox
    #enable the function plot if at least two bases are selected
    bind $w.distG.resSel.resBase1.resIdBase1 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 0
      ::curvespackage::enableCommand 0
    
    }

    bind $w.distG.resSel.resBase2.resIdBase2 <<ComboboxSelected>> {
      ::curvespackage::selectWithResid 1
      ::curvespackage::enableCommand 1
    }
  }
}
proc ::curvespackage::enableCommand {b} {
  variable w

  switch $b {
    1 {
      set test [$w.distG.resSel.resBase1.resIdBase1 get]
      if {$test != ""} {
        $w.distG.resSel.distVal configure -state normal
        $w.distG.resSel.angleVal configure -state normal
      } else {
        $w.distG.resSel.distVal configure -state disabled
        $w.distG.resSel.angleVal configure -state disabled

      }
    }
    0 {
      set test [$w.distG.resSel.resBase2.resIdBase2 get]
      if {$test != ""} {
        $w.distG.resSel.distVal configure -state normal
        $w.distG.resSel.angleVal configure -state normal
      } else {
        $w.distG.resSel.distVal configure -state disabled
        $w.distG.resSel.angleVal configure -state disabled
      }
    } 
    default {
      puts "you can't"
    }
  }
}


#proc ::curvespackage::hello {} {
#  puts "Hello world"
#}

#proc ::curvespackage::hellopy {} {
#  set pyprefix {gopython}
#  puts "[$pyprefix "hello.py"]"
#  puts "[$pyprefix -command helloworld()]"
#}

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



proc ::curvespackage::trajectLoad {} {
  #recupère la trajectoire à charger
  set newTrajectory [tk_getOpenFile]
  
  #verifie que le chemin a bien été pris en compte
  if {$newTrajectory != ""} {
    #ajoute la trajecroire à la mol en court
    mol addfile $newTrajectory
    pbc unwrap -all 
  }
}

proc ::curvespackage::listeResname {} {
  variable w
  variable maxDNA
  variable minDNA
  variable mid 
  variable selectList

  set sel [atomselect top "all"]

  set selectList [dict create]

  set names [$sel get {resname resid}]
  set names [lsort -unique $names]
  set stc [list]
  set stcId [list]
  foreach name $names  {
      #recupère resname et resid
      set rsn [split $name "\ "]
      set rsi [lindex $rsn 1]
      set rsn [lindex $rsn 0]

      #ajout dans un dict sous la forme {{"RESNAME":"id1" "id2"}{"RESNAME2":"id3" "id4"}}
      if {![dict exist $selectList $rsn]} {
        dict set ::curvespackage::selectList $rsn $rsi 
      } else {
        dict lappend ::curvespackage::selectList $rsn $rsi 
      }

      if {[regexp {^DA} $rsn] || [regexp {^DT} $rsn] || [regexp {^DC} $rsn] || [regexp {^DG} $rsn]} {
        lappend stc $rsn
        lappend stcId $rsi
      }
    }

    set selNucleic [atomselect top "nucleic"]
    set listNucleic [$selNucleic get resid]
    set maxDNA [tcl::mathfunc::max {*}$listNucleic]
    set minDNA [tcl::mathfunc::min {*}$listNucleic]
    set mid [expr ($maxDNA - ($minDNA -1))/2]
    $selNucleic delete
    
    #set stc [$sel get resname]
    set stc [lsort -unique $stc]
    set stcId [lsort -integer $stcId]
    $w.distG.resSel.resBase1.resNameBase1 configure -values $stc
    $w.distG.resSel.resBase1.resNameMatch1 configure -values $stc
    $w.distG.resSel.resBase2.resNameBase2 configure -values $stc
    $w.distG.resSel.resBase2.resNameMatch2 configure -values $stc

    $w.distG.resSel.resBase1.resIdBase1 configure -values $stcId
    $w.distG.resSel.resBase2.resIdBase2 configure -values $stcId
    
    $sel delete
}

proc ::curvespackage::selectWithResname {b} {
  variable w

  #quel liste déroulante appelle pour savoir chez qui récupérer le name 
  switch $b {
    0 {
      set name [$w.distG.resSel.resBase1.resNameBase1 get]
    }
    1 {
      set name [$w.distG.resSel.resBase2.resNameBase2 get]
    }
    2 {
      set name [$w.distG.resSel.resBase1.resNameMatch1 get]
    }
    3 {
      set name [$w.distG.resSel.resBase2.resNameMatch2 get]
    }
    default {
      puts "there is a problem, call us!" 
    }
  }
  
  #defini la liste de resid
  if {$name != ""} {
    set list stc

    dict for {id info} $::curvespackage::selectList {
      if {$id eq $name} {
        set stc [split $info "\ "]
        break 
      }
    }
    set stc [lsort -integer $stc]
    
    switch $b {
    0 {
      $w.distG.resSel.resBase1.resIdBase1 configure -values $stc
    }
    1 {
      
      $w.distG.resSel.resBase2.resIdBase2 configure -values $stc
    }
    2 {
      $w.distG.resSel.resBase1.resIdMatch1 configure -values $stc
    }
    3 {
      $w.distG.resSel.resBase2.resIdMatch2 configure -values $stc
    }
    default {
        puts "there is a problem, call us!" 
      }
    }
  } else {
    tk_messageBox -message "Please make a selection"
  } 
}

proc ::curvespackage::selectWithResid {b} {
  variable w 
  variable selectList

  switch $b {
    0 {
      set stcId [$w.distG.resSel.resBase1.resIdBase1 get]
      if {$stcId != ""} {
        dict for {id info} $selectList {
          if {[regexp {^DA} $id] || [regexp {^DT} $id] || [regexp {^DC} $id] || [regexp {^DG} $id]} {
            if {[lsearch -exact $info $stcId] >= 0} {
              $w.distG.resSel.resBase1.resNameBase1 set $id
              break
            }
          }
        }
      }
    }

    1 {
      set stcId [$w.distG.resSel.resBase2.resIdBase2 get]
      if {$stcId != ""} {
        dict for {id info} $selectList {
          if {[regexp {^DA} $id] || [regexp {^DT} $id] || [regexp {^DC} $id] || [regexp {^DG} $id]} {
            if {[lsearch -exact $info $stcId] >= 0 } {
              $w.distG.resSel.resBase2.resNameBase2 set $id
              break
            }
          }
        }
      }
    }
  }
}

proc ::curvespackage::matchList {} {
  variable selectList
  variable w
  variable maxDNA
  variable minDNA
  variable mid 

  #part with the first and second bases
  set name1 [$w.distG.resSel.resBase1.resNameBase1 get]
  set idSel1 [$w.distG.resSel.resBase1.resIdBase1 get]

  if {$idSel1 <= $mid && $name1 != "" && $idSel1 != ""} {
    
    set diff [expr {$mid - [expr {int($idSel1)}]}]
    set match [expr {$mid + 1 + $diff}]
    
    if {[regexp {^DA} $name1] || [regexp {^DT} $name1] || [regexp {^DC} $name1] || [regexp {^DG} $name1]} {
      dict for {id info} $selectList {
        if {[regexp {^DA} $name1] || [regexp {^DT} $name1] || [regexp {^DC} $name1] || [regexp {^DG} $name1]} {
          append stc [split $info "\ "]
          append stc "\ "
        }
      }
    if {[lsearch -exact $stc $match] >= 0 && $match > $mid } {
      $w.distG.resSel.resBase1.resIdMatch1 set $match 
        dict for {id info} $selectList {
          if {[lsearch -exact $info $match] >= 0 } {
            if {[regexp {^DA} $name1] && [regexp {^DT} $id] } {
              $w.distG.resSel.resBase1.resNameMatch1 set $id
            } elseif {[regexp {^DT} $name1] && [regexp {^DA} $id]} {
                $w.distG.resSel.resBase1.resNameMatch1 set $id
            } elseif {[regexp {^DC} $name1] && [regexp {^DG} $id]} {
                $w.distG.resSel.resBase1.resNameMatch1 set $id
            } elseif {[regexp {^DG} $name1] && [regexp {^DC} $id]} {
                $w.distG.resSel.resBase1.resNameMatch1 set $id
            } else {
                $w.distG.resSel.resBase1.resIdMatch1 set -1
                $w.distG.resSel.resBase1.resNameMatch1 set "NO MATCH"
                tk_messageBox -message "No match, your DNA is damaged"
              }
            break
          }
        }
      } else {
          $w.distG.resSel.resBase1.resIdMatch1 set -1
          $w.distG.resSel.resBase1.resNameMatch1 set "NO MATCH"
          tk_messageBox -message "No match, your DNA is damaged"
      }
    }
  } 
  #else {
   #   $w.distG.resSel.resBase1.resIdMatch1 set -1
    #  $w.distG.resSel.resBase1.resNameMatch1 set "NO MATCH"
     # tk_messageBox -message "Select something on the first strand (See mid to determine this)"
    #}

  #part with the third and fourth bases 
   #$w.distG.resSel.resNameMatch1 configure -values $stc
    #$w.distG.resSel.resNameMatch2 configure -values $stc
    
  set name1 [$w.distG.resSel.resBase2.resNameBase2 get]
  set idSel1 [$w.distG.resSel.resBase2.resIdBase2 get]

  if {$idSel1 <= $mid && $name1 != "" && $idSel1 != ""} {
    
    set diff [expr {$mid - [expr {int($idSel1)}]}]
    set match [expr {$mid + 1 + $diff}]
    
    if {[regexp {^DA} $name1] || [regexp {^DT} $name1] || [regexp {^DC} $name1] || [regexp {^DG} $name1]} {
      dict for {id info} $selectList {
        if {[regexp {^DA} $name1] || [regexp {^DT} $name1] || [regexp {^DC} $name1] || [regexp {^DG} $name1]} {
          append stc [split $info "\ "]
          append stc "\ "
        }
      }
    if {[lsearch -exact $stc $match] >= 0 && $match > $mid } {
      $w.distG.resSel.resBase2.resIdMatch2 set $match 
        dict for {id info} $selectList {
          if {[lsearch -exact $info $match] >= 0 } {
            if {[regexp {^DA} $name1] && [regexp {^DT} $id] } {
              $w.distG.resSel.resBase2.resNameMatch2 set $id
            } elseif {[regexp {^DT} $name1] && [regexp {^DA} $id]} {
                $w.distG.resSel.resBase2.resNameMatch2 set $id
            } elseif {[regexp {^DC} $name1] && [regexp {^DG} $id]} {
                $w.distG.resSel.resBase2.resNameMatch2 set $id
            } elseif {[regexp {^DG} $name1] && [regexp {^DC} $id]} {
                $w.distG.resSel.resBase2.resNameMatch2 set $id
            } else {
                $w.distG.resSel.resBase2.resIdMatch2 set -1
                $w.distG.resSel.resBase2.resNameMatch2 set "NO MATCH"
                tk_messageBox -message "No match, your DNA is damaged"
              }
            break
          }
        }
      } else {
          $w.distG.resSel.resBase2.resIdMatch2 set -1
          $w.distG.resSel.resBase2.resNameMatch2 set "NO MATCH"
          tk_messageBox -message "No match, your DNA is damaged"
      }
    }
  } 
  #else {
   #   $w.distG.resSel.resBase2.resIdMatch2 set -1
    #  $w.distG.resSel.resBase2.resNameMatch2 set "NO MATCH"
     # tk_messageBox -message "Select something on the first strand (See mid to determine this)"
    #}
}

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

proc ::curvespackage::plotBases { type } {

  variable w
  variable atomsDNA
  variable frameStart
  variable frameEnd
  variable step
  
  set base1 [$w.distG.resSel.resBase1.resNameBase1 get]
  set idBase1 [$w.distG.resSel.resBase1.resIdBase1 get]
  set base2 [$w.distG.resSel.resBase2.resNameBase2 get]
  set idBase2 [$w.distG.resSel.resBase2.resIdBase2 get]
  set match1 [$w.distG.resSel.resBase1.resNameMatch1 get]
  set idMatch1 [$w.distG.resSel.resBase1.resIdMatch1 get]
  set match2 [$w.distG.resSel.resBase2.resNameMatch2 get]
  set idMatch2 [$w.distG.resSel.resBase2.resIdMatch2 get]
  set color1 [$w.distG.resSel.resBase1.colorB1 get]
  set color2 [$w.distG.resSel.resBase2.colorB2 get]
  #puts $atomsDNA
  
  if { $color1 eq "" } {
    set color1 red
  }
  
  if {$color2 eq "" } {
    set color2 green
  }
  
  set res1 ""
  set res2 ""
  set res3 ""
  set res4 ""
  
  if {$base1 ne "" && $match1 ne "" && $idBase1 ne "" && $idMatch1 ne ""} {
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
    if { [regexp {angl$} $type] } {
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
          puts "DG : $atoms"
          set atom1 [lindex $atoms 0]
          set atom2 [lindex $atoms 1]
          set res1 [atomselect top "resid $idBase1 and name $atom1"]
          set res2 [atomselect top "resid $idBase1 and name $atom2"]
        }
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
    } elseif { [regexp {dist$} $type] } {
      set res1 [atomselect top "resid $idBase1"]
      set res2 [atomselect top "resid $idMatch1"]
    }
    if {$base2 eq ""} {
      if { $type eq "angl" } {
        set listP [::curvespackage::computeFrames "angB" $res1 $res2 $res3 $res4]
        $res1 delete
	$res2 delete
	$res3 delete
	$res4 delete
	set plothandle [multiplot -x $xlist -y $listP \
                      -xlabel "Frame" -ylabel "Angle" -title "Angle between the bases" \
                      -lines -linewidth 1 -linecolor $color1 \
                      -marker none -legend "Angle" -plot];
      } elseif { $type eq "dist" } {
        set listP [::curvespackage::computeFrames "dist" $res1 $res2]
	$res1 delete
	$res2 delete
	set plothandle [multiplot -x $xlist -y $listP \
                      -xlabel "Frame" -ylabel "Distance" -title "Distance between the bases" \
                      -lines -linewidth 1 -linecolor $color1 \
                      -marker none -legend "Distance" -plot];
      }
    } else {
      if {$base2 ne "" && $match2 ne "" && $idBase2 ne "" && $idMatch2 ne ""} {
        if {[regexp {angl$} $type]} {
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
	} elseif {[regexp {dist$} $type]} {
	  set res3 [atomselect top "resid $idBase2"]
          set res4 [atomselect top "resid $idMatch2"]
	}
	if { $type eq "angl" } {
	  set listP1 [::curvespackage::computeFrames "angB" $res1 $res2 $res3 $res4]
	  set listP2 [::curvespackage::computeFrames "angB" $res5 $res6 $res7 $res8]
          $res1 delete
	  $res2 delete
	  $res3 delete
	  $res4 delete
	  $res5 delete
	  $res6 delete
	  $res7 delete
	  $res8 delete
	  set plothandle [multiplot -x $xlist -y $listP1 \
                      -xlabel "Frame" -ylabel "Angle" -title "Angle between the bases" \
                      -lines -linewidth 1 -linecolor $color1 \
                      -marker none -legend "Angle between the first bases"];
	  $plothandle add $xlist $listP2 -lines -linewidth 1 -linecolor $color2 -marker none -legend "Angle between the second bases" -plot
	} elseif { $type eq "dist" } {
	  set listP1 [::curvespackage::computeFrames "dist" $res1 $res2]
	  set listP2 [::curvespackage::computeFrames "dist" $res3 $res4]
	  $res1 delete
	  $res2 delete
	  $res3 delete
	  $res4 delete
	  set plothandle [multiplot -x $xlist -y $listP1 \
                      -xlabel "Frame" -ylabel "Distance" -title "Distance between the bases" \
                      -lines -linewidth 1 -linecolor $color1 \
                      -marker none -legend "Distance between the first bases"];
	  $plothandle add $xlist $listP2 -lines -linewidth 1 -linecolor $color2 -marker none -legend "Distance between the second bases" -plot
	} elseif { $type eq "4angl" } {
	  set listP [::curvespackage::computeFrames "ang4" $res1 $res2 $res3 $res4 $res5 $res6 $res7 $res8]
	  $res1 delete
	  $res2 delete
	  $res3 delete
	  $res4 delete
	  $res5 delete
	  $res6 delete
	  $res7 delete
	  $res8 delete
	  set plothandle [multiplot -x $xlist -y $listP \
                      -xlabel "Frame" -ylabel "Angle" -title "Angle between the sets of bases" \
                      -lines -linewidth 1 -linecolor red \
                      -marker none -legend "Angle between the sets of bases" -plot];
	} elseif { $type eq "4dist" } {
	  set listP [::curvespackage::computeFrames "dist4" $res1 $res2 $res3 $res4]
	  $res1 delete
	  $res2 delete
	  $res3 delete
	  $res4 delete
	  set plothandle [multiplot -x $xlist -y $listP \
                      -xlabel "Frame" -ylabel "Distance" -title "Distance between the sets of bases" \
                      -lines -linewidth 1 -linecolor red \
                      -marker none -legend "Distance between the sets of bases" -plot];
	}
      } else {
        puts "Error, some fields are empty"
      }
    }
  } else {
    puts "Error, some fields are empty"
  }
}

proc ::curvespackage::computeFrames { type res1 res2 {res3 0} {res4 0} {res5 0} {res6 0} {res7 0} {res8 0} } {
  variable frameStart
  variable frameEnd
  variable step
  
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
  
  switch $type {
    "dist" {
      set lDist {}
      for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
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
      for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
        $res1 frame $i
	$res2 frame $i
	$res1 update
	$res2 update
	set com1 [measure center $res1]
        set com2 [measure center $res2]
	set len1 [veclength $com1]
	set len2 [veclength $com2]
	#puts "com1 = $com1"
	#puts "com2 = $com2"
	set dotprod [vecdot $com1 $com2]
	set dotprodcor [expr $dotprod / ($len1 * $len2)]
	set ang [expr {57.2958 * [::tcl::mathfunc::acos $dotprodcor]}]
	lappend lAngl $ang
      }
      return $lAngl
    }
    "angV" {
      set lAngl {}
      for {set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
        $res1 frame $i
	$res2 frame $i
	$res3 frame $i
	$res4 frame $i
	$res1 update
	$res2 update
	$res3 update
	$res4 update
	set com1 [measure center $res1]
	set com2 [measure center $res2]
	set vectBase [vecsub $com2 $com1]
	set com1 [measure center $res3]
	set com2 [measure center $res4]
	set vectComp [vecsub $com2 $com1]
	set lenB [veclength $vectBase]
	set lenC [veclength $vectComp]
	set dotprod [vecdot $vectBase $vectComp]
	set dotprodcor [expr $dotprod / ($lenB * $lenC)]
	if {$dotprodcor > 1.0} {
	  set dotprodcor 1.0
	}
	if {$dotprodcor < -1.0} {
	  set dotprodcor -1.0
	}
	set ang [expr {57.2958 * [::tcl::mathfunc::acos $dotprodcor]}]
	lappend lAngl $ang
      }
      return $lAngl
    }
    "angB" {
      set lAngl {}
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
	set lenV1 [veclength $vect1]
	set lenV2 [veclength $vect2]
	set dotprod [vecdot $vect1 $vect2]
	set dotprodcor [expr $dotprod / ($lenV1 * $lenV2)]
	if {$dotprodcor > 1.0} {
	  set dotprodcor 1.0
	}
	if {$dotprodcor < -1.0} {
	  set dotprodcor -1.0
	}
	set ang [expr {57.2958 * [::tcl::mathfunc::acos $dotprodcor]}]
	lappend lAngl $ang
      }
      return $lAngl
    }
    "ang4" {
      set lAngl {}
      for { set i $frameStart } { $i < $frameEnd } { set i [expr {$i + $step}] } {
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
	set xyzA1 [split [string range [$res1 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res2 get {x y z}] 1 end-1] "\ "]
	set vectB1 [vecsub $xyzA1 $xyzA2]
	set xyzA1 [split [string range [$res3 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res4 get {x y z}] 1 end-1] "\ "]
	set vectB2 [vecsub $xyzA1 $xyzA2]
	set vect1 [vecsub $vectB2 $vectB1]
	set xyzA1 [split [string range [$res5 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res6 get {x y z}] 1 end-1] "\ "]
	set vectB1 [vecsub $xyzA1 $xyzA2]
	set xyzA1 [split [string range [$res7 get {x y z}] 1 end-1] "\ "]
	set xyzA2 [split [string range [$res8 get {x y z}] 1 end-1] "\ "]
	set vectB2 [vecsub $xyzA1 $xyzA2]
	set vect2 [vecsub $vectB2 $vectB1]
	set lenV1 [veclength $vect1]
	set lenV2 [veclength $vect2]
	set dotprod [vecdot $vect1 $vect2]
	set dotprodcor [expr $dotprod / ($lenV1 * $lenV2)]
	if {$dotprodcor > 1.0} {
	  set dotprodcor 1.0
	}
	if {$dotprodcor < -1.0} {
	  set dotprodcor -1.0
	}
	set ang [expr {57.2958 * [::tcl::mathfunc::acos $dotprodcor]}]
	lappend lAngl $ang
      }
      return $lAngl
    }
    "dist4" {
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
	set center1 [measure center $res1]
	set center2 [measure center $res2]
	set vect1 [vecsub $center2 $center1]
	set center1 [measure center $res3]
	set center2 [measure center $res4]
	set vect2 [vecsub $center2 $center1]
	lappend lDist [vecdist $vect1 $vect2]
      }
      return $lDist
    }
    default {
      puts uss
    }
  }
}

proc curvespackage_tk {} {
  ::curvespackage::packageui
}
