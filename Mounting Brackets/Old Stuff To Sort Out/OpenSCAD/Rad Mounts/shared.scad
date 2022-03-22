// Shared functions

// Ryan Crosby 2019

// Triangular prism
module prism(l, w, h){
       polyhedron(
               points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
               faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
               );
}

module cube_round(v, r = 3) {
    if(r <= 0) {
        cube(v);
    }
    else {
        w = v[0];
        l = v[1];
        h = v[2];
        hull() 
        {
            translate([r, r, 0]) cylinder(h, r, r);
            translate([w - r, r, 0]) cylinder(h, r, r);
            translate([r, l - r, 0]) cylinder(h, r, r);
            translate([w - r, l - r, 0]) cylinder(h, r, r);
        }
    }
}