// ============================================================
//  Cylinder with Digits 0-9 Engraved on the Border
//  Diameter: 25 mm  |  Height: 3 mm
// ============================================================

// ── Parameters (edit here) ──────────────────────────────────
diameter   = 25;    // outer diameter [mm]
cyl_height = 3;     // total cylinder height [mm]
text_depth = 0.8;   // engraving depth [mm]
text_size  = 2.4;   // digit font size [mm]
font_name  = "Liberation Mono:style=Bold";
$fn        = 120;   // curve resolution (higher = smoother)

// ── Derived values ──────────────────────────────────────────
radius     = diameter / 2;
num_digits = 10;
angle_step = 360 / num_digits;   // 36° between each digit

// ── Model ───────────────────────────────────────────────────
difference() {

    // Base cylinder
    cylinder(h = cyl_height, d = diameter, center = false);

    // Engrave digits 0-9 evenly around the cylindrical surface
    for (i = [0 : num_digits - 1]) {
        rotate([0, 0, i * angle_step])                  // step 36° around Z axis
        translate([0, radius + 0.01, cyl_height / 2])   // place at outer surface
        rotate([90, 0, 0])                               // lay text flat on cylinder wall
        linear_extrude(height = text_depth + 0.02)       // cut inward
        mirror([1, 0, 0])                                // correct mirroring for readability
        rotate([0, 0, 90])
        text(
            str(i),
            size   = text_size,
            font   = font_name,
            halign = "center",
            valign = "center"
        );
    }
}