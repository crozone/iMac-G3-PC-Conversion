// iMac G3 motherboard plate top mount
// Ryan Crosby 2019
//
// All units are in mm

//
// Part selection
//

enable_top_mount = true;
enable_bottem_left_mount = true;
enable_bottom_right_mount = true;

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
// Variables
//


top_spacing = 5;
post_diameter = 8 + 1; // 1mm tolerence
post_channel_length = 2 + 1; // 1mm telerence
post_channel_width = 1 + 0.5; // 0.5mm of tolerance
screw_diameter = 5;
post_height_offset = 5;

box_width = 145;
box_length = 40;
box_height = 30;

post_height = box_height - post_height_offset + 2 * SEM;
post_channel_length_total = post_diameter / 2 + post_channel_length + 2 * SEM;
post_channel_upper_length_total = post_diameter / 2 + top_spacing + 2 * SEM;

post_channel_upper_cutout_length_total = post_diameter / 2 + 1.5 + 2 * SEM;
post_channel_upper_cutout_height = 4 + 2 * SEM;

//
// Modules
//

// Triangular prism
module prism(l, w, h){
       polyhedron(
               points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
               faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
               );
}

module hole(r, h) {
    cylinder(h = h + 2 * SEM, r1 = r, r2 = r, center = true);
}

module cube_round(w, l, h, r) {
    hull() 
    {
        translate([r, r, 0]) cylinder(h, r, r);
        translate([w - r, r, 0]) cylinder(h, r, r);
        translate([r, l - r, 0]) cylinder(h, r, r);
        translate([w - r, l - r, 0]) cylinder(h, r, r);
    }
}

//
// Parts
//

module motherboard_screwhole() {
    rotate([90, 0, 0])
    translate([0, 0, -10])
    union() {
        hole(2, 20);
        translate([0, 0, 2])
        hole(4, 20);
    }
}

module motherboard() {
    motherboard_width=241;
    motherboard_height=241;
    
    translate([-motherboard_width / 2, 0, 0])
    union() {
        union() {
            plate_thickness = 2.5;
            lip_thickness = 4;
            
            // Motherboard baseplate
            cube([motherboard_width, plate_thickness, motherboard_height]);
            
            // Underneath of motherboard
            translate([2, plate_thickness - SEM, 2])
            cube([motherboard_width - 4, lip_thickness + 2 * SEM, motherboard_height - 4]);
            
            // Keep Out Zone for motherboard
            keep_out_depth = 100 - plate_thickness - lip_thickness;
            
            translate([0, plate_thickness + lip_thickness - SEM, -1])
            cube([motherboard_width, keep_out_depth + 2 * SEM, motherboard_height + 3]);
            
            // GPU/PCIe card Keep Out
            translate([-50, plate_thickness + lip_thickness, -1])
            cube([50, keep_out_depth, 90]);
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

module post_complete() {
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

module upper_mobo_mount() {
    
    // Distance between two main display posts
    width_spacing = 41.5;
    
    top_offset = - post_diameter / 2 - top_spacing;
    
    difference() {
        translate([-box_width / 2 - 34, top_offset, 0])
        cube_round(box_width, box_length, box_height, 3);

        union() {
            // Mic Cutout
            translate([0, -12, 0])
            union() {
               translate([-10 / 2, 0, - SEM])
               cube_round(10, 10, box_height + SEM, 2);
                
               translate([-24 / 2, 0, 12 + SEM])
               cube_round(24, 22.5, box_height - 12, 2);
            } 
            
            // Posts cutout
            union() {
                translate([width_spacing / 2, 0, 0])
                post_complete();
                
                translate([-width_spacing / 2, 0, 0])
                post_complete();
            }
            
            shim_depth_offset = box_height - post_height_offset + 0.5;
            
            translate([-width_spacing / 2 - 58.25, 0, 0])
                union() {
                    translate([0, top_offset - SEM, - SEM])
                    #cube([post_channel_width, 10 + 2 * SEM, box_height + SEM * 2]);
                    
                    translate([0, top_offset - SEM, (box_height - shim_depth_offset) - SEM])
                    #cube([post_channel_width, 24 + 2 * SEM, shim_depth_offset + SEM * 2]);
                    
                }
        }
    }
}

module baseplate_screwhole() {
    translate([0, 0, 0])
    union() {
        translate([0, 0, 10])
        hole(4, 20);
        
        hole(2, 40);
        
        translate([0, 0, -11])
        hole(3, 20); // post diameter is 5mm
    }
}

module lower_left_mobo_mount() {
    
    
    screw_a_x_dist = 12; // distance from right screw to mobo edge
    screw_a_y_dist = 30; // distance from right screw to mobo front
    
    edge_x_lip = screw_a_x_dist + 10;
    
    lmount_width = 85 + edge_x_lip;
    lmount_height = 85 + 15;
    lmount_thickness = 10 + 10;
    
    translate([0, 0, -15])
    difference() {
        union() {
            translate([-edge_x_lip, -5, 0])
            cube([lmount_width, lmount_thickness, lmount_height]);
            translate([-edge_x_lip, 0, 0])
            cube([lmount_width, screw_a_y_dist + 10, 15]);
        }
        
        translate([-screw_a_x_dist, screw_a_y_dist, 15])
        #baseplate_screwhole();
    }
}

//
// All parts
//

difference() {
    
    union() {
        if(enable_top_mount) {
            //translate([0, 6.5, 246])
            translate([-10, 30, 249])
            rotate([-70, 0, 180])
            upper_mobo_mount();
        }
        
        if(enable_bottem_left_mount) {
            translate([-241/2, 0, 0])
            lower_left_mobo_mount();
        }
    
    }
    
    motherboard();
}









