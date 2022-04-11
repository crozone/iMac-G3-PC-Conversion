include  <../Shared/shared_settings.scad>;

bottom_mount_version = "v1.2";
bottom_mount_height = 30;
bottom_mount_tab_length = 10; // length of tab.
bottom_mount_tab_width = bottom_mount_height;
bottom_connecting_tab_tab_height = material_thickness - 0.2;

bottom_mount_tab_positions = [
    [10, 0],
    [35 - material_thickness, 0],

    // [70, 0],
    // [95 - material_thickness, 0],

    //[125, 0],
    //[150 - material_thickness, 0],

    [140, 0],
    [165 - material_thickness, 0],
];
