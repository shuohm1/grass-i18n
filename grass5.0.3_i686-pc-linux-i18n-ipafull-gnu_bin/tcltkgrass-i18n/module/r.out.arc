interface_build {
    {r.out.arc} 0
    {Converts a raster map layer into an ESRI ARC-GRID file.}
    {entry input {Input raster map:} 0 raster}
    {entry output {Ouput ARC-GRID file:} 0 file}
    {entry dp {Number of decimal places (default: 6):} 0 ""}
    {checkbox -h {Suppress printing of header information.} "" -h}
    {checkbox -1 {List one entry per line instead of full row.} "" -1}
}
