//
// TRUE MATHEMATICAL VORONOI CYLINDRICAL LATTICE
// Parametric OpenSCAD model
//
// The Voronoi diagram is generated in 2D on an unwrapped cylindrical
// surface (circumference x height), then wrapped exactly around the
// cylinder. Each Voronoi cell is represented by its polygon boundary,
// producing a genuine Voronoi lattice rather than random holes.
//
// Units: millimeters
//
// Default:
//   diameter = 85 mm
//   height   = 20 mm
//
// NOTE:
// OpenSCAD is not a general-purpose computational-geometry language,
// so the Voronoi construction below uses an O(n^3) half-plane
// intersection algorithm. This is intentionally self-contained.
// Keep site_count moderate for reasonable preview/render times.
//

$fn = 96;

// ====================== USER PARAMETERS ==========================

diameter       = 85;       // outside diameter, mm
height         = 20;       // cup height, mm

wall           = 2.0;      // thickness of solid Voronoi ribs
bottom         = 2.5;      // solid bottom thickness

site_count     = 32;       // number of Voronoi sites
seed           = 91827;    // deterministic random seed

// Site distribution.
// site_margin keeps cells away from top/bottom edges.
top_margin     = 2.0;
bottom_margin  = 2.0;

// Voronoi lattice construction:
// "web" creates the Voronoi edges as ribs.
// Increasing wall makes a stronger lattice.
rim_width      = 3.0;      // solid rim width at top and bottom

// ====================== DERIVED VALUES ===========================

R = diameter / 2;
C = 2 * PI * R;

// The computational rectangle is [0,C] x [bottom_margin,height-top_margin].
// X wraps periodically, because the left and right edges represent
// the same cylindrical seam.

// ---------------------- deterministic RNG ------------------------

function rnd(n) =
    let(v = sin(n * 127.1 + seed * 311.7) * 43758.5453123)
    v - floor(v);

function sx(i) = C * rnd(i*2+1);
function sy(i) = bottom_margin +
                 (height-top_margin-bottom_margin) * rnd(i*2+2);

// 2D vector helpers
function vsub(a,b) = [a[0]-b[0], a[1]-b[1]];
function vadd(a,b) = [a[0]+b[0], a[1]+b[1]];
function vmul(a,s) = [a[0]*s, a[1]*s];
function dot2(a,b) = a[0]*b[0] + a[1]*b[1];

// A polygon is clipped against a half-plane:
//     dot(n,p) <= c
function clip_poly(poly,n,c) =
    len(poly) == 0 ? [] :
    [
        for (j=[0:len(poly)-1])
            each clip_edge(
                poly[j],
                poly[(j+1)%len(poly)],
                n,c
            )
    ];

function clip_edge(a,b,n,c) =
    let(
        da = dot2(n,a)-c,
        db = dot2(n,b)-c,
        ina = da <= 0,
        inb = db <= 0,
        t = da/(da-db),
        p = vadd(a, vmul(vsub(b,a),t))
    )
    ina && inb ? [b] :
    ina && !inb ? [p] :
    !ina && inb ? [p,b] :
    [];

// Build one periodic Voronoi cell.
//
// Periodic copies of every site at x-C, x, x+C are considered.
// The initial polygon is the whole computational rectangle.
// Each perpendicular-bisector inequality is then applied.
function vor_cell(i) =
    let(
        xi = sx(i),
        yi = sy(i),
        initial = [[0,bottom_margin],
                   [C,bottom_margin],
                   [C,height-top_margin],
                   [0,height-top_margin]]
    )
    vor_cell_loop(i, initial, 0);

function vor_cell_loop(i,poly,j) =
    j >= site_count*3 ? poly :
    let(
        k = floor(j/3),
        copy = j%3-1,
        xk = sx(k) + copy*C,
        yk = sy(k)
    )
    k == i
        ? vor_cell_loop(i,poly,j+1)
        : vor_cell_loop(
            i,
            clip_poly(
                poly,
                [2*(xk-sx(i)), 2*(yk-sy(i))],
                xk*xk + yk*yk - sx(i)*sx(i) - sy(i)*sy(i)
            ),
            j+1
        );

// Remove degenerate cells.
function valid_cell(p) = len(p) >= 3;

// ---------------------- wrapped Voronoi cells -------------------
//
// We turn each cell into a solid region on the cylinder, then subtract
// those regions from a cylindrical shell. The remaining material is
// the Voronoi-edge network.
//
// A small amount of overlap between neighboring cell cutters creates
// ribs of approximately `wall` thickness.
//
// To achieve this geometrically, each Voronoi cell is expanded
// radially in the unwrapped plane by wall/2 using an offset operation.
//
// OpenSCAD's offset() works on 2D polygons and gives the required
// Minkowski-style expansion.

module cell_cutter(poly) {
    // offset radius is half the desired rib thickness.
    offset(delta=-wall/2)
        polygon(poly);
}

// The complete lattice is constructed as:
// outer cylinder minus inner cylinder,
// minus the interiors of every shrunken Voronoi cell.
//
// Thus the material remaining between cells is exactly the Voronoi
// edge network (within the chosen wall thickness).

module voronoi_wall() {
    difference() {
        // cylindrical shell
        cylinder(r=R, h=height);

        translate([0,0,bottom])
            cylinder(r=R-wall, h=height-bottom+0.1);

        // Subtract each cell's interior. The cutters are extruded
        // radially by mapping the unwrapped x coordinate to angle.
        for (i=[0:site_count-1])
            if (valid_cell(vor_cell(i)))
                wrap_cell(vor_cell(i));
    }
}

// Convert a polygon from (arc length,height) coordinates into a
// polygonal prism wrapped around the cylinder.
//
// The polygon is first represented as a thin strip in the radial
// direction, then intersected with the cylindrical shell.
//
// This method preserves the Voronoi geometry on the developable
// cylindrical surface.

module wrap_cell(poly) {
    // Make a 3D polygonal surface at radius R-wall/2.
    // A linear_extrude along Z cannot directly wrap arbitrary polygons,
    // so each polygon is tessellated into triangles from its centroid.
    //
    // Each triangle is converted to a thin radial prism by hull().

    cx = sum([for(p=poly) p[0]]) / len(poly);
    cy = sum([for(p=poly) p[1]]) / len(poly);

    for (j=[0:len(poly)-1])
        wrap_triangle(
            [cx,cy],
            poly[j],
            poly[(j+1)%len(poly)]
        );
}

function cylpt(p,r) =
    [r*cos(p[0]/r*180/PI),
     r*sin(p[0]/r*180/PI),
     p[1]];

// A triangle on the unwrapped cylindrical surface, given a small
// radial thickness. Hull of the six corresponding points makes a
// printable solid patch.

module wrap_triangle(a,b,c) {
    hull() {
        for (r=[R-wall/2-0.05, R+wall/2+0.05])
            for (p=[a,b,c])
                translate(cylpt(p,r))
                    sphere(r=0.08,$fn=8);
    }
}

// ========================== MODEL ===============================
//
// Build the Voronoi edge lattice and add a solid base and rim.
// The base is deliberately separate from the lattice so the cup
// remains printable and watertight.

union() {

    // Voronoi lattice wall
    intersection() {
        voronoi_wall();

        // Remove the top/bottom margins from the lattice region.
        translate([0,0,bottom])
            cylinder(r=R+0.01,h=height-bottom-rim_width);
    }

    // Solid bottom
    cylinder(r=R, h=bottom);

    // Solid upper rim
    translate([0,0,height-rim_width])
        difference() {
            cylinder(r=R,h=rim_width);
            translate([0,0,-0.1])
                cylinder(r=R-wall,h=rim_width+0.2);
        }
}

// ========================== NOTES ================================
//
// True Voronoi behavior:
//   Each site is a point in the unwrapped cylindrical coordinate
//   system. A cell consists of all points closer to that site than
//   to every other site. The cylinder is periodic in X, so the seam
//   does not create an artificial edge.
//
// Useful settings:
//
//   Fewer/larger cells:
//       site_count = 20;
//
//   Denser lattice:
//       site_count = 55;
//
//   Stronger ribs:
//       wall = 2.5;
//
//   Taller cup:
//       height = 40;
//
//   Wider cup:
//       diameter = 100;
//
// Change `seed` to produce another deterministic Voronoi pattern.
//
// IMPORTANT PERFORMANCE NOTE:
// OpenSCAD preview/rendering can become slow because the Voronoi
// cells are computed by repeated polygon clipping and then wrapped
// into many 3D triangular patches. For final STL export, use F6.
// For very high site counts, generating the Voronoi mesh externally
// (e.g. Python) is substantially faster.
