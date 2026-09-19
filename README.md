# Set-Operations-Assembly

A little 16-bit x86 assembly program that does basic discrete math set operations (union, intersection, difference, powerset, cartesian product, subset checks, etc.) with a text-mode menu, running as a `.com` program under DOSBox.

Made this mostly to actually understand how sets/subsets/powersets work "under the hood" instead of just calling library functions — turns out doing it in raw assembly with segment registers and BIOS interrupts is a great way to make sure you *really* understand it.

## What it does

Two sets, A and B (max 10 elements each, values 0–255, no duplicates). You can:

- Add / delete elements from A or B
- Check if an element exists in A or B
- Union, Intersection, Difference, Symmetric Difference (results go into "Set C")
- Cartesian Product (printed directly, not stored)
- Check if A is a subset / strict subset of B
- Powerset of A or B
- Get size of A or B, check if empty
- Clear everything and start over

Everything runs off a single menu screen that redraws itself after every action, so you can chain operations without losing your place.

## Requirements

- [NASM](https://www.nasm.us/) to assemble it
- [DOSBox](https://www.dosbox.com/) to actually run it (it's a raw `.com`, org 0x100, so it needs a real/emulated DOS environment)

## How to build and run

```bash
nasm code.asm -o code.com
```

Then either:

- Drop `code.com` into your DOSBox mounted folder and run it from there, or
- Just double check DOSBox is mounted to the folder containing it, then `code.com` from the DOSBox prompt

```
mount c C:\path\to\this\folder
c:
code.com
```

## Controls

It's letter-based, not number-based — press the letter shown next to the option (A, B, C... up to T, plus Z to exit). Case doesn't matter, it uppercases lowercase input for you. Any key not on the menu just throws an "Invalid choice" message and redraws.

When it asks for a number, type digits (0–255) and hit Enter. Backspace works too.

## Some notes / quirks (read before you file a bug)

- Max 10 elements per set. Set C (used for union/intersection/etc results) can hold up to 20, since union of two full sets could need that many.
- No duplicates allowed — it'll tell you if you try to add one that's already there instead of silently ignoring it.
- Values are single bytes, so 0–255 only. Anything bigger and it'll flag "Out of Bounds."
- Cartesian product doesn't get stored into Set C — it's printed straight to screen via interrupts since pairs don't really fit the same array format as the other results. If you look at the code and wonder why Set C looks untouched after running it, that's why.
- Everything writes directly to video memory (segment 0xb800) for text output except a couple of spots (cartesian product, powerset, char input) that just use BIOS int 10h/int 16h directly. Bit of a mix, not the cleanest, but it worked and I didn't feel like refactoring it all to one style.

## Why assembly

No good reason honestly, just wanted to see if I could pull it off without any high-level language safety net. Debugging a duplicate-check off-by-one with nothing but registers and a stack diagram is a special kind of pain, but it does make the concepts stick.

## License

Do whatever you want with it.
