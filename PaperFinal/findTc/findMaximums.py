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

    TcC = T[np.argmax(C)]
    TcX = T[np.argmax(X)]
    maxC = np.max(C)
    maxX = np.max(X)
    magabs_Tc_C = magabs[np.argmax(C)]
    magabs_Tc_X = magabs[np.argmax(X)]

    # Using C and X as a "probability" distribution, find the maximum value and the error
    # Compute the mean by integrating the distribution
    C = C - np.min(C)
    X = X - np.min(X)
    C = C / np.trapz(C, T)
    X = X / np.trapz(X, T)
    errC = np.sqrt(np.trapz(C * (T - TcC) ** 2, T))
    errX = np.sqrt(np.trapz(X * (T - TcX) ** 2, T))

    maximums.append([L, TcC, errC, TcX, errX, maxC, maxX, magabs_Tc_C, magabs_Tc_X])

    h = 0.2
    ax[0].plot(T, C, label="L = {}".format(L))
    ax[0].plot([TcC, TcC], [h * len(maximums) + 0.5, h * len(maximums) + 1], "--", color="C{}".format(len(maximums) - 1))
    ax[0].plot([TcC - errC, TcC + errC], [h * len(maximums) + 0.5, h * len(maximums) + 0.5], color="C{}".format(len(maximums) - 1))

    ax[1].plot(T, X, label="L = {}".format(L))
    ax[1].plot([TcX, TcX], [h * len(maximums) + 0.5, h * len(maximums) + 1], "--", color="C{}".format(len(maximums) - 1))
    ax[1].plot([TcX - errX, TcX + errX], [h * len(maximums) + 0.5, h * len(maximums) + 0.5], color="C{}".format(len(maximums) - 1))

plt.legend()
plt.show()


maximums = np.array(maximums)
np.savetxt(
    "maximums.dat",
    maximums,
    header="L, critical T (by Cv), err Tc (by Cv), critical T (by X), err Tc (by X), max Cv, max X, absolute magnetization at Tc (by Cv), absolute magnetization at Tc (by X",
)

from sklearn.linear_model import LinearRegression

# Find linear fit for the maximum values of specific heat and magnetic susceptibility
L, TcC, errTcC, TcX, errTcX, maxC, maxX, magabs_Tc_C, magabs_Tc_X = maximums.T
L = L.reshape(-1, 1)
TcC = TcC.reshape(-1, 1)
TcX = TcX.reshape(-1, 1)

modelC = LinearRegression().fit(1 / L, TcC)
modelX = LinearRegression().fit(1 / L, TcX)

newX = np.linspace(0, 1 / L.min(), 100)[1:]
newYC = modelC.predict(newX.reshape(-1, 1))
newYX = modelX.predict(newX.reshape(-1, 1))

np.savetxt("fitC.dat", np.column_stack((newX, newYC, newYX)), header="1/L, T_max_C, T_max_X")

print("C: ", modelC.coef_, modelC.intercept_)
print("X: ", modelX.coef_, modelX.intercept_)
