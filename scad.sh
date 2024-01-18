#!/bin/sh 
(/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD --export-format binstl -o o.stl $1 2>&1 | sed -e 's/, line /:/')