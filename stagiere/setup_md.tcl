#!/usr/bin/tclsh
package require Tk


############################# ---TITLE--- ##################################
wm title . "DemonMD - Setup MD simulation"
############################################################################




############################# ---WINDOW GEOMETRY--- ########################
set width 550 ;# in pixels
set height 380 ;# in pixels
wm geometry . ${width}x$height
############################################################################







############################# ---SPACE-- ########################
label .label_0 -text "\n"
    pack .label_0
############################################################################








############################# ---CHOSE FILE AND DIRECTORY--- ########################
entry  .entry_1 -textvariable ::file -width 50 -validate all -validatecommand {isFile %P .entry_1}
button .button_1 -text "Browse your molecule file ..." -command {set ::file [tk_getOpenFile -filetypes $types -parent .]}
    pack .entry_1 .button_1

set types {
    {"Protein Data Bank"     {.pdb .PDB} }
    {"All files"            *}
}

proc isFile {f w} {
    if { [::file exists $f] && [::file isfile $f] } {
        $w configure -fg black
    } else {
        $w configure -fg red
    }
    return 1;
}
############################################################################








############################# ---NOTEBOOK--- ###############################
ttk::notebook .notebook
    pack .notebook -pady 10

###### FRAME 1 #####
ttk::frame .notebook.frame_1
    pack .notebook.frame_1 
    .notebook add .notebook.frame_1 -text "TlEap"


#### -- HMR
ttk::frame .notebook.frame_1.hmr_frame
    pack .notebook.frame_1.hmr_frame 
#
set _HMR_ "HMRyes"
#
ttk::radiobutton .notebook.frame_1.hmr_frame.cbutton_1 -text "Hydrogen Mass Repartitioning" -value "HMRyes" -variable _HMR_
    pack .notebook.frame_1.hmr_frame.cbutton_1 -side "left" -padx 5 -pady 0
#
ttk::radiobutton .notebook.frame_1.hmr_frame.cbutton_2 -text "no HMR" -value "HMRno" -variable _HMR_
    pack .notebook.frame_1.hmr_frame.cbutton_2 -side "left" -padx 5 -pady 0
####



#### --CONTAINER
ttk::panedwindow .notebook.frame_1.pane_1 -orient "horizontal"
    pack .notebook.frame_1.pane_1 -pady 5


## --chose solvatation box type
ttk::labelframe .notebook.frame_1.pane_1.labelframe_1 -width 140 -height 30 -text "Box type"
    pack .notebook.frame_1.pane_1.labelframe_1 -side "left"
    .notebook.frame_1.pane_1 add .notebook.frame_1.pane_1.labelframe_1

frame .notebook.frame_1.pane_1.labelframe_1.f_2102
    pack .notebook.frame_1.pane_1.labelframe_1.f_2102 


set _box_geometry_ "Octahedral"
ttk::radiobutton .notebook.frame_1.pane_1.labelframe_1.rbutton_3301 -text "Octahedral" -value "Octahedral" -variable _box_geometry_
    pack .notebook.frame_1.pane_1.labelframe_1.rbutton_3301 -padx 5 -pady 0 -anchor "w"

ttk::radiobutton .notebook.frame_1.pane_1.labelframe_1.rbutton_3302 -text "Cubic" -value "Cubic" -variable _box_geometry_
    pack .notebook.frame_1.pane_1.labelframe_1.rbutton_3302 -padx 5 -pady 0 -anchor "w"

ttk::radiobutton .notebook.frame_1.pane_1.labelframe_1.rbutton_3303 -text "Rectangular" -value "Rectangular" -variable _box_geometry_
    pack .notebook.frame_1.pane_1.labelframe_1.rbutton_3303 -padx 5 -pady 0 -anchor "w"
##


## --chose solvatation box size
ttk::labelframe .notebook.frame_1.pane_1.labelframe_2 -width 140 -height 30 -text "Solvate with ... (A)"
    pack .notebook.frame_1.pane_1.labelframe_2 -side "right"
    .notebook.frame_1.pane_1 add .notebook.frame_1.pane_1.labelframe_2

set _solvatation_x_size_ 12
label .notebook.frame_1.pane_1.labelframe_2.label_5002 -text "x size"
    pack .notebook.frame_1.pane_1.labelframe_2.label_5002 

scale .notebook.frame_1.pane_1.labelframe_2.scale_5000 -orient "horizontal" -variable _solvatation_x_size_
    pack .notebook.frame_1.pane_1.labelframe_2.scale_5000 -fill "x" -expand 0

label .notebook.frame_1.pane_1.labelframe_2.label_5003 -text "y size (Rectangular box only)" 
    pack .notebook.frame_1.pane_1.labelframe_2.label_5003 

scale .notebook.frame_1.pane_1.labelframe_2.scale_5001 -orient "horizontal" -variable _solvatation_y_size_
    pack .notebook.frame_1.pane_1.labelframe_2.scale_5001 -fill "x" -expand 0

label .notebook.frame_1.label_5004 -text "Equilibrate with salt"
    pack .notebook.frame_1.label_5004 -pady 5
##


#### --CHOSE SALT
frame .notebook.frame_1.salt_frame
    pack .notebook.frame_1.salt_frame 

#
set _salt_ "KCl"
#

ttk::radiobutton .notebook.frame_1.salt_frame.rbutton_3304 -text "KCl" -value "KCl" -variable _salt_
    pack .notebook.frame_1.salt_frame.rbutton_3304 -side "left" -padx 5 -pady 0 -anchor "nw"
#
ttk::radiobutton .notebook.frame_1.salt_frame.rbutton_3305 -text "NaCl" -value "NaCl" -variable _salt_
    pack .notebook.frame_1.salt_frame.rbutton_3305 -side "left" -padx 5 -pady 0 -anchor "nw"
#
ttk::radiobutton .notebook.frame_1.salt_frame.rbutton_3306 -text "CsCl" -value "CsCl" -variable _salt_
    pack .notebook.frame_1.salt_frame.rbutton_3306 -side "left" -padx 5 -pady 0 -anchor "w"
#
ttk::radiobutton .notebook.frame_1.salt_frame.rbutton_3307 -text "CaCl2" -value "CaCl2" -variable _salt_
    pack .notebook.frame_1.salt_frame.rbutton_3307 -side "left" -padx 5 -pady 0 -anchor "nw"
#
ttk::radiobutton .notebook.frame_1.salt_frame.rbutton_3308 -text "ZnCl2" -value "ZnCl2" -variable _salt_
    pack .notebook.frame_1.salt_frame.rbutton_3308 -side "left" -padx 5 -pady 0 -anchor "nw"
#
ttk::radiobutton .notebook.frame_1.salt_frame.rbutton_3309 -text "MgCl2" -value "MgCl2" -variable _salt_
    pack .notebook.frame_1.salt_frame.rbutton_3309 -side "left" -padx 5 -pady 0 -anchor "nw"
#### 


####################




###### FRAME 2 #####
ttk::frame .notebook.frame_2
    pack .notebook.frame_2 
    .notebook add .notebook.frame_2 -text "NAMD"

####
set _temperature_ 300
#
frame .notebook.frame_2.frame_1
    pack .notebook.frame_2.frame_1 
#
label .notebook.frame_2.frame_1.label_1 -text "Temperature (K)"
    pack .notebook.frame_2.frame_1.label_1 -side "left"
#
spinbox .notebook.frame_2.frame_1.spinbox_1 -from 0 -to 1000 -increment 1 -textvariable _temperature_
    pack .notebook.frame_2.frame_1.spinbox_1 -pady 5
####


####
set _minimisation_ 10000
#
frame .notebook.frame_2.frame_2
    pack .notebook.frame_2.frame_2 
#
label .notebook.frame_2.frame_2.label_1 -text "Minimisation (steps)"
    pack .notebook.frame_2.frame_2.label_1 -side "left"
#
spinbox .notebook.frame_2.frame_2.spinbox_1 -from 0 -to 100000 -increment 1 -textvariable _minimisation_
    pack .notebook.frame_2.frame_2.spinbox_1 -pady 5
####


####
set _constraints_ptotocol_ "1:12 0.5:12 0.1:12"
#
frame .notebook.frame_2.frame_3
    pack .notebook.frame_2.frame_3 
#
label .notebook.frame_2.frame_3.label_1 -text "Constraints Protocol (value:time)"
    pack .notebook.frame_2.frame_3.label_1 -side "left"
#
ttk::entry .notebook.frame_2.frame_3.entry_1 -textvariable _constraints_ptotocol_
    pack .notebook.frame_2.frame_3.entry_1 -pady 5
####


####
set _dynamic_time_ 300
#
frame .notebook.frame_2.frame_4
    pack .notebook.frame_2.frame_4 
#
label .notebook.frame_2.frame_4.label_1 -text "Dynamic time (ns)"
    pack .notebook.frame_2.frame_4.label_1 -side "left"
#
spinbox .notebook.frame_2.frame_4.spinbox_1 -from 0 -to 1000000 -increment 1 -textvariable _dynamic_time_
    pack .notebook.frame_2.frame_4.spinbox_1 -pady 5
####






###### FRAME 3 #####
ttk::frame .notebook.frame_3
    pack .notebook.frame_3 
    .notebook add .notebook.frame_3 -text "Colvar"


#### -- COLVAR
ttk::frame .notebook.frame_3.colvar_frame
    pack .notebook.frame_3.colvar_frame 
#
set _COLVAR_ "COLVARno"
#
ttk::radiobutton .notebook.frame_3.colvar_frame.cbutton_1 -text "Collective Variables Interface" -value "COLVARyes" -variable _COLVAR_
    pack .notebook.frame_3.colvar_frame.cbutton_1 -side "left" -padx 5 -pady 0
#
ttk::radiobutton .notebook.frame_3.colvar_frame.cbutton_2 -text "no Colvar" -value "COLVARno" -variable _COLVAR_
    pack .notebook.frame_3.colvar_frame.cbutton_2 -side "left" -padx 5 -pady 0
####




#### -- TEXT-WIDGET
ttk::entry .notebook.frame_3.entry_1 -textvariable _colvar_atom_list_
    pack .notebook.frame_3.entry_1 -pady 5 -expand 1 -fill both
####


# temperature (k) - defaut =  300
# minimisation (ns ; faire calcul)
# contraintes : 0 sont interdit
#               protocole type  1:12 0.5:12 0.1:12   == defaut 
#                               valeur de la contraine : temps (ns ; faire calcul) (3000000 équivaut à 12ns) 
# dynamique (ns ; faire calcul , ne pas oublier d'ajouter le temps des contraintes)

####################
############################################################################









############################################################################
button .button_2 -text "Generate MD setup" -command {exec firefox}
    pack .button_2

# bouton generate setup

# lors de la generation utiliser le nom du fichier PDB pour les fichier MD et PMF !

############################################################################








############################# ---LABEL WARNINGS -- ########################
label .label_1 -text "WARNINGS:\n \
1. Molecule files must be in your work directory ! \n \
2. Solvatation : x and y are added to the edges of the molecule ! \n \
3. Colvar : Paste atoms list without linebreak ! \n " -justify left
    pack .label_1
############################################################################
