// Mounting plate for M.NT68676.2A LVDS converter board.
// This mounts the board to the PCIe GPU bracket.
//
// The mounting plate is mounted on top of the PCB (the PCB sits in the positive Z axis).
// There are cutouts for mounting a 40x40mm case fan for cooling, since several of the ICs get quite hot.

use <../Shared/2Dshapes.scad>;
use <../Shared/rounded_corner.scad>;

include  <../Shared/shared_settings.scad>;


// Set default viewport location
$vpt = [ 75, 57, 0 ];
$vpr = [ 0, 0, 0 ];
$vpd = 400;

$fn = $preview ? 64 : 128;

// A very small distance to overcome rounding errors
$eps = pow(2, -15);

// Render mode:
//
// 0: 3D visual
// 1: 2D cutter layout
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

if(EXPORT_LAYER != 0) {
    echo(str("EXPORT_LAYER enabled, set to ", EXPORT_LAYER));
}

RENDER_MODE = EXPORT_LAYER > 0 ? 1 : RENDER_MODE_DEFAULT;
ENGRAVE_MODE = EXPORT_LAYER == 1 ? 0 : (EXPORT_LAYER == 2 ? 2 : ENGRAVE_MODE_DEFAULT);

echo(str("Render mode: ", RENDER_MODE));
echo(str("Engrave mode: ", ENGRAVE_MODE));

material_thickness = 3;

// These are needed if the VGA and PC Audio plugs are populated on the PCB
enable_vga_audio_cutouts = false;

// From M.NT68676.2A datasheet
pcb_size = [139, 58];
pcb_offset = [0, 15];
pcb_height = 1.2 + 11.4;

pcb_corner_radius = [3, 3];
plate_corner_radius = [3, 3];

extra_horizontal_offset = 5 + 5;

plate_mount_screwhole_offset = [pcb_size[0] + pcb_offset[0] + extra_horizontal_offset, 5];

// Screw hole size for #6-32 UNC PC case screw
plate_mount_screwhole_diameter = 3.5;
plate_mount_screwhole_positions = [[0, 0], [0, 25], [0, 69], [0, 98]];

// Screw hole size for M3 screw = 3.5mm
plate_pcb_screwhole_diameter = 3.5;
plate_pcb_screwhole_offset = pcb_offset;

// From M.NT68676.2A datasheet
plate_pcb_screwhole_positions = [[13.3, 21],[125, 21],[14.3, 49],[119.3, 49]];

plate_size = plate_mount_screwhole_offset + plate_mount_screwhole_positions[3] + [5, 5];

part_name = "iMac Display Driver";
part_version = "v1.1";

module module_label(submodule_name) {
    text_line1 = str(part_name, " ", submodule_name, " // ", part_version);
    text_line2 = "For M.NT68676.2A LVDS driver board";

    echo(text_line1);
    echo(text_line2);

    union() {
        text(text = text_line1, font = text_font, size = 2, halign = "center", valign = "top");

        translate([0, -4])
        text(text = text_line2, font = text_font, size = 2, halign = "center", valign = "top");
    }
}

module pcb() {
    // complexRoundSquare(size, top left radius, top right radius, bottom right radius, bottom left radius, center)
    complexRoundSquare(pcb_size, rads1=pcb_corner_radius, rads2=pcb_corner_radius, rads3=pcb_corner_radius, rads4=pcb_corner_radius, center=false);
}

module display_converter_mount_2d(engrave_mode) {
    module plate() {
        union() {

            // complexRoundSquare(size, top left radius, top right radius, bottom right radius, bottom left radius, center)
            //complexRoundSquare(plate_size, rads1=plate_corner_radius, rads2=plate_corner_radius, rads3=plate_corner_radius, rads4=plate_corner_radius, center=false);

            // Rectangle for GPU bracket screwholes
            mount_width = 10;
            extra_mount_offset = extra_horizontal_offset - mount_width / 2;
            translate([-mount_width / 2 - extra_mount_offset, 0])
            translate([plate_mount_screwhole_offset[0], 0])
            complexRoundSquare([mount_width + extra_mount_offset, 110], rads1=plate_corner_radius, rads2=plate_corner_radius, rads3=plate_corner_radius, rads4=plate_corner_radius, center=false);

            // Rectangle for mounting PCB
            translate(pcb_offset)
            complexRoundSquare(pcb_size, rads1=[0, 0], rads2=[0,0], rads3=[0,0], rads4=plate_corner_radius, center=false);

            courner_diameter = 10;

            translate(pcb_offset + [pcb_size[0], 0] + [-courner_diameter, -courner_diameter])
            rounded_corner(courner_diameter);

            translate(pcb_offset + pcb_size + [-courner_diameter, courner_diameter])
            rotate(-90)
            rounded_corner(courner_diameter);

            // Support tab on far left
            support_tab_width = 15;
            support_tab_y_overhang = 5;
            translate([0, -support_tab_y_overhang])
            complexRoundSquare([support_tab_width, pcb_offset[1] + support_tab_y_overhang +$eps], rads1=plate_corner_radius, rads2=plate_corner_radius, rads3=[0,0], rads4=[0,0], center=false);
        
            translate([support_tab_width - $eps, pcb_offset[1] + $eps])
            translate([courner_diameter, -courner_diameter])
            rotate(90)
            rounded_corner(courner_diameter);
        }
    }

    module pcb_screw_holes() {
        for (this_pos = plate_pcb_screwhole_positions) {
            translate(this_pos + plate_pcb_screwhole_offset)
            circle(d = plate_pcb_screwhole_diameter);
        }
    }

    module mount_screw_holes() {
        for (this_pos = plate_mount_screwhole_positions) {
            translate(this_pos)
            circle(d = plate_mount_screwhole_diameter);
        }
    }
    
    module part() {
        difference() {
            plate();

            // translate(pcb_offset)
            // %pcb();
            union() {
                pcb_screw_holes();

                translate(plate_mount_screwhole_offset)
                mount_screw_holes();
            }
        }
    }

    module engrave() {
        translate(pcb_offset)
        translate([65, 40])
        module_label("Mount Plate");
    }

    if(engrave_mode <= 1) {
        part();
    }

    if(engrave_mode >= 1) {
        #engrave();
    }
}

module display_converter_top_2d(engrave_mode) {
    fan_offset = [90, 25];

    module plate() {
        difference() {
            // Rectangle for mounting PCB
            translate(pcb_offset)
            complexRoundSquare(pcb_size, rads1=plate_corner_radius, rads2=plate_corner_radius, rads3=plate_corner_radius, rads4=plate_corner_radius, center=false);

            translate(pcb_offset)
            union() {
                plug_cutouts();

                translate(fan_offset)
                fan_40mm_cutout();
            }
        }
    }

    module plug_cutouts() {
        union() {
            // Cutouts for plugs and high features
                
            // Inverter plug
            inverter_plug_size = [5, 14];
            inverter_plug_offset = [0 - $eps, 13];

            translate(inverter_plug_offset + [0, -1])
            complexRoundSquare(inverter_plug_size + [1, 2], rads1=[0,0], rads2=[0,0], rads3=[1,1], rads4=[0,0], center=false);

            // 12V Power plug (Removes the entire corner)
            power_plug_size = [13, 12 + 2 * $eps];
            power_plug_offset = [0, -$eps];

            translate(power_plug_offset)
            complexRoundSquare(power_plug_size, rads1=[0,0], rads2=[0,0], rads3=[1,1], rads4=[0,0], center=false);

            // Rounded corners for Inverter Plug Cutout and 12V Power plug cutout
            translate(inverter_plug_offset + [5 + 1, -1])
            translate([1, 1])
            rotate(180)
            rounded_corner(1);

            translate(inverter_plug_offset + [0, 14 + 1])
            translate([1, 1])
            rotate(180)
            rounded_corner(1);

            translate([13, 0])
            translate([1, 1])
            rotate(180)
            rounded_corner(1);

            // Keypad plug
            key_plug_size = [22, 5];
            key_plug_offset = [24, 58 - 1 - key_plug_size[1] + $eps];

            translate(key_plug_offset + [-1, -1])
            complexRoundSquare(key_plug_size + [2 + $eps, 2], rads1=[1,1], rads2=[0,0], rads3=[0,0], rads4=[0,0], center=false);

            // Rounded corners for Keypad Plug into LVDS plug cutout
            translate(key_plug_offset + [-2, key_plug_size[1]])
            rounded_corner(1);

            translate(key_plug_offset + [key_plug_size[0], -2])
            rounded_corner(1);

            translate(lvds_plug_offset + lvds_plug_size + [1, 4])
            translate([1, -1])
            rotate(90)
            rounded_corner(1);

            // LVDS plug
            lvds_plug_size = [30, 4];
            lvds_plug_offset = [48, 58 - 4 - lvds_plug_size[1] + $eps];

            translate(lvds_plug_offset + [-1, -2])
            complexRoundSquare(lvds_plug_size + [2, 4 + 2], rads1=[1,1], rads2=[1,1], rads3=[0,0], rads4=[0,0], center=false);

            // Speaker plug
            speaker_plug_size = [5, 10];
            speaker_plug_offset = [139 - 5, 17];
            
            translate(speaker_plug_offset + [-2 + $eps, -1])
            complexRoundSquare(speaker_plug_size + [2, 2], rads1=[1,1], rads2=[0,0], rads3=[0,0], rads4=[1,1], center=false);

            // Rounded corners for Speaker plug
            translate(speaker_plug_offset + [-1, -2] + [speaker_plug_size[0], 0])
            rounded_corner(1);

            translate(speaker_plug_offset + [-1, -2] + speaker_plug_size + [0, 3])
            translate([0, 1])
            rotate(270)
            rounded_corner(1);

            if(enable_vga_audio_cutouts) {
                // VGA connector top
                vga_top_size = [31, 2];
                vga_top_offset = [96 - 31 / 2, 0 - $eps];

                translate(vga_top_offset + [-0.5, 0])
                square(vga_top_size + [1, 0.5]);

                // PC audio connector top
                pc_audio_top_size = [8.5, 14.5];
                pc_audio_top_offset = [139 - 22, 0 - $eps];

                translate(pc_audio_top_offset + [-0.5, 0])
                square(pc_audio_top_size + [1, 0.5]);
            }
        }
    }

    module pcb_screw_holes() {
        for (this_pos = plate_pcb_screwhole_positions) {
            translate(this_pos + plate_pcb_screwhole_offset)
            circle(d = plate_pcb_screwhole_diameter);
        }
    }
    
    module part() {
        difference() {
            plate();
            pcb_screw_holes();
        }
    }

    module engrave() {
        translate(pcb_offset)
        translate([35, 40])
        module_label("Cover Plate");

        translate(pcb_offset)
        translate(fan_offset)
        difference() {
            complexRoundSquare([40,40], rads1=[1,1], rads2=[1,1], rads3=[1,1], rads4=[1,1], center=true);
            complexRoundSquare([39,39], rads1=[1,1], rads2=[1,1], rads3=[1,1], rads4=[1,1], center=true);
        }
    }

    if(engrave_mode <= 1) {
        part();
    }

    if(engrave_mode >= 1) {
        #engrave();
    }
}

// Screwholes and vent cutout for 40x40mm fan
module fan_40mm_cutout() {
    // Screws are 32mm apart
    screw_hole_spacing = 32;
    screw_hole_diameter = 4 + 0.8;

    screw_hole_positions = [
        [-screw_hole_spacing / 2, screw_hole_spacing / 2],
        [screw_hole_spacing / 2, screw_hole_spacing / 2],
        [screw_hole_spacing / 2, -screw_hole_spacing / 2],
        [-screw_hole_spacing / 2, -screw_hole_spacing / 2],
    ];

    union() {
        for (this_pos = screw_hole_positions) {
            translate(this_pos)
            circle(d = screw_hole_diameter);
        }

        intersection() {
            square([36, 36], center = true);
            circle(d = 40 - 2);
        }
    }
}

module display_converter_mount_3d(engrave_mode) {
    linear_extrude(height = material_thickness) {
        display_converter_mount_2d(engrave_mode);
    }

    translate([0, 0, material_thickness + 2.4])
    %linear_extrude(height = pcb_height) {
        translate(pcb_offset)
        pcb();
    }

    translate([0, 0, material_thickness + 2.4 + 1.2 + 12])
    linear_extrude(height = material_thickness) {
        display_converter_top_2d(engrave_mode);
    }
}

if(RENDER_MODE == 0) {
    display_converter_mount_3d(ENGRAVE_MODE);
}
else if(RENDER_MODE == 1) {
    display_converter_mount_2d(ENGRAVE_MODE);

    translate([-3, 62])
    display_converter_top_2d(ENGRAVE_MODE);
}
else if(RENDER_MODE == 2) {
    display_converter_mount_2d(ENGRAVE_MODE);
}
else if(RENDER_MODE == 3) {
    display_converter_top_2d(ENGRAVE_MODE);
}
