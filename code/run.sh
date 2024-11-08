#!/bin/bash
#
#
# # get_tracts.sh
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
# This script extractes ROI based tractograms from the template normative connectome (1) 
# using ROI volume masks. 
#
#
# REQUIREMENTS: 
# 1. ROI2ROI docker container [or quivalent]
# 2. ROI nifti volume mask(s)



#############################################
#                                           #
#            CHECK INPUT                    #
#                                           #
#############################################

# ---- loading I/O & logging functionality ---- #
source ${SRCDIR}/utils.sh
source ${SRCDIR}/functions.sh

# ---- parse input variables ---- #

if [[ ! -d "/data" ]]; then
    log_msg "ERROR | no <</data>> directory mounted into container."
    show_usage
else
    Path="/data"
fi

if [[ -z ${seed} ]]; then
    log_msg "ERROR | no <<seed>> variable defined."
    show_usage
fi


if [[ -z ${target} ]]; then
    log_msg "ERROR | no <<target>> variable defined."
    show_usage
fi


if [[ ! -z ${roi} ]] && [[ -f "${Path}/${seed}/roi_masks/${roi}" ]]; then
    log_msg "UPDATE | performing single seed ROI connectivity extraction."
    roi_mode="single"
else
    roi_mode="full"
    if [[ -z ${connectome} ]]; then
        connectome="true"
    fi
fi


if [[ -z ${template} ]]; then
    template="${TEMPLATEDIR}/dTOR_full_tractogram.tck"
elif [[ ! -f ${template} ]]; then
    log_msg "ERROR | <<template>> tractogram not found."
    show_usage
fi


if [[ "${roi_mode}"="full" ]]; then
    if [ -z "${preproc}" ]; then
        preproc="true"
    fi
elif [[ "${roi_mode}"="single" ]]; then
    if [[ ${preproc,,}="only" ]]; then
        log_msg "UPDATE | Only performing preprocessing of seed and target files for downstream connectivity analysis."
    elif [[ ! ${preproc,,} = "true" ]] && [[ ! -f "${Path}/${target}/LUT.txt" ]] || [[ ! -f "${Path}/${target}/${target}.tck" ]] || [[ ! -f "${Path}/${target}/${target}_full_mask.nii.gz" ]]; then
        log_msg "ERROR | no preprocessing results found."
        show_usage
    fi
else
    log_msg "ERROR | can't find corresponding ROI seed file/directory."
    show_usage
fi

if [[ -z ${CLUSTER} ]]; then
    CLUSTER="FALSE"
fi

if [[ ! ${cleanup,,} = "false" ]] ; then
    cleanup="true"
fi

#############################################
#                                           #
#               PREPROCESSING               #
#                                           #
#############################################



if [[ ${preproc,,} = "true" ]] || [[ ${preproc,,} = "only" ]] && [[ ! ${connectome,,} = "only" ]]; then

    log_msg "START | Preprocessing of ${seed} and ${target}"

    # ---- initialize workspace ---- #
    get_temp_dir ${Path}


    # ---- extract look-up tables for both ROI lists ---- #
    if [[ ! -f "${Path}/${seed}/LUT.txt" ]]; then
        log_msg "UPDATE | compute look-up table for ${seed}"
        get_lookup_table /data/${seed}
    fi

    if [[ ! -f "${Path}/${target}/LUT.txt" ]]; then
        log_msg "UPDATE | compute look-up table for ${target}"
        get_lookup_table /data/${target}
    fi


    # ---- create binary mask of all target ROIs ---- #
    if [[ ! -f "${Path}/${target}/${target}_full_mask.nii.gz" ]]; then
        log_msg "UPDATE | create target ROIs binary mask for tract reduction."
        get_binary_volume ${target}
        cp ${TempDir}/${target}_ribbon_bin.nii.gz ${Path}/${target}/${target}_full_mask.nii.gz
    fi

    # ---- reduced normative tractogram ---- #
    if [[ ! -f "${Path}/${target}/${target}.tck" ]]; then
        log_msg "UPDATE | extracting target ROI tract subset."
        get_tract_subset ${Path}/${target}/${target}_full_mask.nii.gz ${template}
    fi
    # ---- removing temporary directory and files ---- #
    rm -r ${TempDir}

    log_msg "FINISHED | Preprocessing of ${seed} and ${target}"
    if [[ ${preproc,,} = "only" ]]; then
        exit 0
    fi
fi


#############################################
#                                           #
#               CONNECTIVITY                #
#                                           #
#############################################


# ---- start connectivity computation ---- #

if [[ ! ${preproc,,} = "only" ]] && [[ ! ${connectome,,} = "only" ]]; then

    if [[ ! -z ${roi} ]]; then
        seed_name=${roi}
    else
        seed_name=${seed}
    fi

    log_msg "START | Computing connectivity for ${seed_name} and ${target}" 


    # ---- prepare variables ---- #
    tck="${Path}/${target}/${target}.tck"

    target_list="${Path}/${target}/roi_masks/*.nii.gz"
    get_list_size ${target_list}


    if [[ ${roi_mode} = "full" ]]; then
        seed_list="${Path}/${seed}/roi_masks/*.nii.gz"
        seed_roi_name=${seed}
    else 
        seed_list="${Path}/${seed}/roi_masks/${roi%.nii.gz}.nii.gz"
        seed_roi_name="${roi%.nii.gz}"
    fi


    # ---- initialize workspace ---- #
    get_temp_dir ${Path}
    log_msg "UPDATE | Creating temporary directory ${TempDir}"

    # --- loop over all ROI 2 ROI pairings


    for roi_seed in ${seed_list}; do
        if [ ! -d "${Path}/${seed}/weights_${target}" ]; then
            mkdir -p "${Path}/${seed}/weights_${target}"
        fi
        log_msg "UPDATE | extract connectivity for seed ROI $( basename ${roi_seed%.nii.gz})"
        touch ${TempDir}/$( basename ${seed%.nii.gz})_weights.tsv
        count=1
        for roi_target in ${target_list}; do
            get_assignments "${roi_seed}" "${roi_target}" "${tck}"
            get_strength ${TempDir}/weights/$( basename ${roi_target%.nii.gz}_weights.tsv)
            echo ${strength} >> ${TempDir}/$( basename ${roi_seed%.nii.gz})_weights.tsv
            progress_bar ${count} ${list_size}
            count=$((count+1))
        done
        cp ${TempDir}/$( basename ${roi_seed%.nii.gz})_weights.tsv \
            ${Path}/${seed}/weights_${target}/$( basename ${roi_seed%.nii.gz})_${target}_weights.tsv
    done

    log_msg "FINISHED | Computing connectivity for ${seed_name} and ${target}"

fi





if [[ ${connectome,,} = "true" ]] || [[ ${connectome,,} = "only" ]]; then
    log_msg "START | combining ROI weights."
    # ---- combine weights of all ROI 2 ROI pairings
    get_connectome ${seed} ${target}
    log_msg "FINISHED | combining ROI weights."
fi


# ---- clean up of temporary files ---- #
if [[ ${cleanup,,} = "true" ]]; then
    if [[ -d ${TempDir} ]]; then
        rm -r ${TempDir}
        log_msg "FINISHED | Performing clean-up of temporary directory"
    fi
fi