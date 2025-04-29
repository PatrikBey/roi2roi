#!/bin/bash
#
#
# # get_roi2brain_connect.sh
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
# * last update: 2025.04.24
#
#
#
# ## Description
#
# This script extractes ROI based connectome including a single ROI seed and full brain 
# targets. This follows the creation principle of disconnectomes.
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
Seed=`getopt1 "--seed" $@`  # "$3" seed ROI name
Atlas=`getopt1 "--atlas" $@`  # "$4" atlas name 
OutDir=`getopt1 "--outdir" $@`  # "$5"output directory



if [[ ! -d "${OutDir}/tracts" ]]; then
    mkdir -p "${OutDir}/tracts"
    mkdir -p "${OutDir}/roi_masks"
    mkdir -p "${OutDir}/weights"
fi


if [[ -f "${Path}/${Atlas}/${Atlas}_mrtrix3.nii.gz" ]]; then
    ParcImage="${Path}/${Atlas}/${Atlas}_mrtrix3.nii.gz"
else
    ParcImage="${Path}/${Atlas}/${Atlas}_MNI152.nii.gz"
fi

#############################################
#                                           #
#            PREPROCESSING                  #
#                                           #
#############################################

# ---- EXTRACTING ROI MASKS BASED CONNECTIONS ---- #

log_msg "START | Extracting ROI based connectivity."


# ---- initialize workspace ---- #
# get_temp_dir ${OutDir}


# ---- reduce normative tractogram ---- #
if [[ ! -f "${OutDir}/tracts/${Seed}.tck" ]]; then
    log_msg "UPDATE | extracting ROI tract subset."
    get_tract_subset ${OutDir}/roi_masks/${Seed}.nii.gz ${TractFile}
fi


log_msg "UPDATE | Compute ROI connectome."

tck2connectome -force -quiet -symmetric -zero_diagonal \
    "${OutDir}/tracts/${Seed}_subset.tck" \
    "${ParcImage}" \
    "${OutDir}/weights/${Seed}.tsv"


python ${SRCDIR}/roi2brain_weight_cleanup.py --path=${OutDir} --roi=${Seed} --atlas=${Atlas}

log_msg "FINISHED | Extracting ROI based connectivity."
