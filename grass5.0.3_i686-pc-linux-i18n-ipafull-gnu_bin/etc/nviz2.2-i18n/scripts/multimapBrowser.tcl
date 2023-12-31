global multimap_browser

proc set_multimap_browser_filename {w name} {

    set file_name ${name}@[get_multimap_browser_mapset $w]

    $w.filename delete 0 end
    if {[string length $name] > 0} {
	$w.filename insert 0 ${name}@[get_multimap_browser_mapset $w]
	set_selection_from_multimap_browser_filename $w
    }
}

proc multimap_browser_list_mapset {w} {

    set mapset [get_multimap_browser_mapset $w]
    set element [get_multimap_browser_element $w]
    
    $w.main.files.f.list delete 0 end
    update
    if {[string length $mapset] == 0} {return}
    if {[string length $element] == 0} {return}
    foreach name [grass_ls $element $mapset] {
	$w.main.files.f.list insert end $name
    }
}

proc get_multimap_browser_element {w} {
    if {[catch {$w.element.entry get} element]} { return {} }

    if {![string compare $element Raster]} {
	set element cell
    } elseif {![string compare $element Vector]} {
	set element dig
    } elseif {![string compare $element Surface]} {
	set element cell
    } elseif {![string compare $element Site]} {
	set element site_lists 
    } elseif {![string compare $element Region]} {
	set element windows
    } elseif {![string compare $element Labels]} {
	set element paint/labels
    } elseif {![string compare $element Icons]} {
	set element icons 
    } 
    return $element 
}

proc set_multimap_browser_element {w name} {
    $w.element.entry delete 0 end
    $w.element.entry insert 0 $name
    multimap_browser_list_mapset $w
}

proc get_multimap_browser_mapset {w} {
    global multimap_browser
    
    if {[info exists multimap_browser($w,mapset)]} {
	return $multimap_browser($w,mapset)
    }
    return {}
}

proc set_multimap_browser_mapset {w name} {
    global multimap_browser
    
    set multimap_browser($w,mapset) $name
    multimap_browser_list_mapset $w
}


proc set_selection_from_multimap_browser_filename { w } {
    $w.filename selection from 0 
    $w.filename selection to end 
    $w.list.l.list insert end [$w.filename get]
}

proc create_multimap_browser {{w .multimap_browser} {type all} {mode 0}} {
    
    global multimap_browser 
    toplevel $w 
    wm title $w [_ "$w"]
    tkwait visibility $w

#puts "BROWSER: $w TYPE: $type MODE: $mode"
    entry $w.filename -bd 2 -relief sunken
    bind $w.filename <Return> "set_selection_from_multimap_browser_filename $w"
    frame $w.main
    frame $w.list

    frame $w.list.l
    listbox $w.list.l.list -bd 2 -relief sunken \
	-exportselection no \
	-selectbackground LightYellow1 \
	-yscroll "$w.list.l.scroll set" \
	-selectmode single
    scrollbar $w.list.l.scroll \
	-command "$w.list.l.list yview"

    button $w.list.remove -text [_ "Remove"] \
	-command "multimap_remove_cmd $w"
    pack $w.list.l.list $w.list.l.scroll -side left -fill y -expand yes
    pack $w.list.l $w.list.remove -side top -fill x -expand yes
    
    frame     $w.main.mapsets
    label     $w.main.mapsets.label -text [_ MAPSETS]
    frame     $w.main.mapsets.f
    listbox   $w.main.mapsets.f.list -bd 2 -relief sunken \
	-exportselection no                     \
	-selectbackground LightYellow1           \
	-yscroll "$w.main.mapsets.f.scroll set" \
	-selectmode single
    scrollbar $w.main.mapsets.f.scroll \
	-command "$w.main.mapsets.f.list yview"

    bind $w.main.mapsets.f.list <ButtonRelease-1> \
	"multimap_browser_select_mapset  %W %y $w"
    
    frame     $w.main.files
    label     $w.main.files.label -text [_ FILES]
    frame     $w.main.files.f
    listbox   $w.main.files.f.list -bd 2 -relief sunken \
	-exportselection no                   \
	-selectbackground LightYellow1         \
	-yscroll "$w.main.files.f.scroll set" \
	-selectmode single
    scrollbar $w.main.files.f.scroll \
	-command "$w.main.files.f.list yview"

    bind $w.main.files.f.list <ButtonRelease-1> \
	"multimap_browser_select_file %W %y $w"
    
    frame $w.element
    entry $w.element.entry -bd 2 -relief sunken
    bind $w.element.entry <Return> "multimap_browser_list_mapset $w"
    
    if { ![string compare rast $type]} { 
	set name Raster
    } elseif { ![string compare vect $type]} {
	set name Vector
    } elseif { ![string compare site $type]} {
	set name Site
    } elseif { ![string compare surf $type]} {
	set name Surface
    } elseif { ![string compare 3dview $type]} {
	set name 3dview
    }
    
    if [string compare $type all] {
	label $w.element.menu -text [_ "Map Type:"] -relief raised
    } else {
	set name ""
	menubutton $w.element.menu -text [_ {Map Type}] -menu $w.element.menu.m -relief raised
	menu $w.element.menu.m
	$w.element.menu.m add command \
	    -label [_ {Raster}] -command "set_multimap_browser_element  $w Raster"
	$w.element.menu.m add command \
	    -label [_ {Vector}] -command "set_multimap_browser_element  $w Vector"
	$w.element.menu.m add command \
	    -label [_ {Site}] -command "set_multimap_browser_element  $w Site"
	$w.element.menu.m add command \
	    -label [_ {Surf}] -command "set_multimap_browser_element $w Surf"
	$w.element.menu.m add command \
	    -label [_ {Regions}] -command "set_multimap_browser_element  $w windows"
	$w.element.menu.m add command \
	    -label [_ {Labels}] -command "set_multimap_browser_element  $w\
		    paint/labels"
	    $w.element.menu.m add command \
	    -label [_ {Icons}] -command "set_multimap_browser_element  $w icons"
    }

    button $w.done -text [_ Done] -command "multimap_done_cmd $w"
    button $w.cancel -text [_ Cancel] -command "multimap_cancel_cmd $w"
    
    pack $w.filename -side top -expand yes -fill x
    pack $w.main -side top
    pack $w.list -side right -in $w.main

    pack $w.main.mapsets -side left
    pack $w.main.mapsets.label -side top
    pack $w.main.mapsets.f -side top
    pack $w.main.mapsets.f.list -side left
    pack $w.main.mapsets.f.scroll -side left -expand yes -fill y
    
    pack $w.main.files -side left
    pack $w.main.files.label -side top
    pack $w.main.files.f -side top
    pack $w.main.files.f.list -side left
    pack $w.main.files.f.scroll -side left -expand yes -fill y
    
    pack $w.element  -side top -expand yes -fill x
    pack $w.element.menu  -side left
    pack $w.element.entry  -side left -expand yes -fill x
    pack $w.done $w.cancel -side left -expand 1
    
    foreach mapset [grass_mapset_list] {
	$w.main.mapsets.f.list insert end $mapset
    }
    set_multimap_browser_element $w $name
    set_multimap_browser_mapset $w {}
    wm title $w [_ "Map Browser"]
    wm protocol $w WM_DELETE_WINDOW "destroy $w"

    
    if {$mode} {grab $w}

    tkwait window $w

    return $multimap_browser($w,Answer)
    
}

proc multimap_remove_cmd {w} {
    # Get the selection to delete
    set selection [lindex [$w.list.l.list curselection] 0]
    if {$selection != ""} then {
	$w.list.l.list delete $selection
    }
}

proc multimap_cancel_cmd {w} {
    global multimap_browser
    set multimap_browser($w,Answer) -1
    destroy $w
}

proc multimap_done_cmd {w} {
    global multimap_browser 
    
    set multimap_browser($w,Answer) [list]
    set size [$w.list.l.list size]
    for {set i 0} {$i < $size} {incr i} {
	lappend multimap_browser($w,Answer) [$w.list.l.list get $i]
    }

    destroy $w
}

proc multimap_browser_select_file {W y w} {
    set near [ $W nearest $y ]
    $W selection set $near $near
    eval set_multimap_browser_filename $w {[$W get $near]}
}

proc multimap_browser_select_mapset {W y w} {
    set near [ $W nearest $y ]
    $W selection set $near $near
    eval set_multimap_browser_mapset $w {[$W get $near]}
}

