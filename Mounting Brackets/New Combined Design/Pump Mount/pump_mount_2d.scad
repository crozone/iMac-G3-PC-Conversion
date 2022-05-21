// Pump mount.
// Ryan Crosby 2022.
//
// Vertical mouinting plate that sits to the side of the motherboard.
// Has two bulkheads for passing through liquid to the GPU

use <../Shared/2Dshapes.scad>;
use <../Shared/tab_strip.scad>;
use <../Shared/baseplate_screw_holes.scad>;

include  <../Shared/shared_settings.scad>;

$fn=256;

// A very small distance to overcome rounding errors
$eps = pow(2, -15);

tab_height = material_thickness - 0.2;
top_mount_y = 203;

// How far forwards and backwards the bottom plate extends, which informs the depth of the rear bracket as well
rear_depth = 55; //60;
front_depth = 15 + 15;

// Plate height is based directly off the top mount screw Y position.
// The top edge is always 15mm higher than the screws, less some buffer.
plate_size = [90, top_mount_y + (15 - 2)];
rear_plate_size = [rear_depth, 140];
bottom_plate_size = [plate_size[0], front_depth + rear_depth];

plate_corner_radius = [4, 4];

plate_screw_hole_diameter = 6.6;
plate_screw_hole_distance = 55;

// Bulkheads are 24mm in diameter, with 20mm thread.
bulkhead_diameter = 24;
bulkhead_hole_diameter = 20.1;

// X is measured from middle of pump mount.
// Y is measured from the bottom screw of pump mount.
pump_pos = [50, 50];

rear_plate_x_offset = (plate_size[0] / 2) - (material_thickness / 2);

// Settings for placeholder GTX 295
gpu_name = "GTX 295 stock";
gpu_y_start = 4;
gpu_y_length = 37;
gpu_z_start = 35;

module pump_mount_holes() {

    h_space = 54.3;
    v_space = 13.5;
    screw_hole_diameter = 3.5; // M3 screw

    hole_positions = [
        [h_space / 2, v_space],
        [-h_space / 2, v_space],
        [h_space / 2, 0],
        [-h_space / 2, 0]
    ];

    for (this_pos = hole_positions) {
        translate(this_pos)
        circle(d = screw_hole_diameter);
    }
}

module bulkhead_holes() {
    h_space = 40;
    screw_hole_diameter = bulkhead_hole_diameter;

    hole_positions = [
        [h_space / 2, 0],
        [-h_space / 2, 0]
    ];

    for (this_pos = hole_positions) {
        translate(this_pos)
        circle(d = screw_hole_diameter);
    }
}

module mount_screw_holes() {
    screw_hole_diameter = plate_screw_hole_diameter;

    hole_positions = [
        [-plate_screw_hole_distance / 2, 0],
        [0, 0],
        [plate_screw_hole_distance / 2, 0]];

    for (this_pos = hole_positions) {
        translate(this_pos)
        circle(d = screw_hole_diameter);
    }
}

module cable_tie_holes() {
    h_space = 8;

    hole_positions = [
        [h_space, 0],
        [0, 0]
    ];

    for(i = [0 : 1 : 3]) {
        offset = [0, i * 40];
        for (this_pos = hole_positions) {
            translate(this_pos + offset)
            square([2, 4]);
        }
    }
}

module cables_through_hole() {
    edge_d = [3, 3];
    complexRoundSquare([20, 20], rads1=[0, 0], rads2=[0, 0], rads3=edge_d, rads4=[0, 0], center=false);

}

module pump_mount_main_2d() {
    // The top plate bounds. Centered around [0,0].
    module plate() {
        // Round the top left and right corners
        // complexRoundSquare(size, top left radius, top right radius, bottom right radius, bottom left radius, center)
        union() {
            translate([0, material_thickness])
            complexRoundSquare(plate_size - [0, material_thickness], rads1=[0, 0], rads2=[0, 0], rads3=plate_corner_radius, rads4=plate_corner_radius, center=false);

            translate([plate_size[0] / 2, material_thickness - tab_height])
            tab_strip(width = plate_size[0], tab_width = 10, tab_height = tab_height + $eps, inverse = true);
        }
    }

    module rear_plate_tabs_receptacle() {
        ts_side_len = rear_plate_size[1] - material_thickness;
        translate([material_thickness, ts_side_len / 2 + material_thickness])
        rotate(90)
        tab_strip(width = ts_side_len, tab_width = 10, tab_height = tab_height + $eps, inverse = false);
    }
    
    difference() {
        plate();

        translate([plate_size[0] / 2, top_mount_y])
        mount_screw_holes();

        translate([plate_size[0] / 2, 175])
        bulkhead_holes();

        translate(pump_pos)
        pump_mount_holes();

        translate([2, 35])
        cable_tie_holes();

        cables_through_hole();

        translate([rear_plate_x_offset, 0])
        rear_plate_tabs_receptacle();
    }
}

module pump_mount_bottom_2d() {
    module plate() {
        //complexRoundSquare(bottom_plate_size, rads1=plate_corner_radius, rads2=plate_corner_radius, rads3=plate_corner_radius, rads4=plate_corner_radius, center=false);
       
        extension_width = 20;
        extension_length = 30;
        wide_length = rear_depth - extension_length;
    
        complexRoundSquare([bottom_plate_size[0], front_depth + wide_length], rads1=plate_corner_radius, rads2=plate_corner_radius, rads3=plate_corner_radius, rads4=plate_corner_radius, center=false);
        

        translate([rear_plate_x_offset - extension_width / 2 + material_thickness / 2, front_depth + wide_length - $eps])
        complexRoundSquare([extension_width, extension_length + $eps], rads1=[0, 0], rads2=[0, 0], rads3=plate_corner_radius, rads4=plate_corner_radius, center=false);
    }

    module main_plate_tabs_receptacle() {
        difference() {
            translate([plate_size[0] / 2, 0])
            tab_strip(width = plate_size[0], tab_width = 10, tab_height = tab_height + $eps, inverse = true);

            translate([0, -$eps])
            square([20, tab_height + $eps * 2]);
        }
    }

    module rear_plate_tabs_receptacle() {
        ts_bot_len = rear_plate_size[0];

        translate([material_thickness, ts_bot_len / 2])
        rotate(90)
        tab_strip(width = ts_bot_len, tab_width = 10, tab_height = material_thickness, inverse = false);
    }

    module baseplate_screw_holes() {
        origin_offset = [0, 0];

        screw_positions = [
            // This 0,0 screw is supposed to be in line with the mobo mounting screws
            origin_offset + baseplate_screwhole_offset([0, 0], false),
            origin_offset + baseplate_screwhole_offset([0, 2], false),
            origin_offset + baseplate_screwhole_offset([8, 0], false),
            origin_offset + baseplate_screwhole_offset([8, 2], false),
        ];

        // Screw holes for mounting to baseplate
        for (this_pos = screw_positions) {
            translate(this_pos)
            baseplate_screw_hole();
        }
    }
    
    difference() {
        translate([0, -front_depth])
        plate();

        translate([0, -tab_height])
        main_plate_tabs_receptacle();

        translate([17.5 - 2, -15])
        #baseplate_screw_holes();

        translate([rear_plate_x_offset, 0])
        rear_plate_tabs_receptacle();
    }
}

module pump_mount_rear_2d() {
    module plate() {
        union() {
            difference() {
                translate([0, material_thickness])
                union() {
                    // Bottom
                    square([rear_plate_size[0], gpu_z_start + 10] - [0, material_thickness], center=false);

                    // First
                    complexRoundSquare([gpu_y_start, rear_plate_size[1]] - [0, material_thickness], rads1=[0,0], rads2=[0,0], rads3=plate_corner_radius, rads4=[0,0], center=false);

                    // Second
                    translate([gpu_y_start + gpu_y_length, gpu_z_start] - [0, material_thickness])
                    complexRoundSquare([rear_plate_size[0] - (gpu_y_start + gpu_y_length), 30] - [0, material_thickness], rads1=[0,0], rads2=[0,0], rads3=plate_corner_radius, rads4=plate_corner_radius, center=false);
                }

                translate([gpu_y_start, gpu_z_start])
                complexRoundSquare([gpu_y_length, rear_plate_size[1] - gpu_z_start], rads1=plate_corner_radius, rads2=plate_corner_radius, rads3=[0,0], rads4=[0,0], center=false);
            }

            //translate([0, material_thickness])
            //complexRoundSquare(rear_plate_size - [0, material_thickness], rads1=[0,0], rads2=[0,0], rads3=plate_corner_radius, rads4=[0,0], center=false);

            ts_bot_len = rear_plate_size[0];
            translate([ts_bot_len / 2, material_thickness - tab_height])
            tab_strip(width = ts_bot_len, tab_width = 10, tab_height = tab_height + $eps, inverse = false);

            ts_side_len = rear_plate_size[1] - material_thickness;
            translate([0, ts_side_len / 2 + material_thickness])
            rotate(90)
            tab_strip(width = ts_side_len, tab_width = 10, tab_height = tab_height + $eps, inverse = false);
        }
    }
    
    difference() {
        plate();
    }
}

module pump_mount_2d() {
    pump_mount_main_2d();

    translate([0, -70])
    pump_mount_bottom_2d();

    translate([100, 0])
    pump_mount_rear_2d();
}

module pump_mount_3d() {
    color("blue")
    rotate([90, 0])
    linear_extrude(height = material_thickness) {
        pump_mount_main_2d();
    }

    color("green")
    linear_extrude(height = material_thickness) {
        pump_mount_bottom_2d();
    }

    color("purple")
    translate([rear_plate_x_offset, 0, 0])
    rotate([90, 00, 90])
    linear_extrude(height = material_thickness) {
        pump_mount_rear_2d();
    }
}

pump_mount_3d();

//pump_mount_3d();