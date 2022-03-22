use <../Shared/2Dshapes.scad>;
use <../Shared/tab_strip.scad>;
use <../Connecting Tabs/angle_tab_2d.scad>

include  <../Shared/shared_settings.scad>;

$fn=256;

tab_height = material_thickness; // Same as material thickness.
plate_width = 270;
plate_height = 75 + tab_height; // Add tab height since measurements are to the inner side of the joining piece
plate_size = [plate_width, plate_height];
plate_corner_radius = [4, 4];

plate_screwhole_offset = [0, 15];
plate_screwhole_diameter = 6.6;
plate_screwhole_positions = [[-120, 0],[-20, 0],[20, 0],[120, 0]];

tab_offset = [0, plate_height - 30 - tab_height];

module top_mount_2d_no_tabs() {
    module screw_holes() {
        for (this_pos = plate_screwhole_positions) {
            translate(this_pos + plate_screwhole_offset)
            circle(d = plate_screwhole_diameter, center = true);
        }
    }

    // The top plate bounds. Centered around [0,0].
    module plate() {
        // Round the top left and right corners
        // complexRoundSquare(size, top left radius, top right radius, bottom right radius, bottom left radius, center)
        complexRoundSquare(plate_size, rads1=plate_corner_radius, rads2=plate_corner_radius, rads3=plate_corner_radius, rads4=plate_corner_radius, center=true);
    }
    
    difference() {
        translate([0, plate_height / 2])
        plate();

        screw_holes();
    }
}

module top_mount_2d() {
    difference() {
        translate([0, -30])
        top_mount_2d_no_tabs();

        translate(tab_offset)
        tab_bounds(width = 240, tab_height = tab_height);

        // Mounting tabs for brackets to secure to rad plate

        union() {
            translate([113, (plate_height - 30) - 15 - 10]) // 10mm inset from the oute edge of the tab
            angle_tabs_cutout();

            translate([-113, (plate_height - 30) - 15 - 10]) // 10mm inset from the oute edge of the tab
            angle_tabs_cutout();
        }
    }

    translate(tab_offset)
    tab_strip(width = 240, tab_width = 10, tab_height = tab_height);
}

module top_mount_3d() {
    linear_extrude(height = material_thickness) {
        top_mount_2d();
    }
}

top_mount_2d();
