               MANAGEMENT OF GRAPHICS DISPLAY FRAMES

After the user has started and selected a graphics monitor for output
(using the \d.mon\ command), the user can subdivide the monitor into
different "frames", and display different GRASS outputs in each frame.
(In past GRASS releases, "graphics frames" were referred to as "graphics
windows"; the latter term is now obsolete.)  For example, the GRASS
program \i.points\ divides the monitor into multiple frames to allow the
user to target \rectification\ points on an image to (user-known) points
on another map layer.  Similarly, the GRASS macro \3d.view.sh\ divides
the monitor into nine frames to demonstrate the 3-d viewing function of
GRASS.

The boundaries of a user's current \geographic region\, which define
which map areas will be displayed, should not be confused with those of
the current display frame, which define the place on the graphics
monitor in which results will be displayed.

The following commands are used to manage the frames in which graphics
are displayed on the user's graphics display device (monitor).  These 
commands affect only the display of graphics, and do not alter the
user's data.  

            \-  d.erase \                 \-  d.frame \

For more information on a specific command, select a command and press
ESC.

