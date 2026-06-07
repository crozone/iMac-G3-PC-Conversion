// Variables that are needed by both the compute sled and the GPU mount.
// Since the compute sled needs to render the GPU mount, and the GPU mount needs to know motherboard screw hole positions,
// this file is used to house shared values and avoid recursive dependencies.

MINI_ITX_MOBO_MOUNTING_HOLES = [
    [ 0,      0      ] + [10.16, 6.35], // Screw hole C, bottom left
    [ 154.94, 0      ] + [10.16, 6.35], // Screw hole H, bottom right
    [ 154.94, 157.48 ] + [10.16, 6.35], // Screw hole J, top right
    [ 22.86,  157.48 ] + [10.16, 6.35]  // Screw hole F
];

MOTHERBOARD_OFFSET = [0, 35];

// GPU mount top is 270 above plane
// At Y offset = -60 the two PCIe slots are horizntal to each other.
GPU_MOUNT_OFFSET = [0, 67];