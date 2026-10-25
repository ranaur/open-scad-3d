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

// Snap
bottom_height = 1.5;         //
snap_size     = 1.5;       // snap fit size [mm]
snap_height   = 0.75;      // snap fit size [mm]
snap_gap      = 1.5;       // snap fit size [mm]
snap_bevel    = 0.74;      // snap fit size [mm]

// Bevel
bevel_diameter = 0.5;  // bevel diameter reduction [mm]

// ── Derived values ──────────────────────────────────────────
inner_diameter  = cylinder_diameter + 2 * gap;
outer_diameter  = inner_diameter + 2 * thickness;
cover_height    = number_of_digits * digit_height + number_of_digits * gap + bottom_height;
rod_height      = cover_height;
window_angle    = 36;  // 360/10 = 36° for 1/10th opening

// ── Model ───────────────────────────────────────────────────
difference() {
    // Main cover body
    union() {
        // Outer cylinder with rounded corners
        translate([0, 0, cover_height+bevel_diameter/2])
        minkowski() {
            cylinder(h = thickness - bevel_diameter, d = outer_diameter - bevel_diameter, center = false);
            sphere(r = bevel_diameter/2);
        }

        // Hollow cylinder
        difference() {
            cylinder(h = cover_height+bevel_diameter, d = outer_diameter, center = false);      
            // Inner hollow space
            translate([0, 0, -0.02])  // slight overlap to avoid z-fighting
                cylinder(h = cover_height + 0.01, d = inner_diameter, center = false);
        }
        
        // Snap clip at rod bottom
        difference() {
            union() {
                // Central rod
                cylinder(h = rod_height, d = rod_diameter, center = false);

                // Snap Lock (rounded top)
                translate([0,0,snap_bevel/2])
                    minkowski() {
                    cylinder(h = snap_height - snap_bevel, d = rod_diameter + snap_size - snap_bevel, center = false); 
                    sphere(r = snap_bevel/2);
                }
                // Bottom
                translate([0,0,snap_bevel/2])
                    cylinder(h = snap_height, d = rod_diameter + snap_size, center = false); 
            }
            union() {
                // Split into two parts with gap
                translate([-snap_gap/2, -(rod_diameter + snap_size + snap_gap)/2, -0.01 - bevel_diameter])
                    cube([snap_gap, rod_diameter + snap_size + snap_gap + 0.02, bevel_diameter + snap_gap + digit_height + 0.02], center = false);
                rotate([0,0,90])
                translate([-snap_gap/2, -(rod_diameter + snap_size + snap_gap)/2, -0.01 - bevel_diameter])
                    cube([snap_gap, rod_diameter + snap_size + snap_gap + 0.02, bevel_diameter + snap_gap + digit_height + 0.02], center = false);
            }
        }
        
    }
    
    // Viewing window (sector centered on cylinder, avoiding rod)
    rotate([0, 0, -window_angle/2])  // center the window
    translate([0, 0, bottom_height])
    linear_extrude(height = number_of_digits * digit_height + number_of_digits * gap)
        difference() {
        // Outer sector with rounded edges
         minkowski() {
            polygon([
                [0, 0],
                [outer_diameter * cos(window_angle), outer_diameter * sin(window_angle)],
                [outer_diameter, 0]
            ]);
            circle(r = bevel_diameter/2);
        }
        // Inner circle to avoid rod
        circle(d = inner_diameter - 0.01); 
    }
}