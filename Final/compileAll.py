"""
Compile all the fortran codes in the lib folder.
"""

import os


def compile():
    """
    Compile all the fortran codes in the lib folder.
    """
    files = os.listdir("lib")
    toCompile = [file for file in files if file.endswith(".f90")]

    deps = [file for file in files if file.endswith((".o", ".mod"))]
    deps = " ".join([os.path.join("lib", file) for file in deps])

    for file in toCompile:
        fortranFile = os.path.join("lib", file)
        exeFile = os.path.join("execs", os.path.splitext(file)[0] + ".exe")
        os.system(f"gfortran -O3 {deps} {fortranFile} -o {exeFile}")
