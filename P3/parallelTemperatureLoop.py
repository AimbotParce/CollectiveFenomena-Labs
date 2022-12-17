# Given that I mainly program in python language, i sort of decided to use it to parallelize the temperature loop.
# I've tried to use existing fortran parallelization, but I couldn't get it to work.
# So I've decided to use python's multiprocessing module to parallelize the temperature loop.

from concurrent.futures import ThreadPoolExecutor


# Loop temperatures (The programs read first the temperature and then start the metropolis loop.)
# The only thing this script has to do is decide the next temperature to be computed, then call the
# fortran program (execs/MC2-single-temperature.exe -t <temperature>).
