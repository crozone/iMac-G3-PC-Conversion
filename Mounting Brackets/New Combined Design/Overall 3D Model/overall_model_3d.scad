use <../Shared/2Dshapes.scad>;
use <../Top Mount/top_mount_2D.scad>;
use <../Rad Mount/rad_mount_2D.scad>;
use <../Motherboard Fixture/motherboard_fixture_3d.scad>
use <../Reservoir Assembly/reservoir_assy.scad>
use <../Connecting Tabs/angle_tab_2d.scad>

include  <../Shared/shared_settings.scad>;

$fn=256;

tab_height = material_thickness; // Same as material thickness.
rad_angle = 36;

translate([0, 0, 230])
union() {
    top_mount_3d();

    tab_offset_a = 5 + 2.5;
    tab_offset_b = 5 + 2.5;

    translate([113 - (material_thickness / 2), 75 - 35 + tab_offset_a]) // 10mm inset from the oute edge of the tab
    rotate([0, 90, 0])
    rotate([0, 0, -90])
    #angle_tab_3d(angle = 90 + rad_angle, offset_a = tab_offset_a, offset_b = tab_offset_b);

    translate([-113 - (material_thickness / 2), 75 - 35 + tab_offset_a]) // 10mm inset from the oute edge of the tab
    rotate([0, 90, 0])
    rotate([0, 0, -90])
    #angle_tab_3d(angle = 90 + rad_angle, offset_a = tab_offset_a, offset_b = tab_offset_b);
}

translate([0, 75 - 30, 230])
translate([0, 0, 2])
rotate([-90 + rad_angle, 0, 0])
rad_mount_3d();

motherboard_fixture_3d();

translate([0, 140, 14])
%reservoir_assy_3d();
