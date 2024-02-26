include <BOSL/shapes.scad>
use <BOSL/shapes.scad>

// The next long line was generated from a Python script and represents the arrangement of 3-dot columns on the drum
// Alpha + space + basic modifiers
DOT_COLUMNS = [[0,0,0],[0,0,0],[0,0,1],[1,1,1],[0,1,0],[1,0,0],[0,0,0],[1,0,1],[0,1,1],[1,0,0],[1,1,0],[1,0,0],[1,0,0],[0,1,0],[1,1,0],[1,1,0],[0,0,0],[1,0,1],[0,1,0],[1,1,1],[0,0,0],[0,1,1],[1,1,0],[0,1,0],[1,0,1],[1,0,1],[0,0,1],[1,0,1],[0,0,0],[1,0,1],[1,1,0],[1,0,1],[1,0,0],[1,0,1],[1,1,1],[0,0,1],[1,1,1],[1,0,0],[1,1,1],[1,1,0]];
// All 64 possible Braille cells
//DOT_COLUMNS = [[0,0,0],[0,0,1],[1,0,1],[0,1,0],[0,1,0],[1,1,0],[1,1,0],[0,0,1],[0,1,1],[0,0,1],[1,1,1],[1,1,1],[1,0,0],[1,1,0],[0,1,0],[1,0,1],[1,1,0],[1,0,1],[1,0,1],[1,0,0],[0,1,1],[1,1,0],[0,1,1],[0,0,0],[0,1,0],[0,0,1],[0,0,1],[1,1,0],[1,0,0],[1,1,1],[0,1,1],[0,1,0],[1,1,1],[0,1,0],[0,1,1],[0,1,1],[1,0,1],[1,1,1],[0,0,1],[0,1,0],[1,0,0],[0,0,1],[0,0,0],[1,1,1],[0,0,0],[1,1,0],[1,1,1],[1,1,0],[0,0,0],[1,0,0],[1,0,1],[0,0,1],[1,0,0],[1,0,0],[0,1,0],[0,0,0],[0,1,1],[1,1,1],[1,0,1],[0,1,1],[1,0,0],[0,0,0],[1,0,1],[0,0,0],[0,0,0]];

// Braille dimensions
DOT_HEIGHT = 0.48;
DOT_DIAM = 1.44;
DOT_SPACING = 2.34; // Center to center
BLANK_SPACE_AT_END = 2; // Blank space to leave before first col and after last col on wheel (set to 0 for 360 deg)
V_PADDING = 1.5;

// DEGREES_TO_POPULATE sepecifies how much of the circle's arc can be "addressed" by the servo.
// I recommend adding a buffer zone so that the disc doesn't have to be perfectly aligned to the servo's movement
// region (e.g. for a 180 degree servo a 170 degree DEGREES_TO_POPULATE lets yo fix a 10 degree difference in
// software calibration rather than in hardware.
DEGREES_TO_POPULATE = 178;
// TODO buffer



 // Set global params for smoother shapes
$fa = 1;
$fs = .2;

/*
braille_drum([
    [0, 1, 1],
    [1, 1, 0],
    [0, 0, 0],
    [1, 1, 1,],
    [0, 1, 0],
     [0, 0, 0],
    [1, 0, 1],
    [0, 1, 0],
     [0, 0, 0],
    [1, 1, 1],
    [1, 0, 1],
     [0, 0, 0],
)] */

braille_drum(DOT_COLUMNS);


module braille_drum(dot_columns) {
    perimeter_needed_for_dots = len(dot_columns) * DOT_SPACING;
    perimeter_of_whole_circle = perimeter_needed_for_dots * 360 / DEGREES_TO_POPULATE;
    radius_of_whole_circle = perimeter_of_whole_circle / PI / 2;
    
    echo("Computed diameter", radius_of_whole_circle * 2, "mm");
    
    module braille_arc() {
        // This is a shape that can be intersected with the support drum to make it less than 360 degrees
        module arc_mask() {
             blank_space_angle = BLANK_SPACE_AT_END / perimeter_of_whole_circle * 360;
            
            zrot(-90 - blank_space_angle) 
                pie_slice(
                    h=100, // Arbitrarily large
                    r=radius_of_whole_circle,
                    ang=DEGREES_TO_POPULATE + 2*blank_space_angle
            );
        }
        
        // Create the base shape with the arc supporting the dots
        intersection() {
            union() {
                // Draw a base
                zcyl(r=radius_of_whole_circle, l=1, center=false);
                // Draw a side
                // TODO vertical padding
                tube(h=2*DOT_SPACING + DOT_DIAM + 2*V_PADDING, or=radius_of_whole_circle, wall=1);
            };
            arc_mask();
        }

        // Add the dots to it
        degrees_per_dot = DEGREES_TO_POPULATE / len(dot_columns);
        for (i = [0: len(dot_columns) - 1]) {
            up(V_PADDING)
                zrot(i * degrees_per_dot)
                    forward(radius_of_whole_circle)
                        vertical_plane_3dots(dot_columns[i]);
        }
    }
        
    // Add a central hub
    // TODO parameterize
    difference() {
        union() {
            braille_arc();
            zcyl(r=12, h=1, center=false); // Central smaller disc
        }
        zcyl(d=2.6, h=100); // For now just a screw hole, TODO make this a proper mount
    };

}

// Produces a veritcal braille cell back against the XZ plane, botton against the XY plane, left on the YZ plane
// six_dots are bools corresponding to the typical braille positions, column-major order
// i.e.. [[1, 2, 3], [4, 5, 6]]
// Example:
// vertical_plane_braille_cell([[true, false, true], [true, true, false]]); // N
module vertical_plane_braille_cell(six_dots) {
    for (col = [0, 1]) {
        left(DOT_SPACING / 2) right(col * DOT_SPACING) // TODO
            vertical_plane_3dots(six_dots[col]);
    }
}

// Produces a vertical column of braille dots back against the XZ plane, bottom against the XY plane, centered on Z
// three_dots corresponds to the column top-first, e.g. [1, 2, 3] for typical Braille dot numbers
module vertical_plane_3dots(three_dots) {   
   for (row = [2, 1, 0]) {
       if (three_dots[row]) {
            right(DOT_DIAM/2)
            up(DOT_DIAM/2) up((2 - row) * DOT_SPACING)
                vertical_plane_braille_dot();
       }
   }
}

// A braille dot facing forward , base on the XZ plane, centered on (x = 0, z = 0)
module vertical_plane_braille_dot() {
    // Note I'm not using the compute power to cut off the back here.
    yscale(DOT_HEIGHT / DOT_DIAM)
        sphere(d=DOT_DIAM);
}