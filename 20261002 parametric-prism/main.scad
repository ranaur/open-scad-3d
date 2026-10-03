// ============================================
// Parametric Prism with Screw and Magnet Holes
// ============================================

margin = 0.1;

// --- Dimensions ---
prism_height = 250;  // mm (25cm)
prism_width = 20;    // mm (1cm) W-E
prism_length = 10;   // mm (1cm) N-S
prism_cut_width = 8; // mm (1cm) N-W

// --- Screw Hole Parameters ---
screw_type = "M3";   // "M2" or "M3"
screw_hole_small = 2;  // mm - pilot hole diameter
screw_hole_cone = true;  // add cone section to screw hole
screw_hole_head = 5;

// Screw dimensions
m2_diameter = 2.2;
m3_diameter = 3.2;
screw_diameter = (screw_type == "M2") ? m2_diameter : m3_diameter;
screw_cone_depth = 2;  // mm

// --- Magnet Hole Parameters ---
magnet_diameter = 5;   // mm
magnet_height = 3;     // mm

// --- N-side Screw Hole Heights ---
n_screw_heights = [25, 75, 125, 175, 225];  // mm

// --- W-side Screw Hole Heights ---
w_screw_heights = [50, 100, 150, 200];  // mm

// --- N-side Magnet Hole Heights ---
n_magnet_heights = [35, 215];  // mm

// --- Offsets from center ---
screw_offset = 0;    // mm
magnet_offset = 0;   // mm

// ============================================
// Main Assembly
// ============================================

difference() {
    // Base prism with 45-degree cut
    prism_with_cut();
    
    // N-side screw holes
    for (h = n_screw_heights) {
        screw_hole_n(h, screw_offset);
    }
    
    // W-side screw holes
    for (h = w_screw_heights) {
        screw_hole_w(h, screw_offset);
    }
    
    // N-side magnet holes
    for (h = n_magnet_heights) {
        magnet_hole_n(h, magnet_offset);
    }
}

// ============================================
// Modules
// ============================================

module prism_with_cut() {
        difference() {
            // Base prism (center at 0,0, prism_height/2)
            cube([prism_length, prism_width, prism_height]);
            
            // 45-degree cut in NW corner (top)
            // NW corner is at (0, 0, prism_height)
            // Cut diagonally from NW towards SE
            rotate([0, 0, 45])
            translate([-prism_cut_width/2, -prism_cut_width/2, -margin])
                cube([prism_cut_width, prism_cut_width, prism_height +margin * 2]);
    }
}

module screw_hole_n(height, offset) {
    // N-side hole: enters from N (length = 0) going towards S
    // Centered in W-E direction with offset
    y_pos = prism_width / 2 + offset;
    
    translate([-margin, y_pos, height])
        rotate([0, 90, 0])
        screw_hole_profile();
}

module screw_hole_w(height, offset) {
    // W-side hole: enters from W (width = 0) going towards E
    // Centered in N-S direction with offset
    x_pos = prism_length / 2 + offset;
    
    translate([x_pos, -margin, height])
        rotate([0, 90, 90])
        screw_hole_profile();
}

module screw_hole_profile() {
    union() {
        // Small pilot hole through entire width/length
        cylinder(h=prism_width + prism_length, d=screw_hole_small, $fn=32);
        
        // Wider screw shaft section
        shaft_length = (prism_width + prism_length) / 2;
        translate([0, 0, screw_hole_head])
            cylinder(h=screw_cone_depth, d1=screw_diameter, d2=screw_hole_small, $fn=32);
        
        if (screw_hole_cone) {
            // Cone section for screw head
            translate([0, 0, 0])
                cylinder(h=screw_hole_head, d1=screw_diameter, d2=screw_diameter, $fn=32);
        }
    };
}

module magnet_hole_n(height, offset) {
    // N-side magnet hole: enters from N going towards S
    // Centered in W-E direction with offset
    y_pos = prism_width / 2 + offset;
    
    translate([-margin, y_pos, height])
        rotate([0, 90, 0])
        cylinder(h=magnet_height, d=magnet_diameter, $fn=32);
}
