// ============================================================
//  Bank of Brimstone – Gold Bullion Coin
//  Obverse: large weight numeral (parametric) with unit below.
//  Reverse: bank name, flame emblem, fineness and year.
//  Defaults follow a 1 troy oz bullion coin (32.7 x 2.9 mm).
// ============================================================

/* [Denomination] */
// Weight in ounces – shown large on the obverse (1, 2, 5, 0.5, ...)
weight_value  = 1;
// Override the numeral text (leave empty to use weight_value)
weight_text_override = "";
// Unit printed right under the numeral
weight_unit   = "";
// Small caption under the unit
weight_caption = "TROY OUNCE";

/* [Legends] */
bank_name     = "BANK OF BRIMSTONE";
fineness_text = "99.99 FINE GOLD";
year_text     = "1883";
motto_text    = "EX SULPHURE FACTUM";
//motto_text    = upper("Facilis descensus Averno");
//motto_text    = "LAPIS NIGER ET AVRVM";

/* [Coin geometry (mm)] */
diameter    = 32.7;
thickness   = 2.9;
// Width of the raised rim
rim_width   = 1.4;
// Height of the rim above the field
rim_height  = 0.4;
// Height of raised lettering/emblem (usually <= rim_height)
relief      = 0.4;
// Raised or engraved (sunken) design
relief_style = "engraved"; // [raised, engraved]    
// medal = reverse upright when flipped about the vertical axis; coin = about the horizontal axis
alignment = "coin"; // [medal, coin]
// Number of beads on the inner border (0 = none)
beads       = 72;
bead_d      = 0.7;

/* [Reeded edge] */
// Number of grooves around the edge (0 = smooth edge)
reeds       = 120;
reed_depth  = 0.25;
reed_width  = 0.45;

/* [Typography] */
font_bold   = "Liberation Sans:style=Bold";
font_serif  = "Liberation Serif:style=Bold";
// Maximum height of the numeral (auto-shrinks for long numbers)
numeral_max_size = 14;
unit_size    = 4;
caption_size = 1.9;
legend_size  = 2.4;
year_size    = 2.6;
// Emblem height on the reverse
emblem_size  = 13;

/* [Output] */
// coin = complete coin; *_half = split at mid-plane for face-up printing
part = "coin"; // [coin, obverse_half, reverse_half]
// Curve resolution
$fn = 180;

/* [Hidden] */
eps        = 0.01;
radius     = diameter / 2;
field_r    = radius - rim_width;          // radius of the flat field
field_z    = thickness - rim_height;      // z of the field plane (top side)
bead_r     = field_r - bead_d;            // bead ring radius
inner_r    = bead_r - bead_d * 1.5;       // usable radius inside the beads
weight_text = weight_text_override == "" ? str(weight_value) : weight_text_override;
arc_gap    = 0.6;                         // clearance between arc text and beads
// radius available inside the upper legend arc
legend_in_r = inner_r - arc_gap - legend_size;
// bold sans digits are ~0.72 em wide and ~1 em tall; fit the numeral
// inside the chord left free by the upper legend
numeral_size = min(numeral_max_size,
                   (legend_in_r * 1.7) / (len(weight_text) * 0.72));
numeral_h    = numeral_size;
// numeral + unit block centred in the band between the two arcs
band_top     = legend_in_r - 1.2;
band_bot     = -(inner_r - arc_gap - caption_size - 0.8);
block_h      = numeral_h + 0.6 + unit_size * 0.9;
numeral_top  = min(band_top, (band_top + band_bot) / 2 + block_h / 2);
numeral_cy   = numeral_top - numeral_h / 2;
unit_cy      = numeral_top - numeral_h - 0.6 - unit_size * 0.45;

// ── Text helpers ────────────────────────────────────────────

// Text following an arc of radius r (baseline). top=true reads left to right
// along the upper arc with glyph tops toward the rim; top=false reads left to
// right along the lower arc with glyph tops toward the centre.
module arc_text(txt, r, size, font, center_ang = 90, top = true, spacing = 0.85) {
    n    = len(txt);
    // degrees per character, measured at the middle of the glyph height
    mid_r = top ? r + size / 2 : r - size / 2;
    step = (size * spacing) / mid_r * 180 / PI;
    span = step * (n - 1);
    for (i = [0 : n - 1]) {
        a = top ? center_ang + span / 2 - i * step
                : center_ang - span / 2 + i * step;
        rotate(a) translate([r, 0]) rotate(top ? -90 : 90)
            text(txt[i], size = size, font = font, halign = "center", valign = "baseline");
    }
}

module centered_text(txt, size, font) {
    text(txt, size = size, font = font, halign = "center", valign = "center");
}

// ── Emblem: brimstone flame (2D, centred, 20 units tall) ────
module flame2d(h) {
    scale(h / 20) translate([0, -10]) {
        difference() {
            union() {
                // main body
                hull() {
                    translate([0, 5.5])   circle(5.5, $fn = 96);
                    translate([0.8, 19.2]) circle(0.8, $fn = 48);
                }
                // left tongue
                hull() {
                    translate([-2.5, 5])   circle(3.5, $fn = 64);
                    translate([-6.2, 12.5]) circle(0.6, $fn = 32);
                }
                // right tongue
                hull() {
                    translate([2.5, 4.5])  circle(3.5, $fn = 64);
                    translate([6.4, 10])   circle(0.6, $fn = 32);
                }
            }
            // hollow core
            hull() {
                translate([0, 4.5])   circle(3.2, $fn = 96);
                translate([0.5, 12.5]) circle(0.6, $fn = 48);
            }
        }
        // inner tongue of fire
        hull() {
            translate([0, 3.6])   circle(1.9, $fn = 64);
            translate([-0.4, 9.2]) circle(0.4, $fn = 32);
        }
    }
}

// ── Face designs (2D, z = 0 field plane, viewed from +Z) ────
module obverse2d() {
    // big numeral just under the upper legend, unit right below it
    translate([0, numeral_cy]) centered_text(weight_text, numeral_size, font_bold);
    translate([0, unit_cy])    centered_text(weight_unit, unit_size, font_bold);
    arc_text(weight_caption, inner_r - arc_gap, caption_size, font_serif, center_ang = -90, top = false);
    arc_text(bank_name, legend_in_r, legend_size, font_serif, center_ang = 90, top = true);
}

module reverse2d() {
    translate([0, 1.6]) flame2d(emblem_size);
    translate([0, 1.6 - emblem_size / 2 - 0.8 - year_size * 0.45])
        centered_text(year_text, year_size, font_bold);
    arc_text(motto_text, legend_in_r, legend_size, font_serif, center_ang = 90, top = true);
    arc_text(fineness_text, inner_r - arc_gap, legend_size, font_serif, center_ang = -90, top = false);
}

module bead_ring2d() {
    if (beads > 0)
        for (i = [0 : beads - 1])
            rotate(i * 360 / beads) translate([bead_r, 0]) circle(d = bead_d, $fn = 24);
}

// Extrude a face design upward from the field plane (z = 0)
module face_relief() {
    linear_extrude(height = relief) children();
}

module obverse_relief() { face_relief() { obverse2d(); bead_ring2d(); } }
module reverse_relief() { face_relief() { reverse2d(); bead_ring2d(); } }

// Turn a top-face design (z >= 0) into a bottom-face design (z <= 0)
// that reads correctly when the coin is flipped over.
module flip() {
    if (alignment == "coin") rotate([180, 0, 0]) children();
    else                     rotate([0, 180, 0]) children();
}

// ── Coin body ───────────────────────────────────────────────
module blank() {
    difference() {
        cylinder(h = thickness, d = diameter);
        // recess both fields inside the rim
        translate([0, 0, field_z]) cylinder(h = rim_height + eps, r = field_r);
        translate([0, 0, -eps])    cylinder(h = rim_height + eps, r = field_r);
        // reeded edge
        if (reeds > 0)
            for (i = [0 : reeds - 1])
                rotate(i * 360 / reeds)
                    translate([radius, 0, thickness / 2])
                        cube([reed_depth * 2, reed_width, thickness + 2 * eps], center = true);
    }
}

module coin() {
    if (relief_style == "raised") {
        union() {
            blank();
            translate([0, 0, field_z - eps]) obverse_relief();
            translate([0, 0, rim_height + eps]) flip() reverse_relief();
        }
    } else {
        difference() {
            blank();
            translate([0, 0, 0.01 + field_z - relief]) obverse_relief();
            translate([0, 0, -0.01 + rim_height + relief]) flip() reverse_relief();
        }
    }
}

// One half of the coin, cut at the mid-plane: flat face on the bed, design up
module half(reverse_up = false) {
    intersection() {
        if (reverse_up) translate([0, 0, thickness / 2]) flip() coin();
        else            translate([0, 0, -thickness / 2]) coin();
        cylinder(h = thickness, d = diameter + 2);
    }
}

// ── Output ──────────────────────────────────────────────────
if (part == "coin")              coin();
else if (part == "obverse_half") half(false);
else if (part == "reverse_half") half(true);
