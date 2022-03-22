use <../Shared/2Dshapes.scad>;

$fn=256;

material_thickness = 3;

pcb_size = [139, 58];
pcb_offset = [5, 30];
pcb_height = 12.6;

pcb_corner_radius = [3, 3];
plate_corner_radius = [3, 3];

plate_mount_screwhole_offset = [150, 5];
plate_mount_screwhole_diameter = 3;
plate_mount_screwhole_positions = [[0, 0], [0, 25], [0, 69], [0, 98]];

plate_pcb_screwhole_diameter = 3.5;
plate_pcb_screwhole_offset = pcb_offset;
plate_pcb_screwhole_positions = [[13.3, 21],[125, 21],[14.3, 49],[119.3, 49]];

plate_size = plate_mount_screwhole_offset + plate_mount_screwhole_positions[3] + [5, 5];

    module pcb() {
        // complexRoundSquare(size, top left radius, top right radius, bottom right radius, bottom left radius, center)
        complexRoundSquare(pcb_size, rads1=pcb_corner_radius, rads2=pcb_corner_radius, rads3=pcb_corner_radius, rads4=pcb_corner_radius, center=false);
    }

module display_converter_mount_2d() {
    module plate() {
        // complexRoundSquare(size, top left radius, top right radius, bottom right radius, bottom left radius, center)
        complexRoundSquare(plate_size, rads1=plate_corner_radius, rads2=plate_corner_radius, rads3=plate_corner_radius, rads4=plate_corner_radius, center=false);
    }

    module pcb_screw_holes() {
        for (this_pos = plate_pcb_screwhole_positions) {
            translate(this_pos + plate_pcb_screwhole_offset)
            circle(d = plate_pcb_screwhole_diameter, center = true);
        }
    }

    module mount_screw_holes() {
        for (this_pos = plate_mount_screwhole_positions) {
            translate(this_pos)
            circle(d = plate_mount_screwhole_diameter, center = true);
        }
    }
    
    difference() {
        union() {
            plate();

            translate(pcb_offset)
            %pcb();
        }
        union() {
            pcb_screw_holes();

            translate(plate_mount_screwhole_offset)
            #mount_screw_holes();
        }
    }
}

module display_converter_mount_3d() {
    linear_extrude(height = material_thickness) {
        display_converter_mount_2d();
    }

    translate([0, 0, material_thickness + 4])
    %linear_extrude(height = pcb_height) {
        translate(pcb_offset)
        pcb();
    }
}

display_converter_mount_3d();
