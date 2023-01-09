# Read all data from all files. Find the maximum value for suscetibility and specific heat for each system size.

import numpy as np
import os

import matplotlib.pyplot as plt

files = [f for f in os.listdir("data") if f.endswith(".dat") and f.startswith("averages")]
# Header:
# Temperature, Energy, Energy squared, Magnetization, Magnetization squared, Magnetization absolute, Specific heat, Magnetic susceptibility

Tc = 2.266
nu = 0.9
alpha = 0.24
beta = 0.10
gamma = 1.58

Cfig = plt.figure()
plt.title("Specific heat")
Xfig = plt.figure()
plt.title("Susceptibility")
magabsfig = plt.figure()
plt.title("Magnetization absolute")

for f in files:
    L = int(f.split("L")[1].split(".dat")[0])
    data = np.loadtxt(os.path.join("data", f), skiprows=1)
    T = data[4:, 0]
    C = data[4:, 6]
    X = data[4:, 7]
    magabs = data[4:, 5]

    newT = (T - Tc) / Tc * L ** (1 / nu)
    newC = C / L ** (alpha / nu)
    newX = X / L ** (gamma / nu)
    newmagabs = magabs / L ** (beta / nu)

    maximums = np.array([newT, newC, newX, newmagabs])
    np.savetxt(
        f'scaled/{f.split(".")[0]}.dat',
        maximums.T,
        header="T, C, X, magabs",
    )
    plt.figure(Cfig.number)
    plt.plot(newT, newC, label=f"L={L}")
    plt.figure(Xfig.number)
    plt.plot(newT, newX, label=f"L={L}")
    plt.figure(magabsfig.number)
    plt.plot(newT, newmagabs, label=f"L={L}")

Cfig.legend()
Xfig.legend()
magabsfig.legend()

plt.show()
