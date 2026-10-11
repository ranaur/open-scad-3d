// ============================================
// PARAMETRIC GOLD BAR (INGOT) - ROUNDED EDGES
// ============================================

/* [Bar Dimensions (mm)] */
base_length = 80;
base_width  = 40;
top_length  = base_length * 0.9;
top_width   = base_width * 0.8;
height      = 20;
edge_radius = 2; // Controls the roundness of all edges (top, bottom, and sides)

/* [Stamp Settings] */
stamp_mode  = "engraved"; // ["engraved", "embossed"]
text_line1  = "FINE GOLD";
text_line2  = "999.9";
text_line3  = "1000g";
font_size   = 7;
stamp_depth = 1.0;

/* [Quality] */
$fn = 60; // Increase for smoother curves (takes longer to render)

/* [Edge Rounding Control] */
// Apply a smooth round transition to the top edges?
round_top = true; 
// Apply a smooth round transition to the bottom edges? 
// (Tip: false is usually better for 3D printing so it sits flat on the bed)
round_bottom = false; 

// ============================================
// MODULES
// ============================================

// Helper module to place either spheres or flat discs at the 4 corners
module place_corners(l, w, z, r, is_rounded) {
    for (x = [1, -1]) {
        for (y = [1, -1]) {
            translate([x * (l/2 - r), y * (w/2 - r), z]) {
                if (is_rounded) {
                    sphere(r = r);
                } else {
                    // A microscopic cylinder creates a perfectly flat, sharp top/bottom edge
                    // while maintaining the rounded vertical side-corners.
                    cylinder(r = r, h = 0.01, center = true);
                }
            }
        }
    }
}

// Generates the main bar based on rounding preferences
module bar_body() {
    hull() {
        // Bottom corners
        // If rounded, shift up by edge_radius. If flat, sit exactly at z=0.
        z_bottom = round_bottom ? edge_radius : 0;
        place_corners(base_length, base_width, z_bottom, edge_radius, round_bottom);
        
        // Top corners
        // If rounded, shift down by edge_radius. If flat, sit exactly at z=height.
        z_top = round_top ? height - edge_radius : height;
        place_corners(top_length, top_width, z_top, edge_radius, round_top);
    }
}

// Generates the text object
module text_stamp() {
    linear_extrude(height = stamp_depth + 0.05) {
        translate([0, 10, 0])
            text(text_line1, size = font_size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
        translate([0, 0, 0])
            text(text_line2, size = font_size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
        translate([0, -10, 0])
            text(text_line3, size = font_size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
    }
}

// ============================================
// ASSEMBLY
// ============================================

if (stamp_mode == "engraved") {
    difference() {
        bar_body();
        translate([0, 0, height - stamp_depth])
            text_stamp();
    }
} else {
    union() {
        bar_body();
        translate([0, 0, height - 0.01])
            text_stamp();
    }
}