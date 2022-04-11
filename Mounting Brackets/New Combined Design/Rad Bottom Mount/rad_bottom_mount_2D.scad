use <../Shared/2Dshapes.scad>;
use <../Shared/tab_strip.scad>;
use <../Connecting Tabs/angle_tab_2d.scad>;
use <../Shared/baseplate_screw_holes.scad>;
use <bottom_connecting_tab_2d.scad>;

include  <../Shared/shared_settings.scad>;
include <bottom_mount_settings.scad>;

$fn=256;
$eps = pow(2, -15);

// Render mode:
//
// 0: 3D visual
// 1: 2D bottom mount only
// 2: 2D Cutter Layout

RENDER_MODE = 2;

// Engrave mode:
//
// 0: Model only
// 1: Model and engrave
// 2: Engrave only

ENGRAVE_MODE = 1;

RULER_ENABLED = false;

part_name = "iMac Rad Base Mount v1.3";
edge_buffer = 10;
bottom_buffer = 8;

plate_size = [edge_buffer * 2, bottom_mount_height] + baseplate_screwhole_offset([21 - (-1), 0]);

module baseplate_screw_hole_cutout() {
    // This offset positions the screw holes on the same X co-ordinate system as the PSU mount, so X = -1 is the leftmost screw hole.
    origin_offset = baseplate_screwhole_offset([1, 0], false);

    screw_positions = [
        origin_offset + baseplate_screwhole_offset([-1, 0], false),
        origin_offset + baseplate_screwhole_offset([-1, 1], false),

        origin_offset + baseplate_screwhole_offset([6, 0], false),
        origin_offset + baseplate_screwhole_offset([13, 0], false),

        origin_offset + baseplate_screwhole_offset([21, 0], false),
        origin_offset + baseplate_screwhole_offset([21, 1], false),
    ];

    // Screw holes for mounting to baseplate
    for (this_pos = screw_positions) {
        translate(this_pos)
        baseplate_screw_hole();
    }

    // for ( i = [-1 : 1 : 20] ) {
    //     if(i <= 13 || i >= 17) {
    //         this_hole_pos = origin_offset + baseplate_screwhole_offset([i, -1], false);
    //         translate(this_hole_pos)
    //         baseplate_screw_hole();
    //     }
    // }
}

module bottom_connecting_tab_attachment() {
    translate([0, bottom_mount_height / 2])
    rotate(-90)
    tab_strip(width = bottom_mount_height, tab_width = bottom_mount_tab_length, tab_height = material_thickness, inverse = false);
}

module bottom_connecting_tab_attachments() {
    for (this_pos = bottom_mount_tab_positions) {
        translate(this_pos)
        bottom_connecting_tab_attachment();
    }
}

module ruler() {
    for ( i = [0 : 10 : plate_size[0]] ) {
        translate([i, 0])
        translate([-0.5 / 2, 0])
        square([0.5, plate_size[1]]);
    }

    for ( i = [0 : 5 : plate_size[0]] ) {
        translate([i, 0])
        translate([-0.5 / 2, 0])
        square([0.5, plate_size[1] / 2]);
    }

    for ( i = [0 : 1 : plate_size[0]] ) {
        translate([i, 0])
        translate([-0.5 / 2, 0])
        square([0.5, plate_size[1] / 5]);
    }
}

module centerline_marker() {
    translate([85, -bottom_buffer])
    translate([-0.5 / 2, 0])
    square([0.5, plate_size[1]]);
}

module engrave_reference() {
    translate([-edge_buffer, -bottom_buffer])
    square([0.5, plate_size[1]]);

    // translate([-edge_buffer + plate_size[0], -bottom_buffer])
    // square([0.5, plate_size[1]]);
}

module module_label(sub_part_name) {
    text_line1 = part_name;
    text_line2 = sub_part_name;

    echo(str(text_line1, " // ", text_line2));

    #union() {
        text(text = text_line1, font = text_font, size = 2, halign = "left", valign = "top");

        translate([0, -3])
        text(text = text_line2, font = text_font, size = 2, halign = "left", valign = "top");
    }
}

module rad_bottom_mount_2d(engrave_mode = 1) {
    module part() {
        difference() {
            translate([-edge_buffer, -bottom_buffer])
            complexRoundSquare(plate_size, rads1=[5, 5], rads2=[5, 5], rads3=[5, 5], rads4=[5, 5], center=false);

            baseplate_screw_hole_cutout();

            translate([0, -bottom_buffer])
            bottom_connecting_tab_attachments();
        }
    }

    if(engrave_mode <= 1) {
        part();
    }

    if(engrave_mode >= 1) {
        #centerline_marker();
        #engrave_reference();

        translate([45, 10])
        module_label();

        if(RULER_ENABLED) {
            #ruler();
        }
    }
}

module rad_bottom_mount_3d(with_tabs, pivot_angle, pivot_height) {
    linear_extrude(height = material_thickness) {
        rad_bottom_mount_2d();
    }

    if(with_tabs) {
        #union() {
            for (this_pos = bottom_mount_tab_positions) {
                translate(this_pos)
                translate([0, -bottom_buffer])
                translate([material_thickness, bottom_mount_height, material_thickness])
                rotate([90, 0, -90])
                bottom_connecting_tab_3d(pivot_angle, pivot_height, engrave_mode);
            }
        }
    }
}


//rad_bottom_mount_3d(with_tabs = true, angle = 90 - 31, pivot_height = 20);

pivot_angle = 90 - radiator_angle;
pivot_height = radiator_bottom_mount_height_offset;

if(RENDER_MODE == 0) {
    rad_bottom_mount_3d(with_tabs = true, pivot_angle = pivot_angle, pivot_height = pivot_height, engrave_mode = ENGRAVE_MODE);
}
else if(RENDER_MODE == 1) {
    rad_bottom_mount_2d(ENGRAVE_MODE);
}
else if(RENDER_MODE == 2) {
    rad_bottom_mount_2d(ENGRAVE_MODE);

    gap = 3;
    //translate([15, (30 - bottom_buffer) + bottom_connecting_tab_tab_height + gap])
    translate([plate_size[0], -3])
    for ( i = [0 : 1 : len(bottom_mount_tab_positions) - 1] ) {
        translate([i * (30 + gap), 0])
        bottom_connecting_tab_2d(pivot_angle, pivot_height, ENGRAVE_MODE);
    }
}
