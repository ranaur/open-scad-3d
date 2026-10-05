// ============================================================
// Square Whiskey Bottle (Jack Daniel's style, no label)
// ============================================================
// Open this file in OpenSCAD (openscad.org) to view/render it.
// Adjust the parameters below to change proportions.

$fn = 64; // smoothness of curves

// ---- Parameters ----
body_width      = 10;   // side-to-side width of the square body
body_depth      = 10;   // front-to-back depth of the square body
body_height     = 20;  // height of the main square section
corner_radius   = 1;   // roundness of the body's corners
body_taper      = 0.97; // slight inward taper from bottom to top (1 = none)

shoulder_height = 5;   // height of the sloped shoulder section

neck_diameter   = 3;   // diameter of the cylindrical neck
neck_height     = 5;   // height of the neck

finish_diameter = 3.6;   // diameter of the bottle "finish" (mouth/cap area)
finish_height   = 1;    // height of the finish
lip_diameter    = 3.2;   // small lip ring under the very top opening
lip_height      = 0.2;

wall_thickness  = 3;    // used only if HOLLOW = true
HOLLOW          = false; // set true for a printable hollow shell

// ---- Helper: rounded square profile ----
module rounded_square(w, d, r) {
    hull() {
        for (x = [-1, 1], y = [-1, 1])
            translate([x * (w/2 - r), y * (d/2 - r), 0])
                circle(r = r);
    }
}

// ---- Main bottle shape ----
module bottle_solid() {
    union() {
        // Square body (slightly tapered for a nicer silhouette)
        translate([0, 0, body_height/2])
            linear_extrude(height = body_height, center = true, scale = body_taper)
                rounded_square(body_width, body_depth, corner_radius);

        // Shoulder: transitions from the square body to the round neck
        translate([0, 0, body_height])
            hull() {
                linear_extrude(height = 0.01)
                    rounded_square(body_width * body_taper, body_depth * body_taper, corner_radius);
                translate([0, 0, shoulder_height])
                    cylinder(d = neck_diameter, h = 0.01);
            }

        // Neck
        translate([0, 0, body_height + shoulder_height])
            cylinder(d = neck_diameter, h = neck_height);

        // Finish (wider section near the top, like a cap seat)
        translate([0, 0, body_height + shoulder_height + neck_height])
            cylinder(d = finish_diameter, h = finish_height);

        // Small lip ring at the very top
        translate([0, 0, body_height + shoulder_height + neck_height + finish_height])
            cylinder(d = lip_diameter, h = lip_height);
    }
}

// ---- Optional hollow shell (approximate, for printable bottles) ----
module bottle_hollow() {
    difference() {
        bottle_solid();
        translate([0, 0, wall_thickness])
            scale([
                (body_width  - 2*wall_thickness) / body_width,
                (body_depth  - 2*wall_thickness) / body_depth,
                1
            ])
                bottle_solid();
    }
}

// ---- Render ----
if (HOLLOW)
    bottle_hollow();
else
    bottle_solid();
