// gridfinity: 42mm by 7mm.abs
//
// We build in the X, Y plane with Z up.
include <fontmetrics.scad>
// External features
gridDim = 42;
gridH = 7;
BinCornerRadius = 4;
BinTopTrim = 0.5;
BaseHeight = 5; // Tray height

WallThickness = 2.4;
InternalWallThickness = 1.0;
ToeW = 0.8;

TextSize = 10;

// Tabs
tabHeight = 13;
tabWidth = 15.85;

// Scoop
fingerRadius = 12;


InsideFilletRadius = BinCornerRadius - WallThickness;

DetailLevel = 36;
Epsilon = 0.0001;

$fn = DetailLevel;

corner_profile = [ [BinCornerRadius, gridH], [0, gridH], [0, BaseHeight], [WallThickness, BaseHeight-WallThickness], [WallThickness, ToeW], [WallThickness + ToeW, 0], [BinCornerRadius, 0] ];
profile = [ [gridDim/2, gridH], [0, gridH], [0, BaseHeight], [WallThickness, BaseHeight-WallThickness], [WallThickness, ToeW], [WallThickness + ToeW, 0], [gridDim/2, 0] ];

module trayBinEdge(nX, thick=1) {
	 blockLen = (nX * gridDim) - 2 * BinCornerRadius;
	 translate([0, BinCornerRadius + blockLen, 0]) rotate([90, 0, 0]) linear_extrude(height = blockLen) scale([thick, 1, thick]) polygon(profile);
	rotate([0, 0, 0]) translate([BinCornerRadius, BinCornerRadius, 0]) rotate_extrude(angle = 90, convexity=10) translate([-BinCornerRadius, 0, -BinCornerRadius]) polygon(corner_profile);
}

// Generate a 2D profile of a bin.  Extrude to make the bin body.
// units in mm 
module BinProfile(x, y) {
	    translate([BinCornerRadius,BinCornerRadius,0]) minkowski() {
		square( [x - 2*BinCornerRadius, y - 2*BinCornerRadius]);
		circle(r=BinCornerRadius);
	}
}

// Make the click-in template for the top.  Shortened by BinTopTrim to avoid the sharp edge
module BinTop(nX, nY) {
	difference() {
	linear_extrude(BaseHeight - BinTopTrim) BinProfile( nX * gridDim, nY * gridDim);
	GridKeyShape(nX, nY);
	}
}

// The "click together" shape.
module GridKeyShape(nX, nY) {
	        trayBinEdge(nY);
	        translate([nX * gridDim, 0,0]) rotate([0, 0, 90]) trayBinEdge(nX);
	        translate([nX * gridDim, nY * gridDim, 0]) rotate([0, 0, 180]) trayBinEdge(nY);
	        translate([0, nY * gridDim, 0]) rotate([0,0,-90]) trayBinEdge(nX);
}

module BinBricks(nX, nY, nZ) {
	difference() {
		union() {
	    		for (x = [0 : 1: nX-1] ) 
	       			for (y = [ 0 : 1 : nY-1])
	            			translate([x * gridDim, y * gridDim, 0]) GridKeyShape(1,1);
			translate([0,0,BaseHeight]) linear_extrude(nZ* gridH) BinProfile(nX * gridDim, nY* gridDim);
	    		translate([0,0,BaseHeight + nZ * gridH]) BinTop(nX, nY);
	    	}
		children();
	}
}


module Tray(nX, nZ) {
	difference() {
	    cube([nX * gridDim, BaseHeight, nZ * gridDim], center=false);
	    
	    for (x = [0 : 1: nX-1] ) 
	        for (z = [ 0 : 1 : nZ-1])
	            translate([x * gridDim, 0, z * gridDim]) Bin(1,1,0);
	    }
}

module DynamicBin(nX, nY, nZ, divX, labels) {
	internal_wall_space = (divX - 1)*InternalWallThickness;
	bucket_space = nX * gridDim - 2 * WallThickness - internal_wall_space;
	bucket_width = bucket_space / divX;

	BinBricks(nX, nY, nZ) union() {
		for(x = [0:1:divX-1]) {
			offset = WallThickness + x * ( InternalWallThickness + bucket_width );
	  		translate([offset,WallThickness,BaseHeight]) plug(bucket_width, gridDim-2*WallThickness, 3*gridH, is_list(labels)?labels[(divX-1)-x]:"");
		}
		if (is_string(labels)) {
			translate([nX * gridDim / 2,TextSize + WallThickness+(tabWidth-TextSize)/2,BaseHeight + nZ * gridH - 1]) labelText(labels, nX * gridDim - 3 * WallThickness );
		}
	}
/*
		if (is_string(labels)) {
echo("string: ", labels);
			translate([nX * gridDim / 2,TextSize + WallThickness+(tabWidth-TextSize)/2,BaseHeight + nZ * gridH - 1]) labelText(labels);
		}
*/
}

DynamicBin(3,1,3,2, "rather very long test text. A bit of an essay.");
translate([0,50,0]) DynamicBin(3,1,3,2, ["left","right"]);

module capsule(c, r) {
	translate([r,r,r]) minkowski() {
		cube([c[0]-2*r, c[1]-2*r, c[2]-2*r]);
		sphere(r);
	}
}

module cylCapsule(l, r, f) {
	translate([0,0,f]) minkowski() {
		cylinder(l-2*f, r-f, r-f);
		sphere(f);
	}
}

module tab(maxLength, height, tabstyle, label) {
	tabProfile = [ [-BaseHeight,0], [tabHeight, 0], [InsideFilletRadius/2, tabWidth], [-BaseHeight, tabWidth] ];
 	translate([0,0,height]) rotate([0,90,0]) {
		difference() {
			linear_extrude(height = maxLength) polygon(tabProfile);

			translate([0.6,TextSize + (tabWidth-TextSize)/2,maxLength / 2]) rotate([0,-90,0]) labelText(label, maxLength);
		}
//		translate([0,TextSize + (tabWidth-TextSize)/2,maxLength / 2]) rotate([0,-90,0]) labelText(label, maxLength);
	}
	
}

module finger(length, y, radius) {
 	translate([0,y-radius,radius]) rotate([0,90,0]) 
		difference() {
			cube([radius, radius, length]);
			cylCapsule(length, radius, InsideFilletRadius);
		}
}

module mouth(x, y, yoffset) {
	translate([InsideFilletRadius,InsideFilletRadius+yoffset,0])linear_extrude(BaseHeight) minkowski() {
		square([x-2*InsideFilletRadius, y-yoffset-2*InsideFilletRadius]);
		circle(InsideFilletRadius);
	}		
}

// zoffset should be the top of the tab
module labelText(label, maxwidth) {
	width = measureText(text=label, font="Liberation Sans", size=TextSize);
	textSize = (width > maxwidth) ? TextSize * maxwidth/width: TextSize;
echo(width, maxwidth, textSize, measureText(text=label, font="Liberation Sans", size=textSize));
	rotate([0,0,180]) linear_extrude(height = BaseHeight) text(text=label,halign="center", font="Liberation Sans",size=textSize);
}

// Assemble the plugs we use to scoop out the insides of the bins.
// Parameterized in mm of total size to use up.  Caller is responsible for placing at the right offset.
// 0:Full,1:Auto,2:Left,3:Center,4:Right,5:None 
module plug(x, y, z, label, tabstyle=0) {
	tabw = tabstyle==5? 0 : tabWidth;
	difference() {
		union() {
			capsule([x,y,z+BaseHeight],InsideFilletRadius);
			translate([0,0,z-InsideFilletRadius]) mouth(x,y,tabw);
		}

		union() {
			tab(x, z, tabstyle, label);
			finger(x, y, fingerRadius);
		}
	}
}
/*
translate([0,150,0]) plug(40,40,21, "Test");
translate([50,100,0]) tab(40,40,21,"test");
*/