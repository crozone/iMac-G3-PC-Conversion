module tab_bounds(width, tab_height) {
    translate([0, tab_height / 2])
    square([width, tab_height], center = true);
}

module tab_strip(width, tab_width, tab_height, inverse = false) {
    module tabs(inverse = false) {
        for ( i = [(inverse ? tab_width : 0) : tab_width * 2 : width / 2 + width] ) {
            translate([i, 0])
            square([tab_width, tab_height], center = true);

            if (i != 0) {
                translate([-i, 0])
                square([tab_width, tab_height], center = true);
            }
        }
    }

    intersection() {
        tab_bounds(width, tab_height);

        translate([0, tab_height / 2])
        tabs(inverse);
    }
}

// Demo of both types of tab strips
tab_strip(width = 244, tab_width = 10, tab_height = 5, inverse = false);

translate([0, 10])
tab_strip(width = 244, tab_width = 10, tab_height = 5, inverse = true);
