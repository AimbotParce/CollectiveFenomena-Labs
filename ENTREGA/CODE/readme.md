# Monte Carlo simulation for a 2D Ising model

To run the simulation, run the `parallelTemperatureLoop.py` script. It will recompile all the fortran files in the `lib/` directory, then compute in parallel exactly 50 temperatures, previously generated as a sparse, gaussian distribution around the temperature T=2.3, which should be roughly where the phase transition is, for each of the following system sizes: 12, 24, 36, 48, 60, 72. Keep in mind this program will generate around 200Gb of data, so run it carefully.

After the simulation is finished (around 29.5 hours in my computer), run `execs\MC2-averages.exe` to compute the overall averages for all the simulations. It will spit out a series of `dat/averages/<geometry>.dat` files with the simulation results depending on the temperature and the geometry of the system.

Finally, run `gnuplot gnu/plotAverages.gnu` to plot the diagrams into the `plots/` folder - temperature over temperature is my favorite.

If you wish to change the parameters of the simulation, you can do so in the `dat/MC2.dat` file, if you wish to change which temperatures should be computed, you'll have to change them in the `parallelTemperatureLoop.py` python script.

If you have any questions, please contact me at marcparcerisa@gmail.com or mparceco7@alumnes.ub.edu.
