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
