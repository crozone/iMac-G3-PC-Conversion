// Shared functions

// Ryan Crosby 2019

// Triangular prism
module prism(l, w, h){
       polyhedron(
               points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
               faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
               );
}

module cube_round(v, r = 3, a = 0, center = false) {
    if(r <= 0) {
        cube(v);
    }
    else {
        w = v[0];
        l = v[1];
        h = v[2];

        offset_x = center ? -w / 2 : 0;
        offset_y = center ? -l / 2 : 0;
        offset_z = center ? -h / 2 : 0;

        translate([offset_x, offset_y, offset_z])
        hull()
        {
            // Curved WRT front
            if(a == 0) {
                translate([r, 0, r])
                translate([0, l, 0])
                rotate([90, 0, 0])
                cylinder(h = l, r = r);

                translate([w - r, 0, r])
                translate([0, l, 0])
                rotate([90, 0, 0])
                cylinder(h = l, r = r);

                translate([r, 0, h - r])
                translate([0, l, 0])
                rotate([90, 0, 0])
                cylinder(h = l, r = r);

                translate([w - r, 0, h - r])
                translate([0, l, 0])
                rotate([90, 0, 0])
                cylinder(h = l, r = r);
            }
            // Curved WRT side
            else if(a == 1) {
                translate([0, r, r])
                rotate([0, 90, 0])
                cylinder(h = w, r = r);

                translate([0, l - r, r])
                rotate([0, 90, 0])
                cylinder(h = w, r = r);

                translate([0, r, h - r])
                rotate([0, 90, 0])
                cylinder(h = w, r = r);

                translate([0, l - r, h - r])
                rotate([0, 90, 0])
                cylinder(h = w, r = r);
            }
            // Curved WRT top
            else if(a == 2) {
                translate([r, r, 0])
                cylinder(h = h, r = r);

                translate([w - r, r, 0])
                cylinder(h = h, r = r);

                translate([r, l - r, 0])
                cylinder(h = h, r = r);

                translate([w - r, l - r, 0])
                cylinder(h = h, r = r);
            }
        }
    }
}
