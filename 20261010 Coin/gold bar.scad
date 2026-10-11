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

// ============================================
// MODULES
// ============================================

// Helper module to place spheres at the 4 corners of a rectangle
module place_corners(l, w, z, r) {
    translate([ (l/2 - r),  (w/2 - r), z]) sphere(r=r);
    translate([ (l/2 - r), -(w/2 - r), z]) sphere(r=r);
    translate([-(l/2 - r),  (w/2 - r), z]) sphere(r=r);
    translate([-(l/2 - r), -(w/2 - r), z]) sphere(r=r);
}

// Generates the main bar with fully rounded top/bottom/side edges
module bar_body() {
    hull() {
        // 4 spheres for the bottom corners
        place_corners(base_length, base_width, edge_radius, edge_radius);
        
        // 4 spheres for the top corners
        place_corners(top_length, top_width, height - edge_radius, edge_radius);
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
        // Cut the text into the top surface
        translate([0, 0, height - stamp_depth])
            text_stamp();
    }
} else {
    union() {
        bar_body();
        // Add the text on top of the surface
        translate([0, 0, height - 0.01])
            text_stamp();
    }
}