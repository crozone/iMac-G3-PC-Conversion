// PCIe bracket reference models
// Ryan Crosby 2026
//
// Built from reference at https://www.overclock.net/threads/guide-to-drawing-pci-e-and-atx-mitx-rear-io-bracket-for-a-custom-case.1589018/

$fn = $preview ? 64 : 128;

SHEET_THICKNESS = 0.86;
PCIE_SPACING_PER_CARD = 20.32;

module pcie_bracket_face_reference_2d() {
    // The perspective of the plate is from the inside of the case looking outwards, so it appears mirrored.

    // X = 0 is the lower (rightmost) surface of the PCB
    // Y = 0 is at the lower face of the top wing that is fastened to the case

    // Top folded wing tab reference
    translate([-17.15 + 2.54, 0])
    %square([21.59 - 2.54, SHEET_THICKNESS]);

    // Wing offset dimension reference
    *translate([-17.15, -4.56])
    %square([21.59, 4.56]);

    // Main plate dimension reference
    *translate([-17.15, -120.02])
    %square([18.42, 120.02]);

    difference() {
        // Main plate
        union() {
            // Top offset section
            union() {
                // Topmost square shifted to right
                hull() {
                    translate([-17.15 + 2.54, -2.92])
                    square([21.59 - 2.54, 2.92]);

                    translate([-17.15 + 2.54, -4.56])
                    square([21.59 - 2.54 - (4.56 - 2.92), 4.56]);
                }

                // Small chamfer on top left
                hull() {
                    translate([-17.15 + 2.54, -3.08 - 1])
                    square([2.54, 1]);

                    translate([-17.15, -(3.08 + 2.54) - 1])
                    square([2.54, 1]);
                }

                // Filler square
                translate([-17.15 + 2.54, -(3.08 + 2.54)])
                square([18.42 - 2.54, (3.08 + 2.54)]);
            }

            // Main plate section
            translate([-17.15, -(112.75 - 4.12)])
            square([18.42, 112.75 - 4.12 -(3.08 + 2.54)]);

            // Taper between main part of plate and bottom tab.
            // These are 45 degrees so height of taper is same as width.
            hull() {
                translate([-17.15 + 18.42/2, - 112.75 + 4.11])
                square([18.42/2, 1]);

                translate([-17.15, - 112.75 + 4.12])
                square([18.42/2, 1]);

                translate([-10.19 - 4.11 + 1.27, -112.75])
                square([10.19, 1]);
            }

            // Bottom tab
            translate([-10.19 - 4.11 + 1.27, -120.02])
            hull() {
                translate([0, 1.91])
                square([10.19, 120.02 - 112.75 - 1.91]);

                translate([1.91, 1.91])
                circle(r = 1.91);

                translate([10.19 - 1.91, 1.91])
                circle(r = 1.91);
            }
        }

        // IO cutout
        translate([-12.06 - 1.57 - 0.35, -89.9 - 10.16])
        square([12.06, 89.9]);
    }

    // PCB reference
    translate([-1.57, -111.15 + 16.4 - 10.16])
    color("red", alpha=0.2)
    %square([1.57, 111.15]);

    // Motherboard reference - This doesn't relate to anything on the PCIe riser, it's just the location of the motherboard in the reference drawings
    translate([-50/2, -10.16 + 16.4 - 111.15 - 3.4 - 1.57])
    color("green", alpha=0.2)
    %square([50, 1.57]);

    // PCIe slot - This doesn't relate to the size of the slot on the PCIe riser, it's just the reference slot design used in the reference drawings
    translate([-1.57/2, -10.16 + 16.4 - 111.15 - 3.4])
    color("pink", alpha=0.5)
    %union() {
        translate([-3.75, 0])
        square([3.75 * 2, 11.25]);
        hull() {
            translate([-3.75, 7.45])
            square([3.75 * 2, 11.25 - 7.45]);

            translate([-5.1, 7.45])
            square([5.1 + 3.75, 0.8]);
        }
    }
}

module pcie_bracket_wing_reference_2d() {
    // X = 0 is the lower (rightmost) surface of the PCB
    // Y = 0 is the outer face of the PCB bracket
    translate([-17.15 + 2.54, 0])
    difference() {
        // Main plate reference
        *square([19.05, 11.43]);

        // Main plate
        union() {
            // Base
            square([19.05, 11.43 - 4.19]);

            hull() {
                translate([0, 11.43 - 4.19])
                square([8.38, 0.38]);

                translate([0, 11.43 - 1])
                square([6.38, 1]);
            }

            hull() {
                translate([19.05 - 7.62, 11.43 - 4.19])
                square([7.62, 0.38]);

                translate([19.05 - 7.62 + 2, 11.43 - 1])
                square([5.62, 1]);
            }
        }

        // Screw hole slot cutout
        translate([16.505, 11.43 - 6.35])
        union() {
            circle(r = 2.21);

            translate([0, -2.21])
            square([5, 2.21*2]);
        }
    }
}

module pcie_bracket_reference_3d() {
    rotate(90, [1, 0, 0])
    union() {
        linear_extrude(height = SHEET_THICKNESS)
        pcie_bracket_face_reference_2d();

        rotate(-90, [1, 0, 0])
        linear_extrude(height = SHEET_THICKNESS)
        pcie_bracket_wing_reference_2d();

        // filler curve
        translate([-17.15 + 2.54, 0])
        rotate(90, [0, 1, 0])
        intersection() {
            translate([-SHEET_THICKNESS, 0])
            cube([SHEET_THICKNESS, SHEET_THICKNESS, 19.05]);
            cylinder(h = 19.05, r = SHEET_THICKNESS);
        }
    }
}

*pcie_bracket_face_reference_2d();
*pcie_bracket_wing_reference_2d();
*pcie_bracket_reference_3d();

for(i = [0:5]) {
    translate([i * -PCIE_SPACING_PER_CARD, 0, 0])
    pcie_bracket_reference_3d();
}

