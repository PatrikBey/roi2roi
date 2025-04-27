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

import numpy, os, argparse, sys, nibabel


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

def check_grouping(_list, _lut):
    '''
    return grouping dimension of ROI names
    from given LUT
    '''
    # initialize grouping counter to spot non-uniqueness
    count = 0
    for group in numpy.arange(_lut.shape[1]):
        if _list[0] in _lut[:,group]:
            log_msg(f'UPDATE | using ROIs defined in <<{_lut[0, group]}>>')
            count += 1
            out = group
    if count > 1:
        log_msg(f'ERROR | Found multiple entries for seeds in look-up table.')
        sys.exit(1)
    return(out)

def get_id(_roi, _grouping, _lut):
    '''
    return ID for a given ROI
    '''
    return(_lut[numpy.where(_lut[:,_grouping] == _roi)[0],0].astype(numpy.int64))


#########################################
#                                       #
#         INITIALIZE VARIABLES          #
#                                       #
#########################################


parser = argparse.ArgumentParser(description=' ')
parser.add_argument("--path", help='Define input directory.', type=str, default = '/data/MAPA3-ROI2BRAIN-pOFC')
parser.add_argument("--roi", help='Define input seed ROI.', type=str, default = 'pOFC')
parser.add_argument("--atlas", help='define atlas used', type=str, default='MAPA3')
args = parser.parse_args()

log_msg('START | Combining ROI pair wise connection weights.')

# ---- load atlas parcellation ---- #
if os.path.isfile(os.path.join(os.path.dirname(args.path), args.atlas, f'{args.atlas}_mrtrix3.nii.gz')):
    atlas = nibabel.load(os.path.join(os.path.dirname(args.path), args.atlas, f'{args.atlas}_mrtrix3.nii.gz'))
else:
    atlas = nibabel.load(os.path.join(os.path.dirname(args.path), args.atlas, f'{args.atlas}_MNI152.nii.gz'))

data = atlas.get_fdata()

# ---- load atlas LUT ---- #
if os.path.isdir(os.path.join(os.path.dirname(args.path), args.atlas, 'lut_mrtrix3.tsv')):
    lut = numpy.genfromtxt(os.path.join(os.path.dirname(args.path), args.atlas, 'lut_mrtrix3.tsv'), dtype = str, delimiter = ';')
else:
    lut = numpy.genfromtxt(os.path.join(os.path.dirname(args.path), args.atlas, 'lut.tsv'), dtype = str, delimiter = ';')



weight_file = os.path.join(args.path, 'weights', f'{args.roi}.tsv')

weights = numpy.genfromtxt(weight_file)


roiid = get_id(args.roi, check_grouping([args.roi], lut), lut)

# ---- get ROI seed connectivity row ---- #

roi_connectivity = weights[roiid-1,:]


roi_connectivity = numpy.delete(roi_connectivity,roiid-1)




