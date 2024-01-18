// gridfinity: 42mm by 7mm.abs
//
// We build in the X, Y plane with Z up.

gridDim = 42;
gridH = 7;

BaseHeight = 5; // Tray height
TW = 2.4;
ToeW = 0.8;

BinCornerRadius = 4;
FilletRadius = 2.8;
BinTopTrim = 0.5;
WallThickness = 1;

DetailLevel = 36;
Epsilon = 0.0001;

$fn = DetailLevel;

corner_profile = [ [BinCornerRadius, gridH], [0, gridH], [0, BaseHeight], [TW, BaseHeight-TW], [TW, ToeW], [TW + ToeW, 0], [BinCornerRadius, 0] ];
profile = [ [gridDim/2, gridH], [0, gridH], [0, BaseHeight], [TW, BaseHeight-TW], [TW, ToeW], [TW + ToeW, 0], [gridDim/2, 0] ];

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

module DynamicBin(nX, nY, nZ) {
    union() {
	difference() {
		union() {
        			for (x = [0 : 1: nX-1] ) 
           			 for (y = [ 0 : 1 : nY-1])
                				translate([x * gridDim, y * gridDim, 0]) GridKeyShape(1,1);
			translate([0,0,BaseHeight]) linear_extrude(nZ* gridH) BinProfile(nX * gridDim, nY* gridDim);
        		}
		//translate([0,0,BaseHeight]) cube([nX * gridDim+Epsilon, nY* gridDim + Epsilon, gridH]);
	}
        translate([0,0,BaseHeight + nZ * gridH]) BinTop(nX, nY);
    }
}


module BinBase() {
    trayBinEdge(1);
    translate([1 * gridDim, 0,0]) rotate([0,-90,0]) trayBinEdge(1);
    translate([1 * gridDim, 0, 1 * gridDim]) rotate([0,180,0]) trayBinEdge(1);
    translate([0, 0, 1 * gridDim]) rotate([0,90,0]) trayBinEdge(1);  
}

module Bin(nX, nY, nZ) {
	BinTop(nX, nY, nZ);
        for (x = [0 : 1: nX-1] ) 
            for (z = [ 0 : 1 : nZ-1])
                translate([x * gridDim, 0, z * gridDim]) BinBase();
}

module Tray(nX, nZ) {
    difference() {
        cube([nX * gridDim, BaseHeight, nZ * gridDim], center=false);
        
        for (x = [0 : 1: nX-1] ) 
            for (z = [ 0 : 1 : nZ-1])
                translate([x * gridDim, 0, z * gridDim]) Bin(1,1,0);
        }
}
/*

BinBase();
Tray(3,2);
translate([3 * gridDim + 5, 0, 0]) DynamicBin(2, 3);
*/
DynamicBin(1, 3, 3);
