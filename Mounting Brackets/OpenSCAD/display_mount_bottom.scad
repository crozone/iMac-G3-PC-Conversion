use <2Dshapes.scad>;
use <shared.scad>;

$fn=64;

module display_holder_bottom() {
    bezel_corner_curve_radius = 19;
    
    post_height = 32;
    post_radius = 9 / 2;
    post_screw_radius = 5 / 2;
    
    post_surround_top_height = 2; // height of material that screw sits on
    post_surround_radius = 18 / 2;
    post_surround_height = post_height + post_surround_top_height;
    
    key_ridge_angle = -90;
    middle_ridge_angle = key_ridge_angle + 161.5;
    lower_ridge_angle = middle_ridge_angle + 120;
    
    module translate_to_post_height() {
        translate([0, 0, -post_surround_height + post_surround_top_height])
        children();
    }
    
    module key_ridge(height) {
        rotate([0, 0, key_ridge_angle])
        translate([15 / 2 + post_radius - 0.1, 0, - height / 2])
        cube([15 + 0.1, 1.5 + 0.5, height], center = true);
    }
    
    module middle_ridge(height) {
        rotate([0, 0, middle_ridge_angle])
        translate([10 / 2 + post_radius - 0.1, 0, -height / 2])
        cube([10 + 0.1, 1.5 + 0.5, height], center = true);
    }
    
    module lower_ridge(height) {
        rotate([0, 0, lower_ridge_angle])
        translate([15 / 2 + post_radius - 0.1, 0, -height / 2])
        cube([15 + 0.1, 1.5 + 0.5, height], center = true);
    }
    
    difference() {
        union() {
            // Display mount box
            hull() {
                translate_to_post_height()
                cylinder(h = post_surround_height, r = post_surround_radius, center = false);
                
                translate([0, 0, post_surround_top_height])
                middle_ridge(post_surround_height);
                
                translate([0, 0, post_surround_top_height])
                lower_ridge(post_surround_height);
                
                // Extra material to hold the display
                translate([-19, 14 - 15, -post_height])
                cube_round([15, 15, post_surround_height]);
            }
        }
        
        union() {
            // Post
            translate([0, 0, -post_height])
            cylinder(h = post_height, r = post_radius, center = false);
            
            // Screw
            translate_to_post_height()
            cylinder(h = post_surround_height, r = post_screw_radius, center = false);
            
            // Key ridge
            key_ridge(post_height);
            
            // Middle ridge
            middle_ridge(post_height);
            // Lower ridge
            lower_ridge(post_height);
            
            // Lower back part of post
            translate([0, 0, -post_height - 1])
            linear_extrude(height = post_height + 1 - 20)
            pieSlice(post_surround_radius + 20, lower_ridge_angle - 360, middle_ridge_angle);
        }
    }
    
}

display_holder_bottom();