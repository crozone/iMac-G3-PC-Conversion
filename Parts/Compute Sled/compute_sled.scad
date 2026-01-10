// Compute Sled.
// Ryan Crosby 2024.
//
// Vertical mounting assembly that holds the motherboard, GPU, and water pump.
// This is intended to make the main components of the computer somewhat self-contained and removable as a single unit,
// without having to disconnect any permanently attached coolant fittings.
// Instead, only the radiator QDs, power supply cables, and IO cables need to be disconnected.
//
// The assembly is attached to the iMac baseplate via 3D printed brackets that can be unbolted.
//
// The motherboard is mounted in the standard orientation with the motherboard facing the rear of the iMac,
// and the IO panel facing the right of the iMac.
//
// The GPU is mounted behind the motherboard, in an upside down orintation with the display outputs facing the right of the iMac.
// The PCIe slot will be at the top, and the coolant ports will be at the bottom.
//
// A PCIe riser travels from the PCIe slot at bottom of the motherboard, underneath the motherboard plate,
// up behind the GPU, and to the top wof the GPU to attach to the PCIe connector.
// 
// The water pump sits to the left of the motherboard, facing the rear of the iMac.
//
// Coolant loop:
// The mwater pump outlet is connected to the GPU coolant inlet, underneath the motherboard.
// The GPU coolant outlet is connected to the motherboard monoblock coolant inlet.
// The monoblock coolant outlet is connected via a QD to the radiator inlet.
// The radiator outlet is connected via a QD to the pump inlet.

use <../Shared/2Dshapes.scad>;
use <../Shared/tab_strip.scad>;
use <../Shared/baseplate_screw_holes.scad>;
use <../Shared/rounded_corner.scad>;
use <gpu_mount.scad>;

include <screw_hole_sizes.scad>
include <../Shared/shared_settings.scad>;

// Render mode:
//
// 0: 3D visual
// 1: 2D cutter layout
// 2: 2D Main Plate
// 3: 2D Bottom Plate
// 4: 2D Rear Plate
RENDER_MODE_DEFAULT = 0;

// Engrave mode:
//
// 0: Model only
// 1: Model and engrave
// 2: Engrave only

ENGRAVE_MODE_DEFAULT = 1;

// Overridden by export script
//
// 1: Cut layert
// 2: Engrave layer

EXPORT_LAYER = 0;

EXPORT_RENDER_MODE = 1;

if(EXPORT_LAYER != 0) {
    echo(str("EXPORT_LAYER enabled, set to ", EXPORT_LAYER));
}

RENDER_MODE = EXPORT_LAYER > 0 ? EXPORT_RENDER_MODE : RENDER_MODE_DEFAULT;
ENGRAVE_MODE = EXPORT_LAYER == 1 ? 0 : (EXPORT_LAYER == 2 ? 2 : ENGRAVE_MODE_DEFAULT);

echo(str("Render mode: ", RENDER_MODE));
echo(str("Engrave mode: ", ENGRAVE_MODE));

$fn = $preview ? 64 : 128;

// A very small distance to overcome rounding errors
$eps = pow(2, -15);

MINI_ITX_MOBO_MOUNTING_HOLES = [
    [ 0,      0      ] + [10.16, 6.35], // Screw hole C, bottom left
    [ 154.94, 0      ] + [10.16, 6.35], // Screw hole H, bottom right
    [ 154.94, 157.48 ] + [10.16, 6.35], // Screw hole J, top right
    [ 22.86,  157.48 ] + [10.16, 6.35]  // Screw hole F
];

MOTHERBOARD_PCIE_DATUM_POS = [10.16 + 46.94, 6.35 - 39.37/2 + 20.32];

material_thickness = 4.5;
tab_height = material_thickness - 0.2;
top_mount_y = 203;

// How far forwards and backwards the bottom plate extends, which informs the depth of the rear bracket as well
rear_depth = 53;
front_depth = 15 + 15;

// Plate height is based directly off the top mount screw Y position.
// The top edge is always 15mm higher than the screws, less some buffer.
plate_size = [90, top_mount_y + (15 - 2)];
rear_plate_size = [rear_depth, 140];
bottom_plate_size = [plate_size[0], front_depth + rear_depth];

plate_corner_radius = [4, 4];

plate_screw_hole_diameter = 6.6;
plate_screw_hole_distance = 55;

// X is measured from middle of pump mount.
// Y is measured from the bottom screw of pump mount.
pump_pos = [50, 50];


rear_plate_x_offset = (plate_size[0] / 2) - (material_thickness / 2);

// Settings for placeholder GTX 295
gpu_y_start = 4;
gpu_y_length = 38;
gpu_z_start = 35;

part_name = "iMac Compute Sled";
part_version = "v1.0";

module module_label(submodule_name) {
    text_line1 = str(part_name, " // ", part_version);
    text_line2 = submodule_name;

    echo(text_line1);
    echo(text_line2);

    union() {
        text(text = text_line1, font = text_font, size = 2, halign = "center", valign = "top");

        translate([0, -4])
        text(text = text_line2, font = text_font, size = 2, halign = "center", valign = "top");
    }
}

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

module bulkhead_labels() {
    translate([0, 12])
    translate(bulkhead_hole_offset)
    text(text = "GPU LOOP", font = text_font, size = 3, halign = "center", valign = "top");

    translate([0, bulkhead_diameter / 2 + 6]) {
        translate(bulkhead_hole_positions[0])
        text(text = "IN", font = text_font, size = 3, halign = "center", valign = "top");

        translate(bulkhead_hole_positions[1])
        text(text = "OUT", font = text_font, size = 3, halign = "center", valign = "top");
    }
}

module mount_screw_holes() {
    screw_hole_diameter = plate_screw_hole_diameter;
    vertical_tolerance = 2;

    hole_positions = [
        [-plate_screw_hole_distance / 2, 0],
        [0, 0],
        [plate_screw_hole_distance / 2, 0]];

    for (this_pos = hole_positions) {
        translate(this_pos)
        hull() {
            translate([0, -vertical_tolerance / 2])
            circle(d = screw_hole_diameter);

            translate([0, vertical_tolerance / 2])
            circle(d = screw_hole_diameter);
        }
    }
}

module cable_tie_holes() {
    h_space = 12;

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
    complexRoundSquare([20, 25], rads1=[0, 0], rads2=[0, 0], rads3=edge_d, rads4=[0, 0], center=false);

}

module pump_mount_main_2d(engrave_mode) {
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

    module part() {
        difference() {
            plate();

            translate([plate_size[0] / 2, top_mount_y])
            mount_screw_holes();

            bulkhead_holes();

            translate(pump_pos)
            pump_mount_holes();

            translate([2, 35])
            cable_tie_holes();

            cables_through_hole();
        }
    }

    module engrave() {
        translate([68, 25])
        module_label("Front Plate");

        bulkhead_labels();
    }

    if(engrave_mode <= 1) {
        part();
    }

    if(engrave_mode >= 1) {
        #engrave();
    }
}

module pump_mount_bottom_2d(engrave_mode) {
    module plate() {
        //complexRoundSquare(bottom_plate_size, rads1=plate_corner_radius, rads2=plate_corner_radius, rads3=plate_corner_radius, rads4=plate_corner_radius, center=false);
       
        extension_width = 30;
        extension_length = 32;
        wide_length = rear_depth - extension_length;
    
        complexRoundSquare([bottom_plate_size[0], front_depth + wide_length], rads1=plate_corner_radius, rads2=[15, 15], rads3=[15, 15], rads4=plate_corner_radius, center=false);

        extension_offset = [rear_plate_x_offset - extension_width / 2 + material_thickness / 2, front_depth + wide_length - $eps];

        translate(extension_offset)
        complexRoundSquare([extension_width, extension_length + $eps], rads1=[0, 0], rads2=[0, 0], rads3=plate_corner_radius, rads4=plate_corner_radius, center=false);

        translate(extension_offset)
        {
            translate([$eps, $eps])
            translate([-10, 10])
            rotate(270)
            rounded_corner(10);

            translate([extension_width - $eps, -$eps])
            translate([10, 10])
            rotate(180)
            rounded_corner(10);
        }
    }

    module main_plate_tabs_receptacle() {
        difference() {
            translate([plate_size[0] / 2, 0])
            tab_strip(width = plate_size[0], tab_width = 10, tab_height = tab_height + $eps, inverse = true);

            translate([0, -$eps])
            square([20, tab_height + $eps * 2]);
        }
    }

    module baseplate_screw_holes() {
        origin_offset = [0, 0];

        screw_positions = [
            // This 0,0 screw is supposed to be in line with the mobo mounting screws
            origin_offset + baseplate_screwhole_offset([0, 0], false),
            origin_offset + baseplate_screwhole_offset([0, 2], false),
            origin_offset + baseplate_screwhole_offset([7, 0], false),
            origin_offset + baseplate_screwhole_offset([7, 2], false),
        ];

        // Screw holes for mounting to baseplate
        for (this_pos = screw_positions) {
            translate(this_pos)
            baseplate_screw_hole();
        }
    }
    
    module part() {
        difference() {
            translate([0, -front_depth])
            plate();

            translate([0, -tab_height])
            main_plate_tabs_receptacle();

            translate([17.5 - 2, -17])
            baseplate_screw_holes();

            translate([rear_plate_x_offset, 0])
            rear_plate_tabs_receptacle();
        }
    }

    module engrave() {
        translate([plate_size[0] / 2, -15])
        module_label("Bottom Plate");
    }

    if(engrave_mode <= 1) {
        part();
    }

    if(engrave_mode >= 1) {
        #engrave();
    }
}

// The motherboard itself. Used as a layout guide.
module mini_itx_motherboard_pcb_2d() {
    difference() {
        square([170, 170]);
        
        union() {
            for(pos = MINI_ITX_MOBO_MOUNTING_HOLES) {
                translate(pos)
                circle(d = MINI_ITX_MOUNTING_CLEARANCE_HOLE);
            }
        }
    }
}

module mini_itx_motherboard_3d() {
    color("purple")
    linear_extrude(height = 1)
    mini_itx_motherboard_pcb_2d();

    color("yellow", alpha=0.8)
    translate(MOTHERBOARD_PCIE_DATUM_POS)
    pcie_slot_3d();
}

module pcie_slot_3d() {
    difference() {
        translate([-14.5, 0, 0])
        rotate(90, [1, 0, 0])
        rotate(90, [0, 1, 0])
        linear_extrude(height = 89) 
        union() {
            translate([-3.75, 0])
            square([3.75 * 2, 11]);
            hull() {
                translate([-3.75, 7.45])
                square([3.75 * 2, 11 - 7.45]);

                translate([-5.1, 7.45])
                square([5.1 + 3.75, 0.8]);
            }
        }

        translate([-11.65 - 1.70/2, -2.5/2, 5])
        cube([11.65, 2.5, 11 - 5 + 0.1]);

        translate([1.70/2, -2.5/2, 5])
        cube([73.15 - 1.70/2, 2.5, 11 - 5 + 0.1]);
    }
}

module bulkhead_holes() {

    // Bulkheads are 24mm in diameter, with 20mm thread.
    bulkhead_diameter = 24;
    bulkhead_hole_diameter = 20.1;

    translate([50, 20]) {
        circle(d = bulkhead_hole_diameter);
        text(text = "GPU LOOP", font = text_font, size = 3, halign = "center", valign = "top");
    }

}

motherboard_offset = [0, 40];
pump_offset = [170 + 50, 50];

// The main vertical back plate that everything mounts to.
module main_plate_2d() {
    difference() {
        translate([-19, 0])
        square([
            19 + 170 + 85, // 170mm for the motherboard, 85mm for the pump
            40 + 170 + 40 // 40mm above the deck, 170mm for the motherboard, 40mm for top attachments
            ]);

        translate(motherboard_offset)
        union() {
            for(pos = MINI_ITX_MOBO_MOUNTING_HOLES) {
                translate(pos)
                circle(d = MINI_ITX_MOUNTING_CLEARANCE_HOLE);
            }
        }

        translate(pump_offset)
        pump_mount_holes();

        bulkhead_holes();

        // GPU mount holes
        translate([0, 70])
        translate([motherboard_offset[0] + MOTHERBOARD_PCIE_DATUM_POS[0] - gpu_mount_pcie_datum_offset() ,0]) // Horizontally align PCIe slots
        scale([-1, 1])
        #union() {
            for(pos = gpu_mount_mounting_holes()) {
                translate(pos)
                circle(d = M4_DRILL_HOLE);
            }
        }
    }
}

module ek_monoblock_3d() {
    // Measurements taken from the installation manual and official dimensions
    translate([0, 0, 35.85 - 27.0])
    union() {
        // Left square offshoot bit that goes over the IO area and replaces the fan
        translate([0, 25.8 + 64.9, 0])
        cube([34, 47.8, 27]);

        // Main waterblock section
        translate([34, 25.8, 0])
        cube([103.5, 122.2, 20.5]);

        // waterblock bit that sits under the audio/SSD board
        translate([16.5, 0, 0])
        cube([85.4, 25.8, 10]); // Z height is a guess since it's not listed, and I haven't measured it.
    
        // Top coolant hole
        translate([34 + 21.3, 148 - 71, 20.5]) // x offset is approximate, calculated by pixel counting official diagrams
        {
            cylinder(h = 20, d = 12.9); // TODO: Verify G1/4" thread minor diameter = 12.9mm

            translate([0, -28, 0]) // x offset is approximate, calculated by pixel counting official diagrams
            cylinder(h = 20, d = 12.9); // TODO: Verify G1/4" thread minor diameter = 12.9mm
        }
    }
}

module compute_sled_3d() {
    rotate([90, 0, 0])
    color("blue")
    linear_extrude(height = material_thickness) {
        main_plate_2d();
    }

    // GPU bracket
    translate([0, 0, 70])
    translate([motherboard_offset[0] + MOTHERBOARD_PCIE_DATUM_POS[0] - gpu_mount_pcie_datum_offset() ,0]) // Horizontally align PCIe slots
    rotate(90, [1, 0, 0])
    rotate(180, [0, 1, 0])
    gpu_mount_3d();

    // Motherboard itself. It sits 8mm above the plate on standoffs.
    translate([0, -7.62, 0])
    rotate([90, 0, 0])
    translate(motherboard_offset)
    union() {
        mini_itx_motherboard_3d();

        color("red", alpha=0.3)
        translate([0, 6.60, 1])
        cube([35, 158.75, 43]);

        // EK waterblock
        color("green")
        translate([-1, 15, 0]) // TODO: Approximate, needs measurement
        ek_monoblock_3d();
    }
}

compute_sled_3d();

// if(RENDER_MODE == 0) {
//     pump_mount_3d(ENGRAVE_MODE);
// }
// else if(RENDER_MODE == 1) {
//     pump_mount_main_2d(ENGRAVE_MODE);

//     translate([134, 153])
//     rotate(270)
//     pump_mount_bottom_2d(ENGRAVE_MODE);

//     translate([97, 0])
//     pump_mount_rear_2d(ENGRAVE_MODE);
// }
// else if(RENDER_MODE == 2) {
//     pump_mount_main_2d(ENGRAVE_MODE);
// }
// else if(RENDER_MODE == 3) {
//     pump_mount_bottom_2d(ENGRAVE_MODE);
// }
// else if(RENDER_MODE == 4) {
//     pump_mount_rear_2d(ENGRAVE_MODE);
// }
