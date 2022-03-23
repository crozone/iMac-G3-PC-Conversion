use <../Shared/2Dshapes.scad>;
use <../Shared/tab_strip.scad>;

include  <../Shared/shared_settings.scad>;

$fn=256;

// Render mode:
//
// 0: 3D visual
// 1: 2D Box Layout
// 2: 2D Cutter Layout

RENDER_MODE = 0;

// Text mode:
//
// 0: Model only
// 1: Model and text
// 2: Text only

TEXT_MODE = 1;

PART_ENABLE = [
    true, true, true, true,
    true, true, true
];

// A very small distance to overcome rounding errors
$eps = pow(2, -15); // 2^-N have exact representations in floating point. 2^-15 ~= 0.0000305

material_thickness = 4.8;
tab_height = material_thickness; // Same as material thickness.

psu_size = [125, 63.5, 100];
psu_offset = [0.25, 0.25, 0];
box_size = [psu_size[0], psu_size[1], 35] + psu_offset * 2;

// Height that PSU sits under clamps
mount_height = 35;

part_name = "iMac PSU Tub v1.0";

function isEven(x) = (x % 2) == 0;

// Size:
//
// A two dimensional array which contains the size of the inner square plate, not including the tabs.

// Tab types:
//
// An array with 4 entries, in the order left, top, right, bottom.
// Possible options:
// 
// 0: None
// 1: Standard tab
// 2: Standard tab with extra width
// 3: Enclosed tab
// 4: Enclosed tab with extra width

// Tabs invert:
//
// An array with 4 entries, in the order left, top, right, bottom.
// Possible options:
//
// 0: Non-inverted
// 1: Inverted.

module tabbed_plate(size, tabs_type, tabs_invert) {
    module plate() {
        square(size, center = false);
    }

    module horizontal_tabs(inverse, enclosed, full_wide, flip) {
        tabs_width = size[0];
        total_width = tabs_width + (full_wide ? 2 * tab_height : 0);

        translate([full_wide ? -tab_height : 0, 0])
        translate([total_width / 2, 0])
        translate([0, flip ? tab_height : 0])
        rotate(flip ? 180 : 0)
        if(!enclosed) {
            tab_strip(width = tabs_width, tab_width = 10, tab_height = tab_height, inverse = inverse);
        }
        else {
            difference() {
                translate([-total_width / 2, -tab_height])
                square([total_width, tab_height * 2]);

                tab_strip(width = tabs_width, tab_width = 10, tab_height = tab_height, inverse = !inverse);
            }
        }
    }

    module bottom_tabs(inverse, enclosed, full_wide) {
        translate([0, -tab_height + $eps])
        horizontal_tabs(inverse, enclosed, full_wide, false);
    }

    module top_tabs(inverse, enclosed, full_wide) {
        translate([0, size[1] - $eps])
        horizontal_tabs(inverse, enclosed, full_wide, true);
    }

    module vertical_tabs(inverse, enclosed, full_wide, flip) {
        total_width = size[1] + (full_wide ? tab_height * 2 : 0);

        translate([0, full_wide ? -tab_height : 0])
        translate([0, total_width / 2])
        rotate(flip ? 90 : -90)
        if(!enclosed) {
            tab_strip(width = total_width, tab_width = 10, tab_height = tab_height, inverse = inverse);
        }
        else {
            difference() {
                translate([-total_width / 2, 0])
                square([total_width, tab_height * 2]);

                tab_strip(width = total_width, tab_width = 10, tab_height = tab_height, inverse = !inverse);
            }
        }
    }

    module left_tabs(inverse, enclosed, full_wide) {
        translate([$eps, 0])
        vertical_tabs(inverse, enclosed, full_wide, true);
    }

    module right_tabs(inverse, enclosed, full_wide) {
        translate([size[0] - $eps, 0])
        vertical_tabs(inverse, enclosed, full_wide, false);
    }

    module tabs() {
        if(tabs_type[3] > 0) {
            bottom_tabs(tabs_invert[3] > 0, tabs_type[3] > 2, isEven(tabs_type[3]));
        }

        if(tabs_type[1] > 0) {
            top_tabs(tabs_invert[1] > 0, tabs_type[1] > 2, isEven(tabs_type[1]));
        }

        if(tabs_type[0] > 0) {
            left_tabs(tabs_invert[0] > 0, tabs_type[0] > 2, isEven(tabs_type[0]));
        }
        
        if(tabs_type[2] > 0) {
            right_tabs(tabs_invert[2] > 0, tabs_type[2] > 2, isEven(tabs_type[2]));
        }
    }
    
    union() {
        plate();
        tabs();
    }
}

module psu_mount_A_2d() {
    plate_size = [box_size[0], box_size[1]];
    inner_cutout_size = plate_size - [20, 20];
    inner_cutout_offset = [10, 10];
    inner_cutout_corner_radius = [4, 4];

    psu_screw_diameter = 4;
    psu_screw_positions = [
        [6, 6], [6, 6 + 25.7], [6, 6 + 25.7 + 25.8],
        [6 + 113, 6], [6 + 113, 6 + 25.7], [6 + 113, 6 + 25.7 + 25.8]
    ];

    module psu_screw_holes() {
        for (this_pos = psu_screw_positions) {
            translate(this_pos)
            circle(d = psu_screw_diameter, center = true);
        }
    }

    // The center square cutout in the middle of the radiator for airflow
    module inner_cutout() {
        complexRoundSquare(inner_cutout_size, rads1=inner_cutout_corner_radius, rads2=inner_cutout_corner_radius, rads3=inner_cutout_corner_radius, rads4=inner_cutout_corner_radius, center=false);
    }
    
    // Part
    if(TEXT_MODE < 2) {
        difference() {
            tabbed_plate(plate_size, [1, 0, 1, 1], [0, 0, 0, 1]);

            translate(psu_offset)
            psu_screw_holes();

            translate(inner_cutout_offset)
            inner_cutout();
        }
    }

    // Text
    if(TEXT_MODE > 0) {
        translate([40, 3])
        rotate(180)
        module_label("Plate A");
    }
}

module psu_mount_B_2d() {
    // Part
    if(TEXT_MODE < 2) {
        union() {
            plate_size = [box_size[0], box_size[2]];
            tabbed_plate(plate_size, [1, 4, 1, 4], [0, 0, 0, 0]);
        }
    }

    // Text
    if(TEXT_MODE > 0) {
        translate([40, 3])
        rotate(180)
        module_label("Plate B");
    }
}

module psu_mount_C_2d() {
    // Part
    if(TEXT_MODE < 2) {
        union() {
            plate_size = [box_size[1], box_size[2]];
            tabbed_plate(plate_size, [1, 3, 0, 3], [1, 1, 0, 1]);
        }
    }

    // Text
    if(TEXT_MODE > 0) {
        translate([40, 3])
        rotate(180)
        module_label("Plate C");
    }
}

module psu_mount_D_2d() {
    // Part
    if(TEXT_MODE < 2) {
        union() {
            plate_size = [box_size[1], box_size[2]];
            tabbed_plate(plate_size, [0, 3, 1, 3], [0, 1, 1, 1]);
        }
    }

    // Text
    if(TEXT_MODE > 0) {
        translate([40, 3])
        rotate(180)
        module_label("Plate D");
    }
}

// Depth of the rear side mount/
// Needs to be shared for translation calculations.
side_mount_A_height = 25;

module side_mount_A_2d() {
    // Part
    if(TEXT_MODE < 2) {
        difference() {
            union() {
                translate([-tab_height, 0])
                square([box_size[0] + 2 * tab_height, side_mount_A_height]);

                translate([box_size[0] / 2, side_mount_A_height])
                tab_strip(width = box_size[0], tab_width = 10, tab_height = tab_height, inverse = true);
            }

            union() {
                // Tabs to lock into side_mount_B_2d
                translate([0, side_mount_A_height / 2])
                rotate(90)
                tab_strip(width = side_mount_A_height, tab_width = 10, tab_height = tab_height, inverse = false);

                // Tabs to lock into side_mount_C_2d
                translate([box_size[0] + tab_height, side_mount_A_height / 2])
                rotate(90)
                tab_strip(width = side_mount_A_height, tab_width = 10, tab_height = tab_height, inverse = false);
            }
        }
    }

    // Text
    if(TEXT_MODE > 0) {
        translate([15, 15])
        module_label("Holder A");
    }
}

module side_mount_B_2d() {
    width = 20;
    height = box_size[1] + side_mount_A_height + material_thickness;

        // Part
    if(TEXT_MODE < 2) {
        union() {
            square([width, height]);

            // Tabs to lock into PSU bucket
            translate([$eps, box_size[1] / 2 + side_mount_A_height + material_thickness])
            rotate(90)
            tab_strip(width = box_size[1], tab_width = 10, tab_height = tab_height, inverse = false);

            // Tabs to lock into side_mount_A_2d
            translate([$eps, side_mount_A_height / 2])
            rotate(90)
            tab_strip(width = side_mount_A_height, tab_width = 10, tab_height = tab_height, inverse = false);
        }
    }

        // Text
    if(TEXT_MODE > 0) {
        translate([10, 15])
        rotate(90)
        module_label("Holder B");
    }
}

module side_mount_C_2d() {
    width = 20;

    // Part
    if(TEXT_MODE < 2) {
        union() {
            translate([-tab_height - width, 0])
            square([width, box_size[1] + side_mount_A_height + material_thickness]);

            // Tabs to lock into PSU bucket
            translate([-$eps, box_size[1] / 2 + side_mount_A_height + material_thickness])
            rotate(90)
            tab_strip(width = box_size[1], tab_width = 10, tab_height = tab_height, inverse = false);

            // Tabs to lock into side_mount_A_2d
            translate([-$eps, side_mount_A_height / 2])
            rotate(90)
            tab_strip(width = side_mount_A_height, tab_width = 10, tab_height = tab_height, inverse = false);
        }
    }

    // Text
    if(TEXT_MODE > 0) {
        translate([-20, 10])
        rotate(90)
        module_label("Holder C");
    }
}

module module_label(sub_part_name) {
    text_line1 = part_name;
    text_line2 = sub_part_name;

    echo(str(text_line1, " // ", text_line2));

    #color("red")
    union() {
        text(text = text_line1, font = text_font, size = 2, halign = "left", valign = "top");

        translate([0, -3])
        text(text = text_line2, font = text_font, size = 2, halign = "left", valign = "top");
    }
}

module psu_mount_2d_layout() {
    if(PART_ENABLE[0]) {
        psu_mount_A_2d();
    }

    if(PART_ENABLE[1]) {
        translate([0, -box_size[2] - tab_height * 4])
        psu_mount_B_2d();
    }

    if(PART_ENABLE[2]) {
        translate([box_size[0] + tab_height * 3, -box_size[2] - tab_height * 4])
        psu_mount_C_2d();
    }

    if(PART_ENABLE[3]) {
        translate([-box_size[1] - tab_height * 3, -box_size[2] - tab_height * 4])
        psu_mount_D_2d();
    }

    if(PART_ENABLE[4]) {
        translate([0, -box_size[2] * 2 - tab_height * 6])
        side_mount_A_2d();
    }

    if(PART_ENABLE[5]) {
        translate([box_size[0] + 2 * tab_height, -box_size[2] * 2 -tab_height])
        rotate(-90)
        side_mount_B_2d();
    }

    if(PART_ENABLE[6]) {
        translate([-tab_height * 2, -box_size[1] - tab_height])
        rotate(90)
        side_mount_C_2d();
    }
}

module psu_mount_2d_cutter_layout() {
    if(PART_ENABLE[0]) {
        psu_mount_A_2d();
    }

    if(PART_ENABLE[1]) {
        translate([0, -box_size[2] - tab_height * 4])
        psu_mount_B_2d();
    }

    if(PART_ENABLE[2]) {
        translate([box_size[0] + tab_height * 3, -box_size[2] - tab_height * 4])
        psu_mount_C_2d();
    }

    if(PART_ENABLE[3]) {
        translate([box_size[0] + 2 * tab_height, 10])
        psu_mount_D_2d();
    }

    if(PART_ENABLE[4]) {
        translate([0, -box_size[2] * 2 - tab_height * 6])
        side_mount_A_2d();
    }

    if(PART_ENABLE[5]) {
        translate([box_size[0] + 2 * tab_height, -box_size[2] * 2 -tab_height])
        rotate(-90)
        side_mount_B_2d();
    }

    if(PART_ENABLE[6]) {
        //translate([-tab_height * 2, -box_size[1] - tab_height])
        translate([110, 40])
        rotate(90)
        side_mount_C_2d();
    }
}

module psu_mount_3d() {
    // Bottom
    if(PART_ENABLE[0]) {
        color("pink")
        translate([0, 0, -material_thickness])
        linear_extrude(height = material_thickness) {
            psu_mount_A_2d();
        }
    }

    // Back
    if(PART_ENABLE[1]) {
        color("purple")
        translate([0, -tab_height, box_size[2]])
        rotate([-90, 0, 0])
        linear_extrude(height = material_thickness) {
            psu_mount_B_2d();
        }
    }

    // Right
    if(PART_ENABLE[2]) {
        color("blue")
        translate([box_size[0] + tab_height, 0, box_size[2]])
        rotate([-90, 0, 90])
        linear_extrude(height = material_thickness) {
            psu_mount_C_2d();
        }
    }

    // Left
    if(PART_ENABLE[3]) {
        color("blue")
        translate([-tab_height, box_size[1], box_size[2]])
        rotate([-90, 0, -90])
        linear_extrude(height = material_thickness) {
            psu_mount_D_2d();
        }
    }

    // Back mount
    if(PART_ENABLE[4]) {
        color("red")
        translate([0, -side_mount_A_height - tab_height, mount_height])
        linear_extrude(height = material_thickness) {
            side_mount_A_2d();
        }
    }

    // SIDE B
    if(PART_ENABLE[5]) {
        color("green")
        translate([box_size[0] + material_thickness, -side_mount_A_height - tab_height, mount_height])
        linear_extrude(height = material_thickness) {
            side_mount_B_2d();
        }
    }

    if(PART_ENABLE[6]) {
        color("orange")
        translate([0, -side_mount_A_height - tab_height, mount_height])
        linear_extrude(height = material_thickness) {
            side_mount_C_2d();
        }
    }

    translate(psu_offset)
    %cube(psu_size);
}

if(RENDER_MODE == 0) {
    psu_mount_3d();
}
else if(RENDER_MODE == 1) {
    psu_mount_2d_layout();
}
else if(RENDER_MODE == 2) {
    psu_mount_2d_cutter_layout();
}
