/* Sweep
 by BARRAGAN <http://barraganstudio.com>
 This example code is in the public domain.

 modified 8 Nov 2013
 by Scott Fitzgerald
 https://www.arduino.cc/en/Tutorial/LibraryExamples/Sweep
*/

#include <Servo.h>

Servo myservo;  // create servo object to control a servo
// twelve servo objects can be created on most boards

int pos = 0;    // variable to store the servo position

void setup() {
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
}

const int DEG_OFFSET = 4;
const int DEGREES_PER_COL = 13;
const unsigned long DELAY_MS = 1000;

// These indicate the character in position if we align to the left column
const char* CELL_CHARS = " ?ICDFEJGH.?-?B";
const int DRUM_COLS = 16; // strlen(CELL_CHARS) = 1
const int MID_POS = DRUM_COLS / 2;
const int START_ANGLE = 90 + MID_POS * DEGREES_PER_COL + DEG_OFFSET;

void setCell(char c) {
  // Find char pos w/o using whole string lib
  int p;
  for (p = 0; p < DRUM_COLS - 1; ++ p) {
    if (CELL_CHARS[p] == c) {
      int angle = START_ANGLE - p * DEGREES_PER_COL;
      myservo.write(angle);  
      return;
    }
  }
}

void loop() {
  setCell('B');
  delay(DELAY_MS);

  setCell('C');
  delay(DELAY_MS);

  setCell('D');
  delay(DELAY_MS);

  setCell('E');
  delay(DELAY_MS);

  setCell('F');
  delay(DELAY_MS);

  setCell('G');
  delay(DELAY_MS);

  /*
  for (pos = 180; pos >= 0; pos -= DEGREES_PER_COL) { // goes from 180 degrees to 0 degrees
    myservo.write(pos + DEG_OFFSET);              // tell servo to go to position in variable 'pos'
    delay(DELAY_MS);                       // waits 15 ms for the servo to reach the position
  }
  */
}
