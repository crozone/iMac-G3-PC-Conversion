use <../Shared/2Dshapes.scad>;
use <../Shared/tab_strip.scad>;
use <../Shared/baseplate_screw_holes.scad>;

include  <../Shared/shared_settings.scad>;

$fn=256;

// Render mode:
//
// 0: 3D visual
// 1: 2D stacked
// 2: 2D Box Layout
// 3: 2D Cutter Layout
// 4: 2D side holder test layout

RENDER_MODE = 0;

// Text mode:
//
// 0: Model only
// 1: Model and text
// 2: Text only

TEXT_MODE = 1;

PART_ENABLE = [
    true,
    true,
    true,
    true,

    true,
    true,
    true
];

// A very small distance to overcome rounding errors
$eps = pow(2, -15); // 2^-N have exact representations in floating point. 2^-15 ~= 0.0000305

material_thickness = 4.5;
tab_height = material_thickness - 0.1; // Same as material thickness.

psu_size = [125, 63.5, 100];
psu_offset = [1.5, 0.5, 0];
box_size = [psu_size[0], psu_size[1], 35] + psu_offset * 2;

// Height that PSU sits under clamps
mount_height = 35;

part_name = "iMac PSU Tub v1.2";

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
        translate([0, flip ? material_thickness : 0])
        rotate(flip ? 180 : 0)
        if(!enclosed) {
            tab_strip(width = tabs_width, tab_width = 10, tab_height = tab_height, inverse = inverse);
        }
        else {
            difference() {
                translate([-total_width / 2, -tab_height])
                square([total_width, material_thickness + tab_height]);

                tab_strip(width = tabs_width, tab_width = 10, tab_height = material_thickness, inverse = !inverse);
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
        total_width = size[1] + (full_wide ? material_thickness * 2 : 0);

        translate([0, full_wide ? -material_thickness : 0])
        translate([0, total_width / 2])
        rotate(flip ? 90 : -90)
        if(!enclosed) {
            tab_strip(width = total_width, tab_width = 10, tab_height = tab_height, inverse = inverse);
        }
        else {
            difference() {
                translate([-total_width / 2, 0])
                square([total_width, material_thickness + tab_height]);

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
    inner_cutout_size = [125, 63.5] - [20, 15];
    inner_cutout_offset = psu_offset + [10.0, 9.5];
    inner_cutout_corner_radius = [2, 2];

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
        complexRoundSquare(inner_cutout_size - [0, 6], rads1=[1,1], rads2=inner_cutout_corner_radius, rads3=inner_cutout_corner_radius, rads4=inner_cutout_corner_radius, center=false);
    
        // Additional cutout for the power switch
        translate([inner_cutout_size[0] - 25, -5])
        complexRoundSquare([25, 15 + 5], rads1=[1,1], rads2=[1,1], rads3=[0,0], rads4=[0,0], center=false);
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
        translate([75, 55])
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
        translate([75, 5])
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
        translate([40, 5])
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
        translate([40, 5])
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
                translate([-material_thickness, 0])
                square([box_size[0] + 2 * material_thickness, side_mount_A_height]);

                translate([box_size[0] / 2, side_mount_A_height])
                tab_strip(width = box_size[0], tab_width = 10, tab_height = tab_height, inverse = true);
            }

            union() {
                // Tabs to lock into side_mount_B_2d
                translate([0, side_mount_A_height / 2])
                rotate(90)
                tab_strip(width = side_mount_A_height, tab_width = 10, tab_height = material_thickness, inverse = false);

                // Tabs to lock into side_mount_C_2d
                translate([box_size[0] + material_thickness, side_mount_A_height / 2])
                rotate(90)
                tab_strip(width = side_mount_A_height, tab_width = 10, tab_height = material_thickness, inverse = false);
            }

            // Baseplate screw-holes
            // Note, this transform must be the exact opposite of the top-down X/Y transform of this part,
            // such that planar_global_cutouts() aligns back to (0,0).
            translate(-[0, -side_mount_A_height - material_thickness])
            planar_global_cutouts();
        }
    }

    // Text
    if(TEXT_MODE > 0) {
        translate([25, 15])
        module_label("Holder A");
    }
}

module side_mount_B_2d() {
    width = 20;
    height = box_size[1] + side_mount_A_height + material_thickness;

        // Part
    if(TEXT_MODE < 2) {
        difference() {
            union() {
                plate_size = [width, height];
                //square(plate_size);
                complexRoundSquare(plate_size, rads1=[0,0], rads2=[5,5], rads3=[5,5], rads4=[0,0], center=false);

                // Tabs to lock into PSU bucket
                translate([$eps, box_size[1] / 2 + side_mount_A_height + material_thickness])
                rotate(90)
                tab_strip(width = box_size[1], tab_width = 10, tab_height = tab_height, inverse = false);

                // Tabs to lock into side_mount_A_2d
                translate([$eps, side_mount_A_height / 2])
                rotate(90)
                tab_strip(width = side_mount_A_height, tab_width = 10, tab_height = material_thickness, inverse = false);
            }

            // Baseplate screw-holes
            // Note, this transform must be the exact opposite of the top-down X/Y transform of this part,
            // such that planar_global_cutouts() aligns back to (0,0).
            translate(-[box_size[0] + material_thickness, -side_mount_A_height - material_thickness])
            planar_global_cutouts();
        }
    }

        // Text
    if(TEXT_MODE > 0) {
        translate([13, 35])
        rotate(90)
        module_label("Holder B");
    }
}

module side_mount_C_2d() {
    width = 40;

    // Part
    if(TEXT_MODE < 2) {
        difference() {
            union() {
                plate_size = [width, box_size[1] + side_mount_A_height + material_thickness];

                translate([-material_thickness - width, 0])
                complexRoundSquare(plate_size, rads1=[5,5], rads2=[0,0], rads3=[0,0], rads4=[5,5], center=false);

                // Tabs to lock into PSU bucket
                translate([-$eps - (material_thickness - tab_height), box_size[1] / 2 + side_mount_A_height + material_thickness])
                rotate(90)
                tab_strip(width = box_size[1], tab_width = 10, tab_height = tab_height, inverse = false);

                // Tabs to lock into side_mount_A_2d
                translate([-$eps, side_mount_A_height / 2])
                rotate(90)
                tab_strip(width = side_mount_A_height, tab_width = 10, tab_height = material_thickness, inverse = false);
            }

            // Baseplate screw-holes
            // Note, this transform must be the exact opposite of the top-down X/Y transform of this part,
            // such that planar_global_cutouts() aligns back to (0,0).
            translate(-[0, -side_mount_A_height - material_thickness])
            planar_global_cutouts();
        }
    }

    // Text
    if(TEXT_MODE > 0) {
        translate([-35, 10])
        rotate(90)
        module_label("Holder C");
    }
}

// planar_global_cutouts includes all cutouts that need to be applied to the parts horizontally, when in their final position.
// This is used to cut out anything that needs to interface to another separate part, which includes
// the baseplate mounting screw holes, as well as the radiator mounting tabs.
//
module planar_global_cutouts() {
    // The bottom right screwhole is 15mm to the left of the box outer left edge, 3mm down from the box outer lower edge
    origin_offset = [-material_thickness - 15, -material_thickness - 3];

    screw_positions = [
        // Left side (Side Holder C)
        origin_offset + baseplate_screwhole_offset([0, 0], false),
        origin_offset + baseplate_screwhole_offset([0, 1], false),
        origin_offset + baseplate_screwhole_offset([-2, 2], false),
        origin_offset + baseplate_screwhole_offset([-2, 4], false),

        // Right side (Side Holder C)
        origin_offset + baseplate_screwhole_offset([20, 0], false),
        origin_offset + baseplate_screwhole_offset([20, 1], false),
        origin_offset + baseplate_screwhole_offset([20, 3], false),
        origin_offset + baseplate_screwhole_offset([20, 4], false),

        // Bottom side (Side Holder A)
        origin_offset + baseplate_screwhole_offset([16, -1], true),

        // // Test holes for through port alignment
        // origin_offset + baseplate_screwhole_offset([0, 2], false),
        // origin_offset + baseplate_screwhole_offset([-1, 5], false),
    ];

    // Screw holes for mounting to baseplate
    for (this_pos = screw_positions) {
        translate(this_pos)
        baseplate_screw_hole();
    }

    // Through hole port on left
    translate([-25, 20])
    complexRoundSquare([15, 40], rads1=[5,5], rads2=[5,5], rads3=[5,5], rads4=[5,5], center=false);
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

module psu_mount_2d_stacked_layout() {
    if(PART_ENABLE[0]) {
        psu_mount_A_2d();
    }

    if(PART_ENABLE[1]) {
        psu_mount_B_2d();
    }

    if(PART_ENABLE[2]) {
        psu_mount_C_2d();
    }

    if(PART_ENABLE[3]) {
        psu_mount_D_2d();
    }

    if(PART_ENABLE[4]) {
        side_mount_A_2d();
    }

    if(PART_ENABLE[5]) {
        side_mount_B_2d();
    }

    if(PART_ENABLE[6]) {
        side_mount_C_2d();
    }
}

module psu_mount_2d_layout() {
    if(PART_ENABLE[0]) {
        psu_mount_A_2d();
    }

    if(PART_ENABLE[1]) {
        translate([0, -box_size[2] - material_thickness * 4])
        psu_mount_B_2d();
    }

    if(PART_ENABLE[2]) {
        translate([box_size[0] + material_thickness * 3, -box_size[2] - material_thickness * 4])
        psu_mount_C_2d();
    }

    if(PART_ENABLE[3]) {
        translate([-box_size[1] - material_thickness * 3, -box_size[2] - material_thickness * 4])
        psu_mount_D_2d();
    }

    if(PART_ENABLE[4]) {
        translate([0, -box_size[2] * 2 - material_thickness * 6])
        side_mount_A_2d();
    }

    if(PART_ENABLE[5]) {
        translate([box_size[0] + 2 * material_thickness, -box_size[2] * 2 -material_thickness])
        rotate(-90)
        side_mount_B_2d();
    }

    if(PART_ENABLE[6]) {
        translate([-material_thickness * 2, -box_size[1] - material_thickness])
        rotate(90)
        side_mount_C_2d();
    }
}

// Acrylic sheets are 300mm wide.
// Aim to fit within 300 x 135mm
module psu_mount_2d_cutter_layout() {
    if(PART_ENABLE[0]) {
        psu_mount_A_2d();
    }

    if(PART_ENABLE[1]) {
        translate([0, -box_size[2] - material_thickness * 4])
        psu_mount_B_2d();
    }

    if(PART_ENABLE[2]) {
        translate([box_size[0] + 16, -box_size[2] + 40])
        rotate(270)
        psu_mount_C_2d();
    }

    if(PART_ENABLE[3]) {
        translate([box_size[0] + material_thickness * 3 + 93, -box_size[2] - 24])
        rotate(90)
        psu_mount_D_2d();
    }

    if(PART_ENABLE[4]) {
        translate([box_size[0] + 148, -box_size[2] * 2 - material_thickness * 6 + 29])
        rotate(90)
        side_mount_A_2d();
    }

    if(PART_ENABLE[5]) {
        translate([111, 25])
        rotate(90)
        side_mount_B_2d();
    }

    if(PART_ENABLE[6]) {
        translate([140, 15])
        rotate(-90)
        side_mount_C_2d();
    }
}

module psu_mount_2d_holder_test_layout() {
    if(PART_ENABLE[0]) {
        psu_mount_A_2d();
    }

    if(PART_ENABLE[4]) {
        translate([0, -side_mount_A_height - material_thickness])
        side_mount_A_2d();
    }

    if(PART_ENABLE[5]) {
        translate([box_size[0] + material_thickness, -side_mount_A_height - material_thickness])
        side_mount_B_2d();
    }

    if(PART_ENABLE[6]) {
        translate([0, -side_mount_A_height - material_thickness])
        side_mount_C_2d();
    }

    // The screw cutouts are actually cut out from the side-mount parts directly, using the appropriate transform for each part.
    // This is here as a guide to verify that the transforms are correct, and that the holes align correctly.
    %planar_global_cutouts();
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
        translate([0, -material_thickness, box_size[2]])
        rotate([-90, 0, 0])
        linear_extrude(height = material_thickness) {
            psu_mount_B_2d();
        }
    }

    // Right
    if(PART_ENABLE[2]) {
        color("blue")
        translate([box_size[0] + material_thickness, 0, box_size[2]])
        rotate([-90, 0, 90])
        linear_extrude(height = material_thickness) {
            psu_mount_C_2d();
        }
    }

    // Left
    if(PART_ENABLE[3]) {
        color("blue")
        translate([-material_thickness, box_size[1], box_size[2]])
        rotate([-90, 0, -90])
        linear_extrude(height = material_thickness) {
            psu_mount_D_2d();
        }
    }

    // Back mount
    if(PART_ENABLE[4]) {
        color("red")
        translate([0, -side_mount_A_height - material_thickness, mount_height])
        linear_extrude(height = material_thickness) {
            side_mount_A_2d();
        }
    }

    // SIDE B
    if(PART_ENABLE[5]) {
        color("green")
        translate([box_size[0] + material_thickness, -side_mount_A_height - material_thickness, mount_height])
        linear_extrude(height = material_thickness) {
            side_mount_B_2d();
        }
    }

    if(PART_ENABLE[6]) {
        color("orange")
        translate([0, -side_mount_A_height - material_thickness, mount_height])
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
    psu_mount_2d_stacked_layout();
}
else if(RENDER_MODE == 2) {
    psu_mount_2d_layout();
}
else if(RENDER_MODE == 3) {
    psu_mount_2d_cutter_layout();
}
else if(RENDER_MODE == 4) {
    psu_mount_2d_holder_test_layout();
}
