# Normalize data on this folder (divide it by 48^2)

import os

L = 48
N = L * L

files = [f for f in os.listdir(".") if f.endswith(".dat")]

for f in files:
    with open(f, "r") as fin:
        with open(".".join(f.split(".")[0:2]) + ".norm", "w") as fout:
            for line in fin:
                if line.startswith("#") or line.startswith(" #"):
                    fout.write(line)
                else:
                    # Lines are written as "i14, f14, i14"
                    # We want to normalize the second and third columns

                    # Get the first column
                    fout.write(line[:14])
                    # Normalize the second column
                    fout.write(f"   {float(line[14:28]) / N}")
                    # Normalize the third column
                    fout.write(f"   {float(line[28:42]) / N}\n")
