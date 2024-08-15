include <BOSL/shapes.scad>
use <BOSL/shapes.scad>

// The next long line was generated from a Python script and represents the arrangement of 3-dot columns on the drum
// All possible cells
//DOT_COLUMNS = [[0,0,0],[1,0,0],[0,1,1],[0,0,1],[0,0,0],[1,1,1],[0,0,1],[1,0,1],[0,1,1],[1,1,1],[1,0,1],[1,0,0],[1,1,0],[1,1,1],[1,1,0],[0,0,0],[0,0,1],[1,1,0],[1,0,1],[1,0,1],[0,0,0],[0,1,1],[1,0,1],[1,1,0],[0,1,0],[0,1,0],[1,0,0],[1,0,1],[0,0,1],[1,1,1],[1,0,0],[0,0,0],[1,1,0],[1,1,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,1,0],[0,0,1],[0,0,1],[0,1,1],[0,1,1],[1,0,0],[0,0,1],[0,1,0],[1,1,0],[0,1,1],[1,1,0],[1,0,0],[1,0,0],[1,1,1],[1,1,1],[0,1,1],[0,1,0],[0,1,1],[0,0,0],[0,0,0],[1,0,1],[1,1,1],[0,0,0],[0,1,0],[1,1,1],[0,1,0],[0,0,0]];
// Alpha + basic punctuation
DOT_COLUMNS = [[1,1,1],[0,0,1],[1,1,1],[0,0,0],[0,0,0],[0,1,1],[0,0,1],[0,0,1],[1,1,1],[0,1,0],[0,1,1],[1,1,0],[0,0,0],[0,1,0],[0,0,0],[1,0,1],[0,1,0],[1,1,0],[1,0,0],[0,1,0],[1,0,0],[1,0,0],[1,1,0],[1,1,0],[0,1,0],[1,1,1],[1,0,0],[0,0,0],[1,0,1],[1,0,1],[1,1,1],[1,1,0],[1,0,1],[1,1,0],[1,0,1],[1,0,0],[1,0,1],[0,1,1],[1,0,0],[1,1,1],[0,0,1],[1,0,1],[0,0,0],[1,0,1],[1,1,1]];


// Numeric
//DOT_COLUMNS = [[0,0,0],[0,0,0],[0,1,0],[1,0,0],[1,0,0],[1,1,0],[1,0,0],[0,1,0],[1,1,0],[1,1,0],[0,1,0],[0,1,1],[0,0,1],[0,0,1],[1,1,0],[0,0,0]];

// Braille dimensions
DOT_HEIGHT = .9;  // Official is .48 but that's hard to feel, so I used the max height from California sign standards
DOT_DIAM = 1.44;
DOT_SPACING = 2.34; // Center to centerde

// DEGREES_TO_POPULATE sepecifies how much of the circle's arc can be "addressed" by the servo.
// I recommend adding a buffer zone so that the disc doesn't have to be perfectly aligned to the servo's movement
// region (e.g. for a 180 degree servo a 170 degree DEGREES_TO_POPULATE lets yo fix a 10 degree difference in
// software calibration rather than in hardware.
DEGREES_TO_POPULATE = 170;

// Drum stuff
BLANK_SPACE_AT_END = 2; // Blank space to leave before first col and after last col on wheel (set to 0 for 360 deg)
V_PADDING = 1.5;
TUBE_WALL = 2;

// Servo stuff
SERVO_RECT_HOLE_WIDTH = 23.6;
SERVO_RECT_HOLE_DEPTH = 13.0;
SERVO_HOLE_TO_SCREW_HOLE_CENTER = 2.2;
SERVO_SCREW_HOLE_WIDTH = 3.0;
SERVO_ROTOR_OFF_CENTER = 5.4;
SERVO_ROTOR_TOP_TO_SCREW_PLATE_BOTTOM = 11.9 + 2.4;

// Window/cover stuff
COVER_RADIUS = 15;
COVER_WALL_THICKNESS = .6;
COVER_WINDOW_WIDTH = DOT_SPACING * 2.7;
COVER_WINDOW_HEIGHT = DOT_SPACING * 5;
COVER_WALL_ABOVE_WINDOW = 4;
COVER_WALL_BESIDE_WINDOW = 4; // This is not permiter length, it's cartesian
COVER_DRUM_GAP = 0; // Extra gap between end of dots and start of cover with window in it
COVER_BRACKET_THICKNESS = 2;
COVER_FOOT_DEPTH = 5;
COVER_FOOT_THICKNESS = SERVO_ROTOR_TOP_TO_SCREW_PLATE_BOTTOM - 2;
COVER_BRACKET_LEN_PAST_SERVO_CENTER = 3;
COVER_BRACKET_LEN_PAST_SERVO_SIDES = 5;
COVER_SIDE_PILLAR_SIZE = 1.5;
COVER_SIDE_PILLAR_BACK = 1.1;  // TODO make this not need trial and error

// Floor
DRUM_FLOOR_THICKNESS = 1;
DRUM_HUB_RADIUS = 12;

// Backlash spring stuff
USE_BACKLASH_SPRING = true;
BACKLASH_SPRING_HORN_LENGTH = 15;
BACKLASH_SPRING_HORN_WIDTH = 6;

// Utility constants
ARBITRARY = 1000; // Arbitrary size for various hole dimensions
SMALL_DELTA = .01;

 // Set global params for smoother shapes
$fa = 1;
$fs = .2;

// Computed constants
perimeter_needed_for_dots = len(DOT_COLUMNS) * DOT_SPACING;
perimeter_of_whole_circle = perimeter_needed_for_dots * 360 / DEGREES_TO_POPULATE;
radius_of_whole_circle = perimeter_of_whole_circle / PI / 2;
cell_height = 2*DOT_SPACING + DOT_DIAM;
drum_height = cell_height + 2*V_PADDING;
cover_width = COVER_WINDOW_WIDTH + 2 * COVER_WALL_BESIDE_WINDOW;

module braille_drum() {
    degrees_per_dot = DEGREES_TO_POPULATE / len(DOT_COLUMNS);
    
    echo("Computed diameter", radius_of_whole_circle * 2, "mm");
    echo("Degrees per dot", degrees_per_dot);
    
    module braille_arc() {
        // This is a shape that can be intersected with the support drum to make it less than 360 degrees
        blank_space_angle = BLANK_SPACE_AT_END / perimeter_of_whole_circle * 360;
        arc_degrees = DEGREES_TO_POPULATE + 2*blank_space_angle;
        module arc_mask() {
            zrot(-90 - blank_space_angle) 
                pie_slice(
                    h=100, // Arbitrarily large
                    r=radius_of_whole_circle,
                    ang=arc_degrees
            );
        }
        echo("Arc degrees:", arc_degrees); // TODO debug
        
        // This rotation corrects the angle so it's symmetical about the x axis
        zrot(blank_space_angle + (180 - arc_degrees)/2) {
            // Create the base shape with the arc supporting the dots
            intersection() {
                union() {
                    // Draw a base
                    zcyl(r=radius_of_whole_circle, l=DRUM_FLOOR_THICKNESS, center=false);
                    // Draw a side
                    tube(h=drum_height, or=radius_of_whole_circle, wall=TUBE_WALL);
                };
                arc_mask();
            }

            // Add the dots to it
            for (i = [0: len(DOT_COLUMNS) - 1]) {
                up(V_PADDING)
                    zrot(i * degrees_per_dot + degrees_per_dot/2)
                        forward(radius_of_whole_circle)
                            vertical_plane_3dots(DOT_COLUMNS[i]);
            }
        }
    }
        
    // Add a central hub

    difference() {
        union() {
            braille_arc();
            
            // Central smaller disc
            zcyl(r=DRUM_HUB_RADIUS, h=DRUM_FLOOR_THICKNESS, center=false);
            
            if (USE_BACKLASH_SPRING) {
                color("blue")
               cuboid([
                    BACKLASH_SPRING_HORN_LENGTH + DRUM_HUB_RADIUS,
                    BACKLASH_SPRING_HORN_WIDTH,
                    DRUM_FLOOR_THICKNESS
                ], align=V_UP + V_LEFT);
            }
        }
        
        // TODO parameterize
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
    yscale(2*DOT_HEIGHT / DOT_DIAM)
        sphere(d=DOT_DIAM);
}

//braille_drum(DOT_COLUMNS);

//
// Bracket
//

module servo_attachment_carveout() {    
    cube([SERVO_RECT_HOLE_WIDTH, SERVO_RECT_HOLE_DEPTH, ARBITRARY], center=true);
    
    left(SERVO_RECT_HOLE_WIDTH / 2 + SERVO_HOLE_TO_SCREW_HOLE_CENTER)
        zcyl(h=ARBITRARY, d=SERVO_SCREW_HOLE_WIDTH);

    right(SERVO_RECT_HOLE_WIDTH / 2 + SERVO_HOLE_TO_SCREW_HOLE_CENTER)
        zcyl(h=ARBITRARY, d=SERVO_SCREW_HOLE_WIDTH);
}

// Result lies flat on x-y plane with center of window at the origin
module cover() {
    wall_above_drum = COVER_WALL_ABOVE_WINDOW - (drum_height - COVER_WINDOW_HEIGHT) / 2;
    cover_height = SERVO_ROTOR_TOP_TO_SCREW_PLATE_BOTTOM + drum_height + wall_above_drum + COVER_BRACKET_THICKNESS;
    
    back(COVER_RADIUS)
        up(cover_height / 2)
            intersection() {
                    difference() {
                        union() {
                            // Faceplate
                            zcyl(r=COVER_RADIUS, h=cover_height);
                            
                            // Small foot
                            down(cover_height / 2 - COVER_FOOT_THICKNESS/2)
                                forward(COVER_RADIUS - COVER_FOOT_DEPTH)
                                    fwdcube([cover_width, COVER_FOOT_DEPTH, COVER_FOOT_THICKNESS]);
                            
                            // Side pillars
                            forward(COVER_RADIUS - COVER_SIDE_PILLAR_BACK)
                                down(cover_height / 2)
                                    union() {
                                        left(cover_width/2)
                                            upcube([COVER_SIDE_PILLAR_SIZE, COVER_SIDE_PILLAR_SIZE, cover_height]);
                                        right(cover_width/2)
                                            upcube([COVER_SIDE_PILLAR_SIZE, COVER_SIDE_PILLAR_SIZE, cover_height]);
                                }
                        }
                       zcyl(r=COVER_RADIUS-COVER_WALL_THICKNESS, h=ARBITRARY);
                        
                        up(cover_height/2 - COVER_WALL_ABOVE_WINDOW - COVER_WINDOW_HEIGHT)
                            upcube([COVER_WINDOW_WIDTH, ARBITRARY, COVER_WINDOW_HEIGHT]);
                    }
                     fwdcube([cover_width, ARBITRARY, ARBITRARY]);
                };
}

module cover_bracket() {
    right(SERVO_ROTOR_OFF_CENTER) cover();
    bracket_length = radius_of_whole_circle + COVER_BRACKET_LEN_PAST_SERVO_CENTER + COVER_DRUM_GAP;
    bracket_width = SERVO_RECT_HOLE_WIDTH +2 * COVER_BRACKET_LEN_PAST_SERVO_SIDES;
    echo("Cover bracket length", bracket_length);
    difference() {
        union() {
            cuboid([bracket_width, bracket_length, COVER_BRACKET_THICKNESS], align=V_UP + V_FWD);
            
            if (USE_BACKLASH_SPRING) {
                   forward(radius_of_whole_circle + COVER_DRUM_GAP) {
                        // Extra bracket floor
                        cuboid([bracket_width, DRUM_HUB_RADIUS, COVER_BRACKET_THICKNESS], align=V_UP + V_FWD);
                       
                       // Stick for attaching spring
                       color("blue")
                       cuboid([
                            BACKLASH_SPRING_HORN_WIDTH,
                            BACKLASH_SPRING_HORN_LENGTH + DRUM_HUB_RADIUS,
                            COVER_BRACKET_THICKNESS
                        ], align=V_UP + V_FWD);
                   }
            }
        }
        forward(radius_of_whole_circle + COVER_DRUM_GAP) servo_attachment_carveout();
    }
    
}

forward(radius_of_whole_circle + COVER_DRUM_GAP) braille_drum();
//cover_bracket();