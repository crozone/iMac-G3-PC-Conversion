// Disc drive mount for the Pioneer BDR-XS07B-UHD external slot loading Blu-ray drive.
// Ryan Crosby 2026

use <../Shared/2Dshapes.scad>;
use <../Shared/rounded_corner.scad>;
use <../Shared/rounded_square.scad>;
use <pioneer_bdr-xs07b-uhd.scad>

include <../Shared/shared_settings.scad>;

$fn = $preview ? 64 : 128;

DRIVE_BASE_DIMENSIONS = [132, 132];
DRIVE_BASE_RADIUS = 2;
DRIVE_BASE_HEIGHT = 3;

DRIVE_DIMENSIONS = [135, 135];
DRIVE_DIMENSIONS_LOWER = [135.5, 135.3];
DRIVE_RADIUS = 4;
DRIVE_HEIGHT = 15;

DRIVE_OFFSET = [0, DRIVE_DIMENSIONS[1]/2, -1.5];

// Leave room on top for 3mm acrylic cover
BRACKET_HEIGHT = DRIVE_BASE_HEIGHT + DRIVE_HEIGHT + 3;

VERSION = "v1.0";

module drive_cutout() {
    union() {
        BASE_CUTOUT_DIMENSIONS = DRIVE_BASE_DIMENSIONS + [1, 1];
        DRIVE_CUTOUT_DIMENSIONS = DRIVE_DIMENSIONS + [3, 3];
        UNDER_BASE_CUTOUT_DIMENSIONS = DRIVE_BASE_DIMENSIONS - [25, 25];

        // Base
        linear_extrude(height = DRIVE_BASE_HEIGHT - 1)
        translate(-BASE_CUTOUT_DIMENSIONS/2)
        rounded_square(BASE_CUTOUT_DIMENSIONS, r = DRIVE_BASE_RADIUS);

        // Under base
        translate([0, 0, -20])
        linear_extrude(height = 20)
        translate(-UNDER_BASE_CUTOUT_DIMENSIONS/2)
        rounded_square(UNDER_BASE_CUTOUT_DIMENSIONS, r = DRIVE_BASE_RADIUS);

        // Main body
        translate([0, 0, DRIVE_BASE_HEIGHT - 1])
        linear_extrude(height = DRIVE_HEIGHT + 1 + 10)
        translate(-DRIVE_CUTOUT_DIMENSIONS/2)
        rounded_square(DRIVE_CUTOUT_DIMENSIONS, r = DRIVE_RADIUS);

        // Front slot area
        translate([-125/2, -DRIVE_DIMENSIONS[1]/2 - 30 + 1, DRIVE_BASE_HEIGHT + DRIVE_HEIGHT - 3.5 - 10.5])
        cube([125, 30, 12]);
    }
}

// Keepout areas from the metal tray mount
module tray_cutout() {
    union() {
        // Front lip
        translate([-142/2, -2 - 2, -26])
        cube([142, 2 + 2, 26]);

        translate([-142/2, -2, -26])
        cube([2.5, 11, 26]);

        translate([142/2 - 2.5, -2, -26])
        cube([2.5, 11, 26]);
    }
}

module bracket() {
    difference() {
        union() {
            translate([-142/2, -3, -3])
            linear_extrude(height = BRACKET_HEIGHT + 3) 
            rounded_square(size = [142, 28 + 3], corners = [DRIVE_RADIUS, DRIVE_RADIUS, undef, undef]);

            translate([-(142 + 16)/2, 28, BRACKET_HEIGHT-38])
            linear_extrude(height = 38)
            rounded_square(size = [142 + 16, 17], corners = [DRIVE_RADIUS, DRIVE_RADIUS, undef, DRIVE_RADIUS]);

            translate([-142/2, 17 + 28, -3])
            linear_extrude(height = BRACKET_HEIGHT + 3) 
            rounded_square(size = [142 + 8, 95], corners = [undef, undef, DRIVE_RADIUS, DRIVE_RADIUS]);
        }

        translate(DRIVE_OFFSET)
        drive_cutout();
        tray_cutout();
    }
}

translate(DRIVE_OFFSET)
%drive();
%tray_cutout();

bracket();
