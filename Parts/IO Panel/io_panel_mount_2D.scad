// Mounting plate for IO ports on the side of the iMac.
// This mounts to a 3D backing bracket to attach it to the iMac, which is a separate part not included here.

use <../Shared/2Dshapes.scad>;
use <../Shared/rounded_corner.scad>;

include  <../Shared/shared_settings.scad>;


// Set default viewport location
// $vpt = [ 75, 57, 0 ];
// $vpr = [ 0, 0, 0 ];
// $vpd = 400;

$fn = $preview ? 64 : 128;

// A very small distance to overcome rounding errors
$eps = pow(2, -15);

// Render mode:
//
// 0: 3D visual
// 1: 2D cutter layout

RENDER_MODE_DEFAULT = 1;

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

part_name = "iMac IO Panel";
part_version = "v1.0";

material_thickness = 3;

//M3 Clearance Hole :
//Close fit: 3.2 mm, Normal fit: 3.4 mm , Loose fit: 3.6 mm
m3_clearance_hole_d = 3.4;

//M4 Clearance Hole :
//Close fit: 4.3 mm, Normal fit: 4.5 mm , Loose fit: 4.8 mm
m4_clearance_hole_d = 4.5;


module module_label() {
    text_line1 = str(part_name, " // ", part_version);
    echo(text_line1);
    text(text = text_line1, font = text_font, size = 2, halign = "center", valign = "top");
}

module io_panel_2d(engrave_mode) {
    module plate() {
        hull() {
            translate([45/2, 0])
            circle(d = 45);

            translate([114 - 45/2, 0])
            circle(d = 45);
        }
    }

    module dp_port_cutout() {
        translate([-27 / 2, 0])
        circle(d = m4_clearance_hole_d);

        translate([27 / 2, 0])
        circle(d = m4_clearance_hole_d);

        // DP hole = 18x7, give 0.5mm for tolerence (can always reduce later)
        square([18.5, 7.5], center = true);
    }

    module hdmi_port_cutout() {
        translate([-27 / 2, 0])
        circle(d = m4_clearance_hole_d);

        translate([27 / 2, 0])
        circle(d = m4_clearance_hole_d);

        // HDMI hole = 6x15, give 0.5mm for tolerence (can always reduce later)
        square([15.5, 6.5], center = true);
    }

    module usbc_port_cutout() {
        translate([-17 / 2, 0])
        circle(d = m3_clearance_hole_d);

        translate([17 / 2, 0])
        circle(d = m3_clearance_hole_d);

        // USB-C port is 9.0 x 3.3
        translate([0, -4.5])
        hull() {
            translate([-9.5 / 2 + 3.5 / 2, 0])
            circle(d = 3.5);

            translate([9.5 / 2 - 3.5 / 2, 0])
            circle(d = 3.5);
        }
    }

    module power_port_cutout() {
        circle(d = 8);
    }

    module usba_port_cutout() {
        // USB-A port is 13.2 x 5.7

        square([13.5, 6], center = true);
    }

    module ethernet_port_cutout() {
        translate([-27 / 2, 0])
        circle(d = m4_clearance_hole_d);

        translate([27 / 2, 0])
        circle(d = m4_clearance_hole_d);

        // 15.8 x 13.1
        translate([0, -5])
        square([16, 14], center = true);

        //square([16, 23], center = true);
    }
    
    module part() {
        // Largest DP plug I've seen is 13mm thick, so 14mm should be enough spacing
        port_spacing = 14;

        difference() {
            plate();

            // Ports
            translate([45/2 - 10, 0]) {
                translate([0 * port_spacing, 0])
                rotate(-90)
                hdmi_port_cutout();

                translate([1 * port_spacing, 0])
                rotate(-90)
                dp_port_cutout();

                translate([2 * port_spacing, 0])
                rotate(-90)
                dp_port_cutout();

                translate([3 * port_spacing, 12])
                power_port_cutout();

                translate([3 * port_spacing - 4.5, -8])
                rotate(90)
                usbc_port_cutout();

                translate([4.5 * port_spacing - 1, 0])
                for (i = [-1 : 1]){
                    for (j = [0 : 1]) {
                        translate([i * 8, j * 16 - 16/2])
                        rotate(-90)
                        usba_port_cutout();
                    }
                }

                translate([6 * port_spacing + 7, 0])
                rotate(-90)
                ethernet_port_cutout();
            }

            // Screw holes to mount to attachment bracket
            union() {
                translate([4, 0])
                circle(d = m4_clearance_hole_d);

                translate([45/2 - 10 + 1.5 * port_spacing, 0]) {
                    translate([0, 45 / 2 - 4])
                    circle(d = m4_clearance_hole_d);

                    translate([0, -45 / 2 + 4])
                    circle(d = m4_clearance_hole_d);
                }

                translate([45/2 - 10 + 4.5 * port_spacing - 1 - 13, 0]) {
                    translate([0, 45 / 2 - 4])
                    circle(d = m4_clearance_hole_d);

                    translate([0, -45 / 2 + 4])
                    circle(d = m4_clearance_hole_d);
                }

                translate([45/2 - 10 + 4.5 * port_spacing - 1 + 13, 0]) {
                    translate([0, 45 / 2 - 4])
                    circle(d = m4_clearance_hole_d);

                    translate([0, -45 / 2 + 4])
                    circle(d = m4_clearance_hole_d);
                }
            }
        }
    }

    module engrave() {
        //translate([114 / 2 - 50, -45 / 2 + 20])
        //module_label();
    }

    if(engrave_mode <= 1) {
        part();
    }

    if(engrave_mode >= 1) {
        #engrave();
    }
}

module io_panel_3d(engrave_mode) {
    linear_extrude(height = material_thickness) {
        io_panel_2d(engrave_mode);
    }
}

if(RENDER_MODE == 0) {
    io_panel_3d(ENGRAVE_MODE);
}
else if(RENDER_MODE == 1) {
    io_panel_2d(ENGRAVE_MODE);
}
