include <BOSL/shapes.scad>
use <BOSL/shapes.scad>

// The next long line was generated from a Python script and represents the arrangement of 3-dot columns on the drum
// Alpha + space + basic modifiers
DOT_COLUMNS = [[0,0,0],[0,0,0],[0,0,1],[1,1,1],[0,1,0],[1,0,0],[0,0,0],[1,0,1],[0,1,1],[1,0,0],[1,1,0],[1,0,0],[1,0,0],[0,1,0],[1,1,0],[1,1,0],[0,0,0],[1,0,1],[0,1,0],[1,1,1],[0,0,0],[0,1,1],[1,1,0],[0,1,0],[1,0,1],[1,0,1],[0,0,1],[1,0,1],[0,0,0],[1,0,1],[1,1,0],[1,0,1],[1,0,0],[1,0,1],[1,1,1],[0,0,1],[1,1,1],[1,0,0],[1,1,1],[1,1,0]];
// All 64 possible Braille cells
//DOT_COLUMNS = [[0,0,0],[0,0,1],[1,0,1],[0,1,0],[0,1,0],[1,1,0],[1,1,0],[0,0,1],[0,1,1],[0,0,1],[1,1,1],[1,1,1],[1,0,0],[1,1,0],[0,1,0],[1,0,1],[1,1,0],[1,0,1],[1,0,1],[1,0,0],[0,1,1],[1,1,0],[0,1,1],[0,0,0],[0,1,0],[0,0,1],[0,0,1],[1,1,0],[1,0,0],[1,1,1],[0,1,1],[0,1,0],[1,1,1],[0,1,0],[0,1,1],[0,1,1],[1,0,1],[1,1,1],[0,0,1],[0,1,0],[1,0,0],[0,0,1],[0,0,0],[1,1,1],[0,0,0],[1,1,0],[1,1,1],[1,1,0],[0,0,0],[1,0,0],[1,0,1],[0,0,1],[1,0,0],[1,0,0],[0,1,0],[0,0,0],[0,1,1],[1,1,1],[1,0,1],[0,1,1],[1,0,0],[0,0,0],[1,0,1],[0,0,0],[0,0,0]];

// Braille dimensions
DOT_HEIGHT = 0.6;  // Official is .48 but that's hard to feel
DOT_DIAM = 1.44;
DOT_SPACING = 2.34; // Center to center

// DEGREES_TO_POPULATE sepecifies how much of the circle's arc can be "addressed" by the servo.
// I recommend adding a buffer zone so that the disc doesn't have to be perfectly aligned to the servo's movement
// region (e.g. for a 180 degree servo a 170 degree DEGREES_TO_POPULATE lets yo fix a 10 degree difference in
// software calibration rather than in hardware.
DEGREES_TO_POPULATE = 178;

// Drum stuff
BLANK_SPACE_AT_END = 2; // Blank space to leave before first col and after last col on wheel (set to 0 for 360 deg)
V_PADDING = 1.5;
TUBE_WALL = 2;

// Window/cover stuff
COVER_DRUM_GAP = .2; // Extra gap between end of dots and start of cover with window in it
COVER_H_PADDING = 10; // MM to the left and right of window
COVER_V_PADDING = 2; // MM above and below the window TODO
COVER_WALL = .8; // TODO test this out

// TODO we probably won't have a cover foot like this, it's just for testing manually
COVER_FOOT_HEIGHT = 1; 
COVER_FOOT_RADIUS = 2;

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
    
    degrees_per_dot = DEGREES_TO_POPULATE / len(dot_columns);
    
    echo("Computed diameter", radius_of_whole_circle * 2, "mm");
    
    cell_height = 2*DOT_SPACING + DOT_DIAM;
    drum_height = cell_height + 2*V_PADDING;
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
                tube(h=drum_height, or=radius_of_whole_circle, wall=TUBE_WALL);
            };
            arc_mask();
        }

        // Add the dots to it
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

    module cover() {
        // Window for a single cell
        cover_inner_radius = radius_of_whole_circle + DOT_HEIGHT + COVER_DRUM_GAP;
        cover_arc_perimeter = 2 * DOT_SPACING + 2 * COVER_H_PADDING;
        // Note I just used the inner radius here because it's easier, so the actual window padding will be a bit larger.
        cover_arc_angle = cover_arc_perimeter / (2 * PI * cover_inner_radius) * 360;
     
        difference() {
            zrot(-cover_arc_angle / 2) // To center on x axis
                intersection() {
                    union() {
                        // Cover drum segment
                        tube(h=drum_height + COVER_V_PADDING * 2, ir=cover_inner_radius, wall=COVER_WALL);;
                        // Add a foot so we can print this and it'll stand up
                        tube(or=cover_inner_radius, wall=COVER_FOOT_RADIUS, h=COVER_FOOT_HEIGHT);
                    }
                    pie_slice( // Limit it to only a portion of the arc
                        h=100, // Arbitrarily large
                        r=cover_inner_radius + 100, // 100 is arbitrary,
                        ang=cover_arc_angle
                    );
                }
        
            // Cut out a window
            up(V_PADDING + COVER_V_PADDING)
                zrot(-degrees_per_dot) // To center on x-axis
                    pie_slice(
                            h=cell_height,
                            r=100, // arbitrary
                            ang=2*degrees_per_dot
                    );
        }
        

    }
    
    right(30) // So the models ungroup
    down(COVER_V_PADDING)
        cover();
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
    yscale(2*DOT_HEIGHT / DOT_DIAM)
        sphere(d=DOT_DIAM);
}