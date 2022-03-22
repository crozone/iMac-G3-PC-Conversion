// iMac G3 PSU mount for back of the ITX mobo plate.
// Ryan Crosby 2020
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

//
// Variables
//

baseplate_post_height = 7.5;

screw_a_pos = [5, -22, baseplate_post_height];
screw_b_pos = screw_a_pos + [70, 5, 0];

//
// Modules
//

module screw_hole(h = 5) {
    cylinder(d = 3 + 1, h = h);
}

module psu_mount_plate() {
    difference() {
        psu_width = 125;
        psu_height = 63.5;

        cube([psu_width, psu_height, 5]);

        union() {
            translate([10, 5, 0])
            cube([psu_width - 10 * 2, 40, 5]);

            %translate([10, 5, 0])
            cube([33, 40, 5]);

            screw_x_offset = 6;
            screw_y_offset = 6;

            translate([screw_x_offset, screw_y_offset, 0])
            screw_hole();

            translate([screw_x_offset, screw_y_offset + 25.7, 0])
            screw_hole();

            translate([screw_x_offset, screw_y_offset + 51.5, 0])
            screw_hole();

            translate([screw_x_offset + 113, screw_y_offset, 0])
            screw_hole();

            translate([screw_x_offset + 113, screw_y_offset + 25.7, 0])
            screw_hole();

            translate([screw_x_offset + 113, screw_y_offset + 51.5, 0])
            screw_hole();
        }
    }
}

module mobo_mount_plate() {
    plate_height = 20;
    plate_width = 40;

    union() {
        difference() {
            cube([plate_width, plate_height, 5]);

            translate([plate_width /2 - 19 /2, plate_height /2 + 2.5, 0])
            screw_hole();

            translate([plate_width /2 + 19 /2, plate_height /2 + 2.5, 0])
            screw_hole();
        }

        cube([5, 20, 63.5]);

        translate([plate_width /2 - 2.5, 0, 0])
        cube([5, 20, 63.5]);

        translate([plate_width - 5, 0, 0])
        cube([5, 20, 63.5]);
    }
}


module psu_bracket() {
    union() {
        psu_mount_plate();

        translate([53 + 45, 0, 0])
        //translate([0, 5, 0])
        rotate([90, 0, 180])
        mobo_mount_plate();
    }
}

psu_bracket();

//mobo_mount_plate();
