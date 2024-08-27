#ifndef ServoBrailleCell_h
#define ServoBrailleCell_h

#include <inttypes.h>
#include <Servo.h>

class ServoBrailleCell {
public:
  ServoBrailleCell(const char * rotor_chars);
  void attach(int pin, uint16_t us_center, uint16_t us_per_4_cols);
  void setChar(char c);

protected:
  Servo servo;
  const char* const rotor_chars_;
  uint16_t first_col_us_ = 0;
  uint16_t us_per_4_cols_ = 0;
};

#endif