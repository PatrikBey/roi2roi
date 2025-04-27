##### DEV SNIPPETS FOR ROI2ROI OVERHAUL

docker run -it -v /mnt/h/Research/ROI2ROI/Data:/data roi2roi:dev bash

export atlas="MAPA3"

export Path="/data"
export seed="pOFC"
# seed based
# seed="/data/lesion_test.nii.gz"
# roi based
# export seed="Frontal_Sup_Medial_L"
export target="brain"
export OutDir="/data/MAPA-ROI2BRAIN-${seed}"



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


docker run -v /mnt/h/Research/ROI2ROI/Data:/data roi2roi:dev python get_atlas_update.py --update='agranular' --grouping='Ia2,Ia3,Ia1'


docker run -v /mnt/h/Research/ROI2ROI/Data:/data roi2roi:dev python get_atlas_update.py --update='dysgranular' --grouping='Id8,Id3,Id4,Id6,Id7,Id10,Id2,Id1,Id5,Id9'

docker run -v /mnt/h/Research/ROI2ROI/Data:/data roi2roi:dev python get_atlas_update.py --update='granular' --grouping='Ig2,Ig3,Ig1'



docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3-agranular" -e seed="agranular" -e target="brain" -e OutDir="/data/MAPA3-ROI2BRAIN-agranular" roi2roi:dev
