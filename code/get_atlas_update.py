#!/bin/python
#
#
#
#
#
#
# This script updates a given atlas image to concatenate
# a set of ROIs into a cohesive group to be used
# within ROI2BRAIN connectivity extraction
#
#
#########################################
#                                       #
#            LOAD LIBRARIES             #
#                                       #
#########################################


import numpy, os, nibabel, argparse, sys

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


def get_mask(_id, _atlas):
    '''
    return binary mask for given ROI id
    '''
    out = numpy.zeros(atlas.shape)
    for i in _id:
        out = out + numpy.where(_atlas == i,1,0)
    return(numpy.where(out != 0,1,0).astype(numpy.float64))

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
    return(numpy.where(_lut[:,_grouping] == _roi)[0].astype(numpy.int64))
    # return(_lut[numpy.where(_lut[:,_grouping] == _roi)[0],0].astype(numpy.int64))

def get_rois():
    '''
    return list of ROIs to concatenate from parser
    '''
    return([ s for s in args.grouping.split(',')])

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


parser = argparse.ArgumentParser(description='prepare atlas ROIs')
parser.add_argument("--path", help='Define input directory.', type=str, default = '/data')
parser.add_argument("--atlas", help='Define input atlas.', type=str, default = 'MAPA3Hemi')
parser.add_argument("--update", help='Define update ROI naming.', type=str, default = 'agranular')
parser.add_argument("--grouping", help='Define ROIs to concatenate.', type=str, default = 'Ia2_L,Ia3_L,Ia1_L,Ia2_R,Ia3_R,Ia1_R')

args = parser.parse_args()

log_msg(f'START | updating {args.atlas} using {args.grouping}.')

# ---- load look-up table ---- #
lut = numpy.genfromtxt(os.path.join(args.path, args.atlas, 'lut.tsv'), dtype = str, delimiter = ';')

# ---- load atlas parcellation volume ---- #
atlas = nibabel.load(os.path.join(args.path, args.atlas, f'{args.atlas}_MNI152.nii.gz'))
affine = atlas.affine
data = atlas.get_fdata()

# ---- get ROI luist ---- #
rois = get_rois()

out_dir = os.path.join(args.path, f'{args.atlas}-{args.update}')

if not os.path.isdir(out_dir):
    os.makedirs(out_dir)

grouping = check_grouping(rois, lut)


roi_ids = [ get_id(r, grouping, lut) for r in rois ]
roi_ids.sort()
new_id = lut[roi_ids[0],0].astype(numpy.int64)
lut_update = numpy.delete(lut, roi_ids[1:], axis = 0)

lut_update[new_id,0] = str(new_id[0])
lut_update[new_id,grouping] = args.update

dims = numpy.arange(1,lut.shape[1])

for d in dims:
    if not d == grouping:
        lut_update[new_id,d] = ''


data_update = data.copy()

for r in roi_ids:
    data_update = numpy.where(data_update == r,roi_ids[0],data_update)


save_image(data_update.astype(numpy.float64),os.path.join(out_dir,f'{args.atlas}-{args.update}_MNI152.nii.gz'),affine)
numpy.savetxt( os.path.join(out_dir, 'lut.tsv'), lut_update, delimiter = ';', fmt = '%s')


log_msg(f'FINISHED | updating {args.atlas} using {args.grouping}.')
