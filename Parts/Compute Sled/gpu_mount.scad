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
use <../Shared/tab_strip.scad>;
use <../Shared/rounded_corner.scad>;

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

material_thickness = 6;

PCIE_SLOT_DATUM_OFFSET = 59.05;

// PCIe bracket height from screw mounting face to lower edge of PCB
PCIE_BRACKET_HEIGHT = 100.36;

// Riser position is relative to screw holes
// The position is the sum of:
// * The PCIe bracket height
// * 7mm gap between bottom of PCIe PCB and the top of the riser PCB
// * 5.5mm between the top of the riser PCB and the riser screw hole center
RISER_Y_POS = PCIE_BRACKET_HEIGHT + 7 + 5.5;

MOUNTING_HOLES = [
    [-4.5 - 2, -10 + 4.5 + 2],
    [-4.5 - 2,  40 + -4.5 - 2],
    [-180 + 4.5 + 2, 4.5 + 2],
    [-180 + 4.5 + 2, 40 + -4.5 - 2],

    [-4.5 - 2, -120 + 4.5 + 2],
];

module base_plate_2d() {
    base_plate_size = [190, 160];

    difference() {
        
        // Base plate
        union() {
            // Plate behind riser
            translate([20, RISER_Y_POS - 5.5 - 7])
            translate([-180, 40]/2)
            roundedSquare([180, 40], r = 3);

            // plate to hold GPU
            gpu_holder_plate_size = [20, RISER_Y_POS - 5.5 - 7 + 30 + 40];
            translate([0, -40])
            translate(gpu_holder_plate_size/2)
            roundedSquare(gpu_holder_plate_size, r = 3);
        }

        // Tab support slots
        translate([0, RISER_Y_POS - 5.5 - 7 + 19.7 - 6 - 1])
        tab_strip(width = 40, tab_width = 7, tab_height = 6, inverse = false);

        // Screw support slots
        translate([20/2, 0])
        tab_strip(width = 20, tab_width = 7, tab_height = 6, inverse = false);

        // Mounting screw holes (M4)
        translate([20, RISER_Y_POS - 5.5 - 7])
        #union() {
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

        // Cutout for PCIe slot on rise
        translate([2, 0]) // Also dodge the cable
        translate([-PCIE_SLOT_DATUM_OFFSET + 14.5, RISER_Y_POS]) // Align to PCIe datum
        translate([-(89 + 2 + 2), -25])
        square([89 + 2 + 2, 25]);

        // translate([20, 130])
        // translate(-base_plate_size/2)
        // roundedSquare(base_plate_size, r = 3);

        // PCIe slot datum to outer face of bracket: 59.05mm delta X
        translate([-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS])
        riser_mounting_holes();

        %translate([-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS])
        riser_reference_2d();
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

module riser_reference_2d() {
        // Riser
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
    }

module pcie_card_reference_2d() {
    translate([0, -PCIE_BRACKET_HEIGHT]) {
        union() {
            translate([PCIE_SLOT_DATUM_OFFSET, 0])
            union() {
                // PCIe card slot

                // Power
                translate([-11 - 1, -4])
                square([11, 13]);

                // Data
                translate([1, -4])
                square([71, 13]);

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

            // PCIe bracket
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
    }
}


if(EXPORT_LAYER == 0 || EXPORT_LAYER == 1) {
    base_plate_2d();
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
    %rotate(180)
    pcie_card_reference_2d();
}

//pcie_card_reference_2d();
