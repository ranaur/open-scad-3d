// ============================================
// PARAMETRIC GOLD BAR (INGOT)
// ============================================

/* [Bar Dimensions (mm)] */
base_length = 40;
base_width  = 20;
top_length  = 36;
top_width   = 12;
height      = 10;
corner_r    = 4;

/* [Stamp Settings] */
stamp_mode  = "engraved"; // ["engraved", "embossed"]
text_line1  = "FINE GOLD";
text_line2  = "999.9";
text_line3  = "1000g";
font_size   = 2
;
stamp_depth = 1.0;

/* [Quality] */
$fn = 60;

// ============================================
// MODULES
// ============================================

module bar_body() {
    scale_x = top_length / base_length;
    scale_y = top_width / base_width;
    
    linear_extrude(height = height, scale = [scale_x, scale_y]) {
        offset(r = corner_r) {
            square([base_length - 2 * corner_r, base_width - 2 * corner_r], center = true);
        }
    }
}

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