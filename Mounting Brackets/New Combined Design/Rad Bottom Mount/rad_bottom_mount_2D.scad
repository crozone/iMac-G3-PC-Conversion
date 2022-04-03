use <../Shared/2Dshapes.scad>;
use <../Shared/tab_strip.scad>;
use <../Connecting Tabs/angle_tab_2d.scad>;
use <../Shared/baseplate_screw_holes.scad>;
use <bottom_connecting_tab_2d.scad>;

include  <../Shared/shared_settings.scad>;
include <bottom_mount_settings.scad>;

$fn=256;
$eps = pow(2, -15);

edge_buffer = 10;
bottom_buffer = 8;

plate_size = [edge_buffer * 2, bottom_mount_height] + baseplate_screwhole_offset([20, 0]);

tab_positions = [
    [10, 0],
    [20, 0],
    [35 - material_thickness, 0],

    [70, 0],
    [95 - material_thickness, 0],

    [125, 0],
    [150 - material_thickness, 0],
];

module baseplate_screw_hole_cutout() {
    // This offset positions the screw holes on the same X co-ordinate system as the PSU mount, so X = -1 is the leftmost screw hole.
    origin_offset = baseplate_screwhole_offset([1, 0], false);

    screw_positions = [
        origin_offset + baseplate_screwhole_offset([-1, 0], false),
        origin_offset + baseplate_screwhole_offset([-1, 1], false),

        origin_offset + baseplate_screwhole_offset([6, 0], false),
        origin_offset + baseplate_screwhole_offset([13, 0], false),

        origin_offset + baseplate_screwhole_offset([19, 0], false),
        origin_offset + baseplate_screwhole_offset([19, 1], false),
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
    tab_strip(width = bottom_mount_height, tab_width = tab_length, tab_height = material_thickness, inverse = false);
}

module bottom_connecting_tab_attachments() {
    for (this_pos = tab_positions) {
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

module rad_bottom_mount_2d() {
    difference() {
        translate([-edge_buffer, -bottom_buffer])
        complexRoundSquare(plate_size, rads1=[5, 5], rads2=[5, 5], rads3=[5, 5], rads4=[5, 5], center=false);

        baseplate_screw_hole_cutout();

        translate([0, -bottom_buffer])
        bottom_connecting_tab_attachments();
    }
}

module rad_bottom_mount_3d(with_tabs, angle, pivot_height) {
    linear_extrude(height = material_thickness) {
        rad_bottom_mount_2d();
    }

    if(with_tabs) {
        for (this_pos = tab_positions) {
            translate(this_pos)
            translate([0, -bottom_buffer])
            translate([material_thickness, bottom_mount_height, material_thickness])
            rotate([90, 0, -90])
            bottom_connecting_tab_3d(angle, pivot_height);
        }
    }
}

//rad_bottom_mount_2d();
rad_bottom_mount_3d(with_tabs = true, angle = 90 - 36, pivot_height = 20);

//ruler();
