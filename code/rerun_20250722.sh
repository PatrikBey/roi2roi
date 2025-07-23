######################
#
# RERUN 2025.07.22
#
######################
$Path="H:\ROI2ROI\ROIS\RERUN20250722\Final-FC-ROIs"
Path="$HOME/Data/ROI2ROI/Final-FC-ROIs"
sudo docker run -it -v ""$Path":/data" patrikneuro/roi2roi:latest bash




# ---- loading I/O & logging functionality ---- #
source ${SRCDIR}/utils.sh
source ${SRCDIR}/functions.sh

# ---- parse input ---- #
Path="/data"
Source="insula"
# Target="allostatic_system"
Target="thermoregulation"



# Target="thermoregulation"
OutDir="${Source}_${Target}"
mkdir -p "${Path}/${OutDir}"
chmod -x ${Path}/$OutDir
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
touch ${Path}/${Source}/lut.txt
echo "ID ROI" >> ${Path}/${Source}/lut.txt
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
    echo "${count} ${source_file%.nii.gz}" >> ${Path}/${Source}/lut.txt
    count=$((count+1))
done

log_msg "UPDATE | Creating ${Target} parcellation"

cp ${TEMPLATEDIR}/Empty.nii.gz "${Path}/${OutDir}/${Target}_parc.nii.gz"

count=1
touch ${Path}/${Target}/lut.txt
echo "ID ROI" >> ${Path}/${Target}/lut.txt
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
    echo "${count} ${target_file%.nii.gz}" >> ${Path}/${Target}/lut.txt
    progress_bar $count ${target_file_count}
    count=$((count+1))
done


# ----combine parcellations ---- #

# fslmaths "${Path}/${OutDir}/${Target}_parc_bin.nii.gz" \
#     -mul "${Path}/${OutDir}/${Source}_parc_bin.nii.gz" \
#     "${Path}/${OutDir}/overlap.nii.gz"

# ---- 1. binary parcellation ---- #
fslmaths "${Path}/${OutDir}/${Target}_parc.nii.gz" -bin \
    "${Path}/${OutDir}/${Target}_parc_bin.nii.gz"

fslmaths "${Path}/${OutDir}/${Target}_parc_bin.nii.gz" \
    -add 1 \
    "${Path}/${OutDir}/${Target}_parc_bin2.nii.gz"
    
fslmaths "${Path}/${OutDir}/${Target}_parc_bin2.nii.gz" \
    -mul "${Path}/${OutDir}/${Target}_parc_bin.nii.gz" \
    "${Path}/${OutDir}/${Target}_parc_bin2.nii.gz"

fslmaths "${Path}/${OutDir}/${Source}_parc.nii.gz" -bin \
    "${Path}/${OutDir}/${Source}_parc_bin.nii.gz"

# ---- combine binaries

fslmaths "${Path}/${OutDir}/${Source}_parc_bin.nii.gz" \
    -add "${Path}/${OutDir}/${Target}_parc_bin2.nii.gz" \
    ${Path}/${OutDir}/TractMask.nii.gz

# ---- 2. complete parcellation ---- #


fslmaths "${Path}/${OutDir}/${Target}_parc.nii.gz" \
    -add ${source_file_count} \
    "${Path}/${OutDir}/parcellation.nii.gz"


fslmaths "${Path}/${OutDir}/parcellation.nii.gz" -mul \
    "${Path}/${OutDir}/${Target}_parc_bin.nii.gz" \
    "${Path}/${OutDir}/parcellation.nii.gz"

fslmaths "${Path}/${OutDir}/parcellation.nii.gz" \
    -add "${Path}/${OutDir}/${Source}_parc.nii.gz" \
    "${Path}/${OutDir}/parcellation.nii.gz"

# checking for overlapps
# for t1 in $target_files; do
#     for t2 in $source_files; do
#         fslmaths "${Path}/${Target}/masks/${t1}" \
#             -mul "${Path}/${Source}/masks/${t2}" \
#             ${Path}/tmp.nii.gz
#         check=$( fslstats ${Path}/tmp.nii.gz -V )
#         echo ${t1} ${t2} ${check}
#     done
# done

# for t1 in $target_files; do
#     fslmaths "${Path}/${Target}/masks/${t1}" \
#         -mul "${Path}/${Source}_${Target}/${Source}_parc_bin.nii.gz" \
#         ${Path}/tmp.nii.gz
#     check=$( fslstats ${Path}/tmp.nii.gz -V )
#     echo ${t1}${check}
# done

# fslmaths $Path/$Target/masks/resampled_red-nucleus_RN.nii.gz \
#     -sub $Path/tmp.nii.gz \
#     $Path/$Target/masks/resampled_red-nucleus_RN.nii.gz 

# overlapp correction example
# fslmaths SN.nii.gz -mul VTA.nii.gz tmp.nii.gz
# fslmaths VTA.nii.gz -sub tmp.nii.gz VTA_clean.nii.gz


# ---- extract connectome ---- #

# ---- 1. get assignments for parcellations masks ---- #

tck2connectome -force -symmetric -zero_diagonal \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "${Path}/${OutDir}/TractMask.nii.gz"  \
    -out_assignments "${Path}/${OutDir}/assignments.txt" \
    "${Path}/${OutDir}/tmp.tsv"

# ---- 2. extract tract subset ---- #

connectome2tck -exclusive -files single \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "${Path}/${OutDir}/assignments.txt" \
    "${Path}/${OutDir}/tracts_subset.tck" -nodes "1,2"


tck2connectome -force -symmetric -zero_diagonal \
    "${Path}/${OutDir}/tracts_subset.tck" \
    "${Path}/${OutDir}/parcellation.nii.gz"  \
    "${Path}/${OutDir}/sc.tsv"

# ---- get full tractogram based SC ---- #


tck2connectome -force -symmetric -zero_diagonal \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "${Path}/${OutDir}/parcellation.nii.gz"  \
    "${Path}/${OutDir}/sc_full.tsv"
