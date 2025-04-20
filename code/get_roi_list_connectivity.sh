#!/bin/bash
#
#
# # get_connectivity.sh
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
# * last update: 2025.04.08
#
#
#
# ## Description
#
# This script extractes ROI based tractograms from the template normative connectome (1) 
# using ROI volume masks. 
#
# ## STEPS
#
#
# In this processing framework the following steps are performed:
#
# 1. extract binary volume masks for all seed $ target ROIs
# 2. create parcellation subset containing all specified seed&target ROIs.
# 3. extract tracts subset intersecting given see&target ROIs
# 4. compute tract length for given subset of ROIs and tracts
# 5. extract tracts for all seed ROI & target ROI pairings
# 6. combine subtracts to compute overall connectivity strength of all pairs



#############################################
#                                           #
#            CHECK INPUT                    #
#                                           #
#############################################




# create different connectivity scripts creating seed&target or only seed based tractogram subsets



WD="${Path}/connectivity"


if [[ ! -d "${WD}" ]]; then
    mkdir -p "${WD}"
    mkdir -p "${WD}/tracts"
fi

# ---- loading I/O & logging functionality ---- #
source ${SRCDIR}/utils.sh
source ${SRCDIR}/functions.sh

log_msg "START | Extract structural connectivity for given ROIs."


if [[ -z ${seed} ]]; then
    log_msg "ERROR | no <<seed>> variable defined."
    show_usage
fi


if [[ -z ${target} ]]; then
    log_msg "ERROR | no <<target>> variable defined."
    show_usage
fi


if [[ ! -z ${grouping} ]]; then
    log_msg "UPDATE | splitting ROIs by <<${grouping}>>."
fi


# updated implementation using single ROI pair tractograms
# that are combined in the end and conenctivity is computed

seed_list="${Path}/${seed}/roi_masks/*.nii.gz"
target_list="${Path}/${target}/roi_masks/*.nii.gz"


# ---- 1. create study parcellation subset ---- #

cp "${TEMPLATEDIR}/Empty.nii.gz" "${WD}/parcellation_subset.nii.gz"

touch "${WD}/LUT.txt"

get_temp_dir ${WD}

count=1
for f in $seed_list; do
    roi=$( basename ${f%.nii.gz})
    fslmaths ${f} -mul ${count} ${TempDir}/tmp.nii.gz
    fslmaths "${WD}/parcellation_subset.nii.gz" \
        -add ${TempDir}/tmp.nii.gz \
        "${WD}/parcellation_subset.nii.gz"
    echo "${count},${roi}" >> "${WD}/lut.txt"
    count=$((count+1))
done

for f in $target_list; do
    roi=$( basename ${f%.nii.gz})
    fslmaths ${f} -mul ${count} ${TempDir}/tmp.nii.gz
    fslmaths "${WD}/parcellation_subset.nii.gz" \
        -add ${TempDir}/tmp.nii.gz \
        "${WD}/parcellation_subset.nii.gz"
    echo "${count},${roi}" >> "${WD}/lut.txt"
    count=$((count+1))
done


# ---- 2. create tract subset ---- #


tckedit -force \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "${WD}/tracts/full.tck" \
    -include "${WD}/parcellation_subset.nii.gz"



# ---- 3. get connection lengths ---- #
get_connection_length "${WD}/tracts/full.tck" \
     "${WD}/parcellation_subset.nii.gz" \
     "${WD}/lengths.tsv"

# ---- compute

tckedit "${WD}/tracts/full.tck" \
    -include /data/MAPA/run_8834/seed/roi_masks/3b.nii.gz \
    -include /data/MAPA/run_8834/target/roi_masks/occipital_cortex.nii.gz \
    -minlength 90 \
    -maxlength 110 \
    ${WD}/tracts/3b_occipital_cortext.tck


get_tract_range() {
    # compute tract length ranges
    # for given ROI pair
    # $1 seed ROI name
    # $2 target ROI name
    # $3 path
    ranges=$( python \
        ${SRCDIR}/prepare_length_range.py \
            --path=${3} \
            --seed="${1}" \
            --target="${2}" \
            --ratio="0.1" )
    IFS=, read -r min_length max_length <<< ${ranges}
}

get_tract_range "PF" "occipital_cortex" ${WD}

# ---- 0. compute length for each ROI pair ---- #


# ---- 1. extract ROI pairing tract files ---- #




get_pair_tracts() {
    # extract subset of tracts only connecting
    # pair of input ROIs
    #
    # $1 = input tractogram to extract from 
    # $2 = input seed roi binary mask
    # $3 = input target roi binary mask
    # $4 = output filename
    teckedit -forcec -quiet \
        ${1} \
        "${TempDir}/tmp.tck" \
        -include ${2}
}







log_msg "FINISHED | Extract structural connectivity for given ROIs."
