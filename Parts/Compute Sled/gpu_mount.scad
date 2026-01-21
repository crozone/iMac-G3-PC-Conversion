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
use <../Shared/rounded_square.scad>;
use <pcie_card_bracket.scad>;

include <screw_hole_sizes.scad>
include <../Shared/shared_settings.scad>;

$fn = $preview ? 64 : 128;

VERSION = "v1.2";

// Render mode:
//
// 0: 3D visual
// 1: 2D all (arranged for cutting)
// 2: 2D Base plate
// 3: 2D Shim plate
// 4: 2D PCIe bracket screw plate
// 5: 2D PCIe bracket slot plate
// 6: 2D PCIe bracket side plate
RENDER_MODE_DEFAULT = 0;
EXPORT_RENDER_MODE = 0;

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

// A very small distance to overcome rounding errors
$eps = pow(2, -15);

// The thickness of the acrylic sheet being cut
MATERIAL_THICKNESS = 6;

// The thickness of the acrylic sheet being cut for the plate that sits against the PCIe bracket.
// It is desirable for it to be thinner for easier access to GPU IO ports
SIDE_PLATE_MATERIAL_THICKNESS = 3;

// On rounded corners, the radius to use.
ROUNDED_CORNER_RADIUS = 3;

// The amount of margin to give tabs. This reduces the length of the tabs which slot into a sheet of acrylic at a right angle.
// This is so that if the acrylic on the receiving side is slightly thinner due to manufacturing tolerences, the tab does not poke through proud on the other side.
TAB_MARGIN = MATERIAL_THICKNESS / 12;
TAB_LENGTH = MATERIAL_THICKNESS - TAB_MARGIN;

// The distance from the PCIe slot datum (the tab in between the power and data parts of the PCIe slot) and the outer face of the PCIe card bracket (from specification)
PCIE_SLOT_DATUM_OFFSET = 59.05;

// PCIe bracket height from screw mounting face to lower edge of PCB (from specification)
PCIE_BRACKET_HEIGHT = 100.36;

// Tweaks for the PCIe bracket IO cutout dimensions.
// This deviates the IO cutout size and position from the official specification in order to better accommodate the ports on a GPU,
// while strengthening the plate where ports are not present.
// Perspective is from the PCIe spec drawings, in which the card is vertical, looking from the inside of the case outwards (PCIe PCB is to the right of the bracket).
// The variable is an array of [ Left, Top, Right, Bottom ] arrays, where each element is a tweak for each PCIe slot.
ENABLE_PCIE_BRACKET_IO_CUTOUT_TWEAK = true;

// Version tuned for ASUS TUF GPUs with 3x DisplayPorts and 1x HDMI port on the 1st slot, and 1x HDMI port on the 2nd slot.
PCIE_BRACKET_IO_CUTOUT_TWEAK = ENABLE_PCIE_BRACKET_IO_CUTOUT_TWEAK ?
[
    [-1.5, 2, -2, -7],
    [-1.5, -57, -2, -7]
]
:
[
     [0, 0, 0, 0],
     [0, 0, 0, 0]
];

SIDE_PLATE_VERSION_TEXT = ENABLE_PCIE_BRACKET_IO_CUTOUT_TWEAK ? "ASUS TUF GPU" : "PCIe Reference";

// Riser position is relative to screw holes
// The position is the sum of:
// * The PCIe bracket height
// * 7mm gap between bottom of PCIe PCB and the top of the riser PCB
// * 5.5mm between the top of the riser PCB and the riser screw hole center
RISER_Y_POS = PCIE_BRACKET_HEIGHT + 7 + 5.5;

// Spacing in between PCIe card slots (from specification)
PCIE_SPACING_PER_CARD = 20.32;

// The number of slots the PCIe card will occupy
PCIE_CARDS = 2;

// Width of the vertical section that the GPU mounting plates extend from
SIDE_PLATE_WIDTH = 17;

// The length of the strip of tabs along the bottom of the side plate and base plate
SIDE_PLATE_LOWER_TABS_LENGTH = RISER_Y_POS - 5.5 - 7 - MATERIAL_THICKNESS - 10;

// Additional height to add to the riser with a shim plate
RISER_SHIM_HEIGHT = 3;

// The Z height of the bottom of the PCIe card PCB.
PCIE_CARD_Z_OFFSET = MATERIAL_THICKNESS + RISER_SHIM_HEIGHT;

// The height of the horizontal plates. Must be large enough to provide clearance for the PCIe brackets and IO connectors.
HORIZONTAL_PLATE_HEIGHT = (PCIE_CARDS * PCIE_SPACING_PER_CARD) - (PCIE_SPACING_PER_CARD - (1.57 + 0.35 + 12.06)) + RISER_SHIM_HEIGHT + 3;

SCREW_PLATE_EXTRA_HEIGHT = 7;
SCREW_PLATE_HEIGHT = HORIZONTAL_PLATE_HEIGHT + SCREW_PLATE_EXTRA_HEIGHT;

SLOT_PLATE_Y = RISER_Y_POS - 5.5 - 7 + 19.7 - 6 - 1;

SIDE_PLATE_LENGTH = SLOT_PLATE_Y - MATERIAL_THICKNESS;

MOUNTING_HOLES = [
    [28 - 116 - 6, 14] + [-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS],
    [28 - 116 - 6, -4] + [-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS],
    [28 + 6, 14] + [-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS],
    [28 + 6, -4] + [-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS],

    [SIDE_PLATE_MATERIAL_THICKNESS + (SIDE_PLATE_WIDTH - SIDE_PLATE_MATERIAL_THICKNESS)/2, 14 + RISER_Y_POS],

    [SIDE_PLATE_MATERIAL_THICKNESS + (SIDE_PLATE_WIDTH - SIDE_PLATE_MATERIAL_THICKNESS)/2, MATERIAL_THICKNESS + 1*(SLOT_PLATE_Y - MATERIAL_THICKNESS)/12],

    // Removed for causing a weak spot in the material
    //[SIDE_PLATE_MATERIAL_THICKNESS + (SIDE_PLATE_WIDTH - SIDE_PLATE_MATERIAL_THICKNESS)/2, MATERIAL_THICKNESS + 11*(SLOT_PLATE_Y - MATERIAL_THICKNESS)/12],
];

// Provides the PCIe slot datum offset for scripts consuming this as a library with use
function gpu_mount_pcie_datum_offset() = PCIE_SLOT_DATUM_OFFSET;

// Provides the bracket mounting holes for scripts consuming this as a library with use
function gpu_mount_mounting_holes() = MOUNTING_HOLES;

//
// The primary plate that everything attaches to
//
module base_plate_2d() {
    difference() {
        // Base plate
        union() {
            // Plate behind riser
            translate([SIDE_PLATE_WIDTH, RISER_Y_POS - 5.5 - 7])
            translate([-165 - SIDE_PLATE_WIDTH, 0])
            rounded_square([165, 35], corners = [ROUNDED_CORNER_RADIUS, 0, 0, ROUNDED_CORNER_RADIUS]);

            // Plate to hold GPU
            gpu_holder_plate_size = [SIDE_PLATE_WIDTH, RISER_Y_POS - 5.5 - 7 + 35];
            rounded_square(gpu_holder_plate_size, corners = [0, 0, ROUNDED_CORNER_RADIUS, 0]);

            // Additional lip at bottom to hold on screw plate
            translate([SIDE_PLATE_WIDTH - 5, -5])
            rounded_square([5, 5], corners = [2, 2, 0, 0]);

        }

        // Base plate tabs
        translate([0, SLOT_PLATE_Y])
        union() {
            translate([-11, 0])
            square([11, MATERIAL_THICKNESS]);
            translate([3, 0])
            square([8, MATERIAL_THICKNESS]);

            // Fastening screw clearance holes (M2)
            translate([SIDE_PLATE_WIDTH - 6/2, MATERIAL_THICKNESS / 2])
            circle(d = M3_CLEARANCE_HOLE);
            translate([-11 - 6/2, MATERIAL_THICKNESS / 2])
            circle(d = M3_CLEARANCE_HOLE);
        }

        // Screw plate tab slots
        union() {
            translate([2, 0])
            square([7, MATERIAL_THICKNESS]);

            translate([15, 0])
            square([2, MATERIAL_THICKNESS]);

            // Fastening screw clearance hole (M2 countersunk)
            translate([12, MATERIAL_THICKNESS / 2])
            circle(d = M3_CLEARANCE_HOLE);
        }

        // Side plate tab slots
        union() {
            translate([0, MATERIAL_THICKNESS + 10])
            for(i = [0:2:4]) {
                translate([0, i*(SIDE_PLATE_LOWER_TABS_LENGTH / 5)])
                square([SIDE_PLATE_MATERIAL_THICKNESS, SIDE_PLATE_LOWER_TABS_LENGTH / 5]);
            }

            translate([0, SIDE_PLATE_LENGTH + MATERIAL_THICKNESS + MATERIAL_THICKNESS + 13 - 9])
            square([SIDE_PLATE_MATERIAL_THICKNESS, 8]);
        }

        // Mounting screw holes (M4)
        union() {
            for(pos = MOUNTING_HOLES) {
                translate(pos)
                circle(d = M4_CLEARANCE_HOLE);
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
}

module base_plate_engrave_2d() {
    module riser_overlap() {
        intersection() {
            translate([PCIE_SLOT_DATUM_OFFSET, -RISER_Y_POS])
            base_plate_2d();
            riser_shim_plate_2d();
        }
    }

    // Glue trap for shim
    color("black")
    translate([-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS])
    difference() {
        offset(r = -1)
        riser_overlap();

        offset(r = -2)
        riser_overlap();
    }

    color("red")
    translate([SIDE_PLATE_MATERIAL_THICKNESS + (SIDE_PLATE_WIDTH - SIDE_PLATE_MATERIAL_THICKNESS)/2 - 3, MATERIAL_THICKNESS + (SLOT_PLATE_Y - MATERIAL_THICKNESS)/2])
    rotate(90)
    union()
    {
        text(text = "GPU Bracket", font = text_font, size = 2.5, halign = "center", valign = "top");
        translate([0, -4])
        text(text = VERSION, font = text_font, size = 2, halign = "center", valign = "top");
    }
}

// X = 0 is PCIe slot datum
// Y = 0 is riser mounting hole line
module riser_shim_plate_2d() {
    difference() {
        // Shim plate behind riser
        translate([PCIE_SLOT_DATUM_OFFSET, 0]) 
        translate([SIDE_PLATE_WIDTH, -5.5 - 7])
        translate([-165 - SIDE_PLATE_WIDTH, 0])
        union() {
            rounded_square([147, 35], corners = [0, ROUNDED_CORNER_RADIUS, ROUNDED_CORNER_RADIUS, ROUNDED_CORNER_RADIUS]);

            // TODO: Decide height
            translate([0, -8])
            #rounded_square([15.5, 8], corners = [ROUNDED_CORNER_RADIUS, ROUNDED_CORNER_RADIUS, 0, 0]);
        }

        // Mounting screw holes (M4)
        translate([PCIE_SLOT_DATUM_OFFSET, -RISER_Y_POS])
        union() {
            for(pos = MOUNTING_HOLES) {
                translate(pos)
                circle(d = M4_CLEARANCE_HOLE);
            }
        }

        // Cutout for PCIe edge connector locking tab thingy
        translate([-89 + 14.5 - 2, -5.5 - 7])
        translate([-12, 0])
        hull() {
        square([12, 2]);
            translate([-(14 - 12), -4])
            square([14, 4]);
        }

        // Cutout for plastic support
        // 3mm from bottom of riser PCB, 7mm from the right):
        translate([-7, 4])
        translate([0, -12 + 7]) // Align to bottom of PCB (PCB is 12 high, 7 is height of support cutout)
        // Align plastic support with top right of PCB:
        translate([28, 6.5])
        translate([-98 - 1/2, -7 - 1])
        square([98 + 1, 7 + 3.5]); // 1mm, 0.5 margin for error

        // Cutout for PCIe slot and cable on riser
        translate([2, 0]) // Dodge the cable
        translate([14.5, 0]) // Connector edge is 14.5mm from datum
        translate([-(89 + 2 + 2), -25])
        square([89 + 2 + 2, 25]);

        // PCIe slot datum to outer face of bracket: 59.05mm delta X
        riser_mounting_holes();
    }
}

module riser_shim_plate_engrave_2d() {
    color("black")
    intersection() {
        translate([0, -5.5 - 7])
        translate([-0.5/2, 0])
        square([0.5, 35]);

        riser_shim_plate_2d();
    }

    color("red")
    translate([-(89 + 2) + 14.5, 35 - 22])
    text(text = str("PCIe riser shim (", RISER_SHIM_HEIGHT, "mm)"), font = text_font, size = 2, halign = "left", valign = "top");

    color("red")
    translate([1, 35 - 25.5])
    rotate(90)
    text(text = str("PCIe slot datum"), font = text_font, size = 1, halign = "left", valign = "top");
    
}

// Aligned with X=0 as PCIe slot datum
module riser_mounting_holes() {
    translate([24, 0])
    union() {
        circle(d = M3_DRILL_HOLE);

        translate([-108, 0])
        circle(d = M3_DRILL_HOLE);
    }
}

//
// The horizontal plate that the PCIe bracket screws onto
//
module screw_plate_2d() {
    difference() {
        // Plate
        union() {
            rounded_square([SIDE_PLATE_WIDTH, SCREW_PLATE_HEIGHT], corners = [0, 0, ROUNDED_CORNER_RADIUS, 0]);

            // Base plate tabs
            translate([2, -TAB_LENGTH])
            square([7, TAB_LENGTH]);

            translate([15, -TAB_LENGTH])
            square([2, TAB_LENGTH]);
        }

        // Side plate tabs
        union() {
            translate([-0.1, 6])
            square([SIDE_PLATE_MATERIAL_THICKNESS + 0.1, 10]);

            difference() {
                translate([-0.1, PCIE_SPACING_PER_CARD + 6])
                square([SIDE_PLATE_MATERIAL_THICKNESS + 0.1, SCREW_PLATE_HEIGHT - (6 + PCIE_SPACING_PER_CARD)]);


                // OPTIONAL: Tab. Disable if using tapped screw hole.
                *translate([0, SCREW_PLATE_HEIGHT - 6])
                square([SIDE_PLATE_MATERIAL_THICKNESS, 3]);
            }
        }

        // PCIe bracket drill holes (M4)
        translate([0, RISER_SHIM_HEIGHT]) 
        translate([11.43 - 6.35, 17.15 - 2.54 - 16.505]) // Tab edge is 17.15mm above bottom of PCIe PCB. Screw Y is 16.505mm below tab edge.
        union() {
            for(i = [0:PCIE_CARDS-1]) {
                translate([0, i * PCIE_SPACING_PER_CARD])
                circle(d = M4_DRILL_HOLE);
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
            translate([-SIDE_PLATE_WIDTH, 0])
            rounded_square([SIDE_PLATE_WIDTH + SIDE_PLATE_WIDTH, HORIZONTAL_PLATE_HEIGHT], corners = [0, 0, ROUNDED_CORNER_RADIUS, ROUNDED_CORNER_RADIUS]);

            // Base plate tabs
            translate([-11, -TAB_LENGTH])
            square([11, TAB_LENGTH]);
            translate([3, -TAB_LENGTH])
            square([8, TAB_LENGTH]);
        }

        // Side plate tab slot
        translate([0, -TAB_LENGTH])
        square([SIDE_PLATE_MATERIAL_THICKNESS, 20 + TAB_LENGTH]);
        
        // PCIe bracket tab slots
        translate([0, RISER_SHIM_HEIGHT]) 
        translate([-(0.86 + 0.14), 4.11 - 1.27 - 0.5/2])
        union() {
            for(i = [0:PCIE_CARDS-1]) {
                translate([0, i * PCIE_SPACING_PER_CARD])
                square([(0.86 + 0.14) + 0.1, 10.19 + 0.5]);
            }
        }
    }
}

// Plate that sits flat against the PCIe bracket and supports the slot and screw plates side on.
module side_plate_2d() {
    // X direction is rotated to be the Z direction in final 3D design,
    // with negative X being "downwards".
    // X = 0 is the bottom of the PCIe card PCB.
    // X height must cover both PCIe brackets.

    difference() {
        union() {
            translate([0, MATERIAL_THICKNESS])
            square([HORIZONTAL_PLATE_HEIGHT, RISER_Y_POS]);

            translate([0, RISER_Y_POS + MATERIAL_THICKNESS])
            intersection() {
                square([HORIZONTAL_PLATE_HEIGHT, -5.5 - 7 + 35 - MATERIAL_THICKNESS]);

                hull() {
                    square([RISER_SHIM_HEIGHT, -5.5 - 7 + 35 - MATERIAL_THICKNESS]);
                    square([HORIZONTAL_PLATE_HEIGHT, 2]);

                    translate([RISER_SHIM_HEIGHT, -5.5 - 7 + 35 - MATERIAL_THICKNESS - ROUNDED_CORNER_RADIUS])
                    circle(r = ROUNDED_CORNER_RADIUS);

                    translate([HORIZONTAL_PLATE_HEIGHT - ROUNDED_CORNER_RADIUS, 2])
                    circle(r = ROUNDED_CORNER_RADIUS);
                }
            }


            difference() {
                union() {
                    // Main tabs on the side
                    translate([6, TAB_MARGIN]) {
                        square([10, TAB_LENGTH]);

                        translate([PCIE_SPACING_PER_CARD, 0])
                        square([(HORIZONTAL_PLATE_HEIGHT + 5) - (6 + PCIE_SPACING_PER_CARD) - 3, TAB_LENGTH]);
                    }

                    hull() {
                        // Lower strip to form ramp
                        translate([HORIZONTAL_PLATE_HEIGHT - 1, MATERIAL_THICKNESS]) 
                        square([1, 20]);

                        // Rounded circle at top of ramp
                        translate([SCREW_PLATE_HEIGHT - ROUNDED_CORNER_RADIUS, MATERIAL_THICKNESS + 2])
                        circle(r = ROUNDED_CORNER_RADIUS);

                        // Main square wrapping around tab
                        translate([HORIZONTAL_PLATE_HEIGHT, 0])
                        square([SCREW_PLATE_EXTRA_HEIGHT, MATERIAL_THICKNESS + 2]);  
                    }

                    // Extra wrap around tab to attach to screw plate
                    translate([HORIZONTAL_PLATE_HEIGHT - 2, -5])
                    rounded_square([SCREW_PLATE_EXTRA_HEIGHT + 2, MATERIAL_THICKNESS + 5], corners = [ROUNDED_CORNER_RADIUS, ROUNDED_CORNER_RADIUS, 0, 0]);
                }

                // Slot plate tab
                *translate([HORIZONTAL_PLATE_HEIGHT + 5 - 5, 0])
                square([3, MATERIAL_THICKNESS]);

                // OR screw hole for screwing into tapped hole in screw plate
                translate([HORIZONTAL_PLATE_HEIGHT + 3, MATERIAL_THICKNESS / 2])
                circle(d = M3_CLEARANCE_HOLE);
            }

            // Base plate tabs
            union() {
                translate([-TAB_LENGTH, MATERIAL_THICKNESS + 10]) 
                for(i = [0:2:4]) {
                    translate([0, i*(SIDE_PLATE_LOWER_TABS_LENGTH / 5)])
                    square([TAB_LENGTH, SIDE_PLATE_LOWER_TABS_LENGTH / 5]);
                }

                translate([-TAB_LENGTH, SIDE_PLATE_LENGTH + MATERIAL_THICKNESS + MATERIAL_THICKNESS + 13 - 9])
                square([TAB_LENGTH, 8]);
            }
        }

        // Slot plate cutout
        translate([20, SLOT_PLATE_Y])
        square([HORIZONTAL_PLATE_HEIGHT - 20 + 0.01, MATERIAL_THICKNESS]);

        // Fastening screw clearance hole (M2 countersunk)
        // for base plate
        translate([-TAB_LENGTH, MATERIAL_THICKNESS + 10 + SIDE_PLATE_LOWER_TABS_LENGTH / 10]) 
        union() {
            for(i = [0:2:4]) {
                translate([MATERIAL_THICKNESS / 2, i * SIDE_PLATE_LOWER_TABS_LENGTH / 5])
                circle(d = M3_CLEARANCE_HOLE);
            }
        }

        // IO cutouts
        translate([RISER_SHIM_HEIGHT, 0])
        translate([1.57 + 0.35, 10.16])
        for(i = [0:PCIE_CARDS-1]) {
            io_tweak = PCIE_BRACKET_IO_CUTOUT_TWEAK[i];

            translate([i * PCIE_SPACING_PER_CARD, 0])
            translate([io_tweak[0], -io_tweak[1]])
            square([12.06, 89.9] - [io_tweak[0], -io_tweak[1]] + [io_tweak[2], io_tweak[3]]);
        }
    }
}

module side_plate_engrave_2d() {
    color("red")
    translate([HORIZONTAL_PLATE_HEIGHT - 4, RISER_Y_POS - 3])
    scale([-1, 1, 1])
    union()
    {
        text(text = str("PCIe IO"), font = text_font, size = 2.5, halign = "left", valign = "top");
        translate([0, -4])
        text(text = SIDE_PLATE_VERSION_TEXT, font = text_font, size = 2, halign = "left", valign = "top");
    }
}

// Riser 2D reference.
// X = 0 is the PCIe slot datum
// Y = 0 is the screw hole center line
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
            circle(d = M3_CLEARANCE_HOLE);

            translate([-108, 0])
            circle(d = M3_CLEARANCE_HOLE);
        }
    }
}

//!pcie_card_reference_2d();

module pcie_card_reference_2d() {
    translate([0, -PCIE_BRACKET_HEIGHT])
    difference() {
        union() {
            translate([PCIE_SLOT_DATUM_OFFSET, 0])
            difference() {
                union() {
                    // PCIe card slot

                    // Power
                    translate([-11 - 1, -4])
                    *square([11, 12]);

                    // Data
                    translate([1, -4])
                    *square([71, 12]);

                    // Combined version for rounded slot
                    translate([-11 - 1, -4])
                    square([11 + 2 + 71, 12]);

                }

                
            }

            // PCIe slot and PCB
            union() {
                translate([2, 0])
                square([17 - 2, 90]);

                translate([35, 0])
                square([8, 8]);

                // Gap fill for rounded slot
                translate([35 + 8, 0])
                square([4.05, 8]);

                translate([17 - 2 + 2, 8])
                square([232 - 17 - 2, 127]); // 5090 TUF PCB measurements
            }

            // Locking tab
            // TODO: Verify exact measurements
            translate([PCIE_SLOT_DATUM_OFFSET, 0])
            translate([1 + 71, 0])
            union() {
                translate([4, 0]) 
            #hull() {
                translate([0, -1])
                square([10, 2.5]);

                translate([0, -1 + 2.5])
                square([12, 2.5]);
            }
            
            %translate([0, -1])
            square([4, 9]);

            }
        }

        // Rounded cutout in-between square tab and PCIe edge connector
        translate([35 + 8, 0])
        hull()
        {
            translate([4.05/2, 6 - 1])
            circle(d = 4.05);

            translate([0, -0.1])
            square([4.05, 4]);
        }

        // Rounded cutout in-between PCIe edge connector Power and Data sections
        translate([PCIE_SLOT_DATUM_OFFSET, 0])
        hull()
        {
            translate([0, 6 - 1])
            circle(r = 1);

            translate([-2/2, -4 - 0.1])
            square([2, 2]);
        }

        // Rounded cutout in-between PCIe edge connector and locking tab
        // TODO

        // Rounded cutout above locking tab
        // TODO
        
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
    difference() {
        linear_extrude(height = MATERIAL_THICKNESS)
        base_plate_2d();

        translate([0, 0, MATERIAL_THICKNESS - 0.2])
        linear_extrude(height = 0.2 + 0.01)
        base_plate_engrave_2d();
    }
}

module riser_shim_plate_3d() {
    linear_extrude(height = RISER_SHIM_HEIGHT)
    riser_shim_plate_2d();
}

module screw_plate_3d() {
    linear_extrude(height = MATERIAL_THICKNESS)
    screw_plate_2d();
}

module slot_plate_3d() {
    linear_extrude(height = MATERIAL_THICKNESS)
    slot_plate_2d();
}

module side_plate_3d() {
    difference() {
        linear_extrude(height = SIDE_PLATE_MATERIAL_THICKNESS)
        side_plate_2d();

        translate([0, 0, SIDE_PLATE_MATERIAL_THICKNESS - 0.2])
        linear_extrude(height = 0.2 + 0.01)
        side_plate_engrave_2d();
    }
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
            cylinder(h = 1 + 0.2, d = M3_CLEARANCE_HOLE);

            translate([-108, 0])
            cylinder(h = 1 + 0.2, d = M3_CLEARANCE_HOLE);
        }
    }
}

module pcie_card_reference_3d() {
    linear_extrude(height = 1.57)
    pcie_card_reference_2d();
}

module gpu_mount_3d() {
    // Base plate
    base_plate_3d();

    // Shim plate
    color(alpha = 0.7)
    translate([-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS, MATERIAL_THICKNESS])
    riser_shim_plate_3d();

    // Screw plate
    color("orange", alpha=0.5)
    translate([0, MATERIAL_THICKNESS, MATERIAL_THICKNESS])
    rotate(90, [1, 0, 0])
    screw_plate_3d();

    // Slot plate
    color("orange", alpha=0.5)
    translate([0, SLOT_PLATE_Y])
    translate([0, MATERIAL_THICKNESS, MATERIAL_THICKNESS])
    rotate(90, [1, 0, 0])
    slot_plate_3d();

    // Side plate
    color("purple", alpha=0.5)
    translate([SIDE_PLATE_MATERIAL_THICKNESS, 0, MATERIAL_THICKNESS])
    rotate(-90, [0, 1, 0])
    side_plate_3d();

    %translate([-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS, PCIE_CARD_Z_OFFSET])
    riser_reference_3d();

    translate([0, 0, PCIE_CARD_Z_OFFSET])
    %rotate(180)
    pcie_card_reference_3d();

    // PCIe bracket reference
    translate([0, 0, PCIE_CARD_Z_OFFSET])
    rotate(90, [1, 0, 0])
    rotate(-90, [0, 0, 1])
    %union() {
        for(i = [0:PCIE_CARDS-1]) {
            translate([i * -PCIE_SPACING_PER_CARD, 0, 0])
            pcie_bracket_reference_3d();
        }
    }

    // Mounting screw screwdriver clearance
    %union() {
        for(pos = MOUNTING_HOLES) {
            translate(pos)
            cylinder(h = HORIZONTAL_PLATE_HEIGHT + 20, d = M4_CLEARANCE_HOLE);
        }
    }
}

if(RENDER_MODE == 0) {
    gpu_mount_3d();
}
else if(RENDER_MODE == 1) {
    // TODO
}
else if(RENDER_MODE == 2) {
    if(CUT) base_plate_2d();
    if(ENGRAVE) base_plate_engrave_2d();
}
else if(RENDER_MODE == 3) {
    if(CUT) riser_shim_plate_2d();
    if(ENGRAVE) riser_shim_plate_engrave_2d();
}
else if(RENDER_MODE == 4) {
    if(CUT) screw_plate_2d();
}
else if(RENDER_MODE == 5) {
    if(CUT) slot_plate_2d();
}
else if(RENDER_MODE == 6) {
    if(CUT) side_plate_2d();
    if(ENGRAVE) side_plate_engrave_2d();
}
else {
    // if(EXPORT_LAYER == 0 || EXPORT_LAYER == 1) {
    //     base_plate_2d();

    //     %translate([-PCIE_SLOT_DATUM_OFFSET, RISER_Y_POS])
    //     riser_reference_2d();
    // }

    // if(EXPORT_LAYER == 0 || EXPORT_LAYER == 2) {
    //     // Engraver reference line
    //     %translate([-1, RISER_Y_POS - 5.5 - 7])
    //     square([1, 30]);
    // }

    // if(EXPORT_LAYER == 0) {
    //     %rotate(180) {
    //     pcie_card_reference_2d();
    //     pcie_bracket_reference_top_down_2d();
    //     }
    // }
}