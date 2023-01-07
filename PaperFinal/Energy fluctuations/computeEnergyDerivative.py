# Open averages_L48.dat and compute the energy derivative (2nd column) depending on the temperature (1st column)

import numpy as np

# Read the data
data = np.loadtxt("averages_L48.dat")

temp, energy, specHeat = data[:, 0], data[:, 1], data[:, -2]

# Compute the derivative
derivative = np.gradient(energy, temp)

# Write the derivative to a file
np.savetxt("energy_derivative_vs_specific_heat.dat", np.transpose([temp, derivative, specHeat]))
