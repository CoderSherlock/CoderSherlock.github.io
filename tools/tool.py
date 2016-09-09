#!/usr/bin/python

import argparse
import os






def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("op")
    parser.add_argument("type")
    res = parser.parse_args()
    print(res)


if __name__ == "__main__":
    main()
