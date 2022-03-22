// iMac G3 PCIe Spacer for underneath the PCIe riser cable female end
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

screw_spacing = 125;
screw_offset = [5, 0, 0];

spacing_height = 5;
spacing_width = 14;
spacing_length = 140;

spacing_offset = [0, -10, 0];
spacing_dimensions = [spacing_length, spacing_width + 10, spacing_height];

side_box_dimensions = [spacing_length, spacing_width + 10, spacing_height - 2];

screw_a_pos = [0, spacing_width / 2, 0] + screw_offset;
screw_b_pos = [screw_spacing, spacing_width / 2, 0] + screw_offset;

//
// Modules
//

module screw_hole(h = 10) {
    cylinder(d = 3 + 1, h = h);
}

module screw_hole_wide(h = 10) {
    hull() {
        screw_hole(h);

        translate([5, 0, 0])
        screw_hole(h);
    }
}

module mainbox() {
    cube(spacing_dimensions);
}

module side_box() {
    cube(side_box_dimensions);
}

module spacer() {
    difference() {
        union() {
            translate(spacing_offset)
            mainbox();

            side_box();
        }

        #translate([0, 0, -1])
        union() {
            translate(screw_a_pos)
            screw_hole_wide();

            translate(screw_b_pos - [-1, 0, 0])
            screw_hole_wide();
        }
    }
}

spacer();
