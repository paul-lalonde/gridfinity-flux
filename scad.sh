#!/bin/sh 
(/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o o.png $1 2>&1 | sed -e 's/, line /:/')