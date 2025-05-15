





















import numpy, matplotlib.pyplot as plt, os, nibabel

reduced = numpy.genfromtxt(os.path.join('ROI2ROI-Left2Right','Seed2TargetROI_weights.tsv'))
full = numpy.genfromtxt(os.path.join('ROI2ROI-Left2Right-RERUN','Seed2TargetROI_weights.tsv'))




##### VALIDATING CROSS HEMISPHERE INSULAR CONNECTIONS #####


docker run -it -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Test_MNI152" roi2roi:dev bash

roi1="Ia1_L"
roi2="Ia1_R"




seed_roi_name=$roi1
target_roi_name=$roi2


python
import numpy, matplotlib.pyplot as plt, os, nibabel


lut = numpy.genfromtxt('lut_mrtrix3.tsv', dtype=str, delimiter = ';')
atlas = nibabel.load(os.path.join('MAPA3H_mrtrix3.nii.gz'))
img = atlas.get_fdata()
ids = numpy.unique(img[img>0]).astype(int)
roiid = list(lut[1:,0])

imgnew = img.copy()
ids = numpy.unique(img[img>0])




for i in numpy.arange(4.,ids.max()+1):
    imgnew = numpy.where(imgnew==i,i-1,imgnew)


idsnew = numpy.unique(imgnew[imgnew>0])

for i in numpy.arange(38.,idsnew.max()+1):
    imgnew = numpy.where(imgnew==i,i-1,imgnew)

idsnew = numpy.unique(imgnew[imgnew>0])

for i in numpy.arange(40.,idsnew.max()+1):
    imgnew = numpy.where(imgnew==i,i-1,imgnew)

idsnew = numpy.unique(imgnew[imgnew>0])

for i in numpy.arange(104.,idsnew.max()+1):
    imgnew = numpy.where(imgnew==i,i-1,imgnew)

idsnew = numpy.unique(imgnew[imgnew>0])

for i in numpy.arange(103.,idsnew.max()+1):
    imgnew = numpy.where(imgnew==i,i-1,imgnew)

idsnew = numpy.unique(imgnew[imgnew>0])

for i in numpy.arange(105.,idsnew.max()+1):
    imgnew = numpy.where(imgnew==i,i-1,imgnew)

idsnew = numpy.unique(imgnew[imgnew>0])

for i in numpy.arange(189.,idsnew.max()+1):
    imgnew = numpy.where(imgnew==i,i-1,imgnew)

idsnew = numpy.unique(imgnew[imgnew>0])

nibabel


save_image(imgnew, 'MAPA3update.nii.gz', atlas.affine)






for i in ids:
    print(f'{i} : {roiid.index(str(i))}')

for i in numpy.arange(1,442):
    if not i in ids:
        print(f'{i} not in image')

missingrois = [4,38,41,105,106,109,194]
# 38;SNc;Pauli
# 41;VTA;Pauli
# 105;LGNpc;Morel
# 106;LGNmc;Morel
# 109;HN;Pauli
# 194;AStr;CAN




missing=[2,14,16,30,37,40,46,56,61,99,104,105,108,128,132,139,141,151,207,213,232,280,283,289,298,305,371,412,431,432,434,21,36,60,93,106,111,120,122,144,147,148,163,166,182,193,203,218,278,281,306,387]


atlas = nibabel.load(os.path.join('MAPA3_MNI152.nii.gz'))
img = atlas.get_fdata()
ids = numpy.unique(img[img>0]).astype(int)
lut = numpy.genfromtxt('lut_clean.tsv', dtype=str, delimiter = ';')

roiid = list(lut[1:,0])




def save_image(_array, _filename, _affine):
    '''
    save _array as Nifti volume
    '''
    nii = nibabel.Nifti1Image(_array, _affine)
    nii.to_filename(_filename)


la = numpy.where(img == 102.,1,0).astype(float)

save_image(la.astype(float),'MAPA3_missing_test_46.nii.gz', atlas.affine)

def check_both_hemi(roi, img):
    '''
    check if a given roi exists in both hemispheres
    '''
    ids = numpy.where(img == roi)[0] # only check x-axis
    if numpy.logical_or(ids > 91, ids < 91).any():
        print(f'ROI:{roi} present in both')
    else:
        print(f'ROI:{roi} not found')


for r in numpy.unique(img):
    check_both_hemi(r,img)




ROI:102.0 not found
ROI:147.0 not found

for r in missingrois:
    if str(r) in roiid:
        print(f'{r}:{roiid.index(str(r))}')



''''recreate HEMI

first check missing roi1remove from list
multiply

relabel
''''




lut = numpy.genfromtxt('lut_clean.tsv', dtype=str, delimiter = ';')
atlas = nibabel.load(os.path.join('MAPA3Hemi_MNI152.nii.gz'))
img = atlas.get_fdata()
ids = numpy.unique(img[img>0]).astype(int)
roiid = list(lut[1:,0])

imgnew = img.copy()
ids = numpy.unique(img[img>0])