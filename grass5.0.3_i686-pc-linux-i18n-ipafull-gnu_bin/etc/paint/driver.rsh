GISBASE=/usr/src/grass-5.0.3/dist.i686-pc-linux-gnu
export GISBASE
PAINTER=${1?}
PAINT_DRIVER=$GISBASE/etc/paint/driver/$1
export PAINTER PAINT_DRIVER
TRANSPARENT=${2-a}
export TRANSPARENT
exec $GISBASE/etc/paint/driver.sh/$1
