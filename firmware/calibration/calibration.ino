// Servo braille cell calibration sketch
// Written by Troy H. Deck (blindmakers.net)
// Be sure to update pin assignment constants below before running

#include <Servo.h>

// Pin assignments
const int SERVO_PIN = 26;
const int LEFT_BUTTON_PIN = 2;
const int CONTINUE_BUTTON_PIN = 1; // TODO rename this to continue button
const int RIGHT_BUTTON_PIN = 0;

// Uncomment one (or more) of these to choose how to retrieve calibration output
#define USE_READOUT_SERIAL
//#define USE_READOUT_MORSE
//#define USE_READOUT_EEPROM // This will write 4 bytes of calibration data to EEPROM; be sure to set EEPROM_WRITE_ADDRESS below
//const int EEPROM_WRITE_ADDRESS = 0; // US_CENTER will be written here, and US_PER_4DEG will be written 2 bytes later

// START OF MAIN CODE

// Constants you probably don't need to change
const uint16_t US_90DEG = 1500;
const int POLL_MS = 1;
const int COARSE_ADJUST_US = 30;
const int FINE_ADJUST_US = 5;
const int PRIOR_40DEG_SHIFT_US = 470; // Initial amount to shift left by; doesn't need to be accurate.

enum State {
  CENTER_COARSE = 0,
  CENTER_FINE = 1,
  LEFT_COARSE = 2,
  LEFT_FINE = 3,
  RIGHT_COARSE = 4,
  RIGHT_FINE = 5,
  READOUT = 6,
};

#ifdef USE_READOUT_EEPROM
#include <EEPROM.h>
#endif

// Globals
Servo myservo;  // create servo object to control a servo

void setup() {
  myservo.attach(SERVO_PIN);  // attaches the servo on pin 9 to the servo object
  pinMode(LEFT_BUTTON_PIN, INPUT);
  pinMode(CONTINUE_BUTTON_PIN, INPUT);
  pinMode(RIGHT_BUTTON_PIN, INPUT);

  #ifdef USE_READOUT_SERIAL
  Serial.begin(9600);
  delay(2000); // Give the serial device time to get set up
  Serial.println("Set center position (coarse)");
  #endif
}

void loop() {
  // This is implemented as a simple state machine. The progression of states is
  // CENTER_COARSE > CENTER_FINE > LEFT_COARSE > LEFT_FINE > RIGHT_COARSE > RIGHT_FINE > READOUT
  // where each state transition is caused by pressing the continue button

  static char current_state = CENTER_COARSE;
  static uint16_t current_pos_us = US_90DEG;
  static int adjust_us = COARSE_ADJUST_US;

  static uint16_t center_pos_us;
  static uint16_t left_pos_us;
  static uint16_t right_pos_us;

  static uint8_t continue_button_history = 0;
  static bool ready_for_press = false;

  // Really basic debounce for the continue button
  continue_button_history = (continue_button_history << 1) | digitalRead(CONTINUE_BUTTON_PIN);
  // Only accept new press if the last one was released
  if (continue_button_history == 0) ready_for_press = true;

  if (ready_for_press && continue_button_history == 0xFF) {
    // Continue button pressed; what to do depends on the state
    ready_for_press = false;

    switch (current_state) {
      case CENTER_COARSE:
        adjust_us = FINE_ADJUST_US;
        current_state = CENTER_FINE;

        #ifdef USE_READOUT_SERIAL
        Serial.println("Set center position (fine)");
        #endif

        break;
      case CENTER_FINE:
        center_pos_us = current_pos_us;
        current_pos_us = center_pos_us + PRIOR_40DEG_SHIFT_US; // Move to estimated left tab position
        adjust_us = COARSE_ADJUST_US;
        current_state = LEFT_COARSE;

        #ifdef USE_READOUT_SERIAL
        Serial.println("Set left position (coarse)");
        #endif

        break;
      case LEFT_COARSE:
        adjust_us = FINE_ADJUST_US;
        current_state = LEFT_FINE;

        #ifdef USE_READOUT_SERIAL
        Serial.println("Set left position (fine)");
        #endif

        break;
      case LEFT_FINE:
        left_pos_us = current_pos_us;
        current_pos_us = center_pos_us - (left_pos_us - center_pos_us); // This should be pretty spot on for right tab
        adjust_us = COARSE_ADJUST_US;
        current_state = RIGHT_COARSE;

        #ifdef USE_READOUT_SERIAL
        Serial.println("Set right position (coarse)");
        #endif

        break;
      case RIGHT_COARSE:
        adjust_us = FINE_ADJUST_US;
        current_state = RIGHT_FINE;

        #ifdef USE_READOUT_SERIAL
        Serial.println("Set right position (fine)");
        #endif

        break;
      case RIGHT_FINE:
        right_pos_us = current_pos_us;
        current_state = READOUT;
        return; // Re-run the loop function in the new state
      case READOUT:
        // This is just for completeness; the button does nothing in this state
        break;
    }
  }

  if (current_state != READOUT) {
    // Handle servo adjustments in all the adjustment states
    current_pos_us = handleManualAdjustment(current_pos_us, adjust_us);
    myservo.writeMicroseconds(current_pos_us);
    delay(POLL_MS);
  } else {
    // Output the calibration results
    uint16_t us_per_4_degrees = (left_pos_us - right_pos_us) / 20; // 80 degrees / 20 = 4 degrees.

    #ifdef USE_READOUT_SERIAL
      Serial.print("US_CENTER = ");
      Serial.print(center_pos_us);
      Serial.println(";");

      Serial.print("US_PER_4DEG = ");
      Serial.print(us_per_4_degrees);
      Serial.println(";");
    #endif

    #ifdef USE_READOUT_EEPROM
      EEPROM.put(EEPROM_WRITE_ADDRESS, (uint16_t)center_pos); // The casts here are just defensive programming
      EEPROM.put(EEPROM_WRITE_ADDRESS + 2, (uint16_t)us_per_4_degrees);
    #endif

    #ifdef USE_READOUT_MORSE
      char buffer[5]; // Buffer to hold output of itoa()
      // This code section could be easily adapted to support other digit-at-a-time readout options

      itoa(center_pos_us, buffer, 10);
      readout_morse_indicateCenter(left_pos_us, center_pos_us, right_pos_us);

      for (char* digit_ptr = buffer; *digit_ptr != 0; ++ digit_ptr) {
        redaout_morse_digit(*digit_ptr, left_pos_us, center_pos_us, right_pos_us);
      }

      itoa(us_per_4_degrees, buffer, 10);
      readout_morse_indicateUsPerDegree(left_pos_us, center_pos_us, right_pos_us);

      for (char* digit_ptr = buffer; *digit_ptr != 0; ++ digit_ptr) {
        redaout_morse_digit(*digit_ptr, left_pos_us, center_pos_us, right_pos_us);
      }
    #endif
  }
}

// This adjusts current_position_us according to any button presses and returns new pos
uint16_t handleManualAdjustment(uint16_t current_position_us, int adjust_us) {
  static bool ready_for_press = 0;
  static uint8_t left_button_history = 0;
  static uint8_t right_button_history = 0;

  // Really basic debounce
  left_button_history = (left_button_history << 1) | digitalRead(LEFT_BUTTON_PIN);
  right_button_history = (right_button_history << 1) | digitalRead(RIGHT_BUTTON_PIN);

  // Only accept new button presses once a prior one has been released
  if (left_button_history == 0 and right_button_history == 0) ready_for_press = 1;

  if (ready_for_press) {
    if (left_button_history == 0xFF) {
      current_position_us = current_position_us - adjust_us;
      ready_for_press = false;
    } else if (right_button_history == 0xFF) {
      current_position_us = current_position_us + adjust_us;
      ready_for_press = false;
    }
  }

  return current_position_us;
}


#ifdef USE_READOUT_MORSE

void readout_morse_indicateCenter(uint16_t left_pos, uint16_t center_pos, uint16_t right_pos) {
  readout_morse__sendCode(0b1010, 4, left_pos, center_pos, right_pos); // Sends a C (-.-.)
}

void readout_morse_indicateUsPerDegree(uint16_t left_pos, uint16_t center_pos, uint16_t right_pos) {
  readout_morse__sendCode(0b100, 3, left_pos, center_pos, right_pos); // Sends a D (-..)
}

// This will "twitch out" a single digit in morse code, using both position and timing to distinguish dit and dah
void redaout_morse_digit(char asciiDigit, uint16_t left_pos, uint16_t center_pos, uint16_t right_pos) {
  const char lookup[10] = { // 1 is dah; 0 is dit; last 5 bits ltr
    0b11111,
    0b01111,
    0b00111,
    0b00011,
    0b00001,
    0b00000,
    0b10000,
    0b11000,
    0b11100,
    0b11110,
  };

  // Note: This does no bounds checking at all; it assumes valid input
  readout_morse__sendCode(lookup[asciiDigit - '0'], 5, left_pos, center_pos, right_pos);
}

void readout_morse__sendCode(char code, int len, uint16_t left_pos, uint16_t center_pos, uint16_t right_pos) {
  const int16_t DIT_LENGTH = 200;

  const char mask = 1 << (len - 1);
  for (int i = 0; i < len; ++ i) {
    char element = code & mask;
    code = code << 1;

    if (element == 0) { // Dit; short pulse to the left
      myservo.writeMicroseconds(left_pos);
      delay(DIT_LENGTH);
    } else { // Dah; longer pulse to the right
      myservo.writeMicroseconds(right_pos);
      delay(3 * DIT_LENGTH);
    }

    // Inter-element space
    myservo.writeMicroseconds(center_pos);
    delay(DIT_LENGTH);
  }

  // Inter-symbol space
  delay(3 * DIT_LENGTH);
}
#endif
