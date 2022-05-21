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

translate([0, 0, 230])
union() {
    top_mount_3d();

    tab_offset_a = 5 + 2.5;
    tab_offset_b = 5 + 2.5;

    translate([113 - (material_thickness / 2), 75 - 35 + tab_offset_a]) // 10mm inset from the oute edge of the tab
    rotate([0, 90, 0])
    rotate([0, 0, -90])
    angle_tab_3d(angle = 90 + radiator_angle, offset_a = tab_offset_a, offset_b = tab_offset_b);

    translate([-113 - (material_thickness / 2), 75 - 35 + tab_offset_a]) // 10mm inset from the oute edge of the tab
    rotate([0, 90, 0])
    rotate([0, 0, -90])
    angle_tab_3d(angle = 90 + radiator_angle, offset_a = tab_offset_a, offset_b = tab_offset_b);
}

// translate([0, 75 - 30, 230])
// translate([0, 0, 2])
// rotate([-90 + radiator_angle, 0, 0])
// rad_mount_3d();


// -77

// The X = -1 screw on the rad_bottom_mount is 85mm left of the center line
neg_one_screw_x_offset = -85;

// Add one screw hole right to get zero hole x offset
zero_screw_hole_x_offset = neg_one_screw_x_offset + baseplate_screwhole_offset([1, 0])[0];

zero_screw_hole_offset = [zero_screw_hole_x_offset, 15 + (baseplate_screwhole_offset([0, 1], true) + baseplate_screwhole_offset([0, 3], false))[1]];

// PSU MOUNT
// Translates the PSU such that the bottom left screw-hole is at (0,0,0)
psu_origin_offset = -[-material_thickness - 15, -material_thickness - 3, 35];
translate(psu_origin_offset)
translate(zero_screw_hole_offset)
psu_mount_3d();


// BOTTOM RADIATOR MOUNT
pivot_angle = 90 - radiator_angle;
pivot_height = radiator_bottom_mount_height_offset;
rad_mount_offset = zero_screw_hole_offset + baseplate_screwhole_offset([-1, 6], true);
translate(rad_mount_offset)
rad_bottom_mount_3d(with_tabs = true, pivot_angle = pivot_angle, pivot_height = pivot_height, engrave_mode = 1);

// RADIATOR MOUNT
translate([0, rad_mount_offset[1] + 7]) // Put it in the middle of the bottom mount
translate([0, 0, pivot_height + material_thickness]) // Raise it up to pivot height
rotate([-pivot_angle, 0, 0]) // Rotate it to match correct pivot angle
//rotate([-80, 0, 0]) // Rotate it to match correct pivot angle
translate([0, -get_rad_mount_height(), 0]) // Translate so that the top of the bottom tab cutout is at Y = 0
rad_mount_3d(engrave_mode = 1);


translate([37, 0])
motherboard_fixture_3d();
