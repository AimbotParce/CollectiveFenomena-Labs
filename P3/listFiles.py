# usage: listFiles.py <directory> <output file>

import os
import sys


def listFiles(dir, fileName):
    with open(fileName, "w") as f:
        for root, dirs, files in os.walk(dir):
            f.write(str(len(files)) + "\n")
            for file in files:
                f.write(os.path.join(root, file) + "\n")


if __name__ == "__main__":
    listFiles(sys.argv[1], sys.argv[2])
