# Given that I mainly program in python language, i sort of decided to use it to parallelize the temperature loop.
# I've tried to use existing fortran parallelization, but I couldn't get it to work.
# So I've decided to use python's multiprocessing module to parallelize the temperature loop.

# We'll generate the temperatures to be computed in a gaussian distribution-like way around T=2.3.
import numpy as np
from scipy import stats

# Generate a normal distribution with mean 1.3 and standard deviation 0.2.
distribution = stats.norm(loc=2.3, scale=0.5)
bounds_for_range = distribution.cdf([1.5, 4.5])

temperatures = np.linspace(*bounds_for_range, num=50)
temperatures = distribution.ppf(temperatures)
# x should now be a list of 50 temperatures, with mean 1.3 and standard deviation 0.2.

# Fix the first temperature to be 1.5, and the last to be 4.5.
temperatures[0] = 1.5
temperatures[-1] = 4.5


import logging as log

# We'll use the logging module to format logs correctly.
log.basicConfig(level=log.INFO, format="[%(asctime)s] %(levelname)s # %(message)s", datefmt="%H:%M:%S")
log.getLogger().setLevel(log.INFO)

import os  # To call the fortran program.
import time

# Loop temperatures (The programs read first the temperature and then start the metropolis loop.)
# The only thing this script has to do is decide the next temperature to be computed, then call the
# fortran program (execs/MC2-single-temperature.exe -t <temperature>).
from concurrent.futures import ThreadPoolExecutor

initialTime = time.time()

threadPool = ThreadPoolExecutor(max_workers=16)  # We'll compute 16 temperatures at the same time.


def computeTemperature(temperature):
    log.info(f"Computing temperature {temperature:.5f}...")
    os.system(
        f".{os.sep}execs{os.sep}MC2-single-temperature.exe -t {temperature:.5f} > .{os.sep}logs{os.sep}{temperature:.5f}.txt"
    )
    # I've added the > .{os.sep}logs{os.sep}{temperature:.5f}.txt to redirect the output to a file.


log.info("Computing temperatures...")
for temperature in temperatures:
    threadPool.submit(computeTemperature, temperature)

# Wait for all threads to finish.
threadPool.shutdown(wait=True)
finalTime = time.time()
log.info(f"All temperatures computed. Time elapsed: {finalTime-initialTime:.1f} seconds.")
