## Walkthrough of the algorithm

Problem: [Model E1337 - Rolling Code Lock V2](https://ctf.hacker101.com/ctf)

The idea of this solution is to recover the original state based on the bits provided by the first two codes.

There are a few things to keep in mind:

1. For the first state we know that for every 4 bits the first and the last bits are the same
2. The last bit of every state matches sets a bit in the code, so we can reverse engineer the operations on the last bit to form an equation

We need to create 64 equations and solve them to get the original state.

### Solving equations

Algorithm used: Gaussian Elimination of Quadratic Matrices
Wikipedia reference: algorithm: https://en.wikipedia.org/wiki/Gaussian_elimination

I've adapted it for XOR operations, but I'm sure I could have simplified things.
