// ============================================
// Parametric Prism with Screw and Magnet Holes
// ============================================

// --- Dimensions ---
prism_height = 250;  // mm (25cm)
prism_width = 10;    // mm (1cm) W-E
prism_length = 10;   // mm (1cm) N-S

// --- Screw Hole Parameters ---
screw_type = "M3";   // "M2" or "M3"
screw_hole_small = 2;  // mm - pilot hole diameter
screw_hole_cone = true;  // add cone section to screw hole

// Screw dimensions
m2_diameter = 2.2;
m3_diameter = 3.2;
screw_diameter = (screw_type == "M2") ? m2_diameter : m3_diameter;
screw_cone_depth = 5;  // mm

// --- Magnet Hole Parameters ---
magnet_diameter = 5;   // mm
magnet_height = 3;     // mm

// --- N-side Screw Hole Heights ---
n_screw_heights = [25, 75, 125, 175, 225];  // mm

// --- S-side Screw Hole Heights ---
s_screw_heights = [];  // mm

// --- W-side Screw Hole Heights ---
w_screw_heights = [50, 100, 150, 200];  // mm

// --- E-side Screw Hole Heights ---
e_screw_heights = [];  // mm

// --- N-side Magnet Hole Heights ---
n_magnet_heights = [35, 215];  // mm

// --- S-side Magnet Hole Heights ---
s_magnet_heights = [];  // mm

// --- E-side Magnet Hole Heights ---
e_magnet_heights = [];  // mm

// --- Offsets from center ---
screw_offset = 0;    // mm
magnet_offset = 0;   // mm

// --- Clearance for clean rendering ---
clearance = 0.01;  // mm

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
    
    // S-side screw holes
    for (h = s_screw_heights) {
        screw_hole_s(h, screw_offset);
    }
    
    // W-side screw holes
    for (h = w_screw_heights) {
        screw_hole_w(h, screw_offset);
    }
    
    // E-side screw holes
    for (h = e_screw_heights) {
        screw_hole_e(h, screw_offset);
    }
    
    // N-side magnet holes
    for (h = n_magnet_heights) {
        magnet_hole_n(h, magnet_offset);
    }
    
    // S-side magnet holes
    for (h = s_magnet_heights) {
        magnet_hole_s(h, magnet_offset);
    }
    
    // E-side magnet holes
    for (h = e_magnet_heights) {
        magnet_hole_e(h, magnet_offset);
    }
}

// ============================================
// Modules
// ============================================

module prism_with_cut() {
    difference() {
        // Base prism
        cube([prism_length, prism_width, prism_height]);
        
        // 45-degree cut in NW corner on XY axis
        // Cut plane is at 45 degrees in XY, extending through entire height
        // NW corner is at (0, 0), we cut diagonally towards SE
        translate([0, 0, 0])
            rotate([0, 0, 45])
            translate([-prism_length, -prism_width, 0])
            cube([prism_length * 2, prism_width * 2, prism_height + clearance]);
    }
}

module screw_hole_n(height, offset) {
    // N-side hole: enters from N (length = 0) going towards S
    // Centered in W-E direction with offset
    y_pos = prism_width / 2 + offset;
    
    translate([0, y_pos, height])
        rotate([0, -90, 0])
        screw_hole_profile();
}

module screw_hole_w(height, offset) {
    // W-side hole: enters from W (width = 0) going towards E
    // Centered in N-S direction with offset
    x_pos = prism_length / 2 + offset;
    
    translate([x_pos, 0, height])
        rotate([0, -90, 90])
        screw_hole_profile();
}

module screw_hole_e(height, offset) {
    // E-side hole: enters from E (width = prism_width) going towards W
    // Centered in N-S direction with offset
    x_pos = prism_length / 2 + offset;
    
    translate([x_pos, prism_width, height])
        rotate([0, 90, 90])
        screw_hole_profile();
}

module screw_hole_s(height, offset) {
    // S-side hole: enters from S (length = prism_length) going towards N
    // Centered in W-E direction with offset
    y_pos = prism_width / 2 + offset;
    
    translate([prism_length, y_pos, height])
        rotate([0, 90, 0])
        screw_hole_profile();
}

module screw_hole_profile() {
    // Small pilot hole through entire width/length
    cylinder(h=prism_width + prism_length + clearance, d=screw_hole_small + clearance, $fn=32);
    
    // Wider screw shaft section
    shaft_length = (prism_width + prism_length) / 2;
    translate([0, 0, shaft_length - screw_cone_depth])
        cylinder(h=screw_cone_depth + clearance, d1=screw_diameter + clearance, d2=screw_hole_small + clearance, $fn=32);
    
    if (screw_hole_cone) {
        // Cone section for screw head
        translate([0, 0, shaft_length - screw_cone_depth - 5])
            cylinder(h=5 + clearance, d1=screw_diameter * 1.5 + clearance, d2=screw_diameter + clearance, $fn=32);
    }
}

module magnet_hole_n(height, offset) {
    // N-side magnet hole: enters from N going towards S
    // Centered in W-E direction with offset
    y_pos = prism_width / 2 + offset;
    
    translate([0, y_pos, height])
        rotate([0, -90, 0])
        cylinder(h=magnet_height + clearance, d=magnet_diameter + clearance, $fn=32);
}

module magnet_hole_s(height, offset) {
    // S-side magnet hole: enters from S going towards N
    // Centered in W-E direction with offset
    y_pos = prism_width / 2 + offset;
    
    translate([prism_length, y_pos, height])
        rotate([0, 90, 0])
        cylinder(h=magnet_height + clearance, d=magnet_diameter + clearance, $fn=32);
}

module magnet_hole_e(height, offset) {
    // E-side magnet hole: enters from E going towards W
    // Centered in N-S direction with offset
    x_pos = prism_length / 2 + offset;
    
    translate([x_pos, prism_width, height])
        rotate([0, 90, 90])
        cylinder(h=magnet_height + clearance, d=magnet_diameter + clearance, $fn=32);
}
