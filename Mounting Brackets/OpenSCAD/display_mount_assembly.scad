// Display assembly for iMac G3
//
// Ryan Crosby 2019
//

//
// Constants
//

// Pretty round things with bigger numbers
// 16 = Good for draft
// 64 = Good for export
$fn=64;

enable_top_left = true;
enable_top_right = true;
enable_bottom_left = false;
enable_bottom_right = false;

//
// Imports
//

use <shared.scad>;
use <display_mount_top.scad>;

//
// Modules
//

module display_assembly() {
    display_width=318;
    display_height=243;
    display_thickness = 7;
    
    display_keepout_width = display_width - 10;
    display_keepout_height = display_height - 10;
    
    display_bezel_bottom = 6;
    display_bezel_top = 5;
    display_bezel_left = 4;
    display_bezel_right = 6;
    
    display_offset_horizontal = (display_bezel_right - display_bezel_left) / 2;
    display_offset_vertical = (display_bezel_top - display_bezel_bottom) / 2;

    upper_mount_screw_spacing_x = 326;
    mount_screw_spacing_spacing_y = 261;
    
    module display_keepout() {
        translate([-display_keepout_width / 2, -display_keepout_height / 2, display_thickness])
        cube_round([display_keepout_width, display_keepout_height, 50], 2);
    }
    
    module display_panel() {
        translate([-display_width / 2, -display_height / 2, 0])
        cube([display_width, display_height, display_thickness]);
    }
    
    module display_viewport() {
        //viewport_corner_curve_radius = 19;
        viewport_corner_curve_radius = 3;
        viewport_width = 310;
        viewport_height = 240;
        viewport_thickness = 30;
        
        translate([-viewport_width / 2, -viewport_height / 2, -viewport_thickness])
        cube_round([viewport_width, viewport_height, viewport_thickness], viewport_corner_curve_radius);
    }

    difference() {
        translate([0, 0, 30])
        union() {
            if(enable_top_left) {
                translate([-upper_mount_screw_spacing_x / 2, mount_screw_spacing_spacing_y / 2,])
                mirror([1, 0, 0])
                display_holder_top();
            }
            
            if(enable_top_right) {
                translate([upper_mount_screw_spacing_x / 2, mount_screw_spacing_spacing_y / 2, 0])
                    display_holder_top();
            }
            
            if(enable_bottom_left) {
                // TODO
            }
            
            if(enable_bottom_right) {
                // TODO
            }
        }

        #union()
        {
            display_keepout();
            
            translate([display_offset_horizontal, display_offset_vertical, 0])
            display_panel();
            display_viewport();
        }
    }
}

display_assembly();

