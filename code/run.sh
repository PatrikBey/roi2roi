#!/bin/bash
#
#
# # run.sh
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

figlet "ROI2ROI" | lolcat 

log_msg "START | ROI2ROI connectivity builder |"
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

if [[ -f ${seed} ]]; then
    log_msg "UPDATE | using $( basename ${seed}) as single seed region"
    singleseed="TRUE"
fi

if [[ -z ${target} ]] && [[ -z ${singleseed} ]] ; then
    log_msg "ERROR | no <<target>> variable defined."
    show_usage
fi

if [[ ${target,,} = 'brain' ]]; then
    log_msg "UPDATE | extracting ${seed} to full brain connectivity."
    singleseed="TRUE"
fi

if [[ -z ${atlas} ]]; then
    log_msg "ERROR | no atlas defined."
    show_usage
elif [[ ! -d ${TEMPLATEDIR}/${atlas} ]] && [[ ! -d ${Path}/${atlas} ]]; then
    log_msg "ERROR | no directory found for ${atlas}"
    show_usage
fi

# if [[ ! -z ${tracts} ]];then
#     log_msg "UPDATE | performing tract extraction for all ROI pairs."
# fi

# if [[ ! -z ${masks} ]]; then
#     log_msg "UPDATE | Only running mask preparations"
#     if [[ -z ${atlas} ]]; then
#         log_msg "ERROR |  Atlas name required for mask preparation."
#         show_usage
#     fi
# fi

# if [[ ! -d "${Path}/Connectomes" ]]; then
#     mkdir -p "${Path}/Connectomes"
# fi

# if [[ ! -d "${Path}/tracts" ]]; then
#     mkdir -p "${Path}/tracts"
# fi

# if [[ ! -z ${roi} ]] && [[ -f "${Path}/${seed}/roi_masks/${roi}" ]]; then
#     log_msg "UPDATE | performing single seed ROI connectivity extraction."
#     roi_mode="single"
# else
#     roi_mode="full"
#     if [[ -z ${connectome} ]]; then
#         connectome="true"
#     fi
# fi


if [[ -z ${template} ]]; then
    template="${TEMPLATEDIR}/dTOR_full_tractogram.tck"
elif [[ ! -f ${template} ]]; then
    log_msg "ERROR | <<template>> tractogram not found."
    show_usage
fi


# if [[ "${roi_mode}"="full" ]]; then
#     if [ -z "${preproc}" ]; then
#         preproc="true"
#     fi
# elif [[ "${roi_mode}"="single" ]]; then
#     if [[ ${preproc,,}="only" ]]; then
#         log_msg "UPDATE | Only performing preprocessing of seed and target files for downstream connectivity analysis."
#     elif [[ ! ${preproc,,} = "true" ]] && [[ ! -f "${Path}/${target}/LUT.txt" ]] || [[ ! -f "${Path}/${target}/${target}.tck" ]] || [[ ! -f "${Path}/${target}/${target}_full_mask.nii.gz" ]]; then
#         log_msg "ERROR | no preprocessing results found."
#         show_usage
#     fi
# else
#     log_msg "ERROR | can't find corresponding ROI seed file/directory."
#     show_usage
# fi

if [[ -z ${CLUSTER} ]]; then
    CLUSTER="FALSE"
fi

# if [[ ! ${cleanup,,} = "false" ]] ; then
#     cleanup="true"
# fi

#############################################
#                                           #
#               PREPROCESSING               #
#                                           #
#############################################





#############################################
#                                           #
#               CONNECTOMICS                #
#                                           #
#############################################


if [[ ${singleseed} = "TRUE" ]]; then

    if [[ -f ${seed} ]]; then

        log_msg "START | extracting volume mask based connectivity."



    else

        log_msg "START | extracting single seed ROI connectivity."
        # '''
        # EXTRACTING DISCONNECTOME FOR GIVEN SING ROI
        # '''
        python ${SRCDIR}/roi2brain_preproc.py --path=${Path} --seed=${seed} --atlas=${atlas} --outdir=${OutDir}

        
        ${SRCDIR}/get_roi2brain_connect.sh \
            --path="${Path}" \
            --seed="${seed}" \
            --atlas="${atlas}" \
            --tck="${template}" \
            --outdir="${OutDir}"
    fi

else

    # '''

    # '''
    log_msg "START | Extract ROI pair(s) connectivities."

    # ---- PREPARING ROI MASKS ---- #
    log_msg "START | Preparing ROI masks"

    python ${SRCDIR}/roi2roi_preproc.py --path=${Path} --seed=${seed} --target=${target} --atlas=${atlas} --outdir=${OutDir}

    log_msg "FINISHED | Preparing ROI masks"

    # ---- COMPUTING TRACT LENGTHS ---- #

    if [[ ! -f "${Path}/${atlas}/${atlas}_tract_lengths.tsv" ]]; then
        log_msg "START | Extracting ROI connection lengths."

        if [[ -f "${Path}/${atlas}/${atlas}_mrtrix3.nii.gz" ]]; then
            parc_image="${Path}/${atlas}/${atlas}_mrtrix3.nii.gz"
        else
            parc_image="${Path}/${atlas}/${atlas}_MNI152.nii.gz"
        fi

        get_connection_length \
            "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
            "${parc_image}" \
            "${Path}/${atlas}/${atlas}_tract_lengths.tsv"
        
        missing=$(python -c "import numpy; empty=numpy.where(numpy.genfromtxt('${Path}/${atlas}/${atlas}_tract_lengths.tsv').sum(axis=0)==0)[0]+1; print(f'No tracts found for ROIs: {empty}.')")

        python -c "import numpy, matplotlib.pyplot as plt; tmp=numpy.genfromtxt('${Path}/${atlas}/${atlas}_tract_lengths.tsv'); plt.imshow(tmp); plt.colorbar(); plt.title('${atlas} connection lengths'); plt.savefig('${Path}/${atlas}/${atlas}_connection_lengths.png')"

        if [[ ! ${missing} = "No tracts found for ROIs: []." ]]; then
            log_msg "WARNING | ${missing}"
        fi

        log_msg "FINISHED | Extracting ROI connection lengths."

    fi

    ${SRCDIR}/get_roi2roi_connect.sh \
        --path="${Path}" \
        --tck="${template}" \
        --atlas="${atlas}" \
        --outdir="${OutDir}"

    log_msg "FINISHED | Extract ROI pair connectivities."
fi




#############################################
#                                           #
#               CONNECTIVITY                #
#                                           #
#############################################



# # initial implementation

# # ---- start connectivity computation ---- #

# if [[ ! ${preproc,,} = "only" ]] && [[ ! ${connectome,,} = "only" ]]; then

#     if [[ ! -z ${roi} ]]; then
#         seed_name=${roi}
#     else
#         seed_name=${seed}
#     fi

#     log_msg "START | Computing connectivity for ${seed_name} and ${target}" 


#     # ---- prepare variables ---- #
#     tck="${Path}/${target}/${target}.tck"

#     target_list="${Path}/${target}/roi_masks/*.nii.gz"
#     get_list_size ${target_list}


#     if [[ ${roi_mode} = "full" ]]; then
#         seed_list="${Path}/${seed}/roi_masks/*.nii.gz"
#         seed_roi_name=${seed}
#     else 
#         seed_list="${Path}/${seed}/roi_masks/${roi%.nii.gz}.nii.gz"
#         seed_roi_name="${roi%.nii.gz}"
#     fi


#     # ---- initialize workspace ---- #
#     get_temp_dir ${Path}
#     log_msg "UPDATE | Creating temporary directory ${TempDir}"

#     # --- loop over all ROI 2 ROI pairings


#     for roi_seed in ${seed_list}; do
#         if [ ! -d "${Path}/${seed}/weights_${target}" ]; then
#             mkdir -p "${Path}/${seed}/weights_${target}"
#         fi
#         log_msg "UPDATE | extract connectivity for seed ROI $( basename ${roi_seed%.nii.gz})"
#         touch ${TempDir}/$( basename ${roi_seed%.nii.gz})_weights.tsv
#         count=1
#         for roi_target in ${target_list}; do
#             get_assignments "${roi_seed}" "${roi_target}" "${tck}"
#             get_strength ${TempDir}/weights/$( basename ${roi_target%.nii.gz}_weights.tsv)
#             echo ${strength} >> ${TempDir}/$( basename ${roi_seed%.nii.gz})_weights.tsv
#             if [[ ! -z ${tracts} ]]; then
#                 get_tract_pair $roi_seed $roi_target $tck ${Path}/tracts/$(basename ${roi_seed%.nii.gz})-$(basename ${roi_target%.nii.gz}).tck
#             fi
#             progress_bar ${count} ${list_size}
#             count=$((count+1))
#         done
#         cp ${TempDir}/$( basename ${roi_seed%.nii.gz})_weights.tsv \
#             ${Path}/${seed}/weights_${target}/$( basename ${roi_seed%.nii.gz})_${target}_weights.tsv
#     done

#     log_msg "FINISHED | Computing connectivity for ${seed_name} and ${target}"

# fi


# if [[ ${connectome,,} = "true" ]] || [[ ${connectome,,} = "only" ]]; then
#     log_msg "START | combining ROI weights."
#     # ---- combine weights of all ROI 2 ROI pairings
#     get_connectome ${seed} ${target}
#     log_msg "FINISHED | combining ROI weights."
# fi


# # # ---- clean up of temporary files ---- #
# # if [[ ${cleanup,,} = "true" ]]; then
# #     if [[ -d ${TempDir} ]]; then
# #         rm -r ${TempDir}
# #         log_msg "FINISHED | Performing clean-up of temporary directory"
# #     fi
# # fi






log_msg "FINISHED | ROI2ROI connectivity builder |"
