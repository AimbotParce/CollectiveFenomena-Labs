# Given that I mainly program in python language, i sort of decided to use it to parallelize the temperature loop.
# I've tried to use existing fortran parallelization, but I couldn't get it to work.
# So I've decided to use python's multiprocessing module to parallelize the temperature loop.

# We'll generate the temperatures to be computed in a gaussian distribution-like way around T=2.3.
import numpy as np
from scipy import stats

# Generate a normal distribution with mean 1.3 and standard deviation 0.2.
distribution = stats.norm(loc=2.3, scale=0.3)
bounds_for_range = distribution.cdf([1.5, 3.0])

temperatures = np.linspace(*bounds_for_range, num=50)
temperatures = distribution.ppf(temperatures)
# x should now be a list of 50 temperatures, with mean 1.3 and standard deviation 0.2.

# Fix the first temperature to be 1.5, and the last to be 4.5.
temperatures[0] = 1.5
temperatures[-1] = 3.0


import logging as log

# We'll use the logging module to format logs correctly.
log.basicConfig(level=log.INFO, format="[%(asctime)s] %(levelname)s # %(message)s", datefmt="%H:%M:%S")
log.getLogger().setLevel(log.INFO)

import os  # To call the fortran program.
import time

# Loop temperatures (The programs read first the temperature and then start the metropolis loop.)
# The only thing this script has to do is decide the next temperature to be computed, then call the
# fortran program (execs/MC2-single-temperature.exe -t <temperature> -h <height> -w <width>).
from concurrent.futures import ThreadPoolExecutor


# Before starting, make sure the folder (specified in dat/MC2.dat) exists.ç
with open("dat/MC2.dat", "r") as f:
    for line in f:
        args = line.split("=")
        if args[0].strip() == "folderName":
            folder = args[1].strip().strip(",").strip('"')

os.makedirs(os.path.join("dat", folder), exist_ok=True)

log.info("Compiling all fortran codes...")
import compileAll

compileAll.compile()
log.info("Done compiling.")


initialTime = time.time()

threadPool = ThreadPoolExecutor(max_workers=6)
# We'll compute 6 temperatures at the same time (That's the ammount of cores in my computer.)


def run(temperature, height, width):
    log.info(f"Computing temperature {temperature:.5f}...")
    executable = os.path.join("execs", "MC2-single-temperature.exe")
    args = f"-t {temperature:.5f} -h {height} -w {width}"
    logOutput = os.path.join("logs", f"T{temperature:.5f}_L{height}.txt")  # Suppose height = width = L
    os.system(f"{executable} {args} > {logOutput}")
    # I've added the > {logOutput} to redirect the output of the program to a file.


log.info("Computing temperatures...")
for geom in [12, 24, 36, 48, 60, 72]:  # Compute for different system sizes
    height = geom
    width = geom
    for temperature in temperatures:
        threadPool.submit(run, temperature, height, width)

# Wait for all threads to finish.
threadPool.shutdown(wait=True)
finalTime = time.time()
log.info(f"All temperatures computed. Time elapsed: {finalTime-initialTime:.1f} seconds.")
