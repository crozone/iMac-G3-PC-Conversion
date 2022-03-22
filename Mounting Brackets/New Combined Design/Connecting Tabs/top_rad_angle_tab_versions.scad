use<./angle_tab_2d.scad>;

//include  <../Shared/shared_settings.scad>;

text_only = false;

versions = [
    // Set 1
    // [[90 + 34, 5 + 2.5, 5 + 2.5], [40, 30]],
    // [[90 + 36, 5 + 2.5, 5 + 2.5], [40, 90]],
    // [[90 + 38, 5 + 2.5, 5 + 2.5], [40, 150]],

    // [[90 + 34, 5 + 3.0, 5 + 3.0], [120, 30]],
    // [[90 + 36, 5 + 3.0, 5 + 3.0], [120, 90]],
    // [[90 + 38, 5 + 3.0, 5 + 3.0], [120, 150]],

    // Set 2
    // [[90 + 34, 5 + 0.5, 5 + 1.0], [40, 30]],
    // [[90 + 34, 5 + 0.5, 5 + 1.5], [40, 65]],
    // [[90 + 34, 5 + 1.0, 5 + 1.5], [40, 100]],

    // Set 3
    // [[90 + 34, 5 + 1.5, 5 + 1.5], [35, 30]],

    // Set 4
    [[90 + 30, 5 + 1.75, 5 + 1.75], [35, 30]],
    [[90 + 33, 5 + 1.75, 5 + 1.75], [35, 90]],
    [[90 + 36, 5 + 1.75, 5 + 1.75], [105, 30]],
    [[90 + 39, 5 + 1.75, 5 + 1.75], [105, 90]],
    [[90 + 42, 5 + 1.75, 5 + 1.75], [176, 30]],
    [[90 + 45, 5 + 1.75, 5 + 1.75], [176, 90]],
];

for (i = versions) {
    values = i[0];
    position = i[1];

    angle = values[0];
    offset_a = values[1];
    offset_b = values[2];

    translate(position)
    union() {
        translate([0, -27.5])
        rotate(90 - angle / 2)
        angle_tab_2d(angle, offset_a, offset_b, text_mode = text_only ? 2 : 1);

        rotate(180)
        translate([0, -27.5])
        rotate(90 - angle / 2)
        angle_tab_2d(angle, offset_a, offset_b, text_mode = text_only ? 2 : 1);
    }
}
