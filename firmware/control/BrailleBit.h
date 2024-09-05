#ifndef BrailleBit_h
#define BrailleBit_h

#include <inttypes.h>
#include <Servo.h>

class BrailleBit {
public:
  BrailleBit(const char * rotor_chars);
  void attach(int pin, uint16_t us_center, uint16_t us_per_4_cols);

  // Move the rotor to the given character. If the rotor is already on that character, it wiggles the
  // rotor to signal that a new character is being presented.
  void displayChar(char c);

  // Move the rotor to the given character. If the rotor is already on that character, it does nothing.
  void setChar(char c);

protected:
  Servo servo;
  const char* const rotor_chars_;
  uint16_t first_col_us_ = 0;
  uint16_t us_per_4_cols_ = 0;
  char current_char_ = 0;
};

namespace NumericRotor {
  const float DEGREES_PER_DOT = 8.95;
  // In this string I use \b (the BELL control character) to mark rotor positions whose braille value doesn't correspond
  // to a single keyboard character. Advanced users who are familar with contracted braille should instead use the BRAILLE_ASCII
  // constants to access all rotor positions.
  const char* const CHARS =         " \bB\b5:06478931\b.?-";
  const char* const BRAILLE_ASCII = " ^B@E3JFDGHICA\"48-";
}

#endif