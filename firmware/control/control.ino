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


// TODO debug stuff
const int LED_PIN = LED_BUILTIN;

void setup() {
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  pinMode(LED_PIN, OUTPUT);
}
// Drum info from script
const int DRUM_COLS = 45;
const char* CELL_CHARS = ",#L ;8-#R4TB\"1.OJFEICDGHWPA.XYQ$N$M%ZS?V+K.U`";

// Servo info
const uint16_t US_90DEG = 1500; // Should not need to be changed
const int US_OFFSET = 0;
const int US_PER_COL = 44; // Orig 45
// Testing
// 45: R great, U is a column off
// 44: U is great,

const int US_BACKLASH = 0; // I think the right value is around 20

// Other stuff
const unsigned long DELAY_MS = 3000;

// Computed values
const int MID_POS = DRUM_COLS / 2;
const uint16_t START_US = US_90DEG + MID_POS * US_PER_COL + US_OFFSET;

uint16_t last_pos_us = 0;
int last_dir = 1; // Either -1 or +1

void setCell(char c) {
  // Find char pos w/o using whole string lib
  int p;
  uint16_t us = START_US;
  for (p = 0; p < DRUM_COLS - 1; ++ p) {
    if (CELL_CHARS[p] == c) {
      uint16_t prior_pos_us = last_pos_us;
      last_pos_us = us;
      
      //int dir = us > prior_pos_us ? 1 : -1;
      /*
      if (dir != last_dir) { // Try to correct for backlash
          us = us + dir * US_BACKLASH;
      }
      */

      //us = us + dir * US_BACKLASH;

      /*
      if (us < prior_pos_us) {
        us = us + US_BACKLASH;
        digitalWrite(LED_PIN, HIGH);
      } else {
        digitalWrite(LED_PIN, LOW);
      }*/

      myservo.writeMicroseconds(MAX_PULSE_WIDTH);
      delay(100);
      
      myservo.writeMicroseconds(us);  
      //last_dir = dir;
      return;
    }
    us -= US_PER_COL;
  }
}

void showMessage(char* text, uint16_t delay_ms) {
  for (char* p = text; *p; ++ p) {
    setCell(*p);
    delay(delay_ms);
  }
}


// NOTE: Here positive change in us == dots and wheel moving rightward in window

void loop() {
  // NOTE led not working
  /*
  digitalWrite(LED_PIN, LOW);
  myservo.writeMicroseconds(US_90DEG);
  delay( 2* DELAY_MS);

  digitalWrite(LED_PIN, HIGH);
  myservo.writeMicroseconds(US_90DEG + US_BACKLASH);
  delay(DELAY_MS);
  */

  //showMessage("BOOGER ", DELAY_MS);

  setCell('R');
  delay(DELAY_MS);

  /*
  setCell('A');
  delay(DELAY_MS);

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
  */
}
