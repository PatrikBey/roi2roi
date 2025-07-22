######################
#
# RERUN 2025.07.22
#
######################

$Path="H:\ROI2ROI\ROIS\RERUN20250722\Final-FC-ROIs"
docker run -it -v ""$Path":/data" patrikneuro/roi2roi:latest bash




# ---- loading I/O & logging functionality ---- #
source ${SRCDIR}/utils.sh
source ${SRCDIR}/functions.sh

# ---- parse input ---- #
Path="/data"
Source="Insula"
Target="allostatic_system"
# Target="thermoregulation"
OutDir="${Source}_${Target}"
mkdir -p "${Path}/${OutDir}"

# ---- get files ---- #
source_files=$(ls "${Path}/${Source}/masks")
get_file_count "${source_files}"
source_file_count=${filecount}
target_files=$(ls "${Path}/${Target}/masks")
get_file_count "${target_files}"
target_file_count=${filecount}

# ---- prepare parcellations ---- #
log_msg "UPDATE | Creating ${Source} parcellation"


cp ${TEMPLATEDIR}/Empty.nii.gz "${Path}/${OutDir}/${Source}_parc.nii.gz"

count=1

for source_file in ${source_files}; do
    source_mask="${Path}/${Source}/masks/${source_file}"
    cp $source_mask "${Path}/${OutDir}/tmp.nii.gz"
    fslmaths "${Path}/${OutDir}/tmp.nii.gz" -bin "${Path}/${OutDir}/tmp.nii.gz"
    fslmaths "${Path}/${OutDir}/tmp.nii.gz" \
        -mul ${count} \
        "${Path}/${OutDir}/tmp.nii.gz"
    fslmaths "${Path}/${OutDir}/${Source}_parc.nii.gz" \
        -add "${Path}/${OutDir}/tmp.nii.gz" \
        "${Path}/${OutDir}/${Source}_parc.nii.gz"
    progress_bar $count ${source_file_count}
    count=$((count+1))
done

log_msg "UPDATE | Creating ${Target} parcellation"

cp ${TEMPLATEDIR}/Empty.nii.gz "${Path}/${OutDir}/${Target}_parc.nii.gz"

count=1
for target_file in ${target_files}; do
    target_mask="${Path}/${Target}/masks/${target_file}"
    cp $target_mask "${Path}/${OutDir}/tmp.nii.gz"
    fslmaths "${Path}/${OutDir}/tmp.nii.gz" -bin "${Path}/${OutDir}/tmp.nii.gz"
    fslmaths "${Path}/${OutDir}/tmp.nii.gz" \
        -mul ${count} \
        "${Path}/${OutDir}/tmp.nii.gz"
    fslmaths "${Path}/${OutDir}/${Target}_parc.nii.gz" \
        -add "${Path}/${OutDir}/tmp.nii.gz" \
        "${Path}/${OutDir}/${Target}_parc.nii.gz"
    progress_bar $count ${target_file_count}
    count=$((count+1))
done




for t1 in $target_files; do
    for t2 in $target_files; do
        fslmaths "${Path}/${Target}/masks/${t1}" \
            -mul "${Path}/${Target}/masks/${t2}" \
            ${Path}/tmp.nii.gz
        check=$( fslstats ${Path}/tmp.nii.gz -V )
        echo ${t1} ${t2} ${check}
    done
done



# HPT.nii.gz SN.nii.gz 20 20.000000

NAcc.nii.gz sgACC.nii.gz 77 77.000000

# PAG.nii.gz DR.nii.gz 12 12.000000
# PAG.nii.gz SC.nii.gz 32 32.000000
# PBN.nii.gz LC.nii.gz 3 3.000000
# SN.nii.gz VTA.nii.gz 82 82.000000


fslmaths SN.nii.gz -mul VTA.nii.gz tmp.nii.gz
fslmaths VTA.nii.gz -sub tmp.nii.gz VTA_clean.nii.gz

fslmaths PBN.nii.gz -mul LC.nii.gz tmp.nii.gz
fslmaths LC.nii.gz -sub tmp.nii.gz LC_clean.nii.gz

fslmaths PAG.nii.gz -mul SC.nii.gz tmp.nii.gz
fslmaths SC.nii.gz -sub tmp.nii.gz SC_clean.nii.gz

fslmaths PAG.nii.gz -mul DR.nii.gz tmp.nii.gz
fslmaths PAG.nii.gz -sub tmp.nii.gz PAG_clean.nii.gz

fslmaths HPT.nii.gz -mul SN.nii.gz tmp.nii.gz
fslmaths SN.nii.gz -sub tmp.nii.gz SN_clean.nii.gz

fslmaths NAcc.nii.gz -mul sgACC.nii.gz tmp.nii.gz
fslmaths sgACC.nii.gz -sub tmp.nii.gz sgACC_clean.nii.gz








