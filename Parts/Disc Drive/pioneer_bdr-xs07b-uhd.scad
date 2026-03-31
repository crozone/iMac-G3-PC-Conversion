// Pioneer BDR-XS07B-UHD external slot loading Blu-ray drive reference model.
// Ryan Crosby 2026

use <../Shared/rounded_square.scad>;

$fn = $preview ? 64 : 128;

DRIVE_BASE_DIMENSIONS = [132, 132];
DRIVE_BASE_RADIUS = 2;
DRIVE_BASE_HEIGHT = 3;

DRIVE_DIMENSIONS = [135, 135];
DRIVE_DIMENSIONS_LOWER = [135.5, 135.3];
DRIVE_RADIUS = 4;
DRIVE_HEIGHT = 15;

FEET_DIMENSIONS = [121.5, 3.5, 0.5];

module drive() {
    
    difference() {
        union() {
            // Base
            color("lightgrey")
            translate(-DRIVE_BASE_DIMENSIONS/2)
            linear_extrude(height = DRIVE_BASE_HEIGHT)
            rounded_square(DRIVE_BASE_DIMENSIONS, r = DRIVE_BASE_RADIUS);

            // Main body
            color("gray")
            translate([0, 0, DRIVE_BASE_HEIGHT])
            hull() {
            linear_extrude(height = DRIVE_HEIGHT)
            translate(-DRIVE_DIMENSIONS/2)
            rounded_square(DRIVE_DIMENSIONS, r = DRIVE_RADIUS);

            linear_extrude(height = 0.1)
            translate(-DRIVE_DIMENSIONS_LOWER/2)
            rounded_square(DRIVE_DIMENSIONS_LOWER, r = DRIVE_RADIUS);

            }
            
            // Eject button
            color("yellow")
            translate([-DRIVE_DIMENSIONS[0]/2 + 13, -DRIVE_DIMENSIONS[1]/2 - 1, DRIVE_BASE_HEIGHT + 1.8])
            cube([9, 1, 3]);

            // Feet
            color("yellow")
            union() {
                translate([0, DRIVE_BASE_DIMENSIONS[1]/2 - FEET_DIMENSIONS[1]/2 - 2, -FEET_DIMENSIONS[2]])
                foot();
                translate([0, -DRIVE_BASE_DIMENSIONS[1]/2 + FEET_DIMENSIONS[1]/2 + 2, -FEET_DIMENSIONS[2]])
                foot();
            }
        }

        // Slot
        translate([0, -DRIVE_DIMENSIONS[1]/2, DRIVE_BASE_HEIGHT + DRIVE_HEIGHT - 3.5])
        #cube([123.5, 5, 2], center = true);

        // USB C port
        translate([-DRIVE_DIMENSIONS[0]/2 + 15, DRIVE_DIMENSIONS[1]/2 - 5/2, DRIVE_BASE_HEIGHT + 2.2])
        #cube([9.5, 5, 4]);

        // DC Jack
        translate([-DRIVE_DIMENSIONS[0]/2 + 36.5, DRIVE_DIMENSIONS[1]/2 - 5/2, DRIVE_BASE_HEIGHT + 4.5])
        rotate(-90, [1, 0, 0])
        #cylinder(d = 5, h = 5);
    }

    module foot() {
        linear_extrude(height = FEET_DIMENSIONS[2]) 
        hull() {
            translate([-FEET_DIMENSIONS[0]/2 + FEET_DIMENSIONS[1]/2, 0])
            circle(d = FEET_DIMENSIONS[1]);
            translate([FEET_DIMENSIONS[0]/2 - FEET_DIMENSIONS[1]/2, 0])
            circle(d = FEET_DIMENSIONS[1]);
        }
    }
}

drive();
