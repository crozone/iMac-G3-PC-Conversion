use <../Shared/2Dshapes.scad>;
use <../Shared/tab_strip.scad>;

include  <../Shared/shared_settings.scad>;
include <bottom_mount_settings.scad>;

$fn=512;

// A very small distance to overcome rounding errors
$eps = pow(2, -15);

width = 30;

tab_height = material_thickness - 0.2; // Same as material thickness.

module bottom_connecting_tab_2d(angle, pivot_height) {
    difference() {
        union() {
            square_height = pivot_height + tab_height / 2;

            square([width, square_height], center = false);

            translate([width / 2, square_height])
            difference() {
                circle(d = width);

                translate([0, -width / 2])
                square([width, width / 2], center = true);
            }
            

            translate([width / 2, -tab_height + $eps])
            tab_strip(width = width, tab_width = tab_length, tab_height = tab_height + $eps, inverse = false);
        }

        // Cutout tab
        translate([width / 2, pivot_height])
        rotate(angle)
        square([width, material_thickness]);
    }
}

module bottom_connecting_tab_3d(angle, pivot_height) {
    linear_extrude(height = material_thickness) {
        bottom_connecting_tab_2d(angle, pivot_height);
    }
}

bottom_connecting_tab_2d(angle = 90 - 36, pivot_height = 20);
