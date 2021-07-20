from z3 import *

toppings = Bools('A B C D E F G H I J K L M N O P')
base = ord("A")

def requirements(line):
    reqs = []

    for sign, topping in zip(line[::2], line[1::2]):
        index = ord(topping) - base

        if sign == "+":
            reqs.append(toppings[index])
        else:
            reqs.append(Not(toppings[index]))

    return Or(reqs)

def print_model(model):
    solution = []

    for x in model:
        if is_true(model[x]):
            solution.append(x.name())

    solution.sort()
    print(solution)

lines = open('toppings.txt').readlines()
s = Solver()
constraints = []

for line in lines:
    if line.strip() == ".":
        s.add(constraints)
        if s.check() == sat:
            print_model(s.model())
        else:
            print("Impossible!")

        s = Solver()
        constraints = []
        continue

    constraints.append(requirements(line[:-1]))





