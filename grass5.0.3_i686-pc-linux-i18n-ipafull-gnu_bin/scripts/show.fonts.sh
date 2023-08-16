:
d.erase
if [ $? != 0 ]
then
	exit 1
fi
d.text << EOF
.S 5
.F cyrilc
cyrilc    AaBbCcDdEeFfGgHhIiJj
.F gothgbt
gothgbt   AaBbCcDdEeFfGgHhIiJj
.F gothgrt
gothgrt   AaBbCcDdEeFfGgHhIiJj
.F gothitt
gothitt   AaBbCcDdEeFfGgHhIiJj
.F greekc
greekc    AaBbCcDdEeFfGgHhIiJj
.F greekcs
greekcs   AaBbCcDdEeFfGgHhIiJj
.F greekp
greekp    AaBbCcDdEeFfGgHhIiJj
.F greeks
greeks    AaBbCcDdEeFfGgHhIiJj
.F italicc
italicc   AaBbCcDdEeFfGgHhIiJj
.F italiccs
italiccs  AaBbCcDdEeFfGgHhIiJj
.F italict
italict   AaBbCcDdEeFfGgHhIiJj
.F romanc
romanc    AaBbCcDdEeFfGgHhIiJj
.F romancs
romancs   AaBbCcDdEeFfGgHhIiJj
.F romand
romand    AaBbCcDdEeFfGgHhIiJj
.F romanp
romanp    AaBbCcDdEeFfGgHhIiJj
.F romans
romans    AaBbCcDdEeFfGgHhIiJj
.F romant
romant    AaBbCcDdEeFfGgHhIiJj
.F scriptc
scriptc   AaBbCcDdEeFfGgHhIiJj
.F scripts
scripts   AaBbCcDdEeFfGgHhIiJj
.F romans
EOF
echo ""
echo "Warning: showfonts has left the font set to romans"
echo "  Use d.font to set to your desired font"
