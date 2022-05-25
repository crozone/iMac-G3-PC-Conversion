// Custom iMac G3 DV watercooling reservoir and pump top.
// Designed to sit to the right of the motherboard.
// Designed for D5 Alphacool VPP655T Pump
// Overall size 80mm x 190mm.

use <2Dshapes.scad>;

// Like a smaller, narrower 240mm D5 Res: https://www.radikult-custom.com/product-page/240-d5

$fn=64;

// The reservoir is made of two acrylic plates that are sandwiched together.
// The top and bottom can be rendered seperately
top_plate = true;
bottom_plate = true;
show_pump = true;

// Outer dimensions: 80mm x 190mm x 35mm
reservoir_2d_size = [80, 190];
reservoir_thickness = 35;

// Space between the edge of the reservoir an the inner tank, leaving space for the o-ring.
reservoir_edge_buffer = 13;

// Alphacool VPP655T Pump
pump_diameter = 60;
pump_height = 45;
pump_inset = 3; // Pump sits 3mm into the reservoir

pump_position = [80 / 2, 60 / 2 + 50];

// G 1/4" fittings
port_diameter = 13.157; // 1/4" = 0.518 inch major diameter
fitting_diameter = 18;

tank_corner_diameter = 10;
tank_corner_radius = [tank_corner_diameter / 2, tank_corner_diameter / 2];
tank_small_width = 22.5;

// Loop order: Reservoir outlet -> Radiator Inlet (bottom) / Radiator Outlet (top) -> CPU -> Passthrough -> GPU -> Reservoir inlet

inner_tanks_2d_offset = [reservoir_edge_buffer, reservoir_edge_buffer];
inner_tanks_2d_size = reservoir_2d_size - [reservoir_edge_buffer * 2, reservoir_edge_buffer * 2];

port_bottom_y_position = inner_tanks_2d_offset[1] + port_diameter / 2;
port_top_y_position = inner_tanks_2d_offset[1] + inner_tanks_2d_size[1] - port_diameter / 2;
port_top_y_position_lower = inner_tanks_2d_offset[1] + inner_tanks_2d_size[1] + port_diameter / 2 - tank_small_width;

port_left_x_position = inner_tanks_2d_offset[0] + port_diameter / 2;
port_right_x_position = inner_tanks_2d_offset[0] + inner_tanks_2d_size[0] - port_diameter / 2;


port_front_positions = [
    [port_left_x_position, port_bottom_y_position + 10], // Reservoir outlet port (front bottom, to radiator)
    [port_right_x_position, port_bottom_y_position], // Reservoir drain port (front bottom, to tap)
    [port_left_x_position, port_top_y_position_lower], // Passthrough inlet (front top left, from CPU)
    [port_right_x_position, port_top_y_position], // Reservoir fill port (front top right, closed?)
    ];

port_back_positions = [
    [port_left_x_position, port_top_y_position], // GPU passthrough outlet (back, to GPU)
    [port_right_x_position, port_top_y_position] // Reservoir inlet port (back, from GPU)
];


mounting_screw_diameter = 4;

mount_screw_positions = [
    [7.5, 7.5],
    [7.5, reservoir_2d_size[1] - 7.5],

    [reservoir_2d_size[0] / 2, 7.5],
    [reservoir_2d_size[0] / 2, reservoir_2d_size[1] - 7.5],

    [reservoir_2d_size[0] - 7.5, 7.5],
    [reservoir_2d_size[0] - 7.5, reservoir_2d_size[1] - 7.5]
];

module plate() {
    // complexRoundSquare(size, top left radius, top right radius, bottom right radius, bottom left radius, center)
    square(reservoir_2d_size, center=false);
}

module pump() {
        circle(d = pump_diameter, center = true);
}

module pump_cutout() {
    circle(d = pump_diameter, center = true);
}

module pump_ports() {
        circle(d = 10, center = true);

        rotate(45)
        translate([0, -pump_diameter / 2 + 10 / 2 - 2])
        circle(d = 10, center = true);
}

module pump_mount() {
    difference() {
        union() {
            circle(d = 75, center = true);

            square([30, 85], center = true);

            rotate(90)
            square([30, 85], center = true);
        }

        circle(d = pump_diameter, center = true);
    }
}

module intake_tank() {
    intake_tank_bot_y = 65;
    intake_tank_size = inner_tanks_2d_size - [0, tank_small_width + 10] - [0, intake_tank_bot_y];

    union() {
        hull() {
            translate(inner_tanks_2d_offset)
            translate([0, intake_tank_bot_y])
            complexRoundSquare(intake_tank_size, rads1=tank_corner_radius, rads2=tank_corner_radius, rads3=[0,0], rads4=tank_corner_radius, center=false);

            translate(pump_position)
            circle(d = 10, center = true);
        }

        translate(inner_tanks_2d_offset)
        translate([0, intake_tank_bot_y])
        translate(intake_tank_size - [tank_small_width, 0])
        complexRoundSquare([tank_small_width, tank_small_width + 10], rads1=[0,0], rads2=[0,0], rads3=tank_corner_radius, rads4=tank_corner_radius, center=false);
    }
}

module outtake_tank() {
    hull() {
        translate(port_front_positions[1] + [0, 40])
        circle(d = port_diameter, center = true);

        translate(port_front_positions[1])
        circle(d = port_diameter, center = true);
    }

    hull() {
        translate(port_front_positions[0] - [0, 10])
        circle(d = port_diameter, center = true);

        translate(port_front_positions[1])
        circle(d = port_diameter, center = true);
    }

    hull() {
        translate(port_front_positions[0] - [0, 10])
        circle(d = port_diameter, center = true);

        translate(port_front_positions[0])
        circle(d = port_diameter, center = true);
    }
}

module through_tank() {
    translate(inner_tanks_2d_offset + [0, inner_tanks_2d_size[1] - tank_small_width])
    complexRoundSquare([tank_small_width, tank_small_width], rads1=tank_corner_radius, rads2=tank_corner_radius, rads3=tank_corner_radius, rads4=tank_corner_radius, center=false);
}

module port_hole() {
    circle(d = port_diameter, center = true);
}

module front_port_holes() {
    for (this_pos = port_front_positions) {
        translate(this_pos)
        port_hole();
    }
}

module rear_port_holes() {
    for (this_pos = port_back_positions) {
        translate(this_pos)
        port_hole();
    }
}

module fitting() {
    circle(d = fitting_diameter, center = true);
}

module front_fittings() {
    for (this_pos = port_front_positions) {
        translate(this_pos)
        fitting();
    }
}

module rear_fittings() {
    for (this_pos = port_back_positions) {
        translate(this_pos)
        fitting();
    }
}

module mount_screw_hole() {
    circle(d = mounting_screw_diameter, center = true);
}

module mount_screw_holes() {
    for (this_pos = mount_screw_positions) {
        translate(this_pos)
        mount_screw_hole();
    }
}

module reservoir_mockup_3d() {
    difference() {
        union() {
            if(top_plate) {
                translate([0, 0, reservoir_thickness / 2])
                linear_extrude(height = reservoir_thickness / 2) {
                    plate();
                }
            }
            if(bottom_plate) {
                linear_extrude(height = reservoir_thickness / 2) {
                    plate();
                }
            }
        }

        // Front ports
        translate([0, 0, reservoir_thickness - 10])
        #linear_extrude(height = 15) {
            front_port_holes();
        }

        // Rear ports
        translate([0, 0, -15 +10])
        #linear_extrude(height = 15) {
            rear_port_holes();
        }

        // Tank cavity
        translate([0, 0, 5])
        #linear_extrude(height = 25) {
            union() {
                intake_tank();
                through_tank();
                outtake_tank();
            }
        }

        // Pump hole
        translate([0, 0, reservoir_thickness - pump_inset])
        translate(pump_position)
        #linear_extrude(height = pump_inset) {
            pump_cutout();
        }

        // Pump inlet and outlet ports
        translate([0, 0, reservoir_thickness - 10 - pump_inset])
        translate(pump_position)
        #linear_extrude(height = 10) {
            pump_ports();
        }

        // Mount screw holes
        #linear_extrude(height = reservoir_thickness)
        mount_screw_holes();
    }

    if(show_pump) {
        translate([0, 0, reservoir_thickness - pump_inset])
        translate(pump_position)
        #linear_extrude(height = 45) {
            pump();
        }

        translate(pump_position)
        translate([0, 0, reservoir_thickness])
        #linear_extrude(height = 10) {
            rotate(45)
            pump_mount();
        }
    }

    // Front fittings
    translate([0, 0, reservoir_thickness])
    %linear_extrude(height = 15) {
        front_fittings();
    }

    // Rear fittings
    translate([0, 0, -15])
    %linear_extrude(height = 15) {
        rear_fittings();
    }
}

reservoir_mockup_3d();
