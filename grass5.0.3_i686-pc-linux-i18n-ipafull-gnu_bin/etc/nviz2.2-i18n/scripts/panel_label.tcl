#!../glnviz.new/nvwish -f
# 4/4/95
# M. Astley
# USACERL, blah blah blah

##########################################################################
# 
# Panel to facilitate label placement for finishing images produced
# by nviz.
#
##########################################################################

# Changes
#

# Panel specific globals
global Nv_

# Font Type: Times, Helvetica, Courier
set Nv_(labelFontType) Times

# Font Weight: Italic, Bold
set Nv_(labelFontWeight) Bold

# Font Point Size: varies
set Nv_(labelFontSize) 12

# Legend section
set Nv_(catval) 1
set Nv_(catlabel) 1
set Nv_(leg_invert) 0
set Nv_(leg_userange) 0
set Nv_(leg_discat) 0
set Nv_(leg_uselist) 0
set Nv_(cat_list) [list]
set Nv_(cat_list_select) 0

# Label Sites section
set Nv_(labvalues) 1
set Nv_(lablabels) 1
set Nv_(labinbox) 1

##########################################################################

proc mklabelPanel { BASE } {
    global Nv_

    set panel [St_create {window name size priority} $BASE [_ "Label"] 2 5]
    frame $BASE -relief groove -borderwidth 2
    Nv_mkPanelname $BASE [_ "Label Panel"]
    
    ##########################################################################
    # This section contains widgets for setting font type, size and color
    frame $BASE.text_char -relief groove -bd 5
    set rbase $BASE.text_char
    
    frame $rbase.font_size -relief raised
    label $rbase.font_size.label -text [_ "Font Size:"]
    entry $rbase.font_size.entry -relief sunken -width 3 \
	-textvariable Nv_(labelFontSize)
    button $rbase.font_size.color -text [_ "Color"] \
	-bg \#ffffff -width 8 \
	-command "change_label_color $rbase.font_size.color"
    pack $rbase.font_size.label $rbase.font_size.entry \
	$rbase.font_size.color -side left \
	-padx 2 -anchor n -expand no 

    frame $rbase.font_type -relief raised
    radiobutton $rbase.font_type.times -text "Times-Roman" \
	-value Times -variable Nv_(labelFontType) -anchor w \
	-width 15
    radiobutton $rbase.font_type.helv  -text "Helvetica" \
	-value Helvetica -variable Nv_(labelFontType) -anchor w \
	-width 15
    radiobutton $rbase.font_type.cour  -text "Courier" \
	-value Courier -variable Nv_(labelFontType) -anchor w \
	-width 15
    pack $rbase.font_type.times $rbase.font_type.helv \
	$rbase.font_type.cour -side top \
	-expand yes

    frame $rbase.font_weight -relief raised
    radiobutton $rbase.font_weight.italic -text [_ "Italic"] \
	-value Italic -variable Nv_(labelFontWeight) -anchor w
    radiobutton $rbase.font_weight.bold   -text [_ "Bold"] \
	-value Bold -variable Nv_(labelFontWeight) -anchor w
    pack $rbase.font_weight.italic $rbase.font_weight.bold \
	-side top -expand yes -anchor w

    pack $rbase.font_type $rbase.font_weight -side left \
	-fill x -expand yes -padx 2 -pady 2 -anchor n
    pack $rbase.font_size -side top -expand yes \
	-before $rbase.font_type -anchor n -padx 2 -pady 2

    ##########################################################################
    # This section contains widgets for specifying the label text and a button
    # which actually places the label
    frame $BASE.text_place -relief groove -bd 5
    set rbase $BASE.text_place

    frame $rbase.buttons -relief raised
    button $rbase.buttons.place -text [_ "Place Label"] -command "place_label"
    button $rbase.buttons.undo -text [_ "Undo"] -command ""
    pack $rbase.buttons.place $rbase.buttons.undo -side left \
	-padx 2 -expand no

    entry $rbase.text -relief sunken -width 30
    label $rbase.label -text [_ "Label Text"]
    pack $rbase.buttons -side top -expand yes\
	-padx 2 -pady 2 -anchor n
    pack $rbase.text $rbase.label -side top -expand no \
	-padx 2 -pady 2 -anchor n


    ##########################################################################
    # Separator
    Nv_makeSeparator $BASE.sep1

    ##########################################################################
    # This section contains widgets for specifying a legend
    frame $BASE.legends -relief groove -bd 5
    set rbase $BASE.legends

    # Legend button, invert checkbutton and category checkbuttons
    frame $rbase.leg_inv
#   button $rbase.leg_inv.legend -text "Legend" -command "place_legend"
    button $rbase.leg_inv.legend -text [_ "Legend"] 
    checkbutton $rbase.leg_inv.invert -text [_ "Invert"] -anchor w \
	-variable Nv_(leg_invert) -onvalue 1 -offvalue 0
    pack $rbase.leg_inv.legend $rbase.leg_inv.invert \
	-fill x -side top -expand no -padx 2 -pady 1

    frame $rbase.cats
    checkbutton $rbase.cats.values -text [_ "Category Values"] \
	-anchor w -variable Nv_(catval) -onvalue 1 -offvalue 0
    checkbutton $rbase.cats.labels -text [_ "Category Labels"] \
	-anchor w -variable Nv_(catlabel) -onvalue 1 -offvalue 0
    pack $rbase.cats.values $rbase.cats.labels -side top \
	-expand no -padx 2 -pady 1

    # Use-range portion of panel
    frame $rbase.ranges -relief sunken
    checkbutton $rbase.ranges.useit -text [_ "Use Range"] -anchor w \
	-variable Nv_(leg_userange) -onvalue 1 -offvalue 0

    frame $rbase.ranges.bound_low
    entry $rbase.ranges.bound_low.entry -relief sunken -width 8
    label $rbase.ranges.bound_low.label -text [_ "Low:"] \
	-width 5 -anchor e
    pack $rbase.ranges.bound_low.entry \
	$rbase.ranges.bound_low.label -side right \
	-padx 2 -pady 1 -fill x -expand no

    frame $rbase.ranges.bound_hi
    entry $rbase.ranges.bound_hi.entry  -relief sunken -width 8
    label $rbase.ranges.bound_hi.label -text [_ "Hi:"] \
	-width 5 -anchor e
    pack $rbase.ranges.bound_hi.entry \
	$rbase.ranges.bound_hi.label -side right \
	-padx 2 -pady 1 -fill x -expand no

    # Return bindings for "use range" entries
    bind $rbase.ranges.bound_low.entry <Return> "$rbase.ranges.useit select"
    bind $rbase.ranges.bound_hi.entry <Return> "$rbase.ranges.useit select"

    pack $rbase.ranges.bound_low $rbase.ranges.bound_hi \
	-side top -padx 2 -pady 1 -expand no
    pack $rbase.ranges.useit -side left -anchor n \
	-padx 2 -pady 2 -expand no \
	-before $rbase.ranges.bound_low

    # Discrete categories and use-list portion
    checkbutton $rbase.disc_cat -text [_ "Discrete Categories"] \
	-anchor w -width 18 -variable Nv_(leg_discat) \
	-onvalue 1 -offvalue 0
    
    # Some special handling for the "Use List" entry
    frame $rbase.use_list
    checkbutton $rbase.use_list.cb -text [_ "Use List"] \
	-anchor w -width 18 -variable Nv_(leg_uselist) \
	-onvalue 1 -offvalue 0 -command "make_cat_list $rbase.use_list.curr.m"
    menubutton $rbase.use_list.curr -text [_ "Current List"] \
	-menu $rbase.use_list.curr.m -relief raised
    menu $rbase.use_list.curr.m -disabledforeground black
    pack $rbase.use_list.cb $rbase.use_list.curr -side left \
	-padx 2 -expand no
    $rbase.use_list.curr.m add command -label [_ "None"] -state disabled

    # Pack all portions
    pack $rbase.leg_inv $rbase.cats -side left -fill x -expand yes
    pack $rbase.use_list \
	$rbase.disc_cat \
	$rbase.ranges \
	-side bottom -expand no -before $rbase.leg_inv \
	-padx 2 -pady 1

    ##########################################################################
    # Separator
    Nv_makeSeparator $BASE.sep2

    ##########################################################################
    # This section contains widgets for specifying label sites
    frame $BASE.lab_sites -relief groove -bd 5
    set rbase $BASE.lab_sites

    frame $rbase.left
    button $rbase.left.lab_sites -text [_ "  Label Sites  "]
    checkbutton $rbase.left.in_box -text [_ "In Box"] -anchor w \
	-variable Nv_(labinbox) -onvalue 1 -offvalue 0
    pack $rbase.left.lab_sites $rbase.left.in_box \
	-side top -fill x -expand no -padx 2 -pady 1

    frame $rbase.right
    checkbutton $rbase.right.values -text [_ "Values"] -anchor w \
	-variable Nv_(labvalues) -onvalue 1 -offvalue 0
    checkbutton $rbase.right.labels -text [_ "Labels"] -anchor w \
	-variable Nv_(lablabels) -onvalue 1 -offvalue 0
    pack $rbase.right.values $rbase.right.labels \
	-side top -fill x -expand no -padx 2 -pady 1

    pack $rbase.left $rbase.right -side left -expand yes \
	-padx 2 -pady 1

    ##########################################################################
    # Pack all frames
    pack $BASE.text_char \
	$BASE.text_place \
	$BASE.sep1 \
	$BASE.legends \
	$BASE.sep2 \
	$BASE.lab_sites \
	-padx 2 -pady 2 -fill x -expand no

    return $panel
}

# Simple routine to change the color of fonts
proc change_label_color { me } {
    set clr [lindex [$me configure -bg] 4]
    set clr [mkColorPopup .colorpop [_ "LabelColor"] $clr 1]
    $me configure -bg $clr
}

# Routine to popup a list selector for selecting a discrete list of values
proc make_cat_list {MENU} {
    global Nv_

    # Check to see if we are turning this check button on
    if {$Nv_(leg_uselist) == 0} return

    # Reinitalize list values
    set Nv_(cat_list) [list]
    set Nv_(cat_list_select) 0
    $MENU delete 0 last

    # Create the "individual" subpanel
    set BASE ".cat_list"
    set pname $BASE
    toplevel $pname -relief raised -bd 3
    wm title $pname [_ "cat_list"]
    list_type1 $pname.list 3c 3c
    $pname.list.t configure -text [_ "Category Values"]
    entry $pname.level -relief sunken -width 10
    bind $pname.level <Return> "make_cat_list_add $BASE"
    button $pname.addb -text [_ "Add"]    -command "make_cat_list_add $BASE"
    button $pname.delb -text [_ "Delete"] -command "make_cat_list_delete $BASE"
    button $pname.done -text [_ "Done"]   -command "set Nv_(cat_list_select) 1"
    pack $pname.list $pname.level $pname.addb $pname.delb $pname.done\
	-fill x -padx 2 -pady 2

    tkwait variable Nv_(cat_list_select)
    for {set i 0} {$i < [$pname.list.l size]} {incr i} {
	set temp [$pname.list.l get $i]
	lappend Nv_(cat_list) $temp
	$MENU add command -label "$temp" -state disabled
    }

    if {[llength $Nv_(cat_list)]==0} {
	$MENU add command -label [_ "None"] -state disabled
    }

    destroy $BASE
}

# Two quick routines to add or delete isosurface levels for
# selecting them individually
proc make_cat_list_add { BASE } {
    # For this routine we just use the value stored in the
    # entry widget
    # Get the value from the entry widget
    set level [$BASE.level get]

    # Now just append it to the list
    $BASE.list.l insert end $level
}

proc make_cat_list_delete { BASE } {
    # For this procedure we require that the user has selected
    # a range of values in the list which we delete
    # Get the range of selections
    set range [$BASE.list.l curselection]
    
    # Now delete the entries
    foreach i $range {
	$BASE.list.l delete $i
    }
}

# Routines to allow user to place a label
proc place_label {} {
    global Nv_
    # We bind the canvas area so that the user can click to place the
    # label.  After the click is processed we unbind the canvas area
}

proc place_label_cb {sx sy} {
    global Nv_
}






