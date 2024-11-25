#!/usr/bin/env python3

import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument("--input1", required=True)
parser.add_argument("--input2", required=True)
parser.add_argument("--output", required=True)
args = parser.parse_args()

with open(args.output, "a") as f:
    print("example output:", file=f)
    print("input1:", args.input1, file=f)
    print("input2:", args.input2, file=f)
    print("input2 file size:", os.path.getsize(args.input2), file=f)
