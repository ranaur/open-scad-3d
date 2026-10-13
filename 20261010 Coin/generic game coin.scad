// Generic Game Coin Generator
// Features: Custom image bitmaps for heads/tails, edge options (rim, reeds, or text)
// Units: mm

$fn = 128;

// ============================================
// COIN PARAMETERS
// ============================================

// Basic dimensions
coin_diameter = 25;
coin_height = 3;
face_depth = 3;  // Maximum depth of bitmap relief

// Edge configuration: "rim", "reeds", or "text"
edge_type = "text";  // Options: "rim", "reeds", "text"

// Rim configuration (used when edge_type = "rim")
rim_width = 1.5;
rim_height = 0.3;

// Reeds configuration (used when edge_type = "reeds")
num_reeds = 120;
reed_depth = 0.3;
reed_width = 0.5;

// Edge text configuration (used when edge_type = "text")
edge_text = "GAME COIN";
edge_text_size = 2;
edge_text_depth = 0.3;
edge_text_vertical = false;  // true for vertical text around edge

// ============================================
// IMAGE BITMAP PARAMETERS
// ============================================

// Image file paths (PNG, JPG, or other formats supported by OpenSCAD)
// Images should be at least 512x512 pixels for good resolution
heads_image = "heads.png";  // Replace with your image file path
tails_image = "tails.png";  // Replace with your image file path

// Image dimensions (in pixels) - adjust to match your actual images
image_width = 512;
image_height = 512;

// ============================================
// MODULES
// ============================================

// Main coin module
module game_coin() {
    difference() {
        union() {
            // Base coin body
            cylinder(d = coin_diameter, h = coin_height);
            
            // Add edge detail based on type
            if (edge_type == "rim") {
                add_rim();
            } else if (edge_type == "reeds") {
                add_reeds();
            }
            // Text edge is handled in difference()
            // Add faces (heads and tails) using image bitmaps
            add_heads_face();
            add_tails_face();
        }
        
        // Add edge text if specified
        if (edge_type == "text") {
            add_edge_text();
        }
        
    }
}

// Add raised rim to edge
module add_rim() {
    translate([0, 0, coin_height - rim_height])
        difference() {
            cylinder(d = coin_diameter, h = rim_height);
            cylinder(d = coin_diameter - rim_width * 2, h = rim_height + 0.01);
        }
}

// Add reeds (grooves) to edge
module add_reeds() {
    reed_angle = 360 / num_reeds;
    for (i = [0:num_reeds-1]) {
        rotate([0, 0, i * reed_angle])
            translate([coin_diameter / 2 - reed_depth, 0, 0])
                cube([reed_depth * 2, reed_width, coin_height], center = true);
    }
}

// Add text around the edge
module add_edge_text() {
    text_radius = coin_diameter / 2 - edge_text_depth / 2;
    text_length = len(edge_text);
    angle_per_char = 360 / text_length;
    
    for (i = [0:text_length - 1]) {
        rotate([90, 0, i * angle_per_char])
            translate([0, text_radius, coin_height / 2])
                rotate([0, 0, 90])
                    linear_extrude(height = edge_text_depth + 0.1, center = true)
                        text(
                            edge_text[i],
                            size = edge_text_size,
                            halign = "center",
                            valign = "center",
                            font = "Arial:style=Bold"
                        );
    }
}

// Add image-based face relief
module image_face(image_file, is_top = true) {
    // Calculate the inscribed square size
    // For a circle of diameter D, the inscribed square has side D
    square_size = coin_diameter;
    
    // Scale factor to fit image onto the inscribed square
    scale_xy = square_size / image_width;
    
    // Height scale: 255 (max greyscale) maps to face_depth
    scale_z = face_depth / 255;
    
    z_offset = is_top ? coin_height : 0;
    z_direction = is_top ? 1 : -1;
    
    translate([0, 0, z_offset])
        scale([scale_xy, scale_xy, scale_z])
            // Rotate 180 degrees for bottom face so it appears correctly
            rotate([is_top ? 0 : 180, 0, 0])
                //translate([0, 0, is_top ? 0 : -255])
                    intersection() {
                        // Load the image as a surface
                        surface(
                            file = image_file,
                            center = true,
                            convexity = 255
                        );
                        
                        // Mask to circular coin shape
                        translate([0, 0, -128])
                            cylinder(
                                d = image_width,
                                h = 255,
                                center = false
                            );
                    }
}

// Add heads face (top)
module add_heads_face() {
    color("lightgray")
        image_face(heads_image, is_top = true);
}

// Add tails face (bottom)
module add_tails_face() {
    color("lightgray")
        image_face(tails_image, is_top = false);
}

// ============================================
// RENDER
// ============================================

game_coin();
