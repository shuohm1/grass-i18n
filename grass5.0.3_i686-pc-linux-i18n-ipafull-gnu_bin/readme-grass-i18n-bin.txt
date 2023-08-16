GRASS i18n readme

This pacakage is Linux binary code for GRASS 5.0.3 i18n
(internationalized) version in gzipped tar format.

Installation:

1.download the binary code package file 
  grass5.0.3_i686-pc-linux-i18n-gnu_bin.tar.gz
  which is the whole binary in a single file.

2.download the installation script
  grass5_i686-pc-linux-i18n-gnu_install.sh

Then you only need to type the following after
you downloaded it (example!):

 # sh grass5_i686-pc-linux-i18n-gnu_install.sh \
   grass5.0.3_i686-pc-linux-i18n-gnu_bin.tar.gz [dest_dir] [bin_dir]

[dest_dir]:install directory for GRASS binary(default:/usr/local/grass5)
[bin_dir]:install directory for grass5 command(default:/usr/local/bin)

You may need to login as root for installation.

Usage:

1.start GRASS
 $ grass5

2.start tcltkgrass-i18n
 GRASS:~>tcltkgrass-i18n&

note)
tcltkgrass-i18n needs mlterm. You must install mlterm before GRASS
instllation.

3.enable to display a TrueType font on the monitor
 GRASS:~>d.mon start x0
 GRASS:~>d.font.freetype [font=TrueTypefontname] [charset=encoding]
 
 [font]:TrueType font path(full path include font file name)
 [charset]:character encoding(EUC-JP,UTF-8,SJIS)
 ex.)RedHat Linux9
 GRASS:~>d.font.freetype font=/usr/share/fonts/ja/TrueType/kochi-gothic.ttf charset=EUC-JP
 
4.disable to display TrueType font on the monitor
 GRASS:~>d.font.freetype font=

note)
Font option such as d.site.labels command are ignored 
if you select a TrueType font.

Build environment:

1.This binary code  was compiled on Redhat Linux 9.

2.configure option
 # ./configure --with-nls --with-freetype --with-freetype-includes=/usr/include/freetype2 \
   --with-tcltk-includes=/usr/include

3.added applications and libraries
libfftw2.1.5
Tcl/Tk8.4
mlterm2.8.0pl1


License:

This program is free software. A license follows the original 
license version of GRASS. 

You can redistribute it and/or modify it under the terms of thr GNU General Public
License as published by the Free Software Foundation; either version 2 of the Licnese.
or ( at your option) any later version.

Please refer to COPYING of package appending, and GPL.TXT for details.

GRASS i18n project members:

Masumoto Shinji, Venkatesh Raghavan, Nonogaki Susumu, 
Nemoto Tatsuya, Hirai Naoki (Osaka City University, Japan), 
Hagiwara Akira, Niwa Makoto, Mori Toru (Orkney Inc., Tokyo), 
Hattori Norihiro (E-Solution Service, Inc., Osaka)

Project sponsored by IPA (Information-technology Promotion Agency, Japan)
