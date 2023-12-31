##########################################################################
# Routines for surface control panel for Nviz program.
# Written Spring 1994
# Terry Baker 
# U.S. Army Construction Engineering Research Laboratory
#
# Major modifications made Jan 1995 to account for restructuring
# of the underlying C code (mca 1/11/95)
#
##########################################################################
# global variables set by widgets in this panel:
#     Nv_(CurrOnly)
#     Nv_(SurfStyle)
#     Nv_(ShadeStyle)
#     Nv_(PolyResWidget) 
#     Nv_(WireResWidget) 
#     Nv_(TopNoZeros) 
#     Nv_(ColNoZeros) 
#     Nv_(CurrSurf)
############################################################################
# procedure to make main control area
###########################################################################

proc mksurfPanel { BASE } {
    global Nv_
    
    catch {destroy $BASE}
    if {[catch {set Nv_(CurrOnly)}]} 		{set Nv_(CurrOnly) 1}
    if {[catch {set Nv_(ShadeStyle)}]} 	{set Nv_(ShadeStyle) gouraud}
    if {[catch {set Nv_(SurfStyle)}]} 	{set Nv_(SurfStyle) poly}
    if {[catch {set Nv_(TopNoZeros)}]} 	{set Nv_(TopNoZeros) 0}
    if {[catch {set Nv_(ColNoZeros)}]} 	{set Nv_(ColNoZeros) 0}
    
    #  Initialize panel info
    if [catch {set Nv_($BASE)}] {
	set panel [St_create {window name size priority} $BASE [_ "Surfaces"] 2 5]
    } else {
	set panel $Nv_($BASE)
    }
    
    frame $BASE  -relief groove -borderwidth 2
    Nv_mkPanelname $BASE [_ "Surface Panel"]
    frame $BASE.top -relief groove -borderwidth 2
    frame $BASE.bottom
    
    set tmp [frame $BASE.top.left]
    ########### make arrows for surf & grid resolution control ###################
    Nv_mkArrows $tmp.gridarrows [_ "Grid Resolution"] [concat set_res wire] 8
    set Nv_(WireResWidget) $tmp.gridarrows.f2.entry
    Nv_mkArrows $tmp.polyarrows [_ "Polygon Resolution"] [concat set_res poly] 8
    set Nv_(PolyResWidget) $tmp.polyarrows.f2.entry
   
#Add bindings for resolution update
bind $tmp.gridarrows.f2.entry <Motion> "+ update_res wire"
bind $tmp.gridarrows.f2.entry <Return> "+ update_res wire"

bind $tmp.polyarrows.f2.entry <Motion> "+ update_res poly"
bind $tmp.polyarrows.f2.entry <Return> "+ update_res poly"
 
    ########### make buttons that control scope of changes made ##################
    radiobutton $tmp.current  -text [_ "Current Surface Only"]\
	-anchor nw -value 1 -variable Nv_(CurrOnly)
    radiobutton $tmp.all -text [_ "All Surfaces"]\
	-anchor nw -value 0 -variable Nv_(CurrOnly) -command set_drawmode
    
    pack $tmp.gridarrows $tmp.polyarrows $tmp.current $tmp.all \
	-side top -fill x -ipady 5
    
    set tmp [frame $BASE.top.right]
    ########## make buttons that control surface & drawing style ##################
    label $tmp.style -text [_ "Surface Style:"] -anchor nw
    radiobutton $tmp.wire -text [_ Wire] \
	-anchor nw -value wire -variable Nv_(SurfStyle) -command set_drawmode
    radiobutton $tmp.poly -text [_ Polygon] \
	-anchor nw -value poly -variable Nv_(SurfStyle) -command set_drawmode
    radiobutton $tmp.wire_poly -text [_ Wire/Poly] \
	-anchor nw -value wire_poly -variable Nv_(SurfStyle) \
	-command set_drawmode
    
    label $tmp.shading -text [_ "Shading:"] -anchor nw
    radiobutton $tmp.flat -text [_ Flat] \
	-anchor nw -value flat -variable Nv_(ShadeStyle) \
	-command set_drawmode
    radiobutton $tmp.gouraud -text [_ Gouraud] \
	-anchor nw -value gouraud -variable Nv_(ShadeStyle) \
	-command set_drawmode
    
    pack $tmp.style $tmp.poly $tmp.wire $tmp.wire_poly \
	$tmp.shading $tmp.flat $tmp.gouraud \
	-side top -fill x -ipady 3 -expand 1
    
    ###### make widgets that control which is current surface (menu, new delete)###
    set tmp [frame $BASE.bottom.top]
    label $tmp.current -text [_ "Current:"] -anchor nw
    mkMapList $tmp.list surf set_display_from_curr
    button $tmp.new -text [_ New] -anchor ne -command new_surf
    button $tmp.delete -text [_ Delete] -anchor ne -command delete_surf
    
    pack $tmp.current $tmp.list -side left
    pack $tmp.delete $tmp.new -side right -expand 1
    
    ####### make buttons that control attributes for current surface ############
    set tmp [frame $BASE.bottom.left]
    button $tmp.draw_current -text [_ "Draw Current"] \
	-command {Nsurf_draw_one [Nget_current surf]}
    pack $tmp.draw_current -expand 0 -side bottom -anchor nw
    foreach i {topography color mask transparency shininess emission} {
	pack [Nv_mkAttbutton $tmp $i] -expand 1 -side top -fill x
    }
    
    
    set tmp [frame $BASE.bottom.right]
    checkbutton $tmp.nozeros1 -text [_ "No Zeros"] \
	-anchor nw  -variable Nv_(TopNoZeros) -command no_zeros
    checkbutton $tmp.nozeros2 -text [_ "No Zeros"] \
	-anchor nw -variable Nv_(ColNoZeros) -command no_zeros
    button $tmp.wireclr -text [_ "Wire Color"] -anchor nw \
	-command "change_wirecolor $tmp.wireclr" \
	-bg [get_curr_wire_color]
    button $tmp.position -text [_ "Position"] -anchor nw -command "mkPositionPanel .pos_surf"
    
    pack $tmp.nozeros1 $tmp.nozeros2 $tmp.wireclr $tmp.position \
	-expand 1 -side top -fill x
    
    ############# manage  frames ################################################
    pack $BASE.top $BASE.bottom -side top -fill x -expand 1
    pack $BASE.top.left -side left -expand 1
    pack $BASE.top.right -side right -expand 1
    pack $BASE.bottom.top -side top -fill x -ipady 5 -expand 1
    pack $BASE.bottom.left -side left -expand 1
    pack $BASE.bottom.right -side top
    
    ########## make button to close panel ########################################
    button $BASE.close -text [_ Close] -command "Nv_closePanel $BASE" -anchor s
    pack $BASE.close -side right 
    set_display_from_curr
    
    return $panel
}

# Reset procedure for this panel
proc Nviz_surf_reset {} {
    # Need to nuke all the surfaces here to reset
    set surf_list [Nget_surf_list]

    foreach i $surf_list {
	Nsurf$i delete
    }

    set_new_curr surf 0
}

# Save procedure for saving state of Nviz
proc Nviz_surf_save {file_hook} {
    # For each surface we write out all of its attribute information. 
    # Surfaces are referenced by logical name so that they are reloadable
    # (otherwise, they may be assigned different id's each time they are loaded
    # and scripts won't work correctly).

    # Get the list of surfaces
    set surf_list [Nget_surf_list]

    # Write out the total number of surfaces
    puts $file_hook "[llength $surf_list]"

    # For each surface write out the following:
    # 1. Logical name
    # 2. topography + no zero status
    # 3. color + no zero status
    # 4. mask + inverted status
    # 5. transparency
    # 6. shininess
    # 7. emission
    # 8. wire color
    # 9. position
    # 10. grid resolution
    # 11. polygon resolution
    # 12. surface style
    # 13. shading
    foreach i $surf_list {

	# logical name
	puts $file_hook "[Nsurf$i get_logical_name]"
	
	# topography source + no zero status
	puts $file_hook "[Nsurf$i get_att topo]"
	puts $file_hook "[Nsurf$i get_nozero topo]"

	# color source + no zero status
	puts $file_hook "[Nsurf$i get_att color]"
	puts $file_hook "[Nsurf$i get_nozero color]"

	# mask source + invert status
	puts $file_hook "[Nsurf$i get_att mask]"
	puts $file_hook "[Nsurf$i get_mask_mode]"

	# transparency -> emission sources
	foreach j [list transp shin emi] {
	    puts $file_hook "[Nsurf$i get_att $j]"
	}

	# wire color
	puts $file_hook "[Nsurf$i get_wirecolor]"

	# position 
	puts $file_hook "[Nsurf$i get_trans]"

	# grid resolution
	puts $file_hook "[Nsurf$i get_res wire]"

	# poly resolution
	puts $file_hook "[Nsurf$i get_res poly]"

	# surface and shade style
	set modes [Nsurf$i get_drawmode]
	puts $file_hook "[lindex $modes 1]"
	puts $file_hook "[lindex $modes 0]"

	flush $file_hook
    }

    # Done...
}

# Load procedure for loading state of Nviz
proc Nviz_surf_load { file_hook } {
    # Read the number of surfaces saved in this state file
    gets $file_hook num_surfs

    # For each surface file, create a new surface with the given logical
    # name and fill in the attributes as appropriate
    for {set i 0} {$i < $num_surfs} {incr i} {
	# Read in the logical name for this new surface
	gets $file_hook logical_name

	# Now create a new surface with the given logical name
	set new_surf [Nnew_map_obj surf "name=$logical_name"]

	# Set all attributes as appropriate (i.e. as they are read from the state file)
	# Note that we can ignore "unset" attributes since this is the default
	
	# topography + no zero status
	gets $file_hook att_data
	set att_data [split "$att_data"]
	if {"[lindex $att_data 0]" == "map"} then {
	    $new_surf set_att topo [lindex $att_data 1]
	} elseif {"[lindex $att_data 0]" == "const"} then {
	    $new_surf set_att topo constant [lindex $att_data 1]
	}

	gets $file_hook att_data
	$new_surf set_nozero topo $att_data

	# color + no zero status
	gets $file_hook att_data
	set att_data [split "$att_data"]
	if {"[lindex $att_data 0]" == "map"} then {
	    $new_surf set_att color [lindex $att_data 1]
	} elseif {"[lindex $att_data 0]" == "const"} then {
	    $new_surf set_att color constant [lindex $att_data 1]
	}

	gets $file_hook att_data
	$new_surf set_nozero color $att_data

	# mask + inverted status
	gets $file_hook att_data
	set att_data [split "$att_data"]
	if {"[lindex $att_data 0]" == "map"} then {
	    $new_surf set_att mask [lindex $att_data 1]
	} elseif {"[lindex $att_data 0]" == "const"} then {
	    $new_surf set_att mask constant [lindex $att_data 1]
	}

	gets $file_hook att_data
	$new_surf set_mask_mode $att_data

	# transparency, shininess, emission
	foreach j [list transp shin emi] {
	    gets $file_hook att_data
	    set att_data [split "$att_data"]
	    if {"[lindex $att_data 0]" == "map"} then {
		$new_surf set_att $j [lindex $att_data 1]
	    } elseif {"[lindex $att_data 0]" == "const"} then {
		$new_surf set_att $j constant [lindex $att_data 1]
	    }
	}

	# wire color
	gets $file_hook att_data
	$new_surf set_wirecolor $att_data

	# position
	gets $file_hook att_data
	set att_data [split "$att_data"]
	$new_surf set_trans [lindex $att_data 0] [lindex $att_data 1] [lindex $att_data 2]

	# grid , polygon resolution
	gets $file_hook att_data
	set wire_data [split $att_data]
	gets $file_hook att_data
	set poly_data [split $att_data]
	$new_surf set_res both [lindex $poly_data 0] [lindex $poly_data 1] \
	    [lindex $wire_data 0] [lindex $wire_data 1]

	# surface, shading style
	gets $file_hook surf_mode
	gets $file_hook shade_mode
	$new_surf set_drawmode $surf_mode $shade_mode
    }

    # Update the interface
    update_surf_interface
    look_center
}

proc set_drawmode {} {
    global Nv_
    
    if {$Nv_(CurrOnly)} {
	set L [list [Nget_current surf]]
    } else {
	set L [Nget_map_list surf]
    }
    
    foreach surf $L {
	if {0 != $surf} then {
	    Nsurf$surf set_drawmode $Nv_(SurfStyle) $Nv_(ShadeStyle)
	}
    }
}

proc set_res {mode E} {
    global Nv_
    
    if {$Nv_(CurrOnly) != 0} {
	set L [list [Nget_current surf]]
    } else {
	set L [Nget_map_list surf]
    }
    
    set res [$E get]
    foreach surf $L {
	if {0 != $surf} then {
	    Nsurf$surf set_res $mode $res $res
	}
    }
}

proc update_res {mode} {
    global Nv_

    if {$Nv_(CurrOnly) != 0} {
        set L [list [Nget_current surf]]
    } else {
        set L [Nget_map_list surf]
    }

if {$mode == "wire"} {
set res [$Nv_(WireResWidget) get]
}
if {$mode == "poly"} {
set res [$Nv_(PolyResWidget) get]
}
    foreach surf $L {
        if {0 != $surf} then {
            Nsurf$surf set_res $mode $res $res
        }
    }
}


proc no_zeros {} {
    global Nv_
    
    set curr [Nget_current surf]
    
    if {0 != $curr} then {
	Nsurf$curr set_nozero topo 	$Nv_(TopNoZeros)
	Nsurf$curr set_nozero color	$Nv_(ColNoZeros)
    }
}

proc set_display_from_curr {args} {
    global Nv_
    
    set curr [Nget_current surf]
    if {0 != $curr} {
	set  L [Nsurf$curr get_res both]
	Nv_setEntry $Nv_(PolyResWidget) [lindex $L 1]
	Nv_setEntry $Nv_(WireResWidget) [lindex $L 2]
	
	set  L [Nsurf$curr get_drawmode]
	set  Nv_(ShadeStyle) [lindex $L 0]
	set  Nv_(SurfStyle) [lindex $L 1]
	set  Nv_(TopNoZeros) [Nsurf$curr get_nozero topo]
	set  Nv_(ColNoZeros) [Nsurf$curr get_nozero color]
    }
}

proc change_wirecolor {me} {
    
    set curr [Nget_current surf]
    if {0 != $curr} {
	set clr [Nsurf$curr get_wirecolor]
	set clr [mkWireColorPopup .colorpop [_ WireColor] $clr 1]
	Nsurf$curr set_wirecolor $clr
    }

    $me configure -bg [get_curr_wire_color]

}

proc delete_surf {} {
    
    set curr [Nget_current surf]
    if {0 != $curr} {
	Nsurf$curr delete
	
	# Now arbitrarily pick a new surface to make the
	# current surface
	set map_list [Nget_map_list surf]
	if {[llength $map_list] == 0} then {
	    set_new_curr surf 0
	} else {
	    set_new_curr surf [lindex $map_list 0]
	}
	set_display_from_curr
    }
    
    Nquick_draw
}

proc new_surf {} {
    global Nv_ attPopup_Status attPopup_Type


set cur_stat [Nget_current surf]

#    if {$cur_stat == 0} {
#    #no surf loaded    
#    set new_obj [string range [Nnew_map_obj surf] 5 end]
#    } else {
#    set new_obj $cur_stat
#    }

    set new_obj [string range [Nnew_map_obj surf] 5 end]
    
    # Make sure we call the focus routine if this is the first surface loaded
    if {$Nv_(CALLED_SET_FOCUS) == "no"} then {
	Nset_focus_map
	set Nv_(CALLED_SET_FOCUS) yes
    }
    
    set_new_curr surf $new_obj
#    set_display_from_curr
    
    # Now automatically invoke the topography popup
    mkAttPopup .temporary_new_surf topography 1

    if {"$attPopup_Status" == "no_change"} then {
	delete_surf
	set curr [Nget_current surf]
	if {0 != $curr} then {
	    set_display_from_curr
	} else return
    }

#Reset view parameters
if {$cur_stat == 0 &&  $attPopup_Type != "constant"} {

#zexag
set exag [Nget_first_exag]
Nv_floatscaleCallback $Nv_(P_AREA).main.midf.zexag b 2 Nchange_exag $exag

#height
set list [Nget_height]
set val [lindex $list 0]
Nv_floatscaleCallback $Nv_(P_AREA).main.midf.height b 2 Nchange_height $val
}


    # Automatically center the new map
    look_center
    
    Nquick_draw
}

# This routine updates the surface panel interface
# If the current surface is invalid then we try to set 
# a new one or 0 if no surfaces are present.
proc update_surf_interface {} {
    set curr [Nget_current surf]
    set map_list [Nget_map_list surf]
    if {[llength $map_list] == 0} then {
	set_new_curr surf 0
    } else {
	if {[lsearch $map_list $curr] == -1} then {
	    set_new_curr surf [lindex $map_list 0]
	}
    }

    set_display_from_curr
}


###########################################################################
# script_new_surf -
#     This routine takes a surface name and loads it in.
#     This routine is primarily meant to be used from a script.
#
#     Set type to constant if map name represents a constant
#
###########################################################################
proc script_new_surf { surf_name {type map}} {
    global Nv_
    
    set new_obj [string range [Nnew_map_obj surf] 5 end]
    # puts "new_obj is $new_obj"
    
    # Make sure we call the focus routine if this is the first surface loaded
    if {$Nv_(CALLED_SET_FOCUS) == "no"} then {
	Nset_focus_map
	set Nv_(CALLED_SET_FOCUS) yes
    }
    
    set_new_curr surf $new_obj
    set_display_from_curr
    
    # Now automatically invoke the topography popup
    if {"$type" != "map"} then {
	Nsurf$new_obj set_att topo constant $surf_name
    } else {
	Nsurf$new_obj set_att topo $surf_name
    }
    
    # Automatically center the new map
    look_center
    
    Nquick_draw

    return $new_obj
}

###########################################################################
#	mkPositionPanel -
#		Create popup for positioning the current surface
#
#	Arguments:
#		w - window name
#	Returns:
#		None
#	Side Effects:
#		Automatically repositions the CURRENT surface.
#		Immediately returns if there aren't any surfaces loaded.
###########################################################################
proc mkPositionPanel { w } {
    global Nv_
    
    # Create toplevel widget to hold everything
    toplevel $w -class Dialog
    wm title $w [_ "Position Surface"]
    wm iconname $w [_ "Attribute"]
    
    # Get current surface attributes
    set curr_surf [Nget_current surf]
    if {0 == $curr_surf} then {
	destroy $w
	return
    }
    set temp [Nsurf$curr_surf get_trans]
    set cur_x [lindex $temp 0]
    set cur_y [lindex $temp 1]
    set cur_z [lindex $temp 2]
    
    # Make a position widget
    # Create the update routines unique for this widget
    set update_routine update
    append update_routine $w
    set ucmd "proc $update_routine \{x y\} \{ set z \[$w.zslide get\] ; psSetSurfPos $w \[Nget_current surf\] \$x \$y \$z \}"
    uplevel #0 $ucmd
    set pos [Nv_mkXYScale $w.pos cross SURF_POS 126 126 63 63 $update_routine]
    pack $pos -side top -padx 3 -pady 3
    
    # Create frames to manage everything
    frame $w.left
    pack $w.left -side left -fill both -before $pos -padx 3 -pady 3 -anchor nw
    frame $w.bottom
    pack $w.bottom -side bottom -before $w.left -fill both -padx 3 -pady 3 -anchor sw
    
    # Create X, Y, and Z entry widgets along with Reset and Close buttons
    frame $w.coords
    label $w.coords.z_lbl -text "Z:"
    label $w.coords.x_lbl -text "X:"
    label $w.coords.y_lbl -text "Y:"
    entry $w.coords.z_ent -width 5 -relief sunken
    entry $w.coords.x_ent -width 5 -relief sunken
    entry $w.coords.y_ent -width 5 -relief sunken
    bind $w.coords.x_ent <Return> "psSetSurfPosFromEntry $w $curr_surf"
    bind $w.coords.y_ent <Return> "psSetSurfPosFromEntry $w $curr_surf"
    bind $w.coords.z_ent <Return> "psSetSurfPosFromEntry $w $curr_surf"
    entry $w.coords.z_ent.old 
    entry $w.coords.x_ent.old
    entry $w.coords.y_ent.old
    $w.coords.x_ent.old delete 0 end
    $w.coords.y_ent.old delete 0 end
    $w.coords.z_ent.old delete 0 end
    $w.coords.x_ent.old insert end $cur_x
    $w.coords.y_ent.old insert end $cur_y
    $w.coords.z_ent.old insert end $cur_z
    pack $w.coords.z_lbl $w.coords.z_ent \
	$w.coords.x_lbl $w.coords.x_ent \
	$w.coords.y_lbl $w.coords.y_ent -side left
    pack $w.coords -side top -in $w.bottom -fill both
    
    frame $w.commands
    button $w.commands.reset 	-text [_ "Reset"]	-command "$w.zslide set 0; Nv_itemDrag $w.pos $Nv_(SURF_POS) 63 63; Nv_xyCallback $update_routine 126 126 63 63"
    button $w.commands.close	-text [_ "Close"]	-command "destroy $w"
    pack $w.commands.reset $w.commands.close \
	-side left -fill both -padx 3 -pady 3 -expand yes
    pack $w.commands -in $w.bottom -fill both
    
    # Create Z slider
    set update_routine zupdate
    append update_routine $w
    set ucmd "proc $update_routine \{ z \} \{ psSetSurfPos $w \[Nget_current surf\] \[lindex \[Nv_getXYPos SURF_POS\] 0\] \[lindex \[Nv_getXYPos SURF_POS\] 1\] \$z \}"
    uplevel #0 $ucmd
    scale $w.zslide -orient vertical -from 1000 -to -1000 -showvalue false \
	-activebackground gray80 -troughcolor gray90 -command $update_routine
    pack $w.zslide -side top -in $w.left
    
    # Initialize the interface and off we go
    psSetSurfPos $w $curr_surf 0.5 0.5 0
    
    # Wait until the window is destroyed and exit
    tkwait window $w
    
    return
}

###########################################################################
#	psSetSurfPos -
#		Routine to set the position of the current surface
#		and update the surface position popup
#
#	Arguments:
#		w - widget for surface position popup
#		curr_surf - name of current surface
#		x - x position
#		y - y position
#		z - z position
#	Returns:
#		None
#	Side Effects:
#		Calls $curr_surf set_trans to set the position of the surface
#		and updates the interface
###########################################################################
proc psSetSurfPos {w curr_surf x y z} {

    # Grab old coordinates
    set x_old [$w.coords.x_ent.old get]
    set y_old [$w.coords.y_ent.old get]
    set z_old [$w.coords.z_ent.old get]
    
    # First update the interface
    $w.coords.x_ent delete 0 end
    $w.coords.y_ent delete 0 end
    $w.coords.z_ent delete 0 end
    
    # Set the Z slider appropriately
    set z [expr $z + $z_old]
    
    # Set the XY position appropriately.  These are given
    # as ratios so we convert the ratios to actual x-y shifts
    set range [Nget_xyrange]
    set x [expr ($x - 0.5) * $range + $x_old]
    set y [expr ($y - 0.5) * $range + $y_old]
    
    # Make the call to the underlying library to set 
    # surface position
    Nsurf$curr_surf set_trans $x $y $z
    Nquick_draw
    $w.coords.x_ent insert 0 "$x"
    $w.coords.y_ent insert 0 "$y"
    $w.coords.z_ent insert 0 "$z"
    
}

###########################################################################
#	psSetSurfPosFromEntry -
#		Routine to set the position of the current surface
#		and update the surface position popup
#
#	Arguments:
#		w - widget for surface position popup
#		curr_surf - name of current surface
#	Returns:
#		None
#	Side Effects:
#		Calls $curr_surf set_trans to set the position of the surface
#		and updates the interface
###########################################################################
proc psSetSurfPosFromEntry {w curr_surf} {
    global Nv_
    
    # Grab coordinates directly from entry widgets
    set x [$w.coords.x_ent get]
    set y [$w.coords.y_ent get]
    set z [$w.coords.z_ent get]
    set x_old [$w.coords.x_ent.old get]
    set y_old [$w.coords.y_ent.old get]
    set z_old [$w.coords.z_ent.old get]
    
    # Figure out appropriate positions 
    set xdiff [expr $x - $x_old]
    set ydiff [expr $y - $y_old]
    set zdiff [expr $z - $z_old]
    if {$xdiff < -500} 	then { set xdiff -500 }
    if {$xdiff > 500} 	then { set xdiff 500 }
    if {$ydiff < -500} 	then { set ydiff -500 }
    if {$ydiff > 500} 	then { set ydiff 500 }
    if {$zdiff < [lindex [$w.zslide configure -to] 4]} then { 
	$w.zslide configure -to $zdiff
    }
    if {$zdiff > [lindex [$w.zslide configure -from] 4]} 	then { 
	$w.zslide configure -from $zdiff
    }
    
    # Update Z slider position 
    $w.zslide set $zdiff
    update
    
    # Update crosshair interface
    set xrat [expr int(($xdiff / 1000.0 + 0.5) * 126)]
    set yrat [expr int(($ydiff / 1000.0 + 0.5) * 126)]
    Nv_itemDrag $w.pos $Nv_(SURF_POS) $xrat $yrat
    
    # Make the call to the underlying library to set 
    # surface position
    Nsurf$curr_surf set_trans [expr $xdiff + $x_old] \
	[expr $ydiff + $y_old] [expr $zdiff + $z_old]
    Nquick_draw
    
    $w.coords.x_ent delete 0 end
    $w.coords.y_ent delete 0 end
    $w.coords.z_ent delete 0 end
    $w.coords.x_ent insert end [expr $xdiff + $x_old]
    $w.coords.y_ent insert end [expr $ydiff + $y_old]
    $w.coords.z_ent insert end [expr $zdiff + $z_old]
    
}

# Quicky routine to get the wire color of the current surface
proc get_curr_wire_color {} {
    set curr [Nget_current surf]
    if {0 == $curr} then {
	return "gray90"
    }

    set color [Nsurf$curr get_wirecolor]

    if {"$color" == "UseMap"} then {
	return "gray90"
    } else {
	set color [expr int([tcl_to_rgb $color])]
	set blue  [hexval [expr int($color & 0x0000ff)]]
	set green [hexval [expr int(($color & 0x00ff00)>>8)]]
	set red   [hexval [expr int(($color & 0xff0000)>>16)]]
	return "#$red$green$blue"
    }
}



