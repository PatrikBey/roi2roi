#!/bin/python
#
#
#
#
#
#
# This script extract relevant tract length
# for a given combination of seed and target ROI
#
#
#
#########################################
#                                       #
#            LOAD LIBRARIES             #
#                                       #
#########################################

import numpy, os, argparse, sys


#########################################
#                                       #
#         INITIALIZE VARIABLES          #
#                                       #
#########################################


# ---- parse input arguments ---- #

parser = argparse.ArgumentParser(description='provide seed / target ROI names')
parser.add_argument("--path", help='Define input directory.', type=str, default = '/data')
parser.add_argument("--atlas", help='Define atlas.', type=str, default = 'MAPA3Hemi')
parser.add_argument("--seed", help='Define seed ROI.', type=str, default = 'Ia1_L')
parser.add_argument("--target", help='Define target ROI.', type=str, default = 'Ia1_R')
parser.add_argument("--ratio", help='Define length extension ratio', type=float, default = 0.05)
args = parser.parse_args()


# ---- load look-up table ---- #
lut = numpy.genfromtxt(os.path.join(args.path, args.atlas, 'lut.tsv'), dtype = str, delimiter = ';')
rois = list(lut[1:,1])
# ---- load lengths file ---- #
lengths = numpy.genfromtxt(os.path.join(args.path, args.atlas, f'{args.atlas}_tract_lengths.tsv'), delimiter= '\t', dtype=str)

# ---- get pair length ---- #

initial_length = lengths[rois.index(args.seed), rois.index(args.target)].astype(float)


# ---- parse length ranges ---- #

min_length = numpy.round((1-args.ratio)*float(initial_length)).astype(int)
max_length = numpy.round((1+args.ratio)*float(initial_length)).astype(int)

print(f'{min_length},{max_length}')