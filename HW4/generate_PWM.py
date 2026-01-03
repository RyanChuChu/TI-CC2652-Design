#!/usr/bin/env python3
"""
gen_pwm_table.py

Generate an ARM assembly PWM table for microstepping a 4-wire stepper:
  A, A_bar, B, B_bar

Usage:
  python gen_pwm_table.py X                # X = microsteps per 90 degrees (integer)
  python gen_pwm_table.py X --amp 4800    # change amplitude
  python gen_pwm_table.py X --label PWMStepperTable

Example:
  python gen_pwm_table.py 16 > pwmtable.s
"""

import math
import argparse
import sys

def generate_table(x: int, amp: int):
    """
    Generate 4*x entries. Step angle = (pi/2) / x per entry.
    Return a list of 4-tuples: (A, A_bar, B, B_bar)
    """
    if x <= 0:
        raise ValueError("x must be positive integer")

    entries = []
    step = (math.pi / 2.0) / x  # radians
    for i in range(4 * x):
        theta = i * step
        # continuous coil amplitudes
        a = amp * math.cos(theta)
        b = amp * math.sin(theta)

        # split into positive and negative channels
        A = int(round(a)) if a >= 0 else 0
        A_bar = int(round(-a)) if a < 0 else 0
        B = int(round(b)) if b >= 0 else 0
        B_bar = int(round(-b)) if b < 0 else 0

        # safety: ensure non-negative
        A = max(0, A)
        A_bar = max(0, A_bar)
        B = max(0, B)
        B_bar = max(0, B_bar)

        entries.append((A, A_bar, B, B_bar))

    return entries

def format_asm(entries, label_name="PWMStepperTable", end_label="EndPWMStepperTable",
               word_directive=".word", width=4):
    """
    Format entries into ARM assembly text with zero-padded fixed-width numbers.
    width = total digits, e.g. width=5 → 00000 ~ 99999.
    """
    lines = []
    lines.append(".align 256")
    lines.append(f"{label_name}:")
    for idx, (A, A_bar, B, B_bar) in enumerate(entries):
        A_s     = str(A).rjust(width, '0')
        Abar_s  = str(A_bar).rjust(width, '0')
        B_s     = str(B).rjust(width, '0')
        Bbar_s  = str(B_bar).rjust(width, '0')
        lines.append(f"    {word_directive} {A_s}, {Abar_s}, {B_s}, {Bbar_s}") # @ idx={idx}
    lines.append("")
    lines.append(f"{end_label}:")
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description="Generate PWM table for microstepping (ARM asm).")
    parser.add_argument("x", type=int, help="number of microsteps per 90 degrees (positive integer). Table length = 4*x")
    parser.add_argument("--amp", type=int, default=4800, help="peak amplitude (default 4800)")
    parser.add_argument("--label", type=str, default="PWMStepperTable", help="label name for table start")
    parser.add_argument("--end-label", type=str, default="EndPWMStepperTable", help="label name for table end")
    parser.add_argument("--word", type=str, default=".word", help="assembly word directive to use (default .word)")
    args = parser.parse_args()

    try:
        entries = generate_table(args.x, args.amp)
    except ValueError as e:
        print("Error:", e, file=sys.stderr)
        sys.exit(2)

    asm = format_asm(entries, label_name=args.label, end_label=args.end_label, word_directive=args.word)
    sys.stdout.write(asm)

if __name__ == "__main__":
    main()
