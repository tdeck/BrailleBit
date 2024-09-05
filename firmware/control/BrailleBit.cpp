#include "api/Common.h"
#include "BrailleBit.h"
#include <string.h>

const int WIGGLE_PAUSE_MS = 50;

// NOTE: We assume rotorChars is a string constant and not going to go away,
// which is valid most of the time for microcontroller code, so we don't copy it.
BrailleBit::BrailleBit(const char* rotor_chars): rotor_chars_(rotor_chars) {}

void BrailleBit::attach(int pin, uint16_t us_center, uint16_t us_per_4_cols) {

  int rotor_positions = strlen(rotor_chars_);
  int mid_pos = rotor_positions / 2;
  first_col_us_ = 
    us_center + 
    ((mid_pos * us_per_4_cols) >> 2); // >> 2 divides by 4

  // An even number of characters means an odd number of dot columns.
  // For a drum with an odd number of dot columns, the central calibration tab
  // will be directly above a line of dots, so we must rotate 1/2 step to have
  // 2 columns in the window and display the character.
  if (rotor_positions % 2 == 0) {
    first_col_us_ -= us_per_4_cols >> 3; // >> 3 divides by 8
  }

  us_per_4_cols_ = us_per_4_cols;

  servo.attach(pin);
}

void BrailleBit::displayChar(char c) {
  if (current_char_ == c) {
    int currentPos = servo.readMicroseconds();

    if (currentPos >= first_col_us_) { // Don't go out of range
      servo.writeMicroseconds(currentPos - (us_per_4_cols_ >> 2));
    } else {
      servo.writeMicroseconds(currentPos + (us_per_4_cols_ >> 2));
    }

    delay(WIGGLE_PAUSE_MS);
    servo.writeMicroseconds(currentPos);
  } else {
    setChar(c);
  }
}

void BrailleBit::setChar(char c) {
  if (us_per_4_cols_ == 0) return; // Not initialized yet

  int16_t us_from_start_times_4 = 0;
  for (const char * rcp = rotor_chars_; *rcp != 0; ++ rcp) {
    if (*rcp == c) {
        uint16_t us = first_col_us_ + (us_from_start_times_4 >> 2);
        // TODO some kind of backlash compensation
        servo.writeMicroseconds(us);
        current_char_ = c;
    }

    us_from_start_times_4 -= us_per_4_cols_;
  }

}