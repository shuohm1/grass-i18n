#!/bin/sh
# the next line restarts using wish \
exec $GRASS_WISH "$0" "$@"

# exec /usr/bin/wish "$0" ${1+"$@"}


# tksys.tcl
# get some basic system information 
# from within tcl/tk.
# Designed to work with tcl/tk 8.0 and above.
# Works in a terminal window and 
# in a graphics window (X Window, MS Windows, Macintosh)
# 
# andreas.lange@rhein-main.de
# $Id: tksys.tcl,v 1.2 2002/01/22 04:51:36 glynn Exp $


array set items { 
    platform   "Platform               "
    os         "Operating System       "
    osVersion  "OS Version             "
    machine    "Processor Type (arch)  "
    user       "User Name              "
    hostname   "Hostname               "
    tclversion "Tcl Version            "
    nameofexecutable \
               "Name of Executable     "
    patchlevel "Tcl Version/Patchlevel " 
    uname      "Full OS ID             " 
    script     "Name of current Script " }


array set range {
    1  platform 
    2  os 
    3  osVersion 
    4  machine 
    5  uname 
    7  patchlevel 
    8  nameofexecutable 
    9  script
    10 hostname 
    11 user }

# tclversion is the same as patchlevel
# 6 tclversion


array set tcl_platform_subst { 
    unix      "Unix"
    windows   "MS Windows"
    macintosh "Apple Macintosh" }


array set tcl_machine_subst { }


array set tcl_os_subst { }


proc sys_getinfo { } \
{
    global sys tcl_platform tcl_platform_subst

    if { [info exists tcl_platform(platform)] } \
    {
	set sys(platform) $tcl_platform_subst($tcl_platform(platform))
    } else {
	set sys(platform) "Unknown"
    } 

    foreach name { os osVersion machine user } \
    {
	if { [info exists tcl_platform($name)] } \
        {
	    set sys($name) $tcl_platform($name)
	} else {
	    set sys($name) "unknown"
	}
    }

    # fix for tcl/tk 8.0, where tcl_platform(user) is missing
    if { [string compare "$sys(user)" "unknown"] == 0 && \
	 [string compare "$sys(platform)" "$tcl_platform_subst(unix)"] == 0 } \
    {
	set sys(user) [exec whoami]
    }

    set host [info hostname]
    if { [string length $host] == 0 } \
    {
	set sys(hostname) "hostname not available"
    } else {
	set sys(hostname) $host
    }

    foreach name { tclversion nameofexecutable patchlevel script } \
    {
	set tmp [info $name]
	if { [info exists tmp] } \
        {
	    set sys($name) $tmp
	} else {
	    set sys($name) "n/a"
	}
    }

if { [string compare "$sys(platform)" "$tcl_platform_subst(unix)"] == 0 } \
    { 
	set tmp [exec uname -srm]
	regsub -all { } $tmp {-} tmp 
	set sys(uname) $tmp
    } else {
	set sys(uname) "unsupported"
    }
    
    return
}


proc hline { {sign "-"} {nbr 75} } \
{
    # string repeat was added with tcl/tk 8.1
    # set string [string repeat $sign $nbr] 
    set string $sign
    for { set i 0 } { $i < $nbr } { incr i 1 } \
    {
	append string $sign
    }

    return $string
}


proc sys_putinfo { path } \
{
    global sys range items

    puts $path "\n"
    puts $path [hline "="]
    puts $path "System Information"
    puts $path [hline "="]
    
    foreach index [lsort -integer [array names range]] \
    {
	set name $range($index)
	set string $items($name)
	puts $path "$string $sys($name)"
	puts $path [hline]
    }

    return
}


proc sys_wininfo { } \
{
    global sys range items

    frame .frame0 -borderwidth 2 -relief raised
    frame .frame0.heading -borderwidth 2

    set t [text .frame0.heading.text -relief ridge \
	       -height 1 -width 40 \
	       -font {Helvetica -12 bold} ]
    $t tag configure all -justify center
    $t insert end "System Information\n"
    $t tag add all 1.0 end
    $t configure -state disabled

    pack .frame0 -side top -fill x
    pack .frame0.heading -side top -fill x
    pack .frame0.heading.text -side top -fill x

    frame .frame1 -borderwidth 2 -relief raised

    foreach index [lsort -integer [array names range]] \
    {
	set name $range($index)
	set string $items($name)

	frame .frame1.$index
	label .frame1.$index.string -anchor w \
	    -width 20 -text "$string"
	label .frame1.$index.name -relief sunken \
	    -anchor w -width 20 -text "$sys($name)" \
	    -wraplength [font measure {Helvetica} "XXXXXXXXXXXXXX" ]
	pack .frame1.$index.string -side left -fill x
	pack .frame1.$index.name -side left
	pack .frame1.$index -side top -fill x
    }

    pack .frame1 -side top -fill x

    frame .frame2 -borderwidth 2 -relief raised

    button .frame2.ok -text "Quit" -padx 10 -command { exit }
    button .frame2.save -text "Save" -padx 10 -command { sys_save }
    button .frame2.clear -text "Clear" -padx 10 -command { update }

    pack .frame2 -side top -fill x
    pack .frame2.ok .frame2.save .frame2.clear -side left -expand yes

    bind . <Return>    { exit }
    bind . <Control-c> { exit }
    bind . <Escape>    { exit }
    
    wm title . "TK System Information"
    wm resizable . 0 0 
    grab .
    tkwait window .

    # never reached
    return
}

proc sys_save { } \
{
    global sys range items

    set file [tk_getSaveFile -initialdir . \
		  -defaultextension ".txt" \
		  -title "Enter filename to save info text"]
    if {[string length $file] == 0 } \
    {
	return
    }
    if [catch {open $file w} out] {
	tk_messageBox -type ok -message $out
    } else {
	sys_putinfo $out
	close $out
    }

    return
}


# main program	
sys_getinfo

if { [regexp {.*tk.*} [lindex $argv 0]] } \
{
    sys_wininfo
} else {
    sys_putinfo stdout
}

exit
