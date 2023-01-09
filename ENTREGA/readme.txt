Marc Parcerisa - MC2 (single temperature).f90 is the code for a single temperature, single L computation. This is called in parallel.

I've coppied it outside the CODE folder for you to be able to locate it fast and grade it without having to search throughout multiple
folders.

If you wish to see the whole machinery, CODE/parallelTemperatureLoop.py runs the parallelization. CODE/lib/MC2-single-temperature.f90 
runs the simulations (it's the file that I've coppied outside the CODE/ folder). And CODE/lib/MC2-averages.f90 computes the overall
averages.