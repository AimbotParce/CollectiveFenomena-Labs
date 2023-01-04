# Monte Carlo simulation for a 2D Ising model

To run the simulation, run the `parallelTemperatureLoop.py` script. It will compute in parallel exactly 50 temperatures. Keep in mind this program will generate around 32Gb of data, so run it carefully.

After the simulation is finished (around 5h in my computer), run `execs\MC2-averages.exe` to compute the overall averages for all the simulations. It will spit out a `dat\averages.dat` file with the simulation results depending on the temperature.

Finally, run `gnuplot gnu\plot_averages.gnu` to plot the diagrams into the `plots\` folder - temperature over temperature is my favorite.

Note that the temperatures are aproximately spaced acording to a gaussian distribution centered at T=2.3, which is roughly the region of interest.

If you wish to change the parameters of the simulation, you can do so in the `dat\MC2.dat` file, if you wish to change the temperatures that should be simulated, you'll have to change them in the `parallelTemperatureLoop.py` python script.

If you have any questions, please contact me at marcparcerisa@gmail.com or mparceco7@alumnes.ub.edu.
