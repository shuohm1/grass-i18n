
What Are Raster Data?

Raster data format uses the cell as its fundamental unit of information.
Data are stored on a grid containing rectangular \cells\ of uniform
size.  Cell dimensions denote data resolution.  Each cell within the
grid can be assigned a data value.  Smaller grid cell size therefore
allows more data to be stored for a given geographic \area\ (i.e., it
can present data at a larger \scale\).  

Each cell is assigned a value (aka, \category value\) and
a label (aka, \category label\) describing the type of data found there.
Each cell is also associated with a specific geographic x,y coordinate
location. 

Each GRASS raster data file describes a specific thematic map in terms
of its geographic coordinates.  Supporting files describe the category
values, category labels, map title, history, etc., corresponding to this
raster data file.  All of the files relating to a given raster data file
are collectively termed a \raster map\ layer.

NOTE: "Cell map" was the term used to denote maps in raster format in
previous versions of GRASS.  A "cell map" is now referred to as a
"raster map" in GRASS 5.0 documentation.

Raster data files are stored under the "cell" directory under each
mapset.  For more information on the location and content of raster
data and supporting files, see the topic "GRASS Database Directory
Structure," accessible from this area's main menu.

Although users can input, display, and output maps in GRASS vector and
sites file formats, most GRASS analysis programs function on raster
data.  If the user wishes to analyze data, he generally must convert
his data to raster data format.  Imagery data are already in raster
data format.






