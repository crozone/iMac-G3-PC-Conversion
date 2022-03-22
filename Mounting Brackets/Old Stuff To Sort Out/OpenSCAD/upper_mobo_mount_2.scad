// iMac G3 motherboard mounts
// Ryan Crosby 2019
//
// All units are in mm

//
// Part selection
//

//
// Constants
//

// Pretty round things with bigger numbers
// 16 = Good for draft
// 64 = Good for export
$fn=64;

// Floating point errors can cause difference operations to leave really thin faces where there should be none.
// Add this to subtracted object dimensions where appropriate to prevent this.
SEM = 0.0000001;

//
// Imports
//

use <shared.scad>;

//
// Modules
//

// Hole
module hole(r, h) {
    cylinder(h = h + 2 * SEM, r1 = r, r2 = r, center = true);
}

//
// Variables
//

motherboard_width=241;
motherboard_height=241;
motherboard_keepout_depth = 120;
motherboard_baseplate_thickness = 2.5; // motherboard thickness

mobo_baseplate_height_offset = -15;

display_width=318;
display_height=243;
display_thickness = 7;

//
// Parts
//

module upper_mobo_mount() {
    box_width = 145;
    box_length = 40;
    box_height = 30;

    top_spacing = 5;
    width_spacing = 41.5; // Distance between two main display posts

    post_diameter = 8 + 1; // 1mm tolerence
    post_channel_length = 2 + 1; // 1mm telerence
    post_channel_width = 1 + 0.5; // 0.5mm of tolerance
    screw_diameter = 5;
    post_height_offset = 5;

    post_height = box_height - post_height_offset + 2 * SEM;
    post_channel_length_total = post_diameter / 2 + post_channel_length + 2 * SEM;
    post_channel_upper_length_total = post_diameter / 2 + top_spacing + 2 * SEM;

    post_channel_upper_cutout_length_total = post_diameter / 2 + 1.5 + 2 * SEM;
    post_channel_upper_cutout_height = 4 + 2 * SEM;

    top_offset = - post_diameter / 2 - top_spacing;
    
    module top_post_complete() {
        union() {
            // Screw hole
            translate([0, 0, post_height_offset / 2])
            hole(h = post_height_offset, r = screw_diameter / 2);
            
            // Post hole
            translate([0, 0, box_height / 2 + post_height_offset / 2])
            hole(h = post_height, r = post_diameter / 2);
            
            // Lower channel
            translate([0, post_channel_length_total / 2, post_height / 2 + post_height_offset])
            cube([post_channel_width, post_channel_length_total, post_height], center = true);
            
            // Upper channel
            difference() {
                translate([0, -post_channel_upper_length_total / 2, box_height / 2])
                cube([post_channel_width, post_channel_upper_length_total, box_height + 2 * SEM], center = true);
                translate([0, -post_channel_upper_cutout_length_total / 2, (post_channel_upper_cutout_height + post_height_offset) / 2])
                cube([post_channel_width, post_channel_upper_cutout_length_total, post_channel_upper_cutout_height + post_height_offset], center = true);
            }
        }
    }
    
    difference() {
        translate([-box_width / 2 - 34, top_offset, 0])
        cube_round([box_width, box_length, box_height], 3);

        union() {
            // Mic Cutout
            translate([0, -12, 0])
            union() {
               translate([-10 / 2, 0, - SEM])
               cube_round([10, 10, box_height + SEM], 2);
                
               translate([-24 / 2, 0, 12 + SEM])
               cube_round([24, 22.5, box_height - 12], 2);
            } 
            
            // Posts cutout
            union() {
                translate([width_spacing / 2, 0, 0])
                top_post_complete();
                
                translate([-width_spacing / 2, 0, 0])
                top_post_complete();
            }
            
            shim_depth_offset = box_height - post_height_offset + 0.5;
            
            translate([-width_spacing / 2 - 58.25, 0, 0])
            union() {
                translate([0, top_offset - SEM, - SEM])
                cube([post_channel_width, 10 + 2 * SEM, box_height + SEM * 2]);
                
                translate([0, top_offset - SEM, (box_height - shim_depth_offset) - SEM])
                cube([post_channel_width, 24 + 2 * SEM, shim_depth_offset + SEM * 2]);
                
            }
        }
    }
}

//
// All parts
//

//translate([0, 6.5, 246])
translate([0, 30, 249])
rotate([-70, 0, 180])
upper_mobo_mount();
