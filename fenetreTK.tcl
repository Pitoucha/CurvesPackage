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