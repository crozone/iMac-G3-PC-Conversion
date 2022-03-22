use <2Dshapes.scad>;
use <shared.scad>;

$fn=256;

module attachment_bracket() {
    base_thickness = 3;
    fan_screw_distance = 154;

    arm_thickness = 8;

    lower_mount_height_offset = 3;
    lower_mount_thickness = arm_thickness;
    lower_cube_width = 10;


    upper_mount_screw_spacing = 20; //21.5; // Distance between the two screws on the mount
    upper_mount_spacing = 120; //117; // Horizontal distance between the two pairs of mounting screws
    upper_mount_y_offset = upper_mount_spacing / 2 - fan_screw_distance / 2; // Inset distance from the fan screw to the mount screw
    upper_mount_y_offset_from_screw = 2.5; // The "upper_mount_y_offset" is for the screw holes, this defines the offset from those screws that the mount is positioned
    upper_mount_x_length = upper_mount_screw_spacing + 4 + 3;
    upper_mount_y_length = 7.5 + 5; //1;
    upper_mount_arm_thickness = arm_thickness;
    upper_mount_thickness = arm_thickness;
    upper_mount_z_offset = 35;
    upper_mount_screw_depth = 2;

    module bracket_body() {
        module upper_mount() {
            translate([fan_screw_distance / 2, upper_mount_y_offset + upper_mount_y_offset_from_screw, upper_mount_z_offset - upper_mount_thickness])
            translate([-upper_mount_x_length / 2, -upper_mount_y_length / 2, 0])
            cube([upper_mount_x_length, upper_mount_y_length, upper_mount_thickness]);
        }

        module base_mount() {
            cube_round(
                [7 + 27, 27 + 7, base_thickness],
                a = 2,
                d = 2
                );
        }

        module left_base_mount_bot() {
            difference() {
                translate([-7, -27, 0])
                base_mount();

                fan_cutout();
            }
        }

        module left_base_mount_top() {
            translate([-lower_cube_width / 2, -lower_cube_width / 2, lower_mount_height_offset])
            cube([lower_cube_width, lower_cube_width, lower_mount_thickness]);
        }

        module left_base_mount() {
            hull() {
                left_base_mount_bot();
                left_base_mount_top();
            }
        }

        module right_base_mount_bot() {
            difference() {
                translate([fan_screw_distance - 27, -27, 0])
                base_mount();
                
                fan_cutout();
            }
        }

        module right_base_mount_top() {
            translate([fan_screw_distance - lower_cube_width / 2, - lower_cube_width / 2, lower_mount_height_offset])
            cube([lower_cube_width, lower_cube_width, lower_mount_thickness]);
        }

        module right_base_mount() {
            hull() {
                right_base_mount_bot();
                right_base_mount_top();
            }
        }

        // Base mounts
        union() {
            left_base_mount();
            right_base_mount();

            // Upper mount
            upper_mount();

            // Arms
            union() {
                hull() {
                    left_base_mount_top();

                    translate([fan_screw_distance / 2, upper_mount_y_offset + upper_mount_y_offset_from_screw, upper_mount_z_offset - upper_mount_arm_thickness])
                    translate([-upper_mount_x_length / 2, -upper_mount_y_length / 2, 0])
                    cube([10, upper_mount_y_length, upper_mount_arm_thickness]);
                }

                hull() {
                    right_base_mount_top();

                    translate([fan_screw_distance / 2, upper_mount_y_offset + upper_mount_y_offset_from_screw, upper_mount_z_offset - upper_mount_arm_thickness])
                    translate([-upper_mount_x_length / 2, -upper_mount_y_length / 2, 0])
                    translate([upper_mount_x_length - 10, 0, 0])
                    cube([10, upper_mount_y_length, upper_mount_arm_thickness]);
                }
            }
        }
    }

    module screw_hole(d1, d2, h) {
        union() {
            cylinder(d = d1, h = h);

            translate([0, 0, h])
            cylinder(d = d2, h = 20);
        }
    }

    module upper_screw(h) {
        screw_hole(4.5, 8 + 1, h);
    }

    module lower_screw(h) {
        screw_hole(4, 8 + 1, h);
    }

    module fan_cutout() {
        // Fan cutout
        translate([154 / 2, -95 + 20, 0])
        cylinder(d = 190, h = lower_mount_height_offset + 2);
    }

    difference() {
        bracket_body();

        #union() {
            // Lower screw holes
            union() {
                lower_screw(h = base_thickness + 1);

                translate([154, 0, 0])
                lower_screw(h = base_thickness + 1);
            }

            // Upper screw holes
            translate([fan_screw_distance / 2, upper_mount_y_offset, upper_mount_z_offset])
            union() {
                rotate([180, 0, 0])
                translate([-upper_mount_screw_spacing / 2, 0, -0.001])
                upper_screw(h = upper_mount_screw_depth);

                rotate([180, 0, 0])
                translate([upper_mount_screw_spacing / 2, 0, -0.001])
                upper_screw(h = upper_mount_screw_depth);
            }

            // Fan cutout
            fan_cutout();
        }
    }
}

attachment_bracket();
