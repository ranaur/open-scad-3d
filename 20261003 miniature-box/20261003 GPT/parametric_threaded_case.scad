//
// Parametric two-piece cylindrical threaded case
// Units: mm
//
// Default dimensions:
//   Internal diameter: 27
//   Wall thickness:     3
//   Bottom side height: 10
//   Top side height:    35
//   Base thickness:      8
//   Magnet:              5 diameter x 3 deep
//   Thread engagement:   5
//
// The bottom piece has an external male thread.
// The top piece has a matching internal female thread.
//
// Open this file in OpenSCAD and use the Customizer if desired.
//

// =========================
// Main parameters
// =========================

internal_diameter = 27;
wall = 3;

bottom_side_height = 10;
top_side_height = 35;
base_height = 8;

magnet_diameter = 5;
magnet_depth = 3;

// Thread parameters
thread_height = 5;       // axial length of threaded section
thread_pitch = 2.0;      // distance between thread turns
thread_depth = 0.9;      // radial thread depth
thread_clearance = 0.18; // radial clearance between male/female threads
thread_starts = 1;

// Thread profile
thread_profile = 0.75;   // fraction of pitch occupied by the ridge
thread_segments = 96;    // smoothness of helix

// Manufacturing / modeling parameters
bottom_clearance = 0.25; // clearance at the shoulder between parts
cap_top_thickness = wall; // top thickness of the cap
bottom_outer_radius = (internal_diameter / 2) + wall;
$fn = 96;


// =========================
// Derived dimensions
// =========================

inner_r = internal_diameter / 2;
outer_r = inner_r + wall;

bottom_total_height = base_height + bottom_side_height;
cap_total_height = top_side_height;

thread_start_z = bottom_total_height - thread_height;

//
// Thread diameters/radii.
//
// Male thread: ridge extends outward from the body's outer radius.
// Female thread: groove is cut into the cap's inner wall.
//
male_root_r = outer_r;
male_major_r = outer_r + thread_depth;

female_root_r = outer_r + thread_clearance;
female_minor_r = outer_r - thread_depth + thread_clearance;


// =========================
// Utility: helical thread
// =========================

module helical_ridge(
    r,
    depth,
    height,
    pitch,
    starts = 1,
    profile = 0.75,
    segments = 96
) {
    turns = height / pitch;
    slices = max(2, ceil(turns * segments));

    // A small triangular-ish trapezoidal thread profile.
    // The polygon is swept helically using linear_extrude.
    //
    // Width is along X, radial depth is along Y.
    linear_extrude(
        height = height,
        twist = 360 * turns * starts,
        slices = slices,
        convexity = 10
    )
    translate([r, 0, 0])
    polygon([
        [0, -pitch * profile / 2],
        [depth, -pitch * profile / 2 * 0.55],
        [depth,  pitch * profile / 2 * 0.55],
        [0,  pitch * profile / 2]
    ]);
}


// =========================
// Bottom part
// =========================

module bottom_body() {

    difference() {

        union() {

            // Main cylindrical body
            cylinder(
                h = bottom_total_height,
                r = outer_r
            );

            // Male thread
            translate([0, 0, thread_start_z])
                helical_ridge(
                    r = male_root_r,
                    depth = thread_depth,
                    height = thread_height,
                    pitch = thread_pitch,
                    starts = thread_starts,
                    profile = thread_profile,
                    segments = thread_segments
                );
        }

        // Main internal cavity.
        // The cavity starts above the solid base.
        translate([0, 0, base_height])
            cylinder(
                h = bottom_total_height - base_height + 0.5,
                r = inner_r
            );

        // Magnet hole, centered on the bottom face.
        //
        // Hole is deliberately cut from Z=0 upward.
        cylinder(
            h = magnet_depth,
            r = magnet_diameter / 2
        );
    }
}


// =========================
// Top / cap part
// =========================

module top_body() {

    difference() {

        // Solid outer cap
        cylinder(
            h = cap_total_height,
            r = outer_r
        );

        // Main internal cavity.
        //
        // The cavity leaves cap_top_thickness at the closed end.
        translate([0, 0, 0])
            cylinder(
                h = cap_total_height - cap_top_thickness,
                r = inner_r + bottom_clearance
            );

        // Female thread groove.
        //
        // We create a helical ridge-like cutter positioned at the
        // female root radius. This removes material from the inside
        // of the cap.
        translate([0, 0, 0])
            helical_ridge(
                r = female_minor_r,
                depth = thread_depth + thread_clearance,
                height = thread_height,
                pitch = thread_pitch,
                starts = thread_starts,
                profile = thread_profile,
                segments = thread_segments
            );
    }
}


// =========================
// Assembly
// =========================

module assembly() {

    // Bottom remains at Z=0.
    bottom_body();

    // Cap is positioned above the bottom.
    //
    // The cap's threaded section overlaps the male thread.
    translate([
        0,
        0,
        bottom_total_height - thread_height + bottom_clearance
    ])
        top_body();
}


// =========================
// Display selection
// =========================

part = "assembly";
// Options:
//   "bottom"
//   "top"
//   "assembly"

if (part == "bottom") {
    bottom_body();
}
else if (part == "top") {
    top_body();
}
else {
    assembly();
}
