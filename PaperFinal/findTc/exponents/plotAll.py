import os

files = [f for f in os.listdir("exponents") if f.endswith(".gnu") or f.endswith(".gnuplot")]

for f in files:
    os.system("gnuplot exponents/{}".format(f))
