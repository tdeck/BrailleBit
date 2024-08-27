include <common.scad>

// This allows you to dial in the servo spline cleaarance with your own printer,  in increments of 0.1mm ("tenths")
// It prints a block with cutouts for the spline of different sizes; each cutout has a number of bumps next to it
// equal to the number of tenths

MIN_TENTHS = 2;
MAX_TENTHS = 5;

MIN_SPACE_BETWEEN_TESTS = 2 * DOT_SPACING;

num_tests = MAX_TENTHS - MIN_TENTHS + 1;
// This is a little wasteful of plastic to have even spacing but it's much easier to write
space_for_dots = DOT_SPACING * (MAX_TENTHS  - 1);
test_spacing = max(
    // If we're going up to a large number of dots, we may need to space the tests out more
    space_for_dots + MIN_SPACE_BETWEEN_TESTS,
    SERVO_SPLINE_OUTER_DIAMETER + 2*SERVO_SPLINE_ATTACHMENT_WALL
);

body_length = test_spacing * (num_tests);
body_depth =  SERVO_SPLINE_OUTER_DIAMETER + 2* SERVO_SPLINE_ATTACHMENT_WALL;
body_height =  SERVO_SPLINE_ATTACHMENT_HEIGHT + ROTOR_FLOOR_THICKNESS;

difference() {
    // Body
    cuboid(
        [
            body_length,
            body_depth,
            body_height,
        ], align=V_UP + V_RIGHT
    );
    
    // Spline carveouts
    right(test_spacing / 2) down(SMALL_DELTA)
    for (i = [0: num_tests - 1]) {
        clearance = (MIN_TENTHS + i) * 0.1;
        
        right(i * test_spacing + SERVO_SPLINE_OUTER_DIAMETER/2) servo_spline_carveout(clearance);
    }
}

// Marker dots
up(body_height/2)
forward(body_depth/2)
for (i = [0: num_tests - 1]) {
    right(i * test_spacing + DOT_DIAM) // Initial offset
    right((MAX_TENTHS - i) * DOT_SPACING/2)
    for (j = [0: i + 1]) {
        right(DOT_SPACING * j) sphere(d=DOT_DIAM);
    }
}