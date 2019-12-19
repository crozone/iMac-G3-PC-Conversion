// iMac G3 PSU mounts
// Ryan Crosby 2019
//
// All units are in mm

//
// Constants
//

// Pretty round things with bigger numbers
// 16 = Good for draft
// 64 = Good for export
$fn=64;

// Floating point errors can cause difference operations to leave really thin faces where there should be none.
// Add this to subtracted object dimensions where appropriate to prevent this.
SEM = 0.0000001;

//
// Imports
//

use <shared.scad>;

//
// Variables
//

baseplate_post_height = 7.5;

screw_a_pos = [5, -22, baseplate_post_height];
screw_b_pos = screw_a_pos + [70, 5, 0];

//
// Modules
//

// Hole
module hole(r, h) {
    cylinder(h = h + 2 * SEM, r1 = r, r2 = r, center = true);
}

module baseplate_screwhole() {
    union() {
        translate([0, 0, 12])
        hole(4, 20);
        
        hole(2, 40);
        
        translate([0, 0, -10])
        hole(3, 20); // post diameter is 5mm, so this has 1mm tolerence in diameter
    }
}

module larger_screwhole() {
    union() {
        // Top of screw cutout
        translate([0, 0, 20 / 2 + 2])
        hole(5, 20);
        
        // Screw thread cutout
        hole(2, 40);
        
        // Post cutout
        translate([0, 0, -10])
        hole(3, 20); // post diameter is 5mm, so this has 1mm tolerence in diameter
    }
}

module larger_screwhole_access() {
    hull() {
        translate([0, 0, 20 / 2 + 2])
        hole(5, 20);
        
        translate([15, 0, 50 / 2 + 2])
        hole(5, 50);
    }
}

//
// Variables
//

psu_height = 64;
psu_width = 131;
psu_length = 101;

panel_width = 87;
panel_depth = 7;
panel_height = 151;

//
// Parts
//

module psu() {
    union() {
        cube([psu_length, psu_height, psu_width]);
        
        // Mobo connectors
        translate([psu_length - 1, 10, 8])
        cube([21, psu_height - 10 - 1, psu_width - 8 - 3]);
        
        // Fan
        translate([50, 0, 63])
        rotate([90, 0, 0])
        cylinder(d = 90, h = 50);
    }
}

module panel() {
    cube([panel_depth, panel_width, panel_height]);
}
 
module mount() {
    cube([psu_length, panel_width,15]);
    
    cube([10, 19, 40]);
    
    // first screw bracket
    translate([0, screw_a_pos[1] - 5, 0])
    difference() {
        cube([10, -screw_a_pos[1] + 5, 12]);
        cube([10, 10, 3.35]);
    }
    
    // second screw bracket
    translate([screw_b_pos[0] - 5, screw_b_pos[1] - 5, 0])
    difference() {
        translate([-60, 0, 0])
        cube([10 + 60, -screw_b_pos[1] + 5, 12]);
        translate([-60, 0, 0])
        cube([10 + 60, 10, 3.35]);
    }
}



difference() {
    mount();
    
    %translate([-panel_depth, 0, 0])
    panel();
    
    #translate([0, 19, 12])
    psu();
    
    translate(screw_a_pos)
    #baseplate_screwhole();
    
    translate(screw_b_pos)
    #baseplate_screwhole();
    
    translate([0, 6, 30])
    rotate([0, 90, 0])
    #larger_screwhole();
    
    translate([0, 6, 6])
    rotate([0, 90, 0])
    #union() {
        larger_screwhole();
        larger_screwhole_access();
    }
    
    translate([0, 70, 6])
    rotate([0, 90, 0])
    larger_screwhole();
    
    translate([0, 80, 6])
    rotate([0, 90, 0])
    larger_screwhole();
    
    hull() {
        translate([0, 70, 6])
        rotate([0, 90, 0])
        larger_screwhole_access();
        
        translate([0, 80, 6])
        rotate([0, 90, 0])
        larger_screwhole_access();
    }
}

