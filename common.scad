include <BOSL/constants.scad>
use <BOSL/transforms.scad>
use <BOSL/shapes.scad>

// The next long line was generated from a Python script and represents the arrangement of 3-dot columns on the rotor wall
// All possible cells
//DOT_COLUMNS = [[0,0,0],[1,0,0],[0,1,1],[0,0,1],[0,0,0],[1,1,1],[0,0,1],[1,0,1],[0,1,1],[1,1,1],[1,0,1],[1,0,0],[1,1,0],[1,1,1],[1,1,0],[0,0,0],[0,0,1],[1,1,0],[1,0,1],[1,0,1],[0,0,0],[0,1,1],[1,0,1],[1,1,0],[0,1,0],[0,1,0],[1,0,0],[1,0,1],[0,0,1],[1,1,1],[1,0,0],[0,0,0],[1,1,0],[1,1,0],[0,0,1],[1,0,0],[0,1,0],[1,0,1],[0,1,0],[0,0,1],[0,0,1],[0,1,1],[0,1,1],[1,0,0],[0,0,1],[0,1,0],[1,1,0],[0,1,1],[1,1,0],[1,0,0],[1,0,0],[1,1,1],[1,1,1],[0,1,1],[0,1,0],[0,1,1],[0,0,0],[0,0,0],[1,0,1],[1,1,1],[0,0,0],[0,1,0],[1,1,1],[0,1,0],[0,0,0]];
// Alpha + basic punctuation
//DOT_COLUMNS = [[0,0,0],[0,0,1],[1,1,1],[0,0,0],[0,0,0],[0,1,1],[0,0,1],[0,0,1],[1,1,1],[0,1,0],[0,1,1],[1,1,0],[0,0,0],[0,1,0],[0,0,0],[1,0,1],[0,1,0],[1,1,0],[1,0,0],[0,1,0],[1,0,0],[1,0,0],[1,1,0],[1,1,0],[0,1,0],[1,1,1],[1,0,0],[0,0,0],[1,0,1],[1,0,1],[1,1,1],[1,1,0],[1,0,1],[1,1,0],[1,0,1],[1,0,0],[1,0,1],[0,1,1],[1,0,0],[1,1,1],[0,0,1],[1,0,1],[0,0,0],[1,0,1],[0,0,1]];

// Numeric
DOT_COLUMNS = [[0,0,0],[0,0,0],[1,1,0],[0,1,0],[1,0,0],[1,0,0],[0,1,0],[0,1,1],[1,0,0],[1,1,0],[1,1,0],[0,0,0],[0,1,0],[1,1,0],[1,0,0],[0,0,0],[0,0,1],[0,0,1]];

// All dots filled, variable size for debugging
//DOT_COLUMNS =  [for(i=[1:5])([1,1,1])];

// Braille dimensions
DOT_HEIGHT = 1.2;  // Official is .48 but that's hard to feel, so I used the max height from California sign standards
DOT_DIAM = 1.44;
DOT_SPACING = 2.34; // Center to center

// DEGREES_TO_POPULATE specifies how much of the circle's arc can be "addressed" by the servo.
// I recommend adding a buffer zone so that the disc doesn't have to be perfectly aligned to the servo's movement
// region (e.g. for a 180 degree servo a 170 degree DEGREES_TO_POPULATE lets yo fix a 10 degree difference in
// software calibration rather than in hardware.
DEGREES_TO_POPULATE = 170;

// Rotor stuff
BLANK_SPACE_AT_END = 2; // Blank space to leave before first col and after last col on wheel (set to 0 for 360 deg)
V_PADDING = 1.5;
ROTOR_WALL_THICKNESS = 2;

// Backlash spring stuff
USE_BACKLASH_SPRING = true; // True is recommended unless your servo has very little play or your rotor radius is small
BACKLASH_SPRING_HORN_LENGTH = 15;
BACKLASH_SPRING_HORN_WIDTH = 6;

// Servo stuff
SERVO_RECT_HOLE_WIDTH = 23.6;
SERVO_RECT_HOLE_DEPTH = 13.0;
SERVO_HOLE_TO_SCREW_HOLE_CENTER = 2.2;
SERVO_MOUNTING_SCREW_HOLE_DIAM = 3.0;
SERVO_ROTOR_OFF_CENTER = 5.4;
SERVO_ROTOR_TOP_TO_SCREW_PLATE_BOTTOM = 11.9 + 2.4;
SERVO_HUB_SCREW_HOLE_DIAM = 2.8; // Should be a little on the small side so screw holds the rotor snugly
SERVO_SPLINE_TEETH = 20;
SERVO_SPLINE_TOOTH_DEPTH = .3; // TODO check
SERVO_SPLINE_OUTER_DIAMETER = 4.9;
SERVO_SPLINE_CLEARANCE = .2; // Adjust this if your print doesn't fit
SERVO_SPLINE_ATTACHMENT_HEIGHT = 3;
SERVO_SPLINE_ATTACHMENT_WALL = 1.6; // Not exact, make a bit larger than it needs

USE_SERVO_SPLINE = USE_BACKLASH_SPRING; // Recommended if you use the backlash spring; makes centering a little more difficult

// Window/cover stuff
COVER_RADIUS = 15;
COVER_WALL_THICKNESS = .6;
COVER_WINDOW_WIDTH = DOT_SPACING * 2.7;
COVER_WINDOW_HEIGHT = DOT_SPACING * 5;
COVER_WALL_ABOVE_WINDOW = 4;
COVER_WALL_BESIDE_WINDOW = 4; // This is not permiter length, it's cartesian
COVER_ROTOR_GAP = 0; // Extra gap between end of dots and start of cover with window in it
COVER_BRACKET_THICKNESS = 2;
COVER_FOOT_DEPTH = 5; // TODO figure out what this really means; it doesn't seem to be using the full 5
COVER_FOOT_HEIGHT = SERVO_ROTOR_TOP_TO_SCREW_PLATE_BOTTOM - 2;
COVER_BRACKET_LEN_PAST_SERVO_CENTER = 3;
COVER_BRACKET_LEN_PAST_SERVO_SIDES = 5;
COVER_BRACKET_WIRE_NOTCH_DEPTH = 2;
COVER_BRACKET_WIRE_NOTCH_WIDTH = 4;
COVER_SIDE_PILLAR_SIZE = 1.8;  // TODO make this not need trial and error

assert(COVER_BRACKET_WIRE_NOTCH_DEPTH < COVER_BRACKET_LEN_PAST_SERVO_SIDES);

// Floor
ROTOR_FLOOR_THICKNESS = 1;
ROTOR_HUB_RADIUS = 4;

// Calbiration tabs
USE_CALIBRATION_TABS = true; // This adds a little bit of plastic but makes aligning and calibrating your servo 10 times easier
CALIBRATION_TAB_ANGLE = 40;
CALIBRATION_TAB_HEIGHT = 2; // This is height above the window; height above the rotor will be greater
CALIBRATION_TAB_WIDTH = 2;
ROTOR_CALIBRATION_TAB_DEPTH = 2;

BOTTOM_CHAMFER_WIDTH = .2; // Used in some places to avoid elephants foot

// Utility constants
ARBITRARY = 1000; // Arbitrary size for various hole dimensions
SMALL_DELTA = .01; // Small movement to resolve ambiguity when part edges overlap

 // Set global params for smoother shapes
$fa = 1;
$fs = .2;

// Computed constants
perimeter_needed_for_dots = (len(DOT_COLUMNS) + 1) * DOT_SPACING; // DOT_SPACING is center-to-center
perimeter_of_whole_circle = perimeter_needed_for_dots * 360 / DEGREES_TO_POPULATE;
radius_of_whole_circle = perimeter_of_whole_circle / PI / 2;
cell_height = 2*DOT_SPACING + DOT_DIAM;
rotor_height = cell_height + 2*V_PADDING;
cover_width = COVER_WINDOW_WIDTH + 2 * COVER_WALL_BESIDE_WINDOW;
cover_wall_above_rotor = COVER_WALL_ABOVE_WINDOW - (rotor_height - COVER_WINDOW_HEIGHT) / 2;

echo("len(DOT_COLUMNS)", len(DOT_COLUMNS));

module servo_spline_carveout(clearance=SERVO_SPLINE_CLEARANCE) {
    // This isn't a partuclarly well modeled socket for the servo spline but it manages
    // to work anyway
    spline_circumference = PI * SERVO_SPLINE_OUTER_DIAMETER;
    tooth_pitch_degrees = 360 / SERVO_SPLINE_TEETH; // This is for the tip + root
    orig_tooth_tip_mm = spline_circumference / SERVO_SPLINE_TEETH / 2;
    
    carveout_diameter = SERVO_SPLINE_OUTER_DIAMETER - 2 * SERVO_SPLINE_TOOTH_DEPTH + 2 * clearance;
    // Hole sized to fit around the spline if the teeth were missing (i.e. filed off)
    zcyl(
        d=carveout_diameter,
        h=SERVO_SPLINE_ATTACHMENT_HEIGHT,
        align=V_UP
    );
    
    // Slots to accommodate the teeth
    tooth_radius = SERVO_SPLINE_OUTER_DIAMETER/2 + clearance;
    for (i = [0: SERVO_SPLINE_TEETH - 1]) {
        zrot(i * tooth_pitch_degrees)
        cuboid(
            [
                tooth_radius,
                orig_tooth_tip_mm, //+ 2 * SERVO_SPLINE_CLEARANCE,
                SERVO_SPLINE_ATTACHMENT_HEIGHT
            ],
            align=V_UP + V_RIGHT
        );
    }
    
    // Bottom chamfer to avoid problems with elephants foot
    chamfer_outer_radius = tooth_radius + BOTTOM_CHAMFER_WIDTH;
    zcyl(
        d2=carveout_diameter,
        r1=chamfer_outer_radius,
        h=chamfer_outer_radius - (carveout_diameter / 2),
        align=V_UP
    );
}


module braille_rotor() {
    degrees_per_dot = DEGREES_TO_POPULATE / len(DOT_COLUMNS);
    
    echo("Computed diameter", radius_of_whole_circle * 2, "mm");
    echo("Degrees per dot", degrees_per_dot);
    
    module braille_arc() {
        // This is a shape that can be intersected with the support rotor to make it less than 360 degrees
        blank_space_angle = BLANK_SPACE_AT_END / perimeter_of_whole_circle * 360; // TODO debug
        arc_degrees = DEGREES_TO_POPULATE + 2*blank_space_angle;
        module arc_mask() {
            zrot(-arc_degrees/2) 
                pie_slice(
                    h=100, // Arbitrarily large
                    r=radius_of_whole_circle,
                    ang=arc_degrees
            );
        }
        echo("Arc degrees:", arc_degrees); // TODO debug
        
        // This rotation corrects the angle so it's symmetical about the x axis

        // Create the base shape with the arc supporting the dots
        intersection() {
            union() {
                // Draw a base
                zcyl(r=radius_of_whole_circle, l=ROTOR_FLOOR_THICKNESS, center=false);
                // Draw a side
                tube(h=rotor_height, or=radius_of_whole_circle, wall=ROTOR_WALL_THICKNESS);
            };
            arc_mask();
        }

        // Add the dots to it
        zrot(90 - DEGREES_TO_POPULATE/2) {
            for (i = [0: len(DOT_COLUMNS) - 1]) {
                up(V_PADDING)
                    zrot(i * degrees_per_dot + degrees_per_dot/2) // 
                        forward(radius_of_whole_circle)
                            vertical_plane_3dots(DOT_COLUMNS[i]);
            }
        }
        
        module rotor_calibration_tab() {
            tab_full_height = rotor_height + cover_wall_above_rotor + CALIBRATION_TAB_HEIGHT;
            right(radius_of_whole_circle)
                cuboid(
                    [ROTOR_CALIBRATION_TAB_DEPTH, CALIBRATION_TAB_WIDTH, tab_full_height],
                    align=V_UP + V_LEFT 
                );
        }
        
        color("green")
        if (USE_CALIBRATION_TABS) {
            rotor_calibration_tab();
            zrot(-CALIBRATION_TAB_ANGLE) rotor_calibration_tab();
            zrot(CALIBRATION_TAB_ANGLE) rotor_calibration_tab();
        }
    }
        
    // Add a central hub
    difference() {
        union() {
            braille_arc();
            
            // Central smaller disc
            zcyl(r=ROTOR_HUB_RADIUS, h=ROTOR_FLOOR_THICKNESS, center=false);
            
            // Servo spline wall/top if used
            if (USE_SERVO_SPLINE)
            zcyl(
                d=SERVO_SPLINE_OUTER_DIAMETER + 2* SERVO_SPLINE_ATTACHMENT_WALL,
                h=SERVO_SPLINE_ATTACHMENT_HEIGHT + ROTOR_FLOOR_THICKNESS,
                align=V_UP
            );
            
            if (USE_BACKLASH_SPRING) {
                color("blue")
               cuboid([
                    BACKLASH_SPRING_HORN_LENGTH + ROTOR_HUB_RADIUS,
                    BACKLASH_SPRING_HORN_WIDTH,
                    ROTOR_FLOOR_THICKNESS
                ], align=V_UP + V_LEFT);
            }
        }
        
        if (USE_SERVO_SPLINE) {
            // TODO it would be nice if the inside roof here had a 45 degree slant so we could print w/o support
            down(SMALL_DELTA) servo_spline_carveout();
        }
       
        zcyl(d=SERVO_HUB_SCREW_HOLE_DIAM, h=ARBITRARY);
    };
}

// Produces a veritcal braille cell back against the XZ plane, botton against the XY plane, left on the YZ plane
// six_dots are bools corresponding to the typical braille positions, column-major order
// i.e.. [[1, 2, 3], [4, 5, 6]]
// Example:
// vertical_plane_braille_cell([[true, false, true], [true, true, false]]); 
// Note: This is unused
module vertical_plane_braille_cell(six_dots) {
    for (col = [0, 1]) {
        left(DOT_SPACING / 2) right(col * DOT_SPACING) // TODO
            vertical_plane_3dots(six_dots[col]);
    }
}

// Produces a vertical column of braille dots bottom against the XY plane, centered on Z axis
// three_dots corresponds to the column top-first, e.g. [1, 2, 3] for typical Braille dot numbers
module vertical_plane_3dots(three_dots) {   
   for (row = [2, 1, 0]) {
       if (three_dots[row]) {
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

//
// Bracket
//

module servo_attachment_carveout() {    
    cube([SERVO_RECT_HOLE_WIDTH, SERVO_RECT_HOLE_DEPTH, ARBITRARY], center=true);
    
    left(SERVO_RECT_HOLE_WIDTH / 2 + SERVO_HOLE_TO_SCREW_HOLE_CENTER)
        zcyl(h=ARBITRARY, d=SERVO_MOUNTING_SCREW_HOLE_DIAM);

    // For the backlash spring the bracket fully surrounds the servo, so we need only one screw for alignment.
    // We replace the right screw hole with a notch to allow us to thread the servo wire through when putting
    // the bracket onto the servo.
    if (USE_BACKLASH_SPRING) {
        right(SERVO_RECT_HOLE_WIDTH / 2 -SMALL_DELTA)
            rightcube([COVER_BRACKET_WIRE_NOTCH_DEPTH, COVER_BRACKET_WIRE_NOTCH_WIDTH, ARBITRARY]);
    } else {
        right(SERVO_RECT_HOLE_WIDTH / 2 + SERVO_HOLE_TO_SCREW_HOLE_CENTER)
            zcyl(h=ARBITRARY, d=SERVO_MOUNTING_SCREW_HOLE_DIAM);
    }
}

// Result lies flat on x-y plane with center of window at the origin
module cover() {
    cover_height = SERVO_ROTOR_TOP_TO_SCREW_PLATE_BOTTOM + rotor_height + cover_wall_above_rotor + COVER_BRACKET_THICKNESS
        - (USE_SERVO_SPLINE ? SERVO_SPLINE_ATTACHMENT_HEIGHT: 0);
    
    back(COVER_RADIUS)
        up(cover_height / 2)
            intersection() {
                    difference() {
                        union() {
                            // Faceplate
                            zcyl(r=COVER_RADIUS, h=cover_height);
                            
                            // Small foot
                            down(cover_height / 2 - COVER_FOOT_HEIGHT/2)
                                forward(COVER_RADIUS - COVER_FOOT_DEPTH)
                                    fwdcube([cover_width, COVER_FOOT_DEPTH, COVER_FOOT_HEIGHT]);
                            
                            // Side pillars
                            color("red")
                            forward(COVER_RADIUS)
                                down(cover_height / 2)
                                    union() {
                                        left(cover_width/2)
                                            cuboid([COVER_SIDE_PILLAR_SIZE, COVER_SIDE_PILLAR_SIZE, cover_height], align=V_UP + V_BACK);
                                        right(cover_width/2)
                                            cuboid([COVER_SIDE_PILLAR_SIZE, COVER_SIDE_PILLAR_SIZE, cover_height], align=V_UP + V_BACK);
                                }
                                
                            // Calibration tab
                            color("green")
                            if(USE_CALIBRATION_TAB) {
                                forward(COVER_RADIUS)
                                    cuboid([
                                        CALIBRATION_TAB_WIDTH,
                                        COVER_WALL_THICKNESS,
                                        cover_height/2 + CALIBRATION_TAB_HEIGHT
                                        ], align=V_UP); // TODO this align
                                
                            }
                        }
                        
                       zcyl(r=COVER_RADIUS-COVER_WALL_THICKNESS, h=ARBITRARY);
                      
                      // Window cutout
                      // TODO review the vertical positinoing here; it's done in a confusing way  
                        up(cover_height/2 - COVER_WALL_ABOVE_WINDOW - COVER_WINDOW_HEIGHT)
                            upcube([COVER_WINDOW_WIDTH, ARBITRARY, COVER_WINDOW_HEIGHT]);
                    }
                     fwdcube([cover_width, ARBITRARY, ARBITRARY]);
                };
}

module cover_bracket() {
    right(SERVO_ROTOR_OFF_CENTER) cover();
    bracket_length = 
        radius_of_whole_circle  
        + COVER_ROTOR_GAP
        + (USE_BACKLASH_SPRING 
            ? SERVO_RECT_HOLE_DEPTH / 2 + COVER_BRACKET_LEN_PAST_SERVO_SIDES
            : COVER_BRACKET_LEN_PAST_SERVO_CENTER);
    bracket_width = SERVO_RECT_HOLE_WIDTH +2 * COVER_BRACKET_LEN_PAST_SERVO_SIDES;
    echo("Cover bracket length", bracket_length);
    difference() {
        union() {
            cuboid([bracket_width, bracket_length, COVER_BRACKET_THICKNESS], align=V_UP + V_FWD);
            
            
            if (USE_BACKLASH_SPRING) {
                   forward(radius_of_whole_circle + COVER_ROTOR_GAP) {
                       // Stick for attaching spring
                       color("blue")
                       right(SERVO_ROTOR_OFF_CENTER) 
                           cuboid([
                                BACKLASH_SPRING_HORN_WIDTH,
                                BACKLASH_SPRING_HORN_LENGTH + ROTOR_HUB_RADIUS,
                                COVER_BRACKET_THICKNESS
                            ], align=V_UP + V_FWD);
                   }
            }
        }
        forward(radius_of_whole_circle + COVER_ROTOR_GAP) servo_attachment_carveout();
    }
    
}