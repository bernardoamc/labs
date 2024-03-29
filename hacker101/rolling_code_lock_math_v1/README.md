## Walkthrough of the algorithm

Problem: [Model E1337 - Rolling Code Lock](https://ctf.hacker101.com/ctf)

The idea of this solution is to recover the original state based on the bits provided by the first two codes.

There are a few things to keep in mind:

1. For the first state we know that for every 4 bits the first and the last bits are the same
2. The last bit of every state matches sets a bit in the code, so we can reverse engineer the operations on the last bit to form an equation

We need to create 64 equations and solve them to get the original state.

### Solving equations

Algorithm used: Gaussian Elimination of Quadratic Matrices
Wikipedia reference: algorithm: https://en.wikipedia.org/wiki/Gaussian_elimination

I've adapted it for XOR operations, but I'm sure I could have simplified things.

### Manual iteration of the first two states


State representation: A B C D E ... V X Y Z

Outer loop:
 - Left shift the current state by 1 bit
 - XOR the highest 3 bits with the lowest 3 bits
 - Drop the highest bit (bit 65)
 - XOR every bit with 1

Inner loop:
- Make every 4 bits of state (B3, B2, B1, B0) into (B0, B0, B3, B3)
- Shift this value left by (iteration * 4) bits
- XOR these bits with the original state

**First run:**

```
((A B C D E F ... V X Y Z 0) XOR (0 0 0 0 ... A B C)) & 0xFFFFFFFFFFFFFFFF => (B C D E F... V X (Y^A) (Z^B) (0^C)
(B^1) (C^1) (D^1) (E^1) (F^1) (G^1) (H^1) (I^1)... (V^1 (X^1) (Y^A^1) (Z^B^1) (C^1)

    Inner loop:
        => (B^1) (C^1) (D^1) (E^1) (F^1) (G^1) (H^1) (I^1) ... (X^1) (Y^A^1) (Z^B^1) (C^1)
        => (E^1) (E^1) (B^1) (B^1) (I^1) (I^1) (F^1) (F^1) ... (C^1) (C^1) (X^1) (X^1)
        => (B^E) (C^E) (B^D) (B^E) (F^I) (G^I) (H^F) (F^I) ... (C^X) (A^C^Y) (B^X^Z) (C^X)
```

**Second run:**

```
(B^E) (C^E) (B^D) (B^E) (F^I) (G^I) (H^F) (F^I) ... (C^X) (A^C^Y) (B^X^Z) (C^X)
    => (C^E) (B^D) (B^E) (F^I) (G^I) (H^F) (F^I) ... (C^X) (A^C^Y) (B^X^Z) (C^X) 0) XOR (0 0 0 0 0 0 0 ... (B^E) (C^E) (B^D))) & 0xFFFFFFFFFFFFFFFF
    => (C^E) (B^D) (B^E) (F^I) (G^I) (H^F) (F^I) ... (C^X) (A^C^Y) (B^B^E^X^Z), (C^C^E^X), (B^D)
    => (C^E) (B^D) (B^E) (F^I) (G^I) (H^F) (F^I) ... (C^X) (A^C^Y) (E^X^Z), (E^X), (B^D)

    Inner loop:
        => (C^E) (B^D) (B^E) (F^I) (G^I) (H^F) (F^I) ... (C^X) (A^C^Y) (E^X^Z), (E^X), (B^D)
        => (F^I) (F^I) (C^E) (C^E) ....                         (B^D)   (B^D)  (A^C^Y) (A^C^Y)
        => (C^E^F^I) (B^D^F^I) (B^C) (F^C^E^I)       ...       (A^B^C^D^Y) (B^D^E^X^Z) (A^C^E^X^Y) (A^B^C^D^Y)
```
