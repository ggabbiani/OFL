#!/usr/bin/env python3
#
# image diff
#
# This file is part of the 'OpenSCAD Foundation Library' (OFL) project.
#
# Copyright © 2021, Giampiero Gabbiani <giampiero@gabbiani.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

import argparse
import cv2
import datetime
import subprocess

from skimage.metrics import structural_similarity,mean_squared_error
from termcolor import colored, cprint

import ofl,os

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--threshold", type=int, help = "minimum threshold proving image similarity", default=100)
parser.add_argument("-v", "--verbosity", type=int, help = "Increase verbosity", choices=[ofl.SILENT,ofl.ERROR,ofl.WARN,ofl.INFO,ofl.DEBUG],default=ofl.ERROR)
parser.add_argument("images", help="Images to test", nargs=2)

args = parser.parse_args()

ofl.verbosity = args.verbosity

num_images  = len(args.images)
if num_images>2:
  ofl.error("max two images are allowed")
  exit(1)

first   = args.images[0]
second  = args.images[1]
ofl.info(f"comparing '{first}' with '{second}'")

img1    = cv2.imread(first)
img2    = cv2.imread(second)

img1_gray = cv2.cvtColor(img1, cv2.COLOR_BGR2GRAY)
img2_gray = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)

# Compute SSIM between two images
score = round(structural_similarity(img1_gray, img2_gray)*100)
if score<args.threshold:
  cprint(f'{score}%','red',end=" ")
  # ofl.error(f"insufficient {score}% similarity")
  exit(1)
else:
  cprint(f'{score}%','green',end=" ")
  # ofl.info(f"{first} looks {score}% like {second}")
