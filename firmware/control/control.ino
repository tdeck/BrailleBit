#include "ServoBrailleCell.h"

#define DEGREES_PER_DOT 10.625

const int SERVO_PIN = 26;
const uint16_t US_CENTER = 1465;
const uint16_t US_PER_4DEG = 45;

ServoBrailleCell cell(" ^HICE4SDGB\"JFA,-");

void setup() {

  cell.attach(SERVO_PIN, US_CENTER, US_PER_4DEG * 10.625);
}

void loop() {
  /*
  for (int i = 0; i < 10; ++ i) {
    cell.setChar('A' + i);
    delay(1000);
  } */
}