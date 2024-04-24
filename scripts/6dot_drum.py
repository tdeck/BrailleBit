# This script explores the concept of a drum with 3 dot high lines on it,
# arranged so two adjacent vertical lines are exposed at once. How many
# positions around the drum do we need to show all 64 Braille characters?
# Could also be used for a disk,  theoretically

# The best length this gives is 65
# Note you will get an extra position because it doesn't account for wrapping around

# Python3
import random

BRAILLE_ASCII_BINARY_ORDER = " A1B'K2L@CIF/MSP\"E3H9O6R^DJG>NTQ,*5<-U8V.%[$+X!&;:4\\0Z7(_?W]#Y)="
braille_ascii_to_dot_string = {}
dot_string_to_braille_ascii = {}
for idx, char in enumerate(BRAILLE_ASCII_BINARY_ORDER):
    dots = "{:06b}".format(idx)[::-1]
    braille_ascii_to_dot_string[char] = dots
    dot_string_to_braille_ascii[dots] = char


def combos_from_braille_ascii(chars):
    return {braille_ascii_to_dot_string[c] for c in chars}


SPACE = " "
ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
BASIC_MODIFIERS = ",#"  # Capital sign, number sign
NUMERIC = "ABCDEFGHIJ"
PERIOD = "4"
MINUS_SIGN = "-"  # This is the nemeth minus sign, UEB expects a dot-5 before it but it's unambiguous here
SIMPLE_PUNCTUATION = "148" + MINUS_SIGN # Comma, period, question mark


# ALL_COMBOS is expressed as 0 or 1 for each dot, dots "123456"
#ALL_COMBOS = {"{:06b}".format(i) for i in range(64)}
ALL_COMBOS = combos_from_braille_ascii(SPACE + ALPHABET + BASIC_MODIFIERS + SIMPLE_PUNCTUATION) # Should get 40
#ALL_COMBOS = combos_from_braille_ascii(NUMERIC + SPACE + PERIOD + MINUS_SIGN)

def try_something_random():
    needed_combos = ALL_COMBOS.copy()
    last = "000"

    order = [last]

    while needed_combos:
        opts = [x for x in needed_combos if x.startswith(last)]
        if not opts:
            # Fall back to just starting a new letter, so the 2 window overlap here does nothing
            # NOTE: this is a hack first part is thrown away, not added to the ring
            opts = ["xxx" + c[:3] for c in needed_combos]

        pair = random.choice(opts)

        needed_combos.discard(pair)

        last = pair[-3:]
        order.append(last)

    return order


def print_for_scad(column_strs):
    print("// **** OpenSCAD constants ****")
    print('DOT_COLUMNS = [' + ','.join(['[' + ','.join(colstr) + ']' for colstr in column_strs]) + '];')
    print()


def print_for_arduino(column_strs):
    cell_chars = ""
    for i in range(len(column_strs) - 1):
        dots = column_strs[i] + column_strs[i + 1]
        char = dot_string_to_braille_ascii[dots]
        if char == '"':
            char = r'\"'
        elif char == '\\':
            char = '\\\\'
        cell_chars += char

    print("// **** Arduino constants ****")
    print("const int DRUM_COLS = {};".format(len(column_strs)))
    print("const char* CELL_CHARS = \"{}\";".format(cell_chars))
    print()

    
best = None
bestLen = None
for i in range(50000):
    r = try_something_random()
    if r is None:
        continue
    halfway = len(r) // 2

    if r[halfway] != "110" or r[halfway + 1] != "110":  # The letter G
        continue

    if bestLen is None or len(r) < bestLen:
        best = r
        bestLen = len(r)
        print(i, "Best len", bestLen)

print("Best length:", bestLen)
print_for_scad(best)
print_for_arduino(best)
# Could be optimized but why bother
