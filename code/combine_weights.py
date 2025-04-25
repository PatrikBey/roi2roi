#!/bin/python
#
#
#
#
#
#
# This script combines ROI pair wise connectivity into
# a single connectivity matrix
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
#           DEFINE FUNCTIONS            #
#                                       #
#########################################

def log_msg(_string):
    '''
    logging function printing date, scriptname & input string to stdout
    '''
    import datetime, os, sys
    print(f'{datetime.date.today().strftime("%a %B %d %H:%M:%S %Z %Y")} {str(os.path.basename(sys.argv[0]))}: {str(_string)}')


#########################################
#                                       #
#         INITIALIZE VARIABLES          #
#                                       #
#########################################


parser = argparse.ArgumentParser(description='provide seed / target ROI names')
parser.add_argument("--path", help='Define input directory.', type=str, default = '/data/AAL3-DMN-L2R')
args = parser.parse_args()

log_msg('START | Combining ROI pair wise connection weights.')

# ---- prepare ROI lists ---- #
seed_list = os.listdir(os.path.join(args.path, 'seed','roi_masks'))
seed_list = [ s[:-7] for s in seed_list]
target_list = os.listdir(os.path.join(args.path, 'target','roi_masks'))
target_list = [ t[:-7] for t in target_list]

# ---- initialize weight matrices
weights = numpy.zeros([len(seed_list), len(target_list)]).astype(object)
combined = numpy.empty([len(seed_list)+1, len(target_list)+1]).astype(object)
combined[0,:] = ['seed/target'] + target_list
combined[1:,0] = seed_list

# ---- combine weight files ---- #
for s in seed_list:
    for t in target_list:
        tmp = numpy.genfromtxt(os.path.join(args.path, 'weights',f'{s}-{t}.tsv'))
        weights[seed_list.index(s), target_list.index(t)] = tmp[0,1].astype(str)

combined[1:,1:] = weights

# ---- save as single output ---- #
numpy.savetxt(os.path.join(args.path, 'Seed2TargetROI_weights.tsv'), combined, fmt='%s')

log_msg('FINISHED | Combining ROI pair wise connection weights.')

