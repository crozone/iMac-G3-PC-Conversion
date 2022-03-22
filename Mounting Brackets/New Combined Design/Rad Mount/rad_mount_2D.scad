use <../Shared/2Dshapes.scad>;
use <../Shared/tab_strip.scad>;
use <../Connecting Tabs/angle_tab_2d.scad>

include  <../Shared/shared_settings.scad>;

$fn=256;

tab_height = material_thickness; // Same as material thickness.
extra_plate_height = 10;

plate_width = 240;
plate_height = 200 + tab_height + extra_plate_height; // Add tab height since measurements are to the inner side of the joining piece
plate_size = [plate_width, plate_height];
plate_corner_radius = [4, 4];

bottom_extension_width = 180;
bottom_extension_height = 50;
bottom_extension_size = [bottom_extension_width, bottom_extension_height];

inner_vent_cutout_radius = [10, 10];

radiator_cutout_width = 120 + 1; // Radiator is 120mm wide. Add 1mm tolerance.
radiator_cutout_height = 35 + 10; // Radiator is 35mm tall. Add 15mm tolerance to account for radiator bracket being on an angle.

rad_mount_screw_spacing = 185; // All screws that mount the radiator to the plate are in an 18.5mm x 18.5mm square

rad_offset = [15 - 25, -extra_plate_height / 2 + 10]; // The offset from center that the radiator sits on the mount, relative to its mounting screws.

// The radiator mounting plate part, without tabs.
module rad_mount_2d_no_tabs() {
    // The rad plate bounds. Centered around [0,0].
    module plate() {
        // Round the top left and right corners
        // complexRoundSquare(size, top left radius, top right radius, bottom right radius, bottom left radius, center)
        complexRoundSquare(plate_size, rads1=[0,0], rads2=[0,0], rads3=plate_corner_radius, rads4=plate_corner_radius, center=true);
    }

    module buttom_extension_plate() {
        complexRoundSquare(bottom_extension_size, rads1=[0,0], rads2=[0,0], rads3=plate_corner_radius, rads4=plate_corner_radius, center=true);
    }

    module buttom_extension() {
        buttom_extension_plate();
    }

    module rad_port_hole() {
        circle(d = 20, center = true);
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
        circle(d = 3.4, center = true);
    }

    // Screwholes for the screws that mount the radiator to this plate.
    module rad_screw_holes() {
        translate([-rad_mount_screw_spacing / 2, -rad_mount_screw_spacing / 2])
        rad_screw_hole();

        translate([rad_mount_screw_spacing / 2, -rad_mount_screw_spacing / 2])
        rad_screw_hole();

        translate([-rad_mount_screw_spacing / 2, rad_mount_screw_spacing / 2])
        rad_screw_hole();

        translate([rad_mount_screw_spacing / 2, rad_mount_screw_spacing / 2])
        rad_screw_hole();
    }

    // The center square cutout in the middle of the radiator for airflow
    module vent_cutout() {
        complexRoundSquare([185, 180], rads1=inner_vent_cutout_radius, rads2=inner_vent_cutout_radius, rads3=inner_vent_cutout_radius, rads4=inner_vent_cutout_radius, center=true);
    }
    
    translate([0, plate_height / 2]) // Submodules are centered over [0,0], so adjust the entire plate module so the top edge of plate is at [0,0].
    difference() {

        union() {
            plate();

            translate([0, (plate_height / 2) + (bottom_extension_height / 2) ])
            buttom_extension();
        }

        // Items cut out of the plate, including screw holes and cutouts
        translate(rad_offset)
        union() {
            rad_screw_holes();

            // Port holes are centered relative to middle of radiator, and 19mm left from left raidator screw mounts.
            translate([rad_mount_screw_spacing / 2 + 19, 0])
            rad_port_holes();

            vent_cutout();
        }
    }
}

module top_tabs() {
    translate([0, 0])
    tab_strip(width = 240, tab_width = 10, tab_height = tab_height);
}

module bottom_tabs() {
    translate([0, plate_height + bottom_extension_height])
    tab_strip(width = 180, tab_width = 10, tab_height = tab_height);
}

module reservoir_cutout() {
    translate([0, (-radiator_cutout_height / 2)])
    square([radiator_cutout_width, radiator_cutout_height], center = true);
}

// The radiator mounting plate part, with tabs to interlock into the top plate and bottom plate.
module rad_mount_2d() {
    difference() {
        union() {
            difference() {
                rad_mount_2d_no_tabs();

                // Tabbed interface to top plate
                top_tabs();
            }

            // Tabbed interface to bottom plate
            bottom_tabs();
        }

        // Cutout at the bottom of the extension to fit around the reservoir
        translate([0, plate_height + bottom_extension_height + tab_height])
        #reservoir_cutout();

        // Cutouts at top of radiator plate, for mounting tabs
        union() {
            translate([113, 15 + 10])
            angle_tabs_cutout();

            translate([-113, 15 + 10])
            angle_tabs_cutout();
        }
    }
}

module rad_mount_3d() {
    linear_extrude(height = material_thickness) {
        rad_mount_2d();
    }
}

rad_mount_2d();
