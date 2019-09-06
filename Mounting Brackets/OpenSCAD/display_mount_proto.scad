use <2Dshapes.scad>;
use <shared.scad>;

$fn=64;

module display_holder_top() {
    bezel_corner_curve_radius = 19;
    
    post_height = 32;
    post_radius = 9 / 2;
    post_screw_radius = 5 / 2;
    
    post_surround_top_height = 3; // height of material that screw sits on
    post_surround_radius = 18 / 2;
    post_surround_height = post_height + post_surround_top_height;
    
    top_ridge_angle = 90;
    middle_ridge_angle = top_ridge_angle + 74;
    lower_ridge_angle = middle_ridge_angle + 117;
    
    top_ridge_2_angle = lower_ridge_angle + 74;
    
    module translate_to_post_height() {
        translate([0, 0, -post_surround_height + post_surround_top_height])
        children();
    }
    
    module top_ridge(height) {
        rotate([0, 0, top_ridge_angle])
        translate([15 / 2 + post_radius - 0.1, 0, - height / 2])
        cube([15 + 0.1, 1.5 + 0.5, height], center = true);
    }
    
    module top_ridge_2(height) {
        rotate([0, 0, top_ridge_2_angle])
        translate([15 / 2 + post_radius - 0.1, 0, - height / 2])
        cube([15 + 0.1, 1.5 + 0.5, height], center = true);
    }
    
    module middle_ridge(height) {
        rotate([0, 0, middle_ridge_angle])
        translate([23 / 2 + post_radius - 0.1, 0, -height / 2])
        cube([23 + 0.1, 1.5 + 0.5, height], center = true);
    }
    
    module lower_ridge(height) {
        rotate([0, 0, lower_ridge_angle])
        translate([23 / 2 + post_radius - 0.1, 0, -height / 2])
        cube([23 + 0.1, 1.5 + 0.5, height], center = true);
    }
    
    difference() {
        union() {
            // Surround
            //translate_to_post_height()
            //cylinder(h = post_surround_height, r = post_surround_radius, center = false);
            
            // Display mount box
            hull() {
                translate_to_post_height()
                cylinder(h = post_surround_height, r = post_surround_radius, center = false);
                
                //translate([-20, -20, -post_surround_height])
                //cube_round([20, 20, 20], 3);
                
                translate([0, 0, post_surround_top_height])
                middle_ridge(post_surround_height);
                
                translate([0, 0, post_surround_top_height])
                lower_ridge(post_surround_height);
                
                // Post (DISABLED FOR TESTING)
                //translate([0, 0, post_surround_top_height - post_surround_height])
                //translate([-22, -20, 0])
                //cylinder(h = post_surround_height, r = post_radius, center = false);
            }
        }
        
        union() {
            // Post
            translate([0, 0, -post_height])
            cylinder(h = post_height, r = post_radius, center = false);
            
            // Screw
            translate_to_post_height()
            cylinder(h = post_surround_height, r = post_screw_radius, center = false);
            
            // Top ridge
            top_ridge(post_height);
            
            //top_ridge_2(post_height);
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

display_holder_top();