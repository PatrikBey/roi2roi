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

def save_image(_array, _filename, _affine):
    '''
    save _array as Nifti volume
    '''
    nii = nibabel.Nifti1Image(_array, _affine)
    nii.to_filename(_filename)


#########################################
#                                       #
#         INITIALIZE VARIABLES          #
#                                       #
#########################################


parser = argparse.ArgumentParser(description=' ')
parser.add_argument("--path", help='Define input directory.', type=str, default = '/data/MAPA3Hemi-ROI2BRAIN-Op2_L')
parser.add_argument("--roi", help='Define input seed ROI.', type=str, default = 'Op2_L')
parser.add_argument("--atlas", help='define atlas used', type=str, default='MAPA3Hemi')
args = parser.parse_args()

log_msg(f'START | Extracting {args.roi}2brain conenctivity vector.')


# ---- load atlas parcellation ---- #
if os.path.isfile(os.path.join(os.path.dirname(args.path), args.atlas, f'{args.atlas}_mrtrix3.nii.gz')):
    atlas = nibabel.load(os.path.join(os.path.dirname(args.path), args.atlas, f'{args.atlas}_mrtrix3.nii.gz'))
else:
    atlas = nibabel.load(os.path.join(os.path.dirname(args.path), args.atlas, f'{args.atlas}_MNI152.nii.gz'))

affine = atlas.affine
data = atlas.get_fdata()

# ---- load atlas LUT ---- #
if os.path.isfile(os.path.join(os.path.dirname(args.path), args.atlas, 'lut_mrtrix3.tsv')):
    lut = numpy.genfromtxt(os.path.join(os.path.dirname(args.path), args.atlas, 'lut_mrtrix3.tsv'), dtype = str, delimiter = ';')
else:
    lut = numpy.genfromtxt(os.path.join(os.path.dirname(args.path), args.atlas, 'lut.tsv'), dtype = str, delimiter = ';')



weight_file = os.path.join(args.path, 'weights', f'{args.roi}.tsv')

weights = numpy.genfromtxt(weight_file)

atlas_dim = weights.shape[1]

grouping = check_grouping([args.roi],lut)
roiid = get_id(args.roi, grouping, lut)

# ---- get ROI seed connectivity row ---- #

roi_connectivity = weights[roiid-1,:]

combined = numpy.zeros([2,atlas_dim]).astype(object)
combined[0,:] = list(lut[1:,grouping])
combined[1,:] = roi_connectivity


# ---- fill volume with connection strength ---- #
parc_strength = numpy.zeros(data.shape)
empty = numpy.array([0.])
for i in numpy.arange(1,roi_connectivity.shape[1]):
    tmp = numpy.where(data == i,roi_connectivity[0,i],0)
    if roi_connectivity[0,i] != 0. :
        tmp = tmp / len(numpy.where(tmp!=0)[0])
    parc_strength = parc_strength + tmp



roi_connectivity = numpy.delete(combined,roiid-1, axis = 1)

# ---- save connectivity vector and volume ---- #
save_image(parc_strength, os.path.join(args.path,'weights',f'{args.roi}-connectivity.nii.gz'), affine)
numpy.savetxt(os.path.join(args.path, 'weights', f'{args.roi}2brain.tsv'), roi_connectivity, fmt = '%s')


log_msg(f'FINISHED | Extracting {args.roi}2brain conenctivity vector.')


