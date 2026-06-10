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
use <../Shared/rounded_square.scad>;
use <gpu_mount.scad>;

include <screw_hole_sizes.scad>
include <../Shared/shared_settings.scad>;

// Render mode:
//
// 0: 3D visual
// 1: 2D all (arranged for cutting)
// 2: 2D Main plate
// 3: GPU support 3080 TUF Vector
// 4: GPU support 5090 TUF Alphacool
RENDER_MODE_DEFAULT = 0;
EXPORT_RENDER_MODE = 2;

// Overridden by export script
// 0: Both layers
// 1: Cut layer
// 2: Engrave layer

EXPORT_LAYER = 0;
CUT = (EXPORT_LAYER == 0) || (EXPORT_LAYER == 1);
ENGRAVE = (EXPORT_LAYER == 0) || (EXPORT_LAYER == 2);

if(EXPORT_LAYER != 0) {
    echo(str("EXPORT_LAYER enabled, set to ", EXPORT_LAYER));
}

RENDER_MODE = EXPORT_LAYER > 0 ? EXPORT_RENDER_MODE : RENDER_MODE_DEFAULT;

echo(str("Render mode: ", RENDER_MODE));

$fn = $preview ? 64 : 128;

// A very small distance to overcome rounding errors
$eps = pow(2, -15);


MINI_ITX_MOBO_MOUNTING_HOLES = [
    [ 0,      0      ] + [10.16, 6.35], // Screw hole C, bottom left
    [ 154.94, 0      ] + [10.16, 6.35], // Screw hole H, bottom right
    [ 154.94, 157.48 ] + [10.16, 6.35], // Screw hole J, top right
    [ 22.86,  157.48 ] + [10.16, 6.35]  // Screw hole F
];

MOTHERBOARD_OFFSET = [0, 35];
MOTHERBOARD_PCIE_DATUM_POS = [10.16 + 46.94, 6.35 - 39.37/2 + 20.32];

// GPU mount top is 270 above plane
// At Y offset = -60 the two PCIe slots are horizntal to each other.
GPU_MOUNT_OFFSET = [0, 67];

material_thickness = 6;
tab_height = material_thickness - 0.2;

// Overall size of the main motherboard mounting plate.
plate_size =
[
    19 + 170 + 85, // 170mm for the motherboard, 85mm for the pump
    40 + 170 + 20 // 40mm above the deck, 170mm for the motherboard, 20mm for top attachments
];

// Plate offset.
// X = 0 is the edge of the motherboard and aligns with the IO plate, so
// offsetting the plate allows for overhang.
plate_offset = [-19, 0];

// Pump offset. Controls (x,y) offset of pump relative to the face of the motherboard backplate.
// X = 0 is the centerline of the pump.
// Y = 0 is the line bisecting the bottom two mounting screw holes on the pump bracket.
pump_offset = [215, 70];

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

module slot_hole(d = undef, r = undef, length) {
    d = is_undef(r) ? d : r * 2;
    hull() {
        translate([-length/2, 0])
        circle(d = d);
        translate([length/2, 0])
        circle(d = d);
    }
}

module pump_3d() {
    // X = 0 runs down the centerline of the pump
    // Y = 0 runs down the centerline of the pump
    // Z = 0 is the top of the mounting bracket

    // Back of mounting plate is at Y = 42
    // There is a gap of 12mm between the pump body and wall

    // Mounting plate
    color("Grey")
    union() {
        // Back
        translate([-66/2, 40, 24 - 32])
        translate([0, 2, 0])
        rotate(90, [1,0,0])
        linear_extrude(2)
        difference() {
            rounded_square([66, 32], corners = [2, 2, 0, 0]);
            translate([66/2, 8])
            pump_mount_holes();
        }

        // Flat
        translate([0, 0, 24 - 2])
        linear_extrude(2)
        hull() {
            translate([-66/2, 40 - 5])
            rounded_square([66, 5], corners = [1, 1, 0, 0]);

            translate([-50/2, 40 - 17])
            square([50, 17]);
        }
    }

    // Pump
    union() {
        // D5 pump body
        color("SlateGray")
        translate([0, 0, -33])
        cylinder(d = 60, h = 33);

        color("DarkGray")
        union() {
            hull() {
                translate([0, 0, 13.5 - 10])
                cylinder(d = 72, h = 10);
                cylinder(d = 67, h = 13.5);
            }

            translate([0, 0, 13.5])
            cylinder(d = 68, h = 1);

            translate([0, 0, 13.5 + 1])
            hull() {
                cylinder(d = 72, h = 12 - 1);

                translate([0, 0, 12 - 1]) 
                intersection() {
                    cylinder(d = 72, h = 10);
                    translate([-38/2, -72/2, 0])
                    cube([38, 72, 10]);
                }

                // Outlet port
                // X - 16 off center
                translate([-16, -72/2 + 20, 21 - 18.5/2])
                rotate(90, [1, 0, 0])
                cylinder(h = 20, d = 18.5);
            }
        }

        // Outlet fitting
        color("DarkSlateGray")
        translate([0, 0, 13.5 + 1])
        translate([-16, -72/2, 21 - 18.5/2])
        rotate(90, [1, 0, 0])
        cylinder(h = 10, d = 19);
    }

    // Top filter
    color("silver")
    translate([0, 0, 13.5 + 22])
    hull() {
        cylinder(d = 25, h = 5);
        cylinder(d = 18, h = 10);
    }
}

module pump_mount_holes() {
    // Horizontal spacing = 54.3mm
    // Vertical spacing = 13.5mm
    PUMP_MOUNTING_HOLE_POS = 
    [
        [54.3 / 2, 13.5],
        [-54.3 / 2, 13.5],
        [54.3 / 2, 0],
        [-54.3 / 2, 0]
    ];

    for (this_pos = PUMP_MOUNTING_HOLE_POS) {
        translate(this_pos)
        circle(d = M3_DRILL_HOLE);
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

// The main vertical back plate that everything mounts to.
module main_plate_2d() {
    module dual_m6_slot(spacing) {
        union() {
            translate([-spacing/2, 0])
            rotate(-90)
            slot_hole(d = M6_CLEARANCE_HOLE, length = 5);

            translate([spacing/2, 0])
            rotate(-90)
            slot_hole(d = M6_CLEARANCE_HOLE, length = 5);
        }
    }

    // Height of gap between the floor and the bottem edge of the motherboard. 
    base_offset = MOTHERBOARD_OFFSET[1] + 1;
    corner_radius = 5;

    difference() {
        union() {
            // Main plate
            translate(plate_offset + [0, base_offset])
            rounded_square(plate_size - [0, base_offset], corners=[undef, undef, corner_radius, corner_radius]);

            // Left support plate
            translate(plate_offset)
            rounded_square([55, base_offset], corners=[corner_radius, corner_radius, undef, undef]);

            // Right support plate
            translate(plate_offset + [plate_size[0], 0] - [86, 0])
            rounded_square([86, base_offset], corners=[corner_radius, corner_radius, undef, undef]);
        }

        translate(plate_offset)
        union() {
            // Bottom mounting slots, for floor mounting pieces
            // Bottom Left
            translate([50/2, 20])
            dual_m6_slot(25);

            // Bottom Right
            translate([plate_size[0] - 86/2, 20])
            dual_m6_slot(60);

            // Top mounting slots, for radiator mounting pieces
            // Top left
            translate([50/2, plate_size[1] - 12.5])
            dual_m6_slot(25);

            // Top right
            translate([plate_size[0] - 50/2, plate_size[1] - 12.5])
            dual_m6_slot(25);

            // Top center slot for display bracket mounting piece (optional?)
            translate([plate_size[0]/2, plate_size[1] - 12.5])
            dual_m6_slot(60); // TODO: Verify spacing against display mounting bracket

            // Hole for GPU power cable to thread through
            translate([plate_size[0] - 35/2 - 86/2, 12])
            rounded_square([35, 23], r = 4);

            // Thread hole for GPU support block
            translate([plate_size[0], 170])
            union()
            {
                translate([-25, 0])
                rotate(90)
                slot_hole(length = 20, d = M6_CLEARANCE_HOLE);

                translate([-65, 0])
                rotate(90)
                slot_hole(length = 20, d = M6_CLEARANCE_HOLE);
            }
        }

        translate(MOTHERBOARD_OFFSET)
        union() {
            for(pos = MINI_ITX_MOBO_MOUNTING_HOLES) {
                translate(pos)
                circle(d = M3_DRILL_HOLE); // To tap, for M3 male-female threaded standoff screwed directly into the plate.
            }
        }

        translate(pump_offset)
        pump_mount_holes();

        // GPU mount holes
        translate(GPU_MOUNT_OFFSET)
        translate([MOTHERBOARD_OFFSET[0] + MOTHERBOARD_PCIE_DATUM_POS[0] - gpu_mount_pcie_datum_offset(), 0]) // Horizontally align PCIe slots
        scale([-1, 1])
        union() {
            for(pos = gpu_mount_mounting_holes()) {
                translate(pos)
                #circle(d = M4_DRILL_HOLE);
            }
        }
    }
}

module gpu_support_block_3080_vector_3d() {
    // 3080 with EK vector waterblock:
    // thickness: 20.3mm
    // back spacing: 6mm
    // Card is flush along bottom with block

    // Screw holes at -25 and -65
    // M6 insert

    // TOOD: These values are only available in GPU mount
    // Should this be over there instead?
    backplate_thickness = 20.3 - 14.6 - 1.57;
    PCIE_CARD_Z_OFFSET = 6 + 3;

    difference() {
        hull() {
            translate([-77.5, -15, -15])
            linear_extrude(h = 15)
            translate([0, 0])
            rounded_square([65, 35], r = 5);

            translate([-77.5, -15, -30])
            linear_extrude(h = 30)
            translate([0, 0])
            rounded_square([65, 20], r = 5);
        }

        // Blind hole for Heat Set Insert M6 x 12.7
        translate([0, 10, 0]) 
        union() {
            translate([-25, 0, -13.7]) 
            cylinder(h = 13.7 + 0.01, d = 8.1);

            translate([-65, 0, -13.7]) 
            cylinder(h = 13.7 + 0.01, d = 8.1);
        }

        translate([-100, -100, -20.3 - PCIE_CARD_Z_OFFSET + backplate_thickness])
        cube([100, 100, 20.3]);
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
    translate([GPU_MOUNT_OFFSET[0], 0, GPU_MOUNT_OFFSET[1]])
    translate([MOTHERBOARD_OFFSET[0] + MOTHERBOARD_PCIE_DATUM_POS[0] - gpu_mount_pcie_datum_offset() ,0]) // Horizontally align PCIe slots
    rotate(90, [1, 0, 0])
    rotate(180, [0, 1, 0])
    gpu_mount_3d();

    // Motherboard itself. It sits 8mm above the plate on standoffs.
    translate([0, -7.62, 0])
    rotate([90, 0, 0])
    translate(MOTHERBOARD_OFFSET)
    union() {
        mini_itx_motherboard_3d();

        color("red", alpha=0.3)
        translate([0, 6.60, 1])
        cube([35, 158.75, 43]);

        // EK motherboard monoblock
        color("green")
        translate([-1, 15, 0]) // TODO: Approximate, needs measurement
        ek_monoblock_3d();
    }

    // Pump reference model
    translate([pump_offset[0], -42 - material_thickness, pump_offset[1]])
    %pump_3d();

    rotate(90, [1,0,0])
    translate(plate_offset + [plate_size[0], GPU_MOUNT_OFFSET[1] + 100.36 - 8])
    gpu_support_block_3080_vector_3d();

}

if(RENDER_MODE == 1) {
    // TODO
}
else if(RENDER_MODE == 2) {
    if(CUT) main_plate_2d();
    // TODO
    //if(ENGRAVE) main_plate_engrave_2d();
}
else if (RENDER_MODE == 3) {
    gpu_support_block_3080_vector_3d();
}
else {
    compute_sled_3d();
}
