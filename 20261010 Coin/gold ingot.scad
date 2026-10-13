// ============================================
// PARAMETRIC GOLD BAR (INGOT) - ROUNDED EDGES
// ============================================

/* [Bar Dimensions (mm)] */
base_length = 30;
base_width  = 10;
top_length  = base_length;
top_width   = base_width;
height      = 3;
edge_radius = 2; // Controls the roundness of all edges (top, bottom, and sides)

/* [Stamp Settings] */
//stamp_mode  = "engraved"; // ["engraved", "embossed"]
stamp_mode  = "embossed"; // ["engraved", "embossed"]

// Text stamping (optional)
use_text    = false;       // Enable/disable text stamping
text_line1  = "FINE GOLD";
text_line2  = "999.9";
text_line3  = "1000g";
font_size   = 7;
stamp_depth = 10.0;

// Bitmap stamping (optional)
use_bitmap  = true;      // Enable/disable bitmap stamping
bitmap_file = "stamp.png"; // Image file path (PNG, JPG, etc.)
bitmap_width = 640;       // Image width in pixels
bitmap_height = 320;      // Image height in pixels
bitmap_scale = 0.5;       // Scale factor relative to top surface (0.0-1.0)
// Height scale: 255 (max greyscale) maps to face_depth
bitmap_extrude_depth = stamp_depth / 511;

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

// Generates the text object (optional)
module text_stamp() {
    if (use_text) {
        linear_extrude(height = stamp_depth + 0.05) {
            translate([0, 10, 0])
                text(text_line1, size = font_size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
            translate([0, 0, 0])
                text(text_line2, size = font_size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
            translate([0, -10, 0])
                text(text_line3, size = font_size, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
        }
    }
}

// Generates the bitmap stamp (optional)
module bitmap_stamp() {
    if (use_bitmap) {
        // Calculate the stamp area based on bitmap_scale
        stamp_l = top_length * bitmap_scale;
        stamp_w = top_width * bitmap_scale;
        
        // Scale factor to fit image onto the stamp area
        scale_xy = stamp_l / bitmap_width;
        
        scale([scale_xy, scale_xy, bitmap_extrude_depth])
            surface(
                file = bitmap_file,
                center = true
            );
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
        translate([0, 0, height])
            bitmap_stamp();
    }
} else { // embossed
    difference() {
        bar_body();
//        translate([0, 0, height - 0.01])
//            text_stamp();
        translate([0, 0, height + bitmap_extrude_depth + 0.01])
            rotate([180,0,0])
            mirror([1,0,0])
            bitmap_stamp();
    }
}