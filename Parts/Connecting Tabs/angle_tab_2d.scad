// Tabs that connect other plates together at a specified angle

include  <../Shared/shared_settings.scad>;

$fn=512;

// A very small distance to overcome rounding errors
$eps = pow(2, -16); // 2^-N have exact representations in floating point. 2^-16 ~= 0.000015

tab_height = material_thickness; // Same as material thickness.
tab_length = 10; // length of tab.

tab_total_length = tab_length * 3;
tab_backing_width = tab_height * 2;

// Small rectangular cutouts for angled mounting tabs to insert into, for mounting the rad plate to the top plate.
module angle_tabs_cutout() {
    translate([0, tab_length])
    square([tab_height, tab_length], center = true);

    translate([0, -tab_length])
    square([tab_height, tab_length], center = true);
}

module angle_tab_2d(angle = 90, offset_a = 10, offset_b = 10, engrave_mode = 1) {
    if(engrave_mode < 2) {
        // A tabs
        rotate(90)
        translate([0, -(tab_total_length / 2) - offset_a])
        translate([-tab_height / 2 + $eps, 0])
        angle_tabs_cutout();

        // B tabs
        rotate(90 + angle)
        translate([0, -(tab_total_length / 2) - offset_b])
        translate([tab_height / 2 - $eps, 0])
        angle_tabs_cutout();

        hull() {
            rotate(90)
            translate([0, -(tab_total_length / 2) - offset_a])
            translate([tab_backing_width / 2, 0])
            square([tab_backing_width, tab_total_length], center = true);

            rotate(90 + angle)
            translate([0, -(tab_total_length / 2) - offset_b])
            translate([-tab_backing_width / 2, 0])
            square([tab_backing_width, tab_total_length], center = true);
        }
    }

    if(engrave_mode > 0) {
        text_line1 = "iMac angle tab v1.0";
        text_line2 = str(material_thickness, "mm / ", angle, chr(176), " / (", offset_a, ",", offset_b,")");

        echo(str(text_line1, " // ", text_line2));

        text_offset = ([offset_a * cos(angle / 2), offset_a * sin(angle / 2)] + [offset_b * cos(angle / 2), offset_b * sin(angle / 2)]) / 2;

        translate([(30 + offset_a) - 2, 3])
        rotate(180)
        union() {
            #text(text = text_line1, font = text_font, size = 2, halign = "left", valign = "top");

            translate([0, -3])
            #text(text = text_line2, font = text_font, size = 2, halign = "left", valign = "top");
        }
    }
}

module angle_tab_3d(angle, offset_a, offset_b) {
    linear_extrude(height = material_thickness) {
        angle_tab_2d(angle, offset_a, offset_b);
    }
}

angle_tab_2d(angle = 90 + 38, offset_a = 5 + 2.5, offset_b = 5 + 2.5);
