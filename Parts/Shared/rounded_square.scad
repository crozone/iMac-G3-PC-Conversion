$fn = $preview ? 64 : 128;

/**
 * Creates a square with rounded corners
 * @param size The size of the square
 * @param r The radius of the rounded corners. A value of 0 will create a sharp corner.
 * @param corners An array to specify the radius of each corner individually. A value of 0 will create a sharp corner. Any undef values will default to the value of r.
 */
module rounded_square(size, r = 0, corners = [undef, undef, undef, undef]) {
    for(len = size) {
        assert(len >= r*2, "Rounded square dimensions must be greater than or equal to twice the corner radius");
    }

    // Get individual corner radius values.
    // Default to r if any value is undef.
    corner_radius = [
        is_undef(corners[0]) ? r : corners[0],
        is_undef(corners[1]) ? r : corners[1],
        is_undef(corners[2]) ? r : corners[2],
        is_undef(corners[3]) ? r : corners[3]
    ];

    intersection() {
        square(size);

        hull() {
            // Bottom left
            if(corner_radius[0] > 0) {
                translate([corner_radius[0], corner_radius[0]])
                circle(r = corner_radius[0]);
            }
            else {
                square(size/2);
            }

            // Bottom right
            if(corner_radius[1] > 0) {
                translate([size[0], 0])
                translate([-corner_radius[1], corner_radius[1]])
                circle(r = corner_radius[1]);
            }
            else {
                translate([size[0]/2, 0])
                square(size/2);
            }

            // Top right
            if(corner_radius[2] > 0) {
                translate([size[0], size[1]])
                translate([-corner_radius[2], -corner_radius[2]])
                circle(r = corner_radius[2]);
            }
            else {
                translate([size[0]/2, size[1]/2])
                square(size/2);
            }

            // Top left
            if(corner_radius[3] > 0) {
                translate([0, size[1]])
                translate([corner_radius[3], -corner_radius[3]])
                circle(r = corner_radius[3]);
            }
            else {
                translate([0, size[1]/2])
                square(size/2);
            }
        }
    }
}

// Test
rounded_square(size = [50, 50], r = 1, corners = [0, undef, 2, 3]);