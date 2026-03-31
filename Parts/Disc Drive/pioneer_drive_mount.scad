// Disc drive mount for the Pioneer BDR-XS07B-UHD external slot loading Blu-ray drive.
// Ryan Crosby 2026

use <../Shared/2Dshapes.scad>;
use <../Shared/rounded_corner.scad>;
use <../Shared/rounded_square.scad>;
use <pioneer_bdr-xs07b-uhd.scad>

include <../Shared/shared_settings.scad>;

$fn = $preview ? 64 : 128;

VERSION = "v1.2";

%drive();
