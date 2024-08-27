include <common.scad>

// These movements and rotations just line the assemblies up so their relationship shows up in the preview
forward(radius_of_whole_circle + COVER_ROTOR_GAP)
    right(SERVO_ROTOR_OFF_CENTER)
    up(SERVO_ROTOR_TOP_TO_SCREW_PLATE_BOTTOM)
    zrot(90)
        braille_rotor();
cover_bracket();