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

enabled_part = 0;

enable_top_left = enabled_part == 0 || enabled_part == 1;
enable_top_right = enabled_part == 0 || enabled_part == 2;
enable_bottom_left = enabled_part == 0 || enabled_part == 3;
enable_bottom_right = enabled_part == 0 || enabled_part == 4;

//
// Imports
//

use <shared.scad>;
use <display_mount_top.scad>;
use <display_mount_bottom.scad>;

//
// Modules
//

module display_assembly() {
    display_width=318 + 1.5; // 1.5mm tolerence
    display_height=243 + 1.5; // 1.5mm tolerence
    display_thickness_top = 7 + 0.5; // 0.5mm tolerence
    display_thickness_bottom = 6 + 0.5; // 0.5mm tolerence
    
    display_keepout_width = display_width - 12;
    display_keepout_height = display_height - 12;
    
    display_bezel_bottom = 6;
    display_bezel_top = 5;
    display_bezel_left = 4;
    display_bezel_right = 6;
    
    display_offset_horizontal = (display_bezel_right - display_bezel_left) / 2;
    display_offset_vertical = (display_bezel_top - display_bezel_bottom) / 2
        + 0;

    mount_screw_spacing_x = 326;
    mount_screw_spacing_y = 261;
    
    module display_keepout() {
        translate([-display_keepout_width / 2, -display_keepout_height / 2, display_thickness_bottom])
        cube_round([display_keepout_width, display_keepout_height, 50], 0);
    }
    
    module display_panel() {
        translate([-display_width / 2, -display_height / 2, 0])
        union() {            
            translate([0, display_height / 2, 0])
            cube([display_width, display_height / 2, display_thickness_top]);
            
            cube([display_width, display_height / 2, display_thickness_bottom]);
        }
    }
    
    module display_viewport() {
        //viewport_corner_curve_radius = 19;
        viewport_corner_curve_radius = 0;
        viewport_width = 309;
        viewport_height = 240;
        viewport_thickness = 30;
        
        translate([-viewport_width / 2, -viewport_height / 2, -viewport_thickness])
        cube_round([viewport_width, viewport_height, viewport_thickness], viewport_corner_curve_radius);
    }

    difference() {
        translate([0, 0, 30])
        union() {
            if(enable_top_left) {
                translate([-mount_screw_spacing_x / 2, mount_screw_spacing_y / 2,])
                mirror([1, 0, 0])
                display_holder_top();
            }
            
            if(enable_top_right) {
                translate([mount_screw_spacing_x / 2, mount_screw_spacing_y / 2, 0])
                display_holder_top();
            }
            
            if(enable_bottom_left) {
                translate([-mount_screw_spacing_x / 2, -mount_screw_spacing_y / 2, 0])
                mirror([1, 0, 0])
                display_holder_bottom();
            }
            
            if(enable_bottom_right) {
                translate([mount_screw_spacing_x / 2, -mount_screw_spacing_y / 2, 0])
                display_holder_bottom();
            }
        }

        union()
        {
            display_keepout();
            
            translate([display_offset_horizontal, display_offset_vertical, 0])
            #display_panel();
            display_viewport();
        }
    }
}

display_assembly();

