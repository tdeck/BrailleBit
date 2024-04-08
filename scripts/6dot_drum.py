# This script explores the concept of a drum with 3 dot high lines on it,
# arranged so two adjacent vertical lines are exposed at once. How many
# positions around the drum do we need to show all 64 Braille characters?
# Could also be used for a disk,  theoretically

# The best length this gives is 65
# Note you will get an extra position because it doesn't account for wrapping around

# Python3
import random

def combos_from_unicode(symbols):
    # Something cool about Braille Unicode is you can easily extract the dot positions
    # from it, so it makes it easy to identify characters for inclusion from a string
    res = set()
    for c in symbols:
        cpoint = ord(c) 
        assert cpoint & 0xFFFF00 == 0x2800
        dots = (cpoint & 63) # Little endian
        res.add("{:06b}".format(dots)[::-1]) # Reverse str to make big endian

    return res

SPACE = "⠀" # Braille unicode character
ALPHABET = "⠁⠃⠉⠙⠑⠋⠛⠓⠊⠚⠅⠇⠍⠝⠕⠏⠟⠗⠎⠞⠥⠧⠺⠭⠽⠵"
BASIC_MODIFIERS = "⠼⠠"


# ALL_COMBOS is expressed as 0 or 1 for each dot, dots "123456"
ALL_COMBOS = {"{:06b}".format(i) for i in range(64)}
#ALL_COMBOS = combos_from_unicode(SPACE + ALPHABET + BASIC_MODIFIERS) # Should get 40

def try_something_random():
    needed_combos = ALL_COMBOS.copy()
    last = "000"

    order = [last]

    while needed_combos:
        opts = [x for x in needed_combos if x.startswith(last)]
        if not opts:
            #return None # It's possible to do this without running out for the full character set
            # fall back to just starting a new letter, so the 2 window overlap here does nothing
            # NOTE: this is a hack first part is thrown away, not added to the ring
            opts = ["xxx" + c[:3] for c in needed_combos]

        pair = random.choice(opts)

        needed_combos.discard(pair)

        last = pair[-3:]
        order.append(last)

    return order

def print_for_scad(column_strs):
    print('[' + ','.join(['[' + ','.join(colstr) + ']' for colstr in column_strs]) + ']')
    
best = None
bestLen = None
for i in range(50000):
    r = try_something_random()
    if r is not None:
        if bestLen is None or len(r) < bestLen:
            best = r
            bestLen = len(r)
            print(i, "Best len", bestLen)

print("Best length:", bestLen)
print_for_scad(best)
# Could be optimized but why bother
