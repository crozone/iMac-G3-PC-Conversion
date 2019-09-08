// iMac G3 motherboard plate top mount
// Ryan Crosby 2019
//
// All units are in mm

//
// Part selection
//

enable_top_mount = false;
enable_bottem_left_mount = true;
enable_bottom_right_mount = false;

enable_display_holders = false;

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

use <shared.scad>


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

module motherboard() {
    module motherboard_screwhole() {
        rotate([90, 0, 0])
        translate([0, 0, -10])
        union() {
            hole(2, 20);
            translate([0, 0, 2])
            hole(4, 20);
        }
    }
    
    translate([-motherboard_width / 2, 0, 0])
    union() {
        union() {
            
            lip_thickness = 4;
            
            // Motherboard baseplate
            cube([motherboard_width, motherboard_baseplate_thickness, motherboard_height]);
            
            // Underneath of motherboard
            translate([2, motherboard_baseplate_thickness - SEM, 2])
            cube([motherboard_width - 4, lip_thickness + 2 * SEM, motherboard_height - 4]);
            
            // Keep Out Zone for motherboard
            keep_out_depth = motherboard_keepout_depth - motherboard_baseplate_thickness - lip_thickness;
            
            translate([0, motherboard_baseplate_thickness + lip_thickness - SEM, -3])
            cube([motherboard_width, keep_out_depth + 2 * SEM, motherboard_height + 5]);
            
            // GPU/PCIe card Keep Out
            translate([-50, motherboard_baseplate_thickness + lip_thickness, -3])
            cube([50, keep_out_depth, 95]);
        }
        
        translate([0, -20 + 0.1, 0])
        union() {
            translate([210, 0, 234])
            motherboard_screwhole();
            
            translate([78.5, 0, 234])
            motherboard_screwhole();
            
            translate([6, 0, 234])
            motherboard_screwhole();
            
            translate([6, 0, 77])
            motherboard_screwhole();
            
            translate([6, 0, 10])
            motherboard_screwhole();
            
            translate([78.5, 0, 10])
            motherboard_screwhole();
            
            translate([78.5, 0, 77])
            motherboard_screwhole();
            
            translate([233, 0, 30])
            motherboard_screwhole();
            
            translate([233, 0, 76])
            motherboard_screwhole();
        }
    }
}

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

module baseplate() {
    module baseplate_screwhole() {
        translate([0, 0, 0])
        union() {
            translate([0, 0, 12])
            hole(4, 20);
            
            hole(2, 40);
            
            translate([0, 0, -10])
            hole(3, 20); // post diameter is 5mm, so this has 1mm tolerence in diameter
        }
    }
    
    screw_a_offset_x = 0;
    screw_a_offset_y = motherboard_baseplate_thickness + 46; // distance from right screw to mobo front + mobo thickness
    
    screw_b_offset_x = 122.5;
    screw_b_offset_y = motherboard_baseplate_thickness + 33; // distance from right screw to mobo front + mobo thickness
    
    baseplate_post_height = 7.5;
    
    translate([-screw_a_offset_x, screw_a_offset_y, baseplate_post_height])
    baseplate_screwhole();
    
    translate([-screw_b_offset_x, screw_b_offset_y, baseplate_post_height])
    baseplate_screwhole();
    
    baseplate_width = 330;
    baseplate_length = 333;
    baseplate_height = 20;
    
    translate([-330 / 2, -33, -baseplate_height])
    cube([baseplate_width, baseplate_length, baseplate_height]);
}

module lower_left_mobo_mount() {
    lmount_width = 143;
    lmount_height = -mobo_baseplate_height_offset + 20;
    
    lmount_thickness = 10;
    lmount_base_depth = motherboard_baseplate_thickness + 56;
    
    translate([-21, -lmount_thickness, mobo_baseplate_height_offset])
    cube_round([lmount_width, lmount_base_depth + lmount_thickness, lmount_height], 3);
}

module display_panel() {
    translate([-display_width / 2, 0, 0])
    cube([display_width, display_thickness, display_height]);
}

module display_holder() {
    bezel_corner_curve_radius = 19;
    post_radius = 9;
    post_screw_radius = 4;
    
    
    
}

//
// All parts
//

// The offset from center for the motherboard plate.
// 10mm provides enough room for a 300mm long GPU.
motherboard_offset_x = 10;

display_offset_y = -100;
display_offset_z = 20;

// module that translates the display assembly componants into the correct position and orientation
module translate_display_assembly()
{
    translate([0, display_offset_y, display_offset_z])
    rotate([-20, 0, 0])
    children();
}

difference() {
    union() {
        if(enable_top_mount) {
            //translate([0, 6.5, 246])
            translate([0, 30, 249])
            rotate([-70, 0, 180])
            upper_mobo_mount();
        }
        
        if(enable_bottem_left_mount) {
            translate([-motherboard_width/2 + motherboard_offset_x, 0, 0])
            lower_left_mobo_mount();
        }
        
        //if(enable_display_holders) {
        //    translate_display_assembly();
        //    
        //    display_holder();
        //}
    }
    
    translate_display_assembly()
    #display_panel();
    
    translate([motherboard_offset_x, 0, 0])
    #motherboard();
    
    translate([0, 0, mobo_baseplate_height_offset])
    #baseplate();
}