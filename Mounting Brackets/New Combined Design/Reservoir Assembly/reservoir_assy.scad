// 3D model representing the reservoir assembly.
// This includes the acrylic reservoir, the water pump, and the solid fixtures attached to the reservoir.

$fn=256;

reservoir_size = [120, 120, 35];

module reservoir_assy_3d() {
    module reservoir_block() {
        cube(reservoir_size, center = true);
    }

    translate([0, 0, reservoir_size[2] / 2])
    reservoir_block();
}

reservoir_assy_3d();
