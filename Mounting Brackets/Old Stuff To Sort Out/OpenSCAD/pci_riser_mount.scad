// iMac G3 PCIe riser mount
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
// Modules
//

//
// Variables
//

screw_distance = 38;
riser_height = 7;
riser_width = 54;
riser_length_offset = 3;

// Small mount screws (ex-wifi splitter thing)
wifi_screw_spacing = 25;
small_screw_a = [-27, -4, 1.5];
small_screw_b = [-27, -4 - wifi_screw_spacing, 1.5];

flat_screw_a = [-18.5, -4 + 30, 0];
flat_screw_b = [-18.5 - 58, -4 + 30, 0];

post_screw_a = [-68, -4 + 30 - 12, 8];

square_length = 46;
square_width = 8;

square_cutout_pos = [-18.5 - 5.5 - square_length, -4 + 30 - square_width / 2];


//
// Modules
//

module flat_screw() {
    unthreaded_length = 3;
    screw_diameter = 4;
    top_diameter = 9 + 1;

    union() {
        cylinder(d = screw_diameter, h = unthreaded_length);
        translate([0, 0, unthreaded_length])
        cylinder(d = top_diameter, h = 20);
    }
}

module post_screw() {
    post_diameter = 5.5 + 0.5;
    post_height = 8;
    screw_diameter = 3;
    screw_hole_height = 2;
    top_diameter = 6 + 1;

    // Post
    translate([0, 0, -post_height])
    cylinder(d = post_diameter, h = post_height);

    cylinder(d = screw_diameter, h = screw_hole_height);

    translate([0, 0, screw_hole_height])
    cylinder(d = top_diameter, h = 20);
}

//
// Parts
//

module mount_plate() {
    difference() {
        // The main part
        union() {
            translate([-riser_width - riser_length_offset, -35, 0])
            cube([riser_width, 45, riser_height]);

            translate([-riser_width - riser_length_offset - 25, 10, 0])
            cube([riser_width + 25, 25, riser_height]);

            translate(post_screw_a - [0, 0, 8])
            cylinder(d = 10, h = riser_height + 5);
        }
        
        #union() {
            translate([-riser_width / 2 - riser_length_offset, -20, 0])
            union() {
                // Cutouts for the mounting screws for the riser
                translate([-screw_distance / 2, 0, 0])
                cylinder(d = 5, h = 10);

                translate([screw_distance / 2, 0, 0])
                cylinder(d = 5, h = 10);

                // Cutouts for the PCIe card's plate
                translate([-36 / 2 + 2, 14, 0])
                cube([36, 4, riser_height]);
            }
        }
    }
}

// All screws and cutouts required by the base plate
module base_cutouts() {
    union() {
        translate(small_screw_a)
        post_screw();

        translate(small_screw_b)
        post_screw();

        translate(flat_screw_a)
        flat_screw();

        translate(flat_screw_b)
        flat_screw();

        translate(post_screw_a)
        post_screw();

        translate(square_cutout_pos)
        cube([square_length, square_width + 10, 20]);
    }
}


difference() {
    mount_plate();
    #base_cutouts();
}
