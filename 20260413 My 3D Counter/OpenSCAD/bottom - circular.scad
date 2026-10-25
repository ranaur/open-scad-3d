    // ============================================================
//  Cylinder with Digits 0-9 Engraved on the Border
//  Diameter: 25 mm  |  Height: 3 mm  |  Digits rotated 90°
//  Central hole: 4 mm diameter
// ============================================================

// ── Parameters (edit here) ──────────────────────────────────
diameter    = 25;     // outer diameter [mm]
cyl_height  = 1.5;    // total cylinder height [mm]
hole_diam   = 4;      // central hole diameter [mm]
snap_size   = 1;      // snap fit size [mm]
snap_height = 0.75;    // snap fit size [mm]
$fn         = 120;    // curve resolution (higher = smoother)
// ── Derived values ──────────────────────────────────────────
radius     = diameter / 2;

// ── Model ───────────────────────────────────────────────────
difference() {

    difference() {

        // Base cylinder
        cylinder(h = cyl_height, d = diameter, center = false);

        // Central through-hole
        translate([0, 0, -0.01])
            cylinder(h = cyl_height + 0.02, d = hole_diam, center = false, $fn = 60);
    }

    // Snap through-hole
    translate([0, 0, -0.01])
        cylinder(h = snap_height + 0.02, d = hole_diam + snap_size, center = false, $fn = 60);
}