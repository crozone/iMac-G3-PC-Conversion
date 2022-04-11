use <../Shared/2Dshapes.scad>;
use <../Shared/tab_strip.scad>;

include  <../Shared/shared_settings.scad>;
include <bottom_mount_settings.scad>;

$fn=512;

// A very small distance to overcome rounding errors
$eps = pow(2, -15);

// Render mode:
//
// 0: 3D visual
// 1: 2D bottom mount only
// 2: 2D Cutter Layout

RENDER_MODE = 1;


// Engrave mode:
//
// 0: Model only
// 1: Model and engrave
// 2: Engrave only

ENGRAVE_MODE = 1;

part_name = "Rad Base Tab v1.3";

width = bottom_mount_tab_width;
tab_height = bottom_connecting_tab_tab_height;

module module_label(pivot_angle) {
    text_line1 = part_name;
    text_line2 = str(pivot_angle, chr(176));

    echo(str(text_line1, " // ", text_line2));

    union() {
        text(text = text_line1, font = text_font, size = 2, halign = "left", valign = "top");

        translate([13, -3])
        text(text = text_line2, font = text_font, size = 2, halign = "center", valign = "top");
    }
}

module bottom_connecting_tab_2d(pivot_angle, pivot_height, engrave_mode) {
    module part(pivot_angle) {
        union() {
            difference() {
                union() {
                    square_height = pivot_height;

                    square([width, square_height], center = false);

                    translate([width / 2, square_height])
                    difference() {
                        circle(d = width);

                        translate([-width / 2, -width / 2])
                        square([width, width / 2], center = false);
                    }

                    translate([width / 2, -tab_height + $eps])
                    tab_strip(width = width, tab_width = bottom_mount_tab_length, tab_height = tab_height + $eps, inverse = false);
                }

                // Cutout tab
                translate([width / 2, pivot_height])
                rotate(pivot_angle)
                square([width / 2, material_thickness + width / 2]);

                // Reference guide
                // #translate([width / 2 + 1.8, pivot_height + 1.2])
                // rotate(90 - 5)
                // square([width / 2, material_thickness]);

                // Cutout elipse
                translate([width / 2, pivot_height])
                rotate(pivot_angle)
                intersection(s) {
                    translate([2, 1.6])
                    resize([7,5])
                    circle(d = 5);

                    translate([0, -2 + $eps])
                    square([5, 2], center = false);
                }
            }

            rounded_height = (width / 2) - material_thickness;

            translate([width / 2, pivot_height])
            rotate(pivot_angle)
            translate([0 - $eps, material_thickness])
            complexRoundSquare([5, rounded_height], rads1=[0, 0], rads2=[3, 3], rads3=[2, 2], rads4=[0, 0], center=false);
            
            translate([width / 2, pivot_height])
            rotate(pivot_angle)
            translate([width / 2 - 5, -$eps])
            complexRoundSquare([5, material_thickness], rads1=[0, 0], rads2=[0, 0], rads3=[1, 1], rads4=[4, 4], center=false);
        }
    }

    module engrave() {
        translate([2, 8])
        module_label(pivot_angle);
    }

    if(engrave_mode <= 1) {
        part(pivot_angle);
    }

    if(engrave_mode >= 1) {
        #engrave();
    }
}

module bottom_connecting_tab_3d(pivot_angle, pivot_height, engrave_mode) {
    linear_extrude(height = material_thickness) {
        bottom_connecting_tab_2d(pivot_angle, pivot_height, engrave_mode);
    }
}

pivot_angle = 90 - radiator_angle;
pivot_height = radiator_bottom_mount_height_offset;

if(ENGRAVE_MODE >= 1) {
    // Reference line
    #translate([-0.1, 0])
    square([0.1, 10]);
}

if(RENDER_MODE == 1) {
    bottom_connecting_tab_2d(pivot_angle = pivot_angle, pivot_height = pivot_height, engrave_mode = ENGRAVE_MODE);
}
else if(RENDER_MODE == 2) {
    gap = 3;
    for ( i = [0 : 1 : len(bottom_mount_tab_positions) - 1] ) {
        translate([i * (30 + gap), 0])
        bottom_connecting_tab_2d(pivot_angle = pivot_angle, pivot_height = pivot_height, engrave_mode = ENGRAVE_MODE);
    }
}
