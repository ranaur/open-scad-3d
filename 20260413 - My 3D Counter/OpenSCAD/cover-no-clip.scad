// ============================================================
//  Cover for Counter Cylinder
//  Hollow cylinder with viewing window, rod, and optional rounded top
// ============================================================

// ── Parameters (edit here) ──────────────────────────────────
cylinder_diameter = 25;    // base cylinder diameter [mm]
gap              = 0.3;    // gap between cover and inner cylinder [mm]
thickness        = 1.5;    // wall thickness [mm]
number_of_digits = 2;      // number of digit layers
digit_height     = 3;      // height per digit layer [mm]
rod_diameter     = 4;      // central rod diameter [mm]
$fn              = 120;    // curve resolution (higher = smoother)

// ── Derived values ──────────────────────────────────────────
inner_diameter  = cylinder_diameter + 2 * gap;
outer_diameter  = inner_diameter + 2 * thickness;
cover_height    = number_of_digits * digit_height + thickness * 2;
rod_height      = cover_height;
window_angle    = 36;  // 360/10 = 36° for 1/10th opening

// ── Model ───────────────────────────────────────────────────
difference() {
    // Main cover body
    union() {
        // Outer cylinder (flat top)
        translate([0, 0, cover_height ])          cylinder(h = thickness, d = outer_diameter, center = false);
        // Hollow cylinder
        difference() {
            cylinder(h = cover_height, d = outer_diameter, center = false);      
            // Inner hollow space
            translate([0, 0, -0.01])  // slight overlap to avoid z-fighting
            cylinder(h = cover_height + 0.02, d = inner_diameter, center = false);
        }
        
        // Central rod
        cylinder(h = rod_height, d = rod_diameter, center = false);
    }
    
    // Viewing window (sector centered on cylinder, avoiding rod)
    rotate([0, 0, -window_angle/2])  // center the window
    translate([0, 0, thickness -0.01])  // slight overlap to avoid z-fighting
    linear_extrude(height = cover_height - thickness + 0.02)
    difference() {
        // Outer sector
        polygon([
            [0, 0],
            [outer_diameter * cos(window_angle), outer_diameter * sin(window_angle)],
            [outer_diameter, 0]
        ]);
        // Inner circle to avoid rod
        circle(d = rod_diameter + 1);  // +1mm clearance around rod
    }
}