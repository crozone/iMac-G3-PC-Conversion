// iMac G3 Radiator Mounts
// Ryan Crosby 2021
//
// All units are in mm
//
// Reference is looking at the iMac front on at the screen, as if using it.
//
// X is left to right from the left edge to the right edge
// Y is front to back, from the display to the rear
// Z is bottom to top, from the bottom of the computer to the top of the case

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

// Space between rear bracket screw holes: 81mm
rear_bracket_screw_spacing = 81;

baseplate_post_height = 7.5;

rear_bracket_screws_pos = 
[
    [-rear_bracket_screw_spacing / 2, 0, 0],
    [rear_bracket_screw_spacing / 2, 0, 0]
];

// Dimensions of the main box "core" of the radiator
radiator_main_dim = [200, 200, 47];
// Dimensions of one of the two bottom caps that the inlets/outlets are fixed into.
radiator_bot_cap_dim = [95, 25, 40];
// The x distance between the two radiator bottom caps
radiator_bot_cap_gap = 3;

// Dimensions of the top cap that the fill port is fixed into.
radiator_top_cap_dim = [195, 14, 40];


//
// Modules
//

// Hole
module hole(r, h) {
    cylinder(h = h + 2 * SEM, r1 = r, r2 = r, center = true);
}

module baseplate_screwhole() {
    union() {
        // Top of screw mount
        translate([0, 0, 20 / 2 + 3])
        hole(4, 20);
        
        // Screw thread cutout
        hole(2, 40);
        
        // Post
        translate([0, 0, -10])
        hole(3, 20); // post diameter is 5mm, so this has 1mm tolerence in diameter
    }
}

module larger_screwhole() {
    union() {
        // Top of screw cutout
        translate([0, 0, 20 / 2 + 3.5])
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
        translate([0, 0, 20 / 2 + 3.5])
        hole(5, 20);
        
        translate([15, 0, 50 / 2 + 3.5])
        hole(5, 50);
    }
}

//
// Parts
//

module radiator() {
        module bot_cap() {
            translate([0, -radiator_main_dim[1] / 2, 0])
            translate(-radiator_bot_cap_dim / 2 - [0, radiator_bot_cap_dim[1] / 2, 0])
            cube(radiator_bot_cap_dim);
        }

        union() {
            translate(-radiator_main_dim / 2)
            cube(radiator_main_dim);

            translate([-radiator_bot_cap_dim[0] / 2 - radiator_bot_cap_gap / 2, 0, 0])
            bot_cap();
            translate([radiator_bot_cap_dim[0] / 2 + radiator_bot_cap_gap / 2, 0, 0])
            bot_cap();

            translate([0, radiator_main_dim[1] / 2, 0])
            translate(-radiator_top_cap_dim / 2 + [0, radiator_top_cap_dim[1] / 2, 0])
            cube(radiator_top_cap_dim);
        }

}
 
module mount() {
    union() {
        translate([-50 / 2, -19 + 5, 0])
        cube([50, 19, 80]);

        translate([-50 / 2, -20, 80])
        cube([50, 40, 30]);

        difference() {
            translate([-90 / 2, -19 + 5, 0])
            cube([90, 19, 10]);

            translate(rear_bracket_screws_pos[0])
            #larger_screwhole();

            translate(rear_bracket_screws_pos[1])
            #larger_screwhole();
        }
    }
}

difference() {
    mount();

    #translate([0, 0, 75])
    rotate([30, 0, 0])
    translate([0, radiator_main_dim[1] / 2 + radiator_bot_cap_dim[1], radiator_main_dim[2] / 2])
    radiator();
}
