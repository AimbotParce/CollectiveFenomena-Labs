# usage: listFiles.py <directory> <output file>

import os
import sys


def listFiles(dir, fileName):
    with open(fileName, "w") as f:
        for root, dirs, files in os.walk(dir):
            filecount = 0
            for file in files:
                if file.startswith("."):
                    continue
                filecount += 1
            f.write(str(filecount) + "\n")
            for file in files:
                if file.startswith("."):

                    continue  # skip hidden files
                f.write(os.path.join(root, file) + "\n")


if __name__ == "__main__":
    listFiles(sys.argv[1], sys.argv[2])
