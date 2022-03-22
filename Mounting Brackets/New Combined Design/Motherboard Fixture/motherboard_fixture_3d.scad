// 3D model representing the motherboard fixture.
// This includes the motherboard mounting bracket, extrusion, and motherboard itself.

$fn=256;

extrusion_width = 30;

// TODO: Accurate measurement
mobo_offset = -20;

mobo_plate_thickness = 3;


module motherboard_mount_3d() {
    module top_extrusion_bar() {
        cube([270, extrusion_width, extrusion_width], center = true);
    }

    module bottom_extrusion_bar() {
        cube([200, extrusion_width, extrusion_width], center = true);
    }

    module mobo_plate() {
        linear_extrude(height = mobo_plate_thickness) {
            square([200, 230], center = true);
        }
    }

    module pcie_cutout() {
        // TODO: Accurate measurement
        cube([100, extrusion_width * 2, extrusion_width + 0.5], center = true);
    }

    difference() {
        union() {
            translate([0, -extrusion_width / 2, 230])
            translate([0, 0, -extrusion_width / 2])
            top_extrusion_bar();

            translate([0, 3, 230 / 2])
            rotate([90, 0, 0])
            mobo_plate();

            translate([0, extrusion_width / 2 + mobo_plate_thickness, extrusion_width / 2])
            bottom_extrusion_bar();
        }

        translate([0, extrusion_width / 2 + mobo_plate_thickness, extrusion_width / 2])
        #pcie_cutout();
    }
}

module motherboard_exclusion_zone() {
    exclusion_height = 50;

    translate([0, 0, exclusion_height / 2])
    cube([200, 200, exclusion_height], center = true);
}

module motherboard_fixture_3d() {
    motherboard_mount_3d();

    %translate([0,mobo_plate_thickness + 5, 200 / 2 + extrusion_width])
    rotate([-90, 0, 0])
    motherboard_exclusion_zone();
}

motherboard_fixture_3d();
