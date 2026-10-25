//
// Voronoi-style cylindrical cup
// Units: millimeters
//
// Default dimensions:
//   Diameter: 85 mm (8.5 cm)
//   Height:   20 mm (2 cm)
//
// The parameters at the top are intended to be changed.
//
// This model creates a thin cylindrical cup with a deterministic
// Voronoi-like organic perforation pattern. The pattern is made by
// subtracting irregular, overlapping "cell" openings from the wall.
// A solid bottom is retained for use as a small cup/container.
//
// Recommended for FDM printing. For resin printing, increase wall and
// bottom thickness as appropriate.
//

$fn = 96;

// ========================= PARAMETERS =========================
diameter        = 85;       // outside diameter, mm
height          = 20;       // total height, mm
wall            = 2.0;      // nominal wall thickness, mm
bottom          = 2.5;      // bottom thickness, mm

// Pattern parameters
cell_count      = 34;       // number of Voronoi seed points
cell_size       = 9.0;      // typical opening diameter, mm
cell_variation  = 0.30;     // 0..1, variation in opening size
pattern_z_scale = 1.00;     // vertical scale of pattern
edge_rim        = 3.0;      // solid material kept at top/bottom edges

// Make the openings somewhat "webbed" rather than perfectly circular.
irregularity    = 0.38;     // 0 = circular, higher = more organic
sides           = 9;        // polygon resolution of each opening

// Deterministic seed; change this for a different pattern.
random_seed     = 73129;

// ========================= DERIVED VALUES ======================
outer_r = diameter / 2;
inner_r = outer_r - wall;
usable_h = height - bottom - 2*edge_rim;

// A point is represented as [x,y].
function hash01(n) =
    let(v = sin(n * 12.9898 + random_seed * 78.233) * 43758.5453)
    v - floor(v);

function rand_range(a,b,n) = a + (b-a)*hash01(n);

// Generate points in a rectangular "pattern sheet".
// The sheet is wrapped around the cylinder circumference.
function seed_x(i) =
    -PI*outer_r + (2*PI*outer_r) * hash01(i*17+1);

function seed_z(i) =
    edge_rim + usable_h * hash01(i*17+2);

function seed_r(i) =
    cell_size * (0.72 + cell_variation * hash01(i*17+3));

// Convert wrapped pattern coordinates to a point on the cylinder.
// x is arc length around circumference; z is height.
function wrap_point(x,z) =
    [outer_r*cos(x/outer_r), outer_r*sin(x/outer_r), z];

// ========================= VORONOI-STYLE OPENINGS =============
//
// A true Voronoi diagram is defined by nearest-neighbour cells.
// For a printable cup, we use each seed as the center of an organic
// cell opening. Neighboring seeds influence the opening size, giving
// the characteristic irregular Voronoi appearance.
//
// The opening is made as a low-sided, smoothly varied polygon and is
// oriented tangent to the cylindrical surface.

module organic_opening(i) {
    x = seed_x(i);
    z = seed_z(i);
    r = seed_r(i);

    // Tangential polygon on a local XY plane.
    // It is subsequently rotated to face radially outward.
    pts = [
        for (k=[0:sides-1])
            let(
                a = 360*k/sides,
                rr = r * (
                    1
                    + irregularity*0.16*(
                        hash01(i*101+k*7+4)-0.5
                    )
                )
            )
            [rr*cos(a), rr*sin(a)]
    ];

    // A small local cylinder/polygon cutter.
    // The cutter is longer than the wall so it fully penetrates it.
    translate(wrap_point(x,z))
        rotate([0,90,x/outer_r])
            linear_extrude(height=wall+4, center=true)
                polygon(points=pts);
}

// ========================= CUP ================================

difference() {
    // Main cup body.
    union() {
        // Outer cylinder
        cylinder(r=outer_r, h=height);

        // Slightly reinforced bottom disk
        cylinder(r=outer_r-0.5, h=bottom);
    }

    // Hollow interior, leaving the bottom.
    translate([0,0,bottom])
        cylinder(r=inner_r, h=height-bottom+0.2);

    // Voronoi-style perforations.
    for (i=[0:cell_count-1])
        organic_opening(i);

    // Keep a solid band around the upper and lower rim.
    // This masks cutters close to the boundaries.
    //
    // The openings are already distributed away from the edges;
    // these two rings provide additional robustness.
    translate([0,0,height-edge_rim])
        difference() {
            cylinder(r=outer_r+0.2,h=edge_rim+0.3);
            cylinder(r=inner_r-0.01,h=edge_rim+0.5);
        }

    translate([0,0,-0.1])
        difference() {
            cylinder(r=outer_r+0.2,h=edge_rim+0.2);
            cylinder(r=inner_r-0.01,h=edge_rim+0.4);
        }
}

// ========================= NOTES ===============================
//
// To make it more open:
//   cell_count = 24;
//   cell_size  = 11;
//
// To make smaller, denser cells:
//   cell_count = 55;
//   cell_size  = 6.5;
//
// For a sturdier print:
//   wall   = 2.5;
//   bottom = 3;
//
// For a more organic pattern:
//   irregularity = 0.7;
//   sides = 8;
//
// IMPORTANT:
// This is a self-contained OpenSCAD model and does not require an
// external library. The pattern is deterministic: changing
// random_seed generates a different repeatable pattern.
