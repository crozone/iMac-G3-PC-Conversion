// Rounded corner module

module rounded_corner(r = 10) {
    difference() {
        square([r, r]);
        circle(r = r);
    }
}
