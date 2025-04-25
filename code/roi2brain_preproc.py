# 20250326 UPDATE MAPA
#
#
# STEPS OF THE PREPROCESSING WRAPPER
#
#
#
# 1. parse input variables
# 2. 





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


def get_mrtrix_compatibility(img):
    '''
    prepare a given parcellation image to fulfil MTRix3 requirement
    of continuous ROI ids
    '''
    ids = list(numpy.unique(img[img > 0]))
    out_img = numpy.zeros(img.shape)
    roi_counter = 1
    out_lut = numpy.empty([len(ids)+1,2])
    for i in ids:
        out_img = out_img + numpy.where(img == i,roi_counter,0)
        out_lut[roi_counter,0] = roi_counter
        out_lut[roi_counter,1] = i
        roi_counter += 1
        print(f'{int((roi_counter/len(ids))*100)}%', end='\r')
    out_lut = out_lut.astype(str)
    out_lut[0,:] = ['id', 'raw_id']
    return(out_img, out_lut)

def update_mrtrix_lut(_lut, _lut_mrtrix, _grouping):
    '''
    adjust the updated MRtrix3 compatible LUT
    with ROI names
    '''
    numpy.concatenate([_lut_mrtrix.reshape(-1,2), _lut[:,grouping].reshape(-1,1)], axis = 0)



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

#########################################
#                                       #
#         INITIALIZE VARIABLES          #
#                                       #
#########################################


# ---- parse input arguments ---- #

parser = argparse.ArgumentParser(description='PREPARE SEED/TARGET MASKS')
parser.add_argument("--path", help='Define input directory.', type=str, default = '/data')
parser.add_argument("--atlas", help='Define atlas name.', type=str, default = 'MAPA')
parser.add_argument("--seed", help='Define <<seed>> ROIs.', type=str, default = 'Id8')
parser.add_argument("--outdir", help='Define <<output directory>>.', type=str, default = '/data/MAPA-ROI2BRAIN-Id8')

args = parser.parse_args()

log_msg('START | preparing ROI seed mask and atlas.')
# ---- prepare working directory ---- #

if not args.outdir:
    outdir = os.path.join(args.path, args.atlas, f'run_{numpy.random.randint(1000,9999)}')
    log_msg(f'UPDATE | no output directory provided using random id: {outdir}')
else:
    outdir = args.outdir
    log_msg(f'UPDATE | Using provided output directory: {os.path.basename(outdir)}')

# ---- create output directories ---- #
if not os.path.isdir(outdir):
    os.makedirs(outdir)
    os.makedirs(os.path.join(outdir, 'roi_masks'))


# ---- load look-up table ---- #
lut = numpy.genfromtxt(os.path.join(args.path, args.atlas, 'lut.tsv'), dtype = str, delimiter = ';')

# ---- load atlas parcellation volume ---- #
atlas = nibabel.load(os.path.join(args.path, args.atlas, f'{args.atlas}_MNI152.nii.gz'))

affine = atlas.affine

data = atlas.get_fdata()

# ---- validate MRTrix3 compatibility of parcellation ---- #
ids = list(numpy.unique(data[data>0]))
if not len(ids) == ids[-1].astype(int) or not lut.shape[0] == data.max():
    log_msg('UPDATE | parcellation volume is not MRTrix3 compatible. Preparing updated image.')
    parc_mrtrix, lut_mrtrix = get_mrtrix_compatibility(data)
    save_image(parc_mrtrix, os.path.join(args.path, args.atlas, f'{args.atlas}_mrtrix3.nii.gz'), affine)
    numpy.savetxt(os.path.join(args.path, args.atlas, 'lut_mrtrix3.tsv'), lut_mrtrix, delimiter = '\t', fmt ='%s')
    data = parc_mrtrix.copy()


# ---- define ROI variables  ---- #

log_msg(f'UPDATE | creating {args.seed} ROI mask.')

grouping = check_grouping([args.seed], lut)

tmp = get_mask(get_id(args.seed,grouping, lut), data)

filename = os.path.join(outdir, 'roi_masks' ,f'{args.seed}.nii.gz')
save_image(tmp, filename, affine)

log_msg('FINISHED | preparing ROI seed mask and atlas.')

