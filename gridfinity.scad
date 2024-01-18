// gridfinity: 42mm by 7mm.abs

gridDim = 42;
gridH = 7;

TH = 5; // Tray height
TW = 2.4;
ToeW = 0.8;

cornerRadius = 4;

corner_profile = [ [cornerRadius, gridH], [0, gridH], [0, TH], [TW, TH-TW], [TW, ToeW], [TW + ToeW, 0], [cornerRadius, 0] ];
profile = [ [gridDim/2, gridH], [0, gridH], [0, TH], [TW, TH-TW], [TW, ToeW], [TW + ToeW, 0], [gridDim/2, 0] ];

module trayBinEdge(nX, thick=1) {
    translate([0, 0, cornerRadius]) linear_extrude(height = (nX * gridDim) - 2 * cornerRadius) scale([thick, 1, thick]) polygon(profile);
    $fn=30;
    rotate([-90, -90, 0]) translate([cornerRadius, cornerRadius, 0]) rotate_extrude(angle = 90, convexity=10) translate([-cornerRadius, 0, -cornerRadius]) polygon(corner_profile);
}
module DynamicBin(nX, nZ) {
    difference() {
        union() {
            trayBinEdge(nZ);
            translate([nX * gridDim, 0,0]) rotate([0,-90,0]) trayBinEdge(nX);
            translate([nX * gridDim, 0, nZ * gridDim]) rotate([0,180,0]) trayBinEdge(nZ);
            translate([0, 0, nZ * gridDim]) rotate([0,90,0]) trayBinEdge(nX);
            translate( [gridDim/2, 0, gridDim/2]) cube([gridDim * (nX-1), gridH, gridDim * (nZ-1)], center = false);
        }
        Tray(nX, nZ);
    }
}

module Bin() {
    trayBinEdge(1);
    translate([1 * gridDim, 0,0]) rotate([0,-90,0]) trayBinEdge(1);
    translate([1 * gridDim, 0, 1 * gridDim]) rotate([0,180,0]) trayBinEdge(1);
    translate([0, 0, 1 * gridDim]) rotate([0,90,0]) trayBinEdge(1);  
}

module Tray(nX, nZ) {
    difference() {
        cube([nX * gridDim, TH, nZ * gridDim], center=false);
        
        for (x = [0 : 1: nX-1] ) 
            for (z = [ 0 : 1 : nZ-1])
                translate([x * gridDim, 0, z * gridDim]) Bin();
        }
}

Tray(3,2);

translate([3 * gridDim + 5, 0, 0]) DynamicBin(3, 3);