    // ============================================================
//  Cylinder with Digits 0-9 Engraved on the Border
//  Diameter: 25 mm  |  Height: 3 mm  |  Digits rotated 90°
//  Central hole: 4 mm diameter
// ============================================================

// ── Parameters (edit here) ──────────────────────────────────
diameter    = 25;   // outer diameter [mm]
cyl_height  = 3;    // total cylinder height [mm]
text_depth  = 0.8;  // engraving depth [mm]
text_size   = 2.4;  // digit font size [mm]
hole_diam   = 4;    // central hole diameter [mm]
//font_name   = "Liberation Mono:style=Bold";
font_name   = "Franklin Gothic:style=Bold";
$fn         = 120;  // curve resolution (higher = smoother)
underline   = 0;    // 1 = show underline, 0 = hide underline
// ── Derived values ──────────────────────────────────────────
radius     = diameter / 2;
num_digits = 10;
angle_step = 360 / num_digits;   // 36° between each digit

// ── Model ───────────────────────────────────────────────────
difference() {

    // Base cylinder
    cylinder(h = cyl_height, d = diameter, center = false);

    // Central through-hole
    cylinder(h = cyl_height + 0.02, d = hole_diam, center = false, $fn = 60);

    // Engrave digits 0-9 evenly around the cylindrical surface
    for (i = [0 : num_digits - 1]) {
        rotate([0, 0, i * angle_step])                  // step 36° around Z axis
        translate([0, radius + 0.01, cyl_height / 2])   // place at outer surface
        rotate([90, 0, 0])                               // lay text flat on cylinder wall
        linear_extrude(height = text_depth + 0.02)       // cut inward
        mirror([1, 0, 0])                                // correct mirroring for readability
        rotate([0, 0, 90])                               // rotate digits 90°
        text(
            str(i),
            size   = text_size,
            font   = font_name,
            halign = "center",
            valign = "center"
        );
        
        // Add underline for digits 6 and 9
        if (underline && (i == 6 || i == 9)) {
            rotate([0, 0, i * angle_step])                  // step 36° around Z axis
            translate([0, radius + 0.01, cyl_height / 2])   // place at outer surface
            rotate([90, 0, 0])                               // lay text flat on cylinder wall
            linear_extrude(height = text_depth + 0.02)       // cut inward
            mirror([1, 0, 0])                                // correct mirroring for readability
            rotate([0, 0, 90])                               // rotate digits 90°
            translate([0, -text_size * 0.7, 0])              // position underline below digit
            square([text_size * 0.8, text_size * 0.15], center = true); // underline bar
        }
    }
}