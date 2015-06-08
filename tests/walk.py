#!/usr/bin/env python3

import os
import subprocess
import sys

def check(args):
    if len(args) == 1 and os.path.isdir(args[0]):
        return True
    else: return False

def walk(path):
    for root, dirs, files in os.walk(path):
        if "paje.trace" in files:
            with open(os.path.join(root, os.path.basename(root) + ".out"), "w") as outfile:
                subprocess.call("yaros " + os.path.join(root, "paje.trace"), stdout=outfile, shell=True)

if __name__ == "__main__":
    if not check(sys.argv[1:]):
        print("Wrong usage")
        sys.exit(2)
    else:
        walk(sys.argv[1])
        sys.exit(0)
