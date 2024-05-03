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
import numpy as np
from skimage.metrics import structural_similarity,mean_squared_error

import ofl,os

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--threshold", type=int, help="threshold to fulfill for a successful exit code", default=4)
parser.add_argument("-v", "--verbosity", type=int, help = "Increase verbosity", choices=[ofl.SILENT,ofl.ERROR,ofl.WARN,ofl.INFO,ofl.DEBUG],default=ofl.ERROR)
parser.add_argument("image1", help="First image to test")
parser.add_argument("image2", help="Second image to test")

args = parser.parse_args()

ofl.verbosity   = args.verbosity

img1    = cv2.imread(args.image1)
img2    = cv2.imread(args.image2)

img1_gray = cv2.cvtColor(img1, cv2.COLOR_BGR2GRAY)
img2_gray = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)

# Compute SSIM between two images
score = round(structural_similarity(img1_gray, img2_gray)*100)
# print("Image similarity", score)
if score!=100:
  ofl.warn(f"{args.image1} differs from {args.image2} (similarity is only {score}%)")
  exit(1)
else:
  ofl.info(f"{args.image1} is a copy of {args.image2}")
