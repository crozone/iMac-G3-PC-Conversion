use <../Shared/2Dshapes.scad>;
use <../Shared/tab_strip.scad>;
use <../Shared/rounded_corner.scad>;
use <../Connecting Tabs/angle_tab_2d.scad>

include  <../Shared/shared_settings.scad>;
include <../Rad Bottom Mount/bottom_mount_settings.scad>;

// Set default viewport location
$vpt = [ 0, 122, 0 ];
$vpr = [ 0, 0, 0 ];

$fn = $preview ? 64 : 512;

// A very small distance to overcome rounding errors
$eps = pow(2, -15);

// Render mode:
//
// 0: 3D visual
// 1: 2D cutter layout
// 2: 2D test

RENDER_MODE = 2;

// Engrave mode:
//
// 0: Model only
// 1: Model and engrave
// 2: Engrave only

ENGRAVE_MODE = 1;

tab_height = material_thickness; // Same as material thickness.
plate_lower_buffer = 7.5 + 5; // 10
plate_upper_buffer = 7.5;

extension_height = 15 + 8 - 5 + 2; // 35
// Length of extra material that hangs past the bottom most tabs
bottom_overhang = 5;
//bottom_tab_size = [50, 35 + bottom_overhang];
bottom_tab_size = [50, extension_height + bottom_overhang];

plate_width = 245;
plate_height = 195 + tab_height + plate_lower_buffer + plate_upper_buffer; // Add tab height since measurements are to the inner side of the joining piece
plate_size = [plate_width, plate_height];
plate_offset = [5 - 1, 0];

inner_vent_cutout_radius = [10, 10];
inner_vent_cutout_size = [185, 180] - [2, 2];

radiator_cutout_width = 120 + 1; // Radiator is 120mm wide. Add 1mm tolerance.
radiator_cutout_height = 35 + 10; // Radiator is 35mm tall. Add 15mm tolerance to account for radiator bracket being on an angle.

rad_mount_screw_spacing = 185; // All screws that mount the radiator to the plate are in an 18.5mm x 18.5mm square

//rad_offset = [15 - 25, -plate_lower_buffer / 2 + plate_upper_buffer]; // The offset from center that the radiator sits on the mount, relative to its mounting screws.
rad_offset = [-15 + 25 - 1, plate_upper_buffer]; // The offset from center that the radiator sits on the mount, relative to its mounting screws.

// total height from the top of the bottom tab cutout, to y = 0.
total_height = plate_height + extension_height;
echo(str("Length: ", str(total_height)));

part_name = "iMac Radiator Mount // v1.4";

function get_rad_mount_height() = total_height;

module module_label() {
    text_line1 = part_name;
    text_line2 = str("Length: ", str(total_height), " // ", "Lower Buffer: ", str(plate_lower_buffer), " // ", "Upper Buffer: ", str(plate_upper_buffer), " // ", "Extension: ", str(extension_height));

    echo(text_line1);
    echo(text_line2);

    union() {
        text(text = text_line1, font = text_font, size = 3, halign = "center", valign = "top");

        translate([0, -4])
        text(text = text_line2, font = text_font, size = 2, halign = "center", valign = "top");
    }
}

// The radiator mounting plate part, without tabs.
module rad_mount_2d_no_tabs(engrave_mode) {
    // The rad plate bounds. Centered around [0,0].
    module plate() {
        // Round the top left and right corners
        // complexRoundSquare(size, top left radius, top right radius, bottom right radius, bottom left radius, center)
        complexRoundSquare(plate_size, rads1=[0,0], rads2=[0,0], rads3=[15, 15], rads4=[15, 15], center=false);
    }

    module buttom_extension() {
        union() {
            arch_rad = 15;

            // Left (more negative X) extension
            {
                left_offset = -50 - 33.5;
                translate([left_offset, 0])
                complexRoundSquare(bottom_tab_size, rads1=[0,0], rads2=[0,0], rads3=[4, 4], rads4=[4, 4], center=false);

                translate([arch_rad + left_offset + bottom_tab_size[0] - $eps, arch_rad - $eps])
                rotate(-180)
                rounded_corner(arch_rad);

                translate([-arch_rad + left_offset + $eps, arch_rad - $eps])
                rotate(-90)
                rounded_corner(arch_rad);
            }

            // Right (more positive X) extension
            {
                right_offset = 47;
                translate([right_offset, 0])
                complexRoundSquare(bottom_tab_size, rads1=[0,0], rads2=[0,0], rads3=[4, 4], rads4=[4, 4], center=false);

                translate([-arch_rad + right_offset + $eps, arch_rad - $eps])
                rotate(-90)
                rounded_corner(arch_rad);

                translate([arch_rad + right_offset + bottom_tab_size[0] - $eps, arch_rad - $eps])
                rotate(-180)
                rounded_corner(arch_rad);
            }
        }
    }

    module part() {
        module main_part() {
            // Combine the plate with the bottom extension
            union() {
                translate([-plate_width / 2, 0])
                translate(plate_offset)
                plate();

                translate([0, plate_height])
                buttom_extension();
            }
        }

        module rad_mount_cutouts() {
            // Cut out radiator mounting from the plate, including screw holes and cutouts
            translate(rad_offset)
            translate([0, 13])
            radiator_mounting_cutouts();
        }

        module bottom_mounting_cutouts() {
            // Cut out bottom mounting tabs
            translate([0, plate_height])
            translate([-50 / 2 - 51 - 5, bottom_tab_size[1] - bottom_overhang])
            union() {
                for (this_pos = bottom_mount_tab_positions) {
                    translate(this_pos)
                    union() {
                        side_tolerance = 0.25;
                        // Sideways tolerance is to allow easy rotation in with slightly misaligned tabs
                        translate([-side_tolerance, -bottom_mount_tab_width / 2 - 0.1])
                        square([material_thickness + side_tolerance * 2, 5 + 0.2]);

                        // TEST: No tolerance
                        // translate([0, -bottom_mount_tab_width / 2])
                        // square([material_thickness, 5]);

                        // TEST: Only bottom tolerence
                        //translate([0, -bottom_mount_tab_width / 2])
                        //square([material_thickness, 5 + 0.1]);

                        square([material_thickness, bottom_overhang + $eps]);
                    }
                }
            }
        }

        difference() {
            main_part();
            rad_mount_cutouts();
            bottom_mounting_cutouts();
        }
    }

    module engrave() {
        intersection() {
            part();

            #union() {
                translate([0, plate_size[1] - plate_lower_buffer])
                rotate(180)
                module_label();

                // Center reference
                translate([-0.1, 0])
                square([0.2, total_height], false);
            }
        }
    }

    if(engrave_mode <= 1) {
        part();
    }

    if(engrave_mode >= 1) {
        engrave();
    }
}

// Contains screw holes, vent hole, and port holes for radiator.
module radiator_mounting_cutouts() {
    module rad_port_hole() {
        // Standard plug or L fitting diameter: 20mm
        // Straight compression fitting diameter: 22mm
        // Factor in some healthy tolerance for observed manufacturing variation
        
        port_diameter = 22;
        port_cutout_diameter = port_diameter + 2;

        // Nominal port location
        %circle(d = port_diameter);

        hull() {
            translate([2, 0])
            circle(d = port_cutout_diameter);

            translate([-1, 0])
            circle(d = port_cutout_diameter);
        }
    }

    // Holes cutout for the radiator pipes
    module rad_port_holes() {
        rad_port_holes_separation = 98;

        translate([0, -rad_port_holes_separation / 2])
        rad_port_hole();

        translate([0, rad_port_holes_separation / 2])
        rad_port_hole();
    }

    module rad_screw_hole() {
        circle(d = 3.4);
    }

    // Screwholes for the screws that mount the radiator to this plate.
    module rad_screw_holes() {
        translate([-rad_mount_screw_spacing / 2, -rad_mount_screw_spacing / 2])
        rad_screw_hole();

        translate([rad_mount_screw_spacing / 2, -rad_mount_screw_spacing / 2])
        rad_screw_hole();

        translate([-rad_mount_screw_spacing / 2, rad_mount_screw_spacing / 2])
        rad_screw_hole();

        // // TEST REF
        // #translate([-rad_mount_screw_spacing / 2 - 35, rad_mount_screw_spacing / 2])
        // rad_screw_hole();

        translate([rad_mount_screw_spacing / 2, rad_mount_screw_spacing / 2])
        rad_screw_hole();

        // // TEST REF
        // #translate([rad_mount_screw_spacing / 2 + 25, rad_mount_screw_spacing / 2])
        // rad_screw_hole();
    }

    // The center square cutout in the middle of the radiator for airflow
    module vent_cutout() {
        complexRoundSquare(inner_vent_cutout_size, rads1=inner_vent_cutout_radius, rads2=inner_vent_cutout_radius, rads3=inner_vent_cutout_radius, rads4=inner_vent_cutout_radius, center=true);
    }

    translate([0, rad_mount_screw_spacing / 2])
    union() {
        rad_screw_holes();

        // Port holes are centered relative to middle of radiator, and 19mm left from left raidator screw mounts.
        //translate([rad_mount_screw_spacing / 2 + 19, 0])
        translate([-rad_mount_screw_spacing / 2 - 19, 0])
        rad_port_holes();

        vent_cutout();
    }
}

module top_tabs() {
    translate([0, 0])
    tab_strip(width = 240, tab_width = 10, tab_height = tab_height);
}

// The radiator mounting plate part, with tabs to interlock into the top plate and bottom plate.
module rad_mount_2d(engrave_mode) {
    echo(str("Rad Mount Engrave Mode: ", str(engrave_mode)));

    difference() {
        union() {
            difference() {
                rad_mount_2d_no_tabs(engrave_mode);

                // Tabbed interface to top plate
                top_tabs();
            }
        }

        // Cutouts at top of radiator plate, for mounting tabs
        union() {
            translate([113, 15 + 10])
            angle_tabs_cutout();

            translate([-113, 15 + 10])
            angle_tabs_cutout();
        }

        // Cutouts on bottom
    }
}

module rad_mount_3d(engrave_mode) {
    linear_extrude(height = material_thickness) {
        rad_mount_2d(engrave_mode);
    }
}

if(RENDER_MODE == 0) {
    rad_mount_3d(ENGRAVE_MODE);
}
else if(RENDER_MODE == 1) {
    rad_mount_2d(ENGRAVE_MODE);
}
else if(RENDER_MODE == 2) {
        %rad_mount_2d(ENGRAVE_MODE);
    intersection() {
        rad_mount_2d(ENGRAVE_MODE);

        // TESTS

        //#translate([37, plate_size[1] + 45 - 30 + $eps])
        //square([40, 30]);

        sub_height = 50;
        translate([-plate_size[0] / 2, total_height + bottom_overhang - sub_height + $eps])
        #square([plate_size[0] + 20, sub_height]);
    }
}
