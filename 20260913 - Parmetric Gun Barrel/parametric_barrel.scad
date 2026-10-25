// =====================================================
// Parametric Perforated Barrel (hollow cylinder)
// Open top, solid bottom with holes, holes around the
// cylindrical wall in a configurable grid pattern.
// =====================================================

// ----- Overall dimensions -----
outer_diameter   = 70;   // mm, outside diameter of the barrel
wall_thickness   = 3;    // mm, thickness of the tube wall
height           = 25;   // mm, total height of the barrel
bottom_thickness = 3;    // mm, thickness of the solid base

// ----- Side wall holes (grid pattern, wrapped around the tube) -----
side_hole_diameter = 4;   // mm
side_hole_rows     = 4;   // number of rows stacked vertically
side_hole_cols     = 48;  // number of holes per row around the circumference
side_hole_margin_top    = 4.5; // mm, no holes within this distance of the top
side_hole_margin_bottom = 4.5; // mm, no holes within this distance of the base

// ----- Bottom holes (radial pattern) -----
bottom_hole_diameter = 3;  // mm
bottom_hole_count    = 5;   // holes per ring
bottom_hole_rings    = 8;   // number of concentric rings
bottom_hole_ring_start = 3; // mm, radius of innermost ring
bottom_hole_ring_step  = 4; // mm, spacing between rings

// ----- Resolution -----
$fn = 48;

// =====================================================
// Modules
// =====================================================

module outer_shell() {
    cylinder(h = height, d = outer_diameter);
}

module inner_cavity() {
    // Hollow interior, starts above the solid bottom, open at the top
    translate([0, 0, bottom_thickness])
        cylinder(h = height - bottom_thickness + 1, d = outer_diameter - 2 * wall_thickness);
}

module side_holes() {
    inner_radius_mid = (outer_diameter / 2); // punch clean through the wall
    usable_height = height - side_hole_margin_top - side_hole_margin_bottom;
    row_spacing = (side_hole_rows > 1) ? usable_height / (side_hole_rows - 1) : 0;
    angle_step = 360 / side_hole_cols;

    for (r = [0 : side_hole_rows - 1]) {
        z = side_hole_margin_bottom + r * row_spacing;
        for (c = [0 : side_hole_cols - 1]) {
            angle = c * angle_step + (r % 2 == 0 ? 0 : angle_step / 2); // stagger alternate rows
            rotate([0, 0, angle])
                translate([inner_radius_mid, 0, z])
                    rotate([0, 90, 0])
                        cylinder(h = wall_thickness * 3, d = side_hole_diameter, center = true);
        }
    }
}

module bottom_holes() {
    for (ring = [0 : bottom_hole_rings - 1]) {
        radius = bottom_hole_ring_start + ring * bottom_hole_ring_step;
        bottom_holes = floor(bottom_hole_count * (radius) / (bottom_hole_ring_start));
        angle_step = 360 / bottom_holes;
        for (c = [0 : bottom_holes - 1]) {
            angle = c * angle_step + (ring % 2 == 0 ? 0 : angle_step / 2);
            rotate([0, 0, angle])
                translate([radius, 0, -1])
                    cylinder(h = bottom_thickness + 2, d = bottom_hole_diameter);
        }
    }
}

module barrel() {
    difference() {
        outer_shell();
        inner_cavity();
        side_holes();
        bottom_holes();
    }
}

// =====================================================
// Render
// =====================================================
barrel();
