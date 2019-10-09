// Display control mount
//
// Ryan Crosby 2019
//

$fn=64;


module display_control_mount() {
    board_thickness = 1.5;
    
    module control_board() {
        board_width = 105;
        board_length = 22;
        
        board_keepout_y_offset = 1;
        board_keepout_front_width = board_width - 4;
        board_keepout_front_length = 10 - board_keepout_y_offset;
        board_keepout_back_width = 25;
        board_keepout_back_length = 18 - board_keepout_y_offset;
        
        board_keepout_thickness= 4;
        
        translate([-board_width / 2, 0, 0])
        cube([board_width, board_length, board_thickness]);
        
        translate([-board_keepout_front_width / 2, board_keepout_y_offset, -board_keepout_thickness + board_thickness])
        cube([board_keepout_front_width, board_keepout_front_length, board_keepout_thickness]);
        
        translate([-board_keepout_back_width / 2, board_keepout_y_offset, -board_keepout_thickness + board_thickness])
        cube([board_keepout_back_width, board_keepout_back_length, board_keepout_thickness]);
    }
    
    module screw_holes() {
        screw_x_dist = 84;
        screw_y_offset = 13.5;
        screw_hole_diameter = 4;
        screw_diameter = 3;
        screw_height = 10;
        
        union() {
            
            // Top halves of screw (wider)
            translate([screw_x_dist / 2, screw_y_offset, screw_height / 2])
            cylinder(d = screw_hole_diameter, h = screw_height, center = true);

            translate([-screw_x_dist / 2, screw_y_offset, screw_height / 2])
            cylinder(d = screw_hole_diameter, h = screw_height, center = true);
            
            // Bottom half of screw for thread to grab (smaller)
            translate([screw_x_dist / 2, screw_y_offset, -screw_height / 2])
            cylinder(d = screw_diameter, h = screw_height, center = true);

            translate([-screw_x_dist / 2, screw_y_offset, -screw_height / 2])
            cylinder(d = screw_diameter, h = screw_height, center = true);
        }
    }
    
    module mount_body() {
        tab_x_dist = 29;
        tab_width = 1 + 0.5; // 1mm with 0.5mm tolerence
        tab_height = 8;
        tab_roof_height = 2;
        
        body_width = 110;
        body_length = 25;
        body_height = tab_height + tab_roof_height;
        
        difference() {
            hull() {
                translate([-body_width / 2, 0, -body_height])
                cube([body_width, 13, body_height + board_thickness]);
                
                translate([-body_width / 2, body_length - 1, -5])
                cube([body_width, 1, 5 + board_thickness]);
            }
            
            #union() {
                translate([(-tab_x_dist / 2) - (tab_width / 2), 0, -body_height])
                cube([tab_width, body_length, tab_height]);
            
                translate([(tab_x_dist / 2) - (tab_width / 2), 0, -body_height])
                cube([tab_width, body_length, tab_height]);
            }
        }
    }
    
    
    difference() {
        mount_body();
        #control_board();
        #screw_holes();
    }
}

display_control_mount();