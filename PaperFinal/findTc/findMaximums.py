# Read all data from all files. Find the maximum value for suscetibility and specific heat for each system size.

import numpy as np
import os

import matplotlib.pyplot as plt

files = [f for f in os.listdir(".") if f.endswith(".dat") and f.startswith("averages")]
# Header:
# Temperature, Energy, Energy squared, Magnetization, Magnetization squared, Magnetization absolute, Specific heat, Magnetic susceptibility

maximums = []
fig, ax = plt.subplots(2, 1, sharex=True)

ax[0].set_title("Specific heat")
ax[1].set_title("Magnetic susceptibility")
for f in files:
    L = int(f.split("L")[1].split(".dat")[0])
    data = np.loadtxt(f, skiprows=1)
    T = data[4:-5, 0]
    C = data[4:-5, 6]
    X = data[4:-5, 7]
    magabs = data[4:-5, 5]

    maxC = T[np.argmax(C)]
    maxX = T[np.argmax(X)]

    C = C - np.min(C)
    X = X - np.min(X)

    C = C / np.trapz(C, T)
    X = X / np.trapz(X, T)

    # Using C and X as a "probability" distribution, find the maximum value and the error
    # Compute the mean by integrating the distribution
    meanC = np.trapz(C * T, T)
    meanX = np.trapz(X * T, T)

    meanC2 = np.trapz(C * T**2, T)
    meanX2 = np.trapz(X * T**2, T)

    errC = np.sqrt(meanC2 - meanC**2) / np.sqrt(L)
    errX = np.sqrt(meanX2 - meanX**2) / np.sqrt(L)

    maxCv = np.max(C)
    maxXv = np.max(X)
    critMagabsC = magabs[np.argmax(C)]
    critMagabsX = magabs[np.argmax(X)]

    maximums.append([L, maxC, errC, maxX, errX, maxCv, maxXv, critMagabsC, critMagabsX])
    print(maximums[-1])

    h = 0.2
    ax[0].plot(T, C, label="L = {}".format(L))
    ax[0].plot([meanC, meanC], [h * len(maximums) + 0.5, h * len(maximums) + 1], "--", color="C{}".format(len(maximums) - 1))
    ax[0].plot([meanC - errC, meanC + errC], [h * len(maximums) + 0.5, h * len(maximums) + 0.5], color="C{}".format(len(maximums) - 1))

    ax[1].plot(T, X, label="L = {}".format(L))
    ax[1].plot([meanX, meanX], [h * len(maximums) + 0.5, h * len(maximums) + 1], "--", color="C{}".format(len(maximums) - 1))
    ax[1].plot([meanX - errX, meanX + errX], [h * len(maximums) + 0.5, h * len(maximums) + 0.5], color="C{}".format(len(maximums) - 1))

plt.legend()
plt.show()


maximums = np.array(maximums)
np.savetxt("maximums.dat", maximums, header="L, T_max_C, errC, T_max_X, errX, maxC, maxX, critMagabsC, critMagabsX")

from sklearn.linear_model import LinearRegression

# Find linear fit for the maximum values of specific heat and magnetic susceptibility
L, TC, errC, TX, errX = maximums.T
L = L.reshape(-1, 1)
TC = TC.reshape(-1, 1)
TX = TX.reshape(-1, 1)

modelC = LinearRegression().fit(1 / L, TC)
modelX = LinearRegression().fit(1 / L, TX)

newX = np.linspace(0, 1 / L.min(), 100)[1:]
newYC = modelC.predict(newX.reshape(-1, 1))
newYX = modelX.predict(newX.reshape(-1, 1))

np.savetxt("fitC.dat", np.column_stack((newX, newYC, newYX)), header="1/L, T_max_C, T_max_X")

print("C: ", modelC.coef_, modelC.intercept_)
print("X: ", modelX.coef_, modelX.intercept_)
