##### DEV SNIPPETS FOR ROI2ROI OVERHAUL

docker run -it -v /mnt/h/Research/ROI2ROI/Data:/data roi2roi:dev bash

export atlas="MAPA3Hemi"
Atlas=$atlas
export Path="/data"
export seed="Op2_L"
Seed=$seed
# seed based
# seed="/data/lesion_test.nii.gz"
# roi based
# export seed="Frontal_Sup_Medial_L"
export seed="Id8,Id3,Ia3"
export target="Id8_L,Id3_L,Ia3_L"


export target="brain"
export OutDir="/data/${atlas}-ROI2BRAIN-${seed}"



docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3" -e seed="pOFC" -e target="brain" -e OutDir="/data/MAPA3-ROI2BRAIN-pOFC" roi2roi:dev


$SRCDIR/run.sh 

#####################
# ISSUE: small connection can still include neighbouring tracts!!!!


Atlas=$atlas
TractFile=$template



get_pair_tract() {
    # extract ROI pair
    # tracts
    # $1 seed ROI mask
    # $2 target ROI mask
    # $3 minimal tract length
    # $4 maximum tract length
    WD=$( dirname $( dirname $( dirname ${2})))
    if [[ ! -d "${WD}/tracts" ]]; then
        mkdir -p "${WD}/tracts"
    fi
    tckedit -force \
        "${WD}/target/full_mask_subset.tck" \
        -include ${1} \
        -include ${2} \
        -minlength ${3} \
        -maxlength ${4} \
        "${WD}/tracts/$(basename ${1%.nii.gz})-$( basename ${2%.nii.gz}).tck"    
}



get_tract_pair() {
    # extract subset of tracts
    # for given seed:target ROI pair
    # $1 = seed ROI filename
    # $2 = target ROI filename
    # $3 = target tract subset
    # $4 = output filename
    tckedit -force -quiet \
        ${3} \
        "${TempDir}/tmp.tck" \
        -include ${2}
    tckedit -force -quiet \
        "${TempDir}/tmp.tck" \
        "${4}" \
        -include ${1}

}



# combine tract files
files="${OutDir}/tracts/*.tck"

tckedit $files ${OutDir}/tracts/combined.tck




get_tract_range() {
    # compute tract length ranges
    # for given ROI pair
    # $1 seed ROI name
    # $2 target ROI name
    # $3 path
    # $4 atlas
    ranges=$( python \
        ${SRCDIR}/prepare_length_range.py \
            --path=${3} \
            --seed="${1}" \
            --target="${2}" \
            --atlas="${4}" \
            --ratio="0.1" )
    IFS=, read -r min_length max_length <<< ${ranges}
}






###################################
#
#      CONCAT ATLAS PREPROCESSING


docker run -v /mnt/h/Research/ROI2ROI/Data:/data roi2roi:dev python get_atlas_update.py --update='agranular' --grouping='Ia2_L,Ia3_L,Ia1_L,Ia2_R,Ia3_R,Ia1_R' --atlas="MAPA3Hemi"


docker run -v /mnt/h/Research/ROI2ROI/Data:/data roi2roi:dev python get_atlas_update.py --update='dysgranular' --grouping='Id8_L,Id3_L,Id4_L,Id6_L,Id7_L,Id10_L,Id2_L,Id1_L,Id5_L,Id9_L,Id8_R,Id3_R,Id4_R,Id6_R,Id7_R,Id10_R,Id2_R,Id1_R,Id5_R,Id9_R' --atlas="MAPA3Hemi"

docker run -v /mnt/h/Research/ROI2ROI/Data:/data roi2roi:dev python get_atlas_update.py --update='granular' --grouping='Ig2_L,Ig3_L,Ig1_L,Ig2_R,Ig3_R,Ig1_R' --atlas="MAPA3Hemi"



docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Hemi-agranular" -e seed="agranular" -e target="brain" -e OutDir="/data/MAPA3-ROI2BRAIN-agranular" roi2roi:dev


docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Hemi" -e seed="Op2_R" -e target="brain" -e OutDir="/data/MAPA3-ROI2BRAIN-Op2_R" roi2roi:dev

docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Hemi" -e seed="Op2_R" -e target="OP2_L" -e OutDir="/data/MAPA3-ROI2ROI-Op2" roi2roi:dev


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



##### SPLIT MAPA3 BY HEMISPHERE

# cd /data
# atlas=MAPA3

def save_image(_array, _filename, _affine):
    '''
    save _array as Nifti volume
    '''
    nii = nibabel.Nifti1Image(_array, _affine)
    nii.to_filename(_filename)


import numpy, nibabel
nii = nibabel.load('Thalamus_atlas.nii.gz')
img = nii.get_fdata()
la = numpy.zeros(img.shape)
la[91:,:,:] = 1
save_image(la,'/data/Thalamus/right.nii.gz',nii.affine  )

fslmaths Thalamus_atlas.nii.gz -mul right.nii.gz Atlasright.nii.gz
fslswapdim right.nii.gz -x y z left.nii.gz
fslmaths Thalamus_atlas.nii.gz -mul left.nii.gz Atlasleft.nii.gz

fslmaths Atlasright.nii.gz -bin Atlasrightbin.nii.gz
fslmaths Atlasright.nii.gz -add 1000 Atlasright1000.nii.gz 
fslmaths Atlasright1000.nii.gz -mul Atlasrightbin.nii.gz Atlasrightupdate.nii.gz

fslmaths Atlasrightupdate.nii.gz -add Atlasleft.nii.gz AtlasHemi.nii.gz

#  fslmaths MAPA3left.nii.gz -bin mapa3leftbin.nii.gz
#  fslmaths mapa3leftbin.nii.gz -binv mapa3leftbinv.nii.gz

#  fslmaths MAPA3right.nii.gz -mul mapa3leftbinv.nii.gz mapa3right.nii.gz


# fslmaths MAPA3right.nii.gz -add 1000 MAPA3right1000.nii.gz
# fslmaths MAPA3right.nii.gz -bin MAPA3rightbin.nii.gz
# fslmaths MAPA3right1000.nii.gz -mul MAPA3rightbin.nii.gz MAPA3RightHemi.nii.gz


# fslmaths MAPA3RightHemi.nii.gz -add MAPA3left.nii.gz MAPA3Hemi.nii.gz