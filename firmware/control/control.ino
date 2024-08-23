#include "ServoBrailleCell.h"

const float DEGREES_PER_DOT = 9.44;
const char* CELL_CHARS = " ^HICE4SDGB\"JFA,-";

const int SERVO_PIN = 26;

// These come from servo calibration
const uint16_t US_PER_4DEG = 46;
const uint16_t US_CENTER = 1500;

// Derived constants; do not change
// Note: Here this is calculated at compile time.
// If you do this calculation dynamically (rather than in a const), you may end
// up including floating point functions and making your code larger!
const uint16_t US_PER_4COL = US_PER_4DEG * DEGREES_PER_DOT;

ServoBrailleCell cell(CELL_CHARS);

// TODO debug stuff
const int CONTINUE_BUTTON_PIN = 1;

void setup() {
  cell.attach(SERVO_PIN, US_CENTER, US_PER_4COL);

  // TODO debug
  pinMode(CONTINUE_BUTTON_PIN, INPUT);
  Serial.begin(9600);
  delay(2000); // Give the serial device time to get set up
}

void loop() {
  static char continue_button_history = 0;
  static bool ready_for_press = 0;

  continue_button_history = (continue_button_history << 1) | digitalRead(CONTINUE_BUTTON_PIN);
  if (continue_button_history == 0) ready_for_press = true;

  if (ready_for_press && continue_button_history == 0xFF) {
    ready_for_press = 0;
    int digit = random(1, 10);
    Serial.println(digit);
    cell.setChar('A' + digit - 1);
  }

  delay(50);
}