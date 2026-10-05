// 
// PARAMETERS (All dimensions in millimeters)
// 

$fn = 100; // Resolution for cylindrical curves

// Base Parameters
base_diameter  = 25;   // Base cylinder diameter (2.5 cm)
base_height    = 15;   // Total height of the base
base_wall      = 2;    // Wall thickness for hollow base (0 for solid)

// Outer Ring Parameters
ring_wall_add  = 3;    // Ring is 3 mm wider than base (outer diameter = base + 2*wall_add)
ring_height    = 12;   // Height of the outer locking ring

// Lock Dimensions & Tolerances
clearance      = 0.25; // Gap for 3D printing tolerance
pin_radius     = 1.25; // Radius of the locking pins (2.5 mm diameter)
channel_depth  = 1.2;  // Depth of the pin channel cut into the base

// Derived Variables
base_radius = base_diameter / 2;
ring_inner_radius = base_radius + clearance;
ring_outer_radius = ring_inner_radius + ring_wall_add;

// 
// DISPLAY / LAYOUT
// 

// Render both parts side-by-side
translate([-base_radius - 5, 0, 0]) base_with_channels();
translate([ring_outer_radius + 5, 0, 0]) ring_with_pins();

// 
// MODULES
// 

module base_with_channels() {
    difference() {
        // Main solid base cylinder
        cylinder(h = base_height, r = base_radius);
        
        // Optional inner hollow cavity
        if (base_wall > 0) {
            translate([0, 0, base_wall])
                cylinder(h = base_height, r = base_radius - base_wall + 0.01);
        }
        
        // Carve two L-shaped bayonet channels (180 degrees apart)
        for (a = [0, 180]) {
            rotate([0, 0, a]) {
                // Vertical entry slot from the top down
                translate([base_radius - channel_depth, 0, base_height - 7])
                    cylinder(h = 8, r = pin_radius + clearance/2);
                
                // Horizontal locking slot
                rotate_extrude(angle = 35) {
                    translate([base_radius - channel_depth, base_height - 7])
                        circle(r = pin_radius + clearance/2);
                }
                
                // Small detent bump at the end of the channel to lock pin in place
                rotate([0, 0, 32])
                    translate([base_radius - channel_depth + 0.3, 0, base_height - 7])
                        sphere(r = pin_radius * 0.7);
            }
        }
    }
}

module ring_with_pins() {
    union() {
        // Hollow outer cylinder ring
        difference() {
            cylinder(h = ring_height, r = ring_outer_radius);
            translate([0, 0, -1])
                cylinder(h = ring_height + 2, r = ring_inner_radius);
        }
        
        // Two internal pins (180 degrees apart) positioned near the top
        for (a = [0, 180]) {
            rotate([0, 0, a]) {
                translate([ring_inner_radius - 0.2, 0, ring_height - 5])
                    rotate([0, 90, 0])
                        cylinder(h = channel_depth + 0.2, r = pin_radius);
            }
        }
    }
}