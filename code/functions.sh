#!/bin/bash
#
#
# # functions.sh
#
#
# * Brain Simulation Section
# * Charité Berlin Universitätsmedizin
# * Berlin Institute of Health
#
# ## Author(s)
# * Bey, Patrik, Charité Universitätsmedizin Berlin, Berlin Institute of Health
# 
#
# * last update: 2024.11.08
#
#
#
# ## Description
#
# This script contains processing functions for use within
# the ROI2ROI connectivity container.
#
#
# FUNCTIONS: 
# 1. get_roi_volume

#############################################
#                                           #
#            HELPER FUNCTIONS               #
#                                           #
#############################################



get_roi_volume() {
    # create parcellation image for given seed:target ROI combination
    # 
    # ${1}: filename of seed ROI
    # ${2}: filename of target ROI
    fslmaths ${2} \
        -mul 2 \
        ${TempDir}/tmp-parc.nii.gz
    fslmaths ${TempDir}/tmp-parc.nii.gz \
        -add ${1} \
        ${TempDir}/tmp-parc.nii.gz 2>/dev/null
}

get_connection_length(){
    # $1 input track file (i.e. normative tractogram)
    # $2 parcellation image (i.e. atlas parcellation)
    # $3 output filename
    if [ -z ${3} ]; then
        outfile="${2%.nii.gz}_lengths.tsv"
    else
        outfile="${3}"
    fi
    tck2connectome -scale_length -quiet -force -zero_diagonal -symmetric -stat_edge mean \
        "${1}" \
        "${2}" \
        "${3}"
}

get_tract_subset() {
    # extract subset of tracts using ROI mask
    # from default normative tractogram
    # $1 = ROI target full mask
    # $2 = base tractogram [optional]
    roi=$(basename ${1%.nii.gz})
    wd=$( dirname $( dirname ${1} ))
    tckedit -force -quiet \
        ${2} \
        "${wd}/tracts/${roi}_subset.tck" \
        -include ${1}
}

# get_pair_tract() {
#     # extract ROI pair
#     # tracts
#     # $1 seed ROI mask
#     # $2 target ROI mask
#     # $3 minimal tract length
#     # $4 maximum tract length
#     WD=$( dirname $( dirname $( dirname ${2})))
#     if [[ ! -d "${WD}/tracts" ]]; then
#         mkdir -p "${WD}/tracts"
#     fi
#     tckedit -force -quiet \
#         "${WD}/tracts/full_mask_subset.tck" \
#         -include ${1} \
#         -include ${2} \
#         -minlength ${3} \
#         -maxlength ${4} \
#         "${WD}/tracts/$(basename ${1%.nii.gz})-$( basename ${2%.nii.gz}).tck"    
# }

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
    tckedit -force -quiet \
        "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
        -include ${1} \
        -include ${2} \
        -minlength ${3} \
        -maxlength ${4} \
        "${WD}/tracts/$(basename ${1%.nii.gz})-$( basename ${2%.nii.gz}).tck"    
}

# get_pair_tract() {
#     # using connectome2tck for
#     # tract extraction via endpoints

# }

get_pair_parc() {
    # create temporary parcellation volume for given
    # ROI pair
    # $1 input seed ROI name
    # $2 input target ROI name
    # $3 output directory
    fslmaths ${3}/target/roi_masks/${2}.nii.gz \
        -mul 2 \
        ${3}/parcellations/${1}-${2}.nii.gz
    fslmaths ${3}/parcellations/${1}-${2}.nii.gz \
        -add ${3}/seed/roi_masks/${1}.nii.gz \
        ${3}/parcellations/${1}-${2}.nii.gz
}

get_roi_weights() {
    # compute connectivity weight
    # for a given ROI pair
    # $1 seed ROI name
    # $2 target ROI name
    # $3 working directory
    tck2connectome -force -quiet \
        "${3}/tracts/${1}-${2}.tck" \
        "${3}/parcellations/${1}-${2}.nii.gz" \
        "${3}/weights/${1}-${2}.tsv"
}



# get_tract_pair() {
#     # extract subset of tracts
#     # for given seed:target ROI pair
#     # $1 = seed ROI filename
#     # $2 = target ROI filename
#     # $3 = target tract subset
#     # $4 = output filename
#     tckedit -force -quiet \
#         ${3} \
#         "${TempDir}/tmp.tck" \
#         -include ${2}
#     tckedit -force -quiet \
#         "${TempDir}/tmp.tck" \
#         "${4}" \
#         -include ${1}

# }

get_lookup_table() {
    # create look-up table for given set of ROIs
    # as integrated in connectivity matrix
    #
    # ${1}: path to ROI file set directory
    files="${1}/roi_masks/*.nii.gz"
    touch "${1}/LUT.txt"
    roi=1
    for f in ${files}; do
        roi_label=$( basename ${f%.nii.gz})
        echo "${roi}    ${roi_label}" >> ${1}/LUT.txt
        roi=$((roi + 1))
    done
}


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


get_binary_volume() {
    # create a binary volume combining all ROIs
    # for reduction of normative tractogram to 
    # reduce computational cost
    #
    # ${1}: Target ROIs directory
    # ---- create initial empty volume
    cp ${TEMPLATEDIR}/Empty.nii.gz \
    ${TempDir}/target_ribbon.nii.gz
    # ---- concatenate ROI masks
    files="${1}/roi_masks/*.nii.gz"
    for f in $files; do
        fslmaths ${TempDir}/target_ribbon.nii.gz \
            -add ${f} \
            ${TempDir}/target_ribbon.nii.gz 2>/dev/null
    done
    # ---- binarize volume
    fslmaths ${TempDir}/target_ribbon.nii.gz \
        -bin \
        ${TempDir}/target_ribbon_bin.nii.gz
}

# get_assignments() {
#     # extract tract assignments for given ROI2ROI combination
#     #
#     # ${1}: seed ROI
#     # ${2}: target ROI
#     # ${3}: tractogram file to use in computation
#     # ---- initialize directory
#     if [ ! -d "${TempDir}/assignments" ]; then
#         mkdir -p "${TempDir}/assignments"
#     fi
#     if [ ! -d "${TempDir}/weights" ]; then
#         mkdir -p "${TempDir}/weights"
#     fi
#     # ---- get individual parcellation volume
#     get_roi_volume ${1} ${2}
#     # ---- compute connectome
#     target_roi=$( basename ${2%.nii.gz})
#     tck2connectome -force -zero_diagonal -quiet \
#         "${3}" \
#         "${TempDir}/tmp-parc.nii.gz" \
#         "${TempDir}/weights/${target_roi}_weights.tsv" \
#         -out_assignment "${TempDir}/assignments/${target_roi}.csv" 2>/dev/null
# }

# get_strength(){
#     # extract connection strength for given ROI2ROI pairs
#     #
#     # ${1}: weight text files created by <get_assignments>
#     read -a arr < ${1}
#     export strength=$( echo ${arr[1]})
# }



# combine_weights() {
#     # create concatenated connectivity matrix for all ROIs
#     #
#     # ${1}: input directory
#     # ${2}: output filename
#     weight_files="${1}/*.tsv"
#     paste ${weight_files} > ${TempDir}/weights.tsv
#     python -c "import sys; print('\n'.join(' '.join(c) for c in zip(*(l.split() for l in sys.stdin.readlines() if l.strip()))))" < ${TempDir}/weights.tsv > ${2}
# }



# get_connectome() {
#     # generate connectome from single ROI weight files
#     # ${1}: Seed ROI list name
#     # ${2}: Target ROI list name
#     get_temp_dir ${Path}
#     weight_files="${Path}/${1}/weights_${2}/*.tsv"
#     paste ${weight_files} > ${TempDir}/weights.tsv
#     roi_list=$( ls "${Path}/${2}/roi_masks" )
#     touch "${TempDir}/target.txt"

#     for r in ${roi_list}; do
#         echo ${r%.nii.gz} >> ${TempDir}/target.txt
#     done
#     paste ${TempDir}/target.txt ${weight_files} > ${TempDir}/weights.tsv

#     python -c "import sys; print('\n'.join(' '.join(c) for c in zip(*(l.split() for l in sys.stdin.readlines() if l.strip()))))" < ${TempDir}/weights.tsv > ${TempDir}/weights_transpose.tsv

#     roi_list=$( ls "${Path}/${seed}/roi_masks" )
#     touch "${TempDir}/seed.txt"
#     echo "ROIs" > "${TempDir}/seed.txt"

#     for r in ${roi_list}; do
#         echo ${r%.nii.gz} >> ${TempDir}/seed.txt
#     done
#     touch ${Path}/Connectomes/${1}_${2}_weights.tsv
#     paste ${TempDir}/seed.txt ${TempDir}/weights_transpose.tsv > ${Path}/Connectomes/${1}_${2}_weights.tsv

#     rm -r ${TempDir}
# }

