use <../Shared/2Dshapes.scad>;
use <../Shared/baseplate_screw_holes.scad>;
use <../Rad Top Mount/top_mount_2D.scad>;
use <../Rad Mount/rad_mount_2D.scad>;
use <../Rad Bottom Mount/rad_bottom_mount_2D.scad>;
use <../Rad Bottom Mount/bottom_connecting_tab_2d.scad>;
use <../PSU Mount/psu_mount_2D.scad>;
use <../Motherboard Fixture/motherboard_fixture_3d.scad>;
use <../Reservoir Assembly/reservoir_assy.scad>;
use <../Connecting Tabs/angle_tab_2d.scad>;

include  <../Shared/shared_settings.scad>;

$fn=256;

tab_height = material_thickness; // Same as material thickness.
rad_angle = 31;

translate([0, 0, 230])
union() {
    top_mount_3d();

    tab_offset_a = 5 + 2.5;
    tab_offset_b = 5 + 2.5;

    translate([113 - (material_thickness / 2), 75 - 35 + tab_offset_a]) // 10mm inset from the oute edge of the tab
    rotate([0, 90, 0])
    rotate([0, 0, -90])
    angle_tab_3d(angle = 90 + rad_angle, offset_a = tab_offset_a, offset_b = tab_offset_b);

    translate([-113 - (material_thickness / 2), 75 - 35 + tab_offset_a]) // 10mm inset from the oute edge of the tab
    rotate([0, 90, 0])
    rotate([0, 0, -90])
    angle_tab_3d(angle = 90 + rad_angle, offset_a = tab_offset_a, offset_b = tab_offset_b);
}

translate([0, 75 - 30, 230])
translate([0, 0, 2])
rotate([-90 + rad_angle, 0, 0])
rad_mount_3d();


zero_screw_hole_offset = [-77, 15 + (baseplate_screwhole_offset([0, 1], true) + baseplate_screwhole_offset([0, 3], false))[1]];

// PSU MOUNT
// Translates the PSU such that the bottom left screw-hole is at (0,0,0)
psu_origin_offset = -[-material_thickness - 15, -material_thickness - 3, 35];
translate(psu_origin_offset)
translate(zero_screw_hole_offset)
psu_mount_3d();


// BOTTOM RADIATOR MOUNT
translate(zero_screw_hole_offset + baseplate_screwhole_offset([-1, 6], true))
rad_bottom_mount_3d(true, angle = 90 - rad_angle, pivot_height = 10);


motherboard_fixture_3d();
