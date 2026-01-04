// GPU Mount
// Part of the compute sled
// Ryan Crosby 2025.
//
// This is a bracket that attaches to the rear side of the motherboard mounting plate.
// It holds the GPU riser and the GPU.
//
// There is an additional mounting hole on the PCIe screw bracket holder for additional support from the iMac chassis.
//
// GPU Riser: K33UF-TU https://www.adt.link/product/K33UF-TU.html
// GPU: NVIDIA 5090 (ASUS TUF) + Alphacool waterblock
//
// Alignment to axis:
// X Axis: Outer (rightmost) face of PCIe bracket on GPU
// Y Axis: Inner mounting face of PCIe bracket screw hole plate
// Remember that the GPU is mounted upside down, with the PCIe riser on top (positive Y direction), and the PCIe mounting bracket to the right (positive X direction)
//
// The PCIe slot "datum" is the tab separating the power pins and the data pins on the slot.
//
use <../Shared/2Dshapes.scad>;
use <../Shared/rounded_corner.scad>;
use <pcie_card_bracket.scad>;

include  <../Shared/shared_settings.scad>;

// Render mode:
//
// 0: 3D visual
// 1: 2D all
// 2: 2D Base plate
// 3: 2D PCIe bracket flat holder
// 4: 2D PCIe bracket screw holder
// 5: 2D PCIe bracket screw holder re-enforcing
RENDER_MODE_DEFAULT = 0;

// Overridden by export script
// 0: Both layers
// 1: Cut layer
// 2: Engrave layer

EXPORT_LAYER = 0;

EXPORT_RENDER_MODE = 1;

if(EXPORT_LAYER != 0) {
    echo(str("EXPORT_LAYER enabled, set to ", EXPORT_LAYER));
}

RENDER_MODE = EXPORT_LAYER > 0 ? EXPORT_RENDER_MODE : RENDER_MODE_DEFAULT;

echo(str("EXPORT_LAYER: ", EXPORT_LAYER));
echo(str("Render mode: ", RENDER_MODE));

$fn = $preview ? 64 : 128;

// A very small distance to overcome rounding errors
$eps = pow(2, -15);

// The thickness of the acrylic sheet being cut
MATERIAL_THICKNESS = 6;

// On rounded corners, the radius to use.
ROUNDED_CORNER_RADIUS = 3;

// The amount of margin to give tabs. This reduces the length of the tabs which slot into a sheet of acrylic at a right angle.
// This is so that if the acrylic on the receiving side is slightly thinner due to manufacturing tolerences, the tab does not poke through proud on the other side.
TAB_MARGIN = MATERIAL_THICKNESS / 12;
TAB_LENGTH = MATERIAL_THICKNESS - TAB_MARGIN;

// The distance from the PCIe slot datum (the tab in between the power and data parts of the PCIe slot) and the outer face of the PCIe card bracket
PCIE_SLOT_DATUM_OFFSET = 59.05;

// PCIe bracket height from screw mounting face to lower edge of PCB
PCIE_BRACKET_HEIGHT = 100.36;

// Riser position is relative to screw holes
// The position is the sum of:
// * The PCIe bracket height
// * 7mm gap between bottom of PCIe PCB and the top of the riser PCB
// * 5.5mm between the top of the riser PCB and the riser screw hole center
RISER_Y_POS = PCIE_BRACKET_HEIGHT + 7 + 5.5;

// Spacing in between PCIe card slots
PCIE_SPACING_PER_CARD = 20.32;

// The number of slots the PCIe card will occupy
PCIE_CARDS = 2;

// Width of the vertical section that the GPU mounting plates extend from
SIDE_PLATE_WIDTH = 25;

// The height of the horizontal plates. Must be large enough to provide clearance for the PCIe brackets and IO connectors.
HORIZONTAL_PLATE_HEIGHT = (PCIE_CARDS * PCIE_SPACING_PER_CARD) - (PCIE_SPACING_PER_CARD - (1.57 + 0.35 + 12.06)) + 1;

MOUNTING_HOLES = [
    //[0, 0],

    [28 - 116 - 6, 12] + [-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS],
    [28 - 116 - 6, -6] + [-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS],
    [28 + 6, 12] + [-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS],
    [28 + 6, -6] + [-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS],

    [SIDE_PLATE_WIDTH - 10, 12 + RISER_Y_POS],
    [SIDE_PLATE_WIDTH - 10, 90],
    [SIDE_PLATE_WIDTH - 10, 30],

    [12 + 13/2, -13/2],
];

//
// The primary plate that everything attaches to
//
module base_plate_2d() {
    base_plate_size = [190, 160];

    difference() {
        // Base plate
        union() {
            // Plate behind riser
            translate([20, RISER_Y_POS - 5.5 - 7])
            translate([-180, 35]/2)
            roundedSquare([190, 35], r = ROUNDED_CORNER_RADIUS);

            // Plate to hold GPU
            gpu_holder_plate_size = [SIDE_PLATE_WIDTH, RISER_Y_POS - 5.5 - 7 + 10];
            square(gpu_holder_plate_size);

            translate([12, -13])
            square([SIDE_PLATE_WIDTH - 12, 13]);
        }

        // PCIe bracket slot plate tab slots
        translate([0, RISER_Y_POS - 5.5 - 7 + 19.7 - 6 - 1])
        union() {
            translate([-2 - 6, 0])
            square([6, MATERIAL_THICKNESS]);
            translate([2, 0])
            square([6, MATERIAL_THICKNESS]);
            translate([16, 0])
            square([6, MATERIAL_THICKNESS]);
        }

        // PCIe bracket screw plate tab slots
        union() {
            translate([2, 0])
            square([6, MATERIAL_THICKNESS]);
            translate([16, 0])
            square([6, MATERIAL_THICKNESS]);
        }

        // Mounting screw holes (M4)
        union() {
            for(pos = MOUNTING_HOLES) {
                translate(pos)
                circle(d = 4.5);
            }
        }

        // Cutout for plastic support
        // 3mm from bottom of riser PCB, 7mm from the right):
        translate([-7, 4])
        translate([0, -12 + 7]) // Align to bottom of PCB (PCB is 12 high, 7 is height of support cutout)
        // Align plastic support with top right of PCB:
        translate([-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS]) // Align to PCIe datum
        translate([28, 6.5])
        translate([-98 - 1/2, -7 - 1])
        square([98 + 1, 7 + 3.5]); // 1mm, 0.5 margin for error

        // Cutout for PCIe slot and cable on riser
        translate([2, 0]) // Dodge the cable
        translate([-PCIE_SLOT_DATUM_OFFSET + 14.5, RISER_Y_POS]) // Align to PCIe datum
        translate([-(89 + 2 + 2), -25])
        square([89 + 2 + 2, 25]);

        // PCIe slot datum to outer face of bracket: 59.05mm delta X
        translate([-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS])
        riser_mounting_holes();
    }

    // Aligned with X=0 as PCIe slot datum
    module riser_mounting_holes() {
        translate([24, 0])
        union() {
            circle(d = 2.5); // M3 screw hole for tapping

            translate([-108, 0])
            circle(d = 2.5); // M3 screw hole for tapping
        }
    }
}

//
// The horizontal plate that the PCIe bracket screws onto
//
module screw_plate_2d() {
    difference() {
        // Plate
        union() {
            square([SIDE_PLATE_WIDTH, HORIZONTAL_PLATE_HEIGHT]);

            // Bottom tabs
            translate([2, -TAB_LENGTH])
            square([6, TAB_LENGTH]);
            translate([16, -TAB_LENGTH])
            square([6, TAB_LENGTH]);
            // Top tabs
            translate([2, HORIZONTAL_PLATE_HEIGHT])
            square([6, TAB_LENGTH]);
            translate([16, HORIZONTAL_PLATE_HEIGHT])
            square([6, TAB_LENGTH]);
        }

        // PCIe bracket drill holes (M4)
        translate([11.43 - 6.35, 17.15 - 2.54 - 16.505]) // Tap edge is 17.15mm above bottom of PCIe PCB. Screw Y is 16.505mm below tab edge.
        union() {
            for(i = [0:PCIE_CARDS-1]) {
                translate([0, i * PCIE_SPACING_PER_CARD])
                circle(d = 3.3); // M4 drill hole for tapping
            }
        }
    }
}

//
// The horizontal plate that the PCIe bracket tab slots into
//
module slot_plate_2d() {
    difference() {
        union() {
            translate([-8, 0])
            hull() {
                difference() {
                    square([SIDE_PLATE_WIDTH + 8, HORIZONTAL_PLATE_HEIGHT]);

                    translate([0, HORIZONTAL_PLATE_HEIGHT - ROUNDED_CORNER_RADIUS])
                    square([ROUNDED_CORNER_RADIUS, ROUNDED_CORNER_RADIUS]);
                }

                translate([ROUNDED_CORNER_RADIUS, HORIZONTAL_PLATE_HEIGHT - ROUNDED_CORNER_RADIUS])
                circle(r = ROUNDED_CORNER_RADIUS);
            }

            // Bottom tabs
            translate([-2 - 6, -TAB_LENGTH])
            square([6, TAB_LENGTH]);
            translate([2, -TAB_LENGTH])
            square([6, TAB_LENGTH]);
            translate([16, -TAB_LENGTH])
            square([6, TAB_LENGTH]);
            // Top tabs
            translate([2, HORIZONTAL_PLATE_HEIGHT])
            square([6, TAB_LENGTH]);
            translate([16, HORIZONTAL_PLATE_HEIGHT])
            square([6, TAB_LENGTH]);
        }

        slot_height_tolerence = 0.5;
        slot_width_tolerence = 0.14;
        slot_pos_offset = 0.0; // The tabs on the PCIe bracket are usually slightly bent, so the tab slot position may need to be tweaked

        // PCIe bracket tab slots
        translate([-0.86 + slot_pos_offset, 4.11 - 1.27 - slot_height_tolerence/2])
        union() {
            for(i = [0:PCIE_CARDS-1]) {
                translate([0, i * PCIE_SPACING_PER_CARD])
                square([0.86, 10.19] + [slot_width_tolerence, slot_height_tolerence]);
            }
        }
    }
}

module riser_reference_2d() {
    // Riser
    difference() {
        union() {
            // PCB
            translate([28, 6.5])
            translate([-116, -12])
            square([116, 12]);

            // PCIe slot
            translate([14.5, 0]) // Align to PCIe slot datum
            translate([0, -5.5])
            translate([-89, -10])
            square([89, 10]);
        }

        // M3 clearance holes
        translate([24, 0])
        union() {
            circle(d = 3.4);

            translate([-108, 0])
            circle(d = 3.4);
        }
    }
}

module pcie_card_reference_2d() {
    translate([0, -PCIE_BRACKET_HEIGHT])
    union() {
        translate([PCIE_SLOT_DATUM_OFFSET, 0])
        union() {
            // PCIe card slot

            // Power
            translate([-11 - 1, -4])
            square([11, 12]);

            // Data
            translate([1, -4])
            square([71, 12]);

        }

        // PCIe slot and PCB
        union() {
            translate([2, 0])
            square([17 - 2, 90]);

            translate([35, 0])
            square([8, 8]);

            translate([17 - 2 + 2, 8])
            square([232 - 17 - 2, 127]); // 5090 TUF PCB measurements
        }
    }
}

module pcie_bracket_reference_top_down_2d() {
    translate([0, -PCIE_BRACKET_HEIGHT])
    union() {
        color("pink")
        translate([-11, PCIE_BRACKET_HEIGHT])
        square([11 + 1, 1]);

        color("blue")
        square([1, PCIE_BRACKET_HEIGHT]);

        color("red")
        translate([0, -15.6])
        square([1, 15.6]);

        color("purple")
        translate([0, -19.7])
        square([1, 19.7 - 15.6]);
    }
}

module base_plate_3d() {
    linear_extrude(height = MATERIAL_THICKNESS)
    base_plate_2d();
}

module screw_plate_3d() {
    linear_extrude(height = MATERIAL_THICKNESS)
    screw_plate_2d();
}

module slot_plate_3d() {
    linear_extrude(height = MATERIAL_THICKNESS)
    slot_plate_2d();
}

module riser_reference_3d() {
    // Riser
    difference() {
        union() {
            // PCB
            translate([28, 6.5, 0])
            translate([-116, -12, 0])
            cube([116, 12, 1]);

            // PCIe slot
            translate([14.5, 0, 0]) // Align to PCIe slot datum
            translate([0, -5.5, 0])
            translate([-89, -10, -10/2 + 1/2])
            cube([89, 10, 10]); // TODO confirm height
        }

        // M3 clearance holes
        translate([24, 0, -0.1])
        union() {
            cylinder(h = 1 + 0.2, d = 3.4); // M3 clearance hole

            translate([-108, 0])
            cylinder(h = 1 + 0.2, d = 3.4); // M3 clearance hole
        }
    }
}

module pcie_card_reference_3d() {
    linear_extrude(height = 1.57)
    pcie_card_reference_2d();
}

if(RENDER_MODE == 0) {
    // Base plate
    base_plate_3d();

    // Screw plate
    color("orange", alpha=0.5)
    translate([0, MATERIAL_THICKNESS, MATERIAL_THICKNESS])
    rotate(90, [1, 0, 0])
    screw_plate_3d();

    // Slot plate
    color("orange", alpha=0.5)
    translate([0, RISER_Y_POS - 5.5 - 7 + 19.7 - 6 - 1])
    translate([0, MATERIAL_THICKNESS, MATERIAL_THICKNESS])
    rotate(90, [1, 0, 0])
    slot_plate_3d();

    %translate([-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS, MATERIAL_THICKNESS])
    riser_reference_3d();

    translate([0, 0, 6])
    %rotate(180)
    pcie_card_reference_3d();

    translate([0, 0, 6])
    rotate(90, [1, 0, 0])
    rotate(-90, [0, 0, 1])
    %union() {
        for(i = [0:PCIE_CARDS-1]) {
            translate([i * -PCIE_SPACING_PER_CARD, 0, 0])
            pcie_bracket_reference_3d();
        }
    }
}
else {
    if(EXPORT_LAYER == 0 || EXPORT_LAYER == 1) {
        base_plate_2d();

        %translate([-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS])
        riser_reference_2d();
    }

    if(EXPORT_LAYER == 0) {
        // Engraver reference line
        %translate([-1, RISER_Y_POS - 5.5 - 7])
        square([1, 30]);
    }
    if(EXPORT_LAYER == 2) {
        // Engraver reference line
        #translate([-1, RISER_Y_POS - 5.5 - 7])
        square([1, 30]);
    }

    if(EXPORT_LAYER == 0) {
        %rotate(180) {
        pcie_card_reference_2d();
        pcie_bracket_reference_top_down_2d();
        }
    }
}
