#ifndef BrailleBit_h
#define BrailleBit_h

#include <inttypes.h>
#include <Servo.h>

class BrailleBit {
public:
  BrailleBit(const char * rotor_chars);
  void attach(int pin, uint16_t us_center, uint16_t us_per_4_cols);
  void setChar(char c);

protected:
  Servo servo;
  const char* const rotor_chars_;
  uint16_t first_col_us_ = 0;
  uint16_t us_per_4_cols_ = 0;
};

namespace NumericRotor {
  const float DEGREES_PER_DOT = 9.44;
  // In this string I use \b (the BELL control character) to mark rotor positions whose braille value doesn't correspond
  // to a single keyboard character. Advanced users who are familar with contracted braille should instead use the BRAILLE_ASCII
  // constants to access all rotor positions.
  const char* const CHARS = " \b8935.S472\b061\b-";
  const char* const BRAILLE_ASCII = " ^HICE4SDGB\"JFA,-";
}

#endif