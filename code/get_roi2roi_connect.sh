#!/bin/bash
#
#
# # get_roi2roi_connect.sh
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
# * last update: 2025.04.20
#
#
#
# ## Description
#
# This script extractes ROI based tractograms from the template normative connectome (1) 
# using ROI volume masks. 
#
#
#############################################
#                                           #
#            CHECK INPUT                    #
#                                           #
#############################################

# ---- loading I/O & logging functionality ---- #
source ${SRCDIR}/utils.sh
source ${SRCDIR}/functions.sh

# ---- parse input ---- #
Path=`getopt1 "--path" $@`  # "$1" working directory 
TractFile=`getopt1 "--tck" $@`  # "$2" tract file to extract connectivity from
Atlas=`getopt1 "--atlas" $@`  # "$3" atlas name 
OutDir=`getopt1 "--outdir" $@`  # "$4"output directory

if [[ ! -d "${OutDir}/tracts" ]]; then
    mkdir -p "${OutDir}/tracts"
    mkdir -p "${OutDir}/parcellations"
    mkdir -p "${OutDir}/weights"
fi

#############################################
#                                           #
#            PREPROCESSING                  #
#                                           #
#############################################

# ---- EXTRACTING ROI MASKS BASED CONNECTIONS ---- #

log_msg "START | Extracting ROI based connectivity."

# ---- initialize workspace ---- #
get_temp_dir ${OutDir}


# ---- extract look-up tables for both ROI lists ---- #
if [[ ! -f "${OutDir}/seed/LUT.txt" ]]; then
    log_msg "UPDATE | compute look-up table for seed ROIS."
    get_lookup_table ${OutDir}/seed
fi

if [[ ! -f "${OutDir}/target/LUT.txt" ]]; then
    log_msg "UPDATE | compute look-up table for target ROIs"
    get_lookup_table ${OutDir}/target
fi


# ---- create binary mask of all target ROIs ---- #
if [[ ! -f "${OutDir}/target/full_mask.nii.gz" ]]; then
    log_msg "UPDATE | create target ROIs binary mask for tract reduction."
    get_binary_volume "${OutDir}/target"
    cp ${TempDir}/target_ribbon_bin.nii.gz "${OutDir}/target/full_mask.nii.gz"
fi

# ---- reduced normative tractogram ---- #
if [[ ! -f "${OutDir}/tracts/target_subset.tck" ]]; then
    log_msg "UPDATE | extracting target ROI tract subset."
    get_tract_subset ${OutDir}/target/full_mask.nii.gz ${TractFile}
fi
# ---- removing temporary directory and files ---- #
rm -r ${TempDir}




#############################################
#                                           #
#               CONNECTIVITY                #
#                                           #
#############################################

# ---- prepare variables ---- #
# tck="${OutDir}/target/full_mask_subset.tck"

target_list="${OutDir}/target/roi_masks/*.nii.gz"
get_list_size ${target_list}

seed_list="${OutDir}/seed/roi_masks/*.nii.gz"


# ---- prepare subset parcellation ---- #

get_temp_dir ${OutDir}
log_msg "UPDATE | Creating temporary directory ${TempDir}"


cp "${TEMPLATEDIR}/Empty.nii.gz" "${OutDir}/parcellations/parcellation_subset.nii.gz"

touch "${OutDir}/LUT.txt"

count=1
for f in $seed_list; do
    roi=$( basename ${f%.nii.gz})
    fslmaths ${f} -mul ${count} ${TempDir}/tmp.nii.gz
    fslmaths "${OutDir}/parcellations/parcellation_subset.nii.gz" \
        -add ${TempDir}/tmp.nii.gz \
        "${OutDir}/parcellations/parcellation_subset.nii.gz"
    echo "${count},${roi}" >> "${OutDir}/lut.txt"
    count=$((count+1))
done

for f in $target_list; do
    roi=$( basename ${f%.nii.gz})
    fslmaths ${f} -mul ${count} ${TempDir}/tmp.nii.gz
    fslmaths "${OutDir}/parcellations/parcellation_subset.nii.gz" \
        -add ${TempDir}/tmp.nii.gz \
        "${OutDir}/parcellations/parcellation_subset.nii.gz"
    echo "${count},${roi}" >> "${OutDir}/lut.txt"
    count=$((count+1))
done



# ---- loop over all ROI 2 ROI pairings ---- #
log_msg "UPDATE | extracting pair wise parcellations & weights."
# prepare progressbar
count=1
get_array_len ${seed_list}
seed_count=${len}
get_array_len ${target_list}
target_count=${len}
pair_count=$(( ${seed_count} * ${target_count} ))

for seed_roi in ${seed_list}; do
    seed_roi_name=$( basename ${seed_roi%.nii.gz})
    for target_roi in ${target_list}; do
        target_roi_name=$( basename ${target_roi%.nii.gz})
        get_tract_range "${seed_roi_name}" "${target_roi_name}" "${Path}" "${Atlas}"
        get_pair_tract "${seed_roi}" "${target_roi}" "${min_length}" "${max_length}"
        get_pair_parc "${seed_roi_name}" "${target_roi_name}" "${OutDir}"
        get_roi_weights "${seed_roi_name}" "${target_roi_name}" "${OutDir}"
        progress_bar $count ${pair_count}
        count=$((count+1))
    done
done

python ${SRCDIR}/combine_weights.py --path=${OutDir}

# ---- clean up temporary directories ---- #
rm -r ${TempDir}




log_msg "FINISHED | Extracting ROI based connectivity."


# ---- create tractogram for all ROIs ---- #

# files="${OutDir}/tracts/*-*.tck"

# tckedit ${files} \
#     ${OutDir}/tracts/ROIs_subset.tck


# log_msg "FINISHED | Extracting ROI based connectivity."

# tck2connectome -force \
#     ${OutDir}/tracts/ROIs_subset.tck \
#     ${OutDir}/parcellation_subset.nii.gz \
#     ${OutDir}/weights.tsv



# if [[ ${connectome,,} = "true" ]] || [[ ${connectome,,} = "only" ]]; then
#     log_msg "START | combining ROI weights."
#     # ---- combine weights of all ROI 2 ROI pairings
#     get_connectome ${seed} ${target}
#     log_msg "FINISHED | combining ROI weights."
# fi


