// Screw holes align to the hole pattern in the iMac base plate
// The hole pattern consists of two grids of 5mm holes, with the spacings:
// 
// x spacing: 14mm
// y spacing: 8mm
//
// The second grid is spaced offset from the first grid, with an offset of x: 4mm and y: 7mm.
function baseplate_screwhole_offset(holes_offset, minor) = [holes_offset[0] * 8, holes_offset[1] * 14] + (minor ? [4, 7] : [0, 0]);

module baseplate_screw_hole() {
    baseplate_screwhole_diameter = 5;
    circle(d = baseplate_screwhole_diameter);
}
