#!/bin/sh

# $Id: slide.show.sh,v 1.6.2.2 2003/08/20 09:35:43 markus Exp $

if test "$GISBASE" = ""; then
 echo "You must be in GRASS GIS to run this program." >&2
 exit 1
fi   
     
eval `g.gisenv`
: ${GISBASE?} ${GISDBASE?} ${LOCATION_NAME?} ${MAPSET?}
LOCATION=$GISDBASE/$LOCATION_NAME/$MAPSET


# set defaults
DOWN=3
ACROSS=4
CWD=`pwd`

# in case of problems or user break:
trap 'cd $CWD ; d.frame -s full_screen ; exit 1' 2 3 15


SHOW_VECT=0

# Get list of current mapsets
if [ -r $LOCATION/SEARCH_PATH ]
then
	MAPSETS=`cat $LOCATION/SEARCH_PATH | tr -s '\012' ' '`
else
	MAPSETS=`echo $MAPSET PERMANENT`
fi

helptext()
{
  echo "Slide show of GRASS raster/vector maps."
  echo "Options: [-v] [across=#maps_across] [down=#_maps_down] [prefix=character[s]] [mapsets=list]"
  echo "Defaults:"
  echo "   across  = $ACROSS"
  echo "   down    = $DOWN"
  echo "   prefix  = * (show all maps. Specify character(s) to view selected maps only)"
  echo "   mapsets = $MAPSETS (Specify mapsets comma separated)"
  echo " "
  echo "Use -v to show vector maps rather than raster maps"
}

if [ "$1" = "help" -o "$1" = "-h" -o "$1" = "-help" ]
then
  helptext
  exit 1
fi


# evaluate arguments
for i do
	case $i in
		p=*|pr=*|pre=*|pref=*|prefi=*|prefix=*)
			PREFIX=`echo $i | sed s/prefix=//`;;
		d=*|do=*|dow=*|down=*)
			DOWN=`echo $i | sed s/down=//` ;;
		h=*|he=*|hei=*|heig=*|heigh=*|height=*)
			DOWN=`echo $i | sed s/height=//` ;;
		a=*|ac=*|acr=*|acro=*|acros=*|across=*)
			ACROSS=`echo $i | sed s/across=//` ;;
		w=*|wi=*|wid=*|widt=*|width=*)
			ACROSS=`echo $i | sed s/width=//` ;;
		m=*|ma=*|map=*|maps=*|mapse=*|mapset=*|mapsets=*)
			#user enters comma separated, we need spaces:
			MAPSETS=`echo $i | sed s/mapsets=//| sed s/,/\ /` ;;
		-v)
			SHOW_VECT=1 ;;
		*)
			echo "Unrecognized option: $i"
			echo ""
			helptext
			exit 1 ;;
	esac
done

drawframes()
{
 d.frame -e
 if [ $? -ne 0 ] ; then
  echo "An error occured."
  exit 1
 fi

 # figure height and widths of the windows
 avail_width=`expr 99 - $ACROSS`
 avail_height=`expr 99 - $DOWN`
 map_width=`expr $avail_width / $ACROSS`
 wind_height=`expr $avail_height / $DOWN`
 label_height=`expr $wind_height / 10`
 map_height=`expr $wind_height - $label_height`

 # generate the needed windows
 at_horiz=0
 left=1
 while [ $at_horiz -lt $ACROSS ]
 do
	at_vert=0
	top=99
	right=`expr $left + $map_width`
	while [ $at_vert -lt $DOWN ]
	do
		bottom=`expr $top - $map_height`
		d.frame -c map.$at_horiz.$at_vert at=$bottom,$top,$left,$right
		top=$bottom
		bottom=`expr $top - $label_height`
		d.frame -c lab.$at_horiz.$at_vert at=$bottom,$top,$left,$right
		at_vert=`expr $at_vert + 1`
		top=`expr $bottom - 1`
	done
	at_horiz=`expr $at_horiz + 1`
	left=`expr $right + 1`
 done
}

drawraster()
{
 for mapset in $MAPSETS
 do
	cd $LOCATION/../$mapset
	if [ ! -d cell ]
	then
		continue
	fi
	for i in MASK `ls cell/$PREFIX* 2> /dev/null`
	do
		i=`echo $i | sed 's/cell\///'`
		if [ ! $i = "MASK" ]
		then
			atnum=`expr $atnum % $totmaps`
			at_vert=`expr $atnum % $DOWN`
			at_hori=`expr $atnum / $DOWN`

			d.frame -s lab.$at_hori.$at_vert
			d.erase
			echo $i in $mapset | d.text size=80

			d.frame -s map.$at_hori.$at_vert
			d.erase
			echo $i
			d.rast $i

			atnum=`expr $atnum + 1`
		fi
	done
 done
}


drawvector()
{
 for mapset in $MAPSETS
 do
	cd $LOCATION/../$mapset
	if [ ! -d dig ]
	then
		continue
	fi
	for i in MASK `ls dig/$PREFIX* 2> /dev/null`
	do
		i=`echo $i | sed 's/dig\///'`
		if [ ! $i = "MASK" ]
		then
			atnum=`expr $atnum % $totmaps`
			at_vert=`expr $atnum % $DOWN`
			at_hori=`expr $atnum / $DOWN`

			d.frame -s lab.$at_hori.$at_vert
			d.erase
			echo $i in $mapset | d.text size=80

			d.frame -s map.$at_hori.$at_vert
			d.erase
			echo $i
			d.area -f $i 2>&1 >/dev/null
			d.vect $i

			atnum=`expr $atnum + 1`
		fi
	done
 done
}


####################################
# main code

drawframes

# Get list of current mapsets
if [ ! "$MAPSETS" = "" ]
then
	if [ -r $LOCATION/SEARCH_PATH ]
	then
		MAPSETS=`cat $LOCATION/SEARCH_PATH`
	else
		MAPSETS=`echo $MAPSET PERMANENT`
	fi
fi

# Draw the maps

atnum=0
totmaps=`expr $ACROSS \* $DOWN`

if [ $SHOW_VECT -eq 0 ] ; then
   echo "Displaying raster maps..."
   drawraster
else
   echo "Displaying vector maps..."
   drawvector
fi

cd $CWD
d.frame -s full_screen
