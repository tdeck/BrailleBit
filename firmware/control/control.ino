#include "ServoBrailleCell.h"

const float DEGREES_PER_DOT = 9.44;
const char* CELL_CHARS = " ^HICE4SDGB\"JFA,-";

const int SERVO_PIN = 26;

// These come from servo calibration
const uint16_t US_PER_4DEG = 45;
const uint16_t US_CENTER = 1500;

// Derived constants; do not change
// Note: Here this is calculated at compile time.
// If you do this calculation dynamically (rather than in a const), you may end
// up including floating point functions and making your code larger!
const uint16_t US_PER_4COL = US_PER_4DEG * DEGREES_PER_DOT;

ServoBrailleCell cell(CELL_CHARS);

void setup() {
  cell.attach(SERVO_PIN, US_CENTER, US_PER_4COL);
}

void loop() {

  for (int i = 0; i < 10; ++ i) {
    cell.setChar('A' + i);
    delay(3000);
  }
}