include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <BOSL2/masks.scad>

// --- CUSTOMIZATION PARAMETERS ---
$fn = 64;                 // Smoothness of circles
box_outer_d = 25;         // Outer diameter of the box (miniature)
box_height = 30;          // Total internal depth/height of the base
wall_thickness = 2;       // Side wall thickness

thread_d = 21;            // Outer diameter of the thread (must clear wall thickness)
thread_pitch = 1.5;       // Pitch in mm (1.5mm is great for miniature resin boxes)
thread_h = 6;             // Height of the threaded section

// GRIP / KNURLING SETTINGS
ridge_count = 24;         // Number of vertical grooves around the perimeter
ridge_depth = 0.6;        // How deep the grip grooves cut into the walls

// RESIN PRINTER CLEARANCE SETTING
// $slop adds radial clearance to internal (female) threads automatically.
// For resin printing, a total clearance of 0.2mm to 0.4mm works best.
// BOSL2 scales internal threads by (4 * $slop), so $slop = 0.075 gives a ~0.3mm total gap.
$slop = 0.075;            

// --- RENDERING CONTROL ---
// Toggle between viewing the "base", "lid", or "both"
render_mode = "both"; 

if (render_mode == "base" || render_mode == "both") {
    color("LightBlue") box_base();
}

if (render_mode == "lid" || render_mode == "both") {
    // Lift the lid up in "both" view to inspect the threads
    translate([0, 0, (render_mode == "both") ? box_height + 15 : 0]) 
        color("Tomato") box_lid();
}

// --- MODULES ---

module box_base() {
    difference() {
        // Main outer body
        cylinder(d=box_outer_d, h=box_height, anchor=BOTTOM);
        
        // Vertical grip ridges cut into the outer wall
        grip_ridges(h=box_height);
        
        // Internal storage cavity
        translate([0, 0, wall_thickness])
            cylinder(d=box_outer_d - (wall_thickness * 2), h=box_height, anchor=BOTTOM);
        
        // Internal Thread (Female) cut out of the top rim
        translate([0, 0, box_height - thread_h])
            threaded_rod(d=thread_d, pitch=thread_pitch, l=thread_h+0.1, internal=true, anchor=BOTTOM);
    }
}

module box_lid() {
    lid_cap_h = wall_thickness + 1;
    
    difference() {
        // Lid Cap
        cylinder(d=box_outer_d, h=lid_cap_h, anchor=BOTTOM);
        
        // Vertical grip ridges cut into the lid cap outer wall
        grip_ridges(h=lid_cap_h);
    }
    
    // Male Thread protruding down from the lid cap
    translate([0, 0, lid_cap_h])
        threaded_rod(d=thread_d, pitch=thread_pitch, l=thread_h, internal=false, anchor=BOTTOM);
}

// Helper module to generate even spacing for grip cuts
module grip_ridges(h) {
    for (i = [0 : ridge_count - 1]) {
        rotate([0, 0, i * (360 / ridge_count)])
            translate([box_outer_d / 2, 0, -0.1])
                // Triangular shape cutting into the side wall
                cylinder(d1=ridge_depth*2, d2=ridge_depth*2, h=h+0.2, $fn=3, anchor=BOTTOM);
    }
}
