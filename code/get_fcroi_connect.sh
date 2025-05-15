#!/bin/bash
#
#
# # get_fcroi_connect.sh
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
# * last update: 2025.05.10
#
#
#
# ## Description
#
# This script is used for development of roi2roi connectivity
# using the FC based ROIs
#
#
#############################################
#                                           #
#            CHECK INPUT                    #
#                                           #
#############################################


docker run -it -v /mnt/h/Research/ROI2ROI/Data/ROIS4FC/ROIS:/data roi2roi:dev bash

# ---- loading I/O & logging functionality ---- #
source ${SRCDIR}/utils.sh
source ${SRCDIR}/functions.sh

# ---- parse input ---- #
Path='/data'
Set="Cortex"


files=$( ls ${Path}/${Set})

count=1
for f in ${files}; do
    fslmaths ${Path}/${Set}/${f} -bin ${Path}/${Set}/${f}
    progress_bar $count 527
    count=$((count+1))
done

cp ${TEMPLATEDIR}/Empty.nii.gz concat.nii.gz
count=1
for f in ${files}; do
    fslmaths concat.nii.gz -add ${Path}/${Set}/${f} concat.nii.gz
    progress_bar $count 527
    count=$((count+1))
done

Set="BrainStem"


files=$( ls ${Path}/${Set})

cp ${TEMPLATEDIR}/Empty.nii.gz concat_${Set}.nii.gz

count=1
for f in ${files}; do
    fslmaths ${Path}/${Set}/${f} -bin ${Path}/${Set}/${f}
    fslmaths concat_${Set}.nii.gz -add ${Path}/${Set}/${f} concat_${Set}.nii.gz
    progress_bar $count 527
    count=$((count+1))
done


Set="Insula"


files=$( ls ${Path}/${Set})

cp ${TEMPLATEDIR}/Empty.nii.gz concat_${Set}.nii.gz

count=1
for f in ${files}; do
    fslmaths ${Path}/${Set}/${f} -bin ${Path}/${Set}/${f}
    fslmaths concat_${Set}.nii.gz -add ${Path}/${Set}/${f} concat_${Set}.nii.gz
    progress_bar $count 32
    count=$((count+1))
done

fslmaths concat_${Set}.nii.gz -add ${Path}/${Set}/${f} concat_${Set}.nii.gz



Set="CortexAtlas"
files=$( ls ${Path}/${Set})

cp ${TEMPLATEDIR}/Empty.nii.gz concat_${Set}.nii.gz
touch ${Set}/lut.txt
count=1

for f in ${files}; do
    fslmaths ${Path}/${Set}/${f} -bin ${Path}/${Set}/${f}
    fslmaths ${Path}/${Set}/${f} -mul ${count} ${Path}/${Set}/${f}
    fslmaths concat_${Set}.nii.gz -add ${Path}/${Set}/${f} concat_${Set}.nii.gz
    echo ${count} ${f%.nii.gz} >> ${Set}/lut.txt
    progress_bar $count 527
    count=$((count+1))
done






tck2connectome -force -symmetric -zero_diagonal \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    concat_${Set}.nii.gz  \
    "${Set}_sc.tsv"



cp ${TEMPLATEDIR}/Empty.nii.gz concat_Insula.nii.gz
Set="Insula"

files=$( ls ${Path}/${Set})
touch ${Set}/lut.txt
count=1

for f in ${files}; do
    fslmaths ${Path}/${Set}/${f} -bin ${Path}/${Set}/${f}
    fslmaths ${Path}/${Set}/${f} -mul ${count} ${Path}/${Set}/${f}
    fslmaths concat_${Set}.nii.gz -add ${Path}/${Set}/${f} concat_${Set}.nii.gz
    echo ${count} ${f%.nii.gz} >> ${Set}/lut.txt
    progress_bar $count 527
    count=$((count+1))
done



Networks=$( ls ${Path}/Networks/roi_masks )

get_tracts_subset_new() {
    # compute assignments for given ROI pair
    # $1 target ROI
    # $2 output file prefix
    fslmaths \
        Insula.nii.gz \
        -add ${1} \
        tmp.nii.gz
    tck2connectome -force -quiet -symmetric -zero_diagonal \
        "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
        "tmp.nii.gz"  \
        -out_assignments ${2}.txt \
        "tmp.tsv"
    connectome2tck -exclusive -quiet -files single \
        "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
        "${2}.txt" \
        ${2}.tck -nodes "1,2"
}

get_connections() {
    # compute connectivity based on tract subset
    fslmaths $1 -mul 33 tmp.nii.gz
    fslmaths concat_Insula.nii.gz -add tmp.nii.gz tmp.nii.gz
    tck2connectome -force -symmetric -zero_diagonal -quiet \
        "${2}.tck" \
        tmp.nii.gz  \
        "${2}_sc.tsv"
}


count=1
for n in $Networks; do
    get_tracts_subset_new ${Path}/Networks/${n} ${n%.nii.gz}
    get_connections ${Path}/Networks/${n} ${n%.nii.gz}
    progress_bar $count 18
    count=$((count+1))
done


########### NETWORK FULL TRACTOGRAM ########



Networks=$( ls ${Path}/Networks/roi_masks )
ParcDir="${Path}/Networks/parcellations"
mkdir -p ${ParcDir}
mkdir -p "${Path}/Networks/connectomes"

count=1
for n in $Networks; do
    fslmaths ${Path}/Networks/roi_masks/${n} -mul 33 tmp.nii.gz
    fslmaths ${Path}/concat_Insula.nii.gz -add tmp.nii.gz ${ParcDir}/${n%.nii.gz}_Insula.nii.gz
    tck2connectome -force -symmetric -zero_diagonal -quiet \
        "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
        ${ParcDir}/${n%.nii.gz}_Insula.nii.gz  \
        "${Path}/Networks/connectomes/${n%.nii.gz}_Insula_sc.tsv"
    progress_bar $count 18
    count=$((count+1))
done



runs="1 2 3 4"
for r in $runs; do
    tck2connectome -force -symmetric -zero_diagonal -quiet \
        "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
        ${Path}/concat_Insula.nii.gz  \
        "${Path}/Insula_sc_run${r}.tsv"
done


files=os.listdir()
names = names[1:]
for f in files[5:]:
    tmp = numpy.genfromtxt(f, delimiter='\t', dtype=str)
    la = numpy.zeros([tmp.shape[0]+1,tmp.shape[0]+1], dtype=object)
    la[1:33,0] = names
    la[0,1:33] = names
    la[33,0] = f[:-7]
    la[0,33] = f[:-7]
    la[1:,1:] = tmp
    la[0,0] = ''
    numpy.savetxt(f, la, fmt='%s')





fslmaths ${Path}/Networks/${n} -bin ${Path}/Networks/${n}




#### THALAMUS

fslmaths Thalamus/thalamus_atlas.nii.gz -bin Thalamus/thalamus_bin.nii.gz

fslmaths Insula.nii.gz -bin Insula_bin.nii.gz
fslmaths Insula_bin.nii.gz -mul 72 Insula72.nii.gz
fslmaths Insula.nii.gz -add Insula72.nii.gz InsulaThalamus.nii.gz


fslmaths InsulaThalamus.nii.gz -add Thalamus_Hemi_mrtrix3.nii.gz InsulaThalamus.nii.gz


tck2connectome -force -symmetric -zero_diagonal \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    InsulaThalamus.nii.gz  \
    "Thalamus2Insula_sc_full.tsv"



#### BrainStem

fslmaths brainstem_atlas.nii.gz -bin bs_bin.nii.gz

fslmaths concat_Insula.nii.gz -bin Insula_bin.nii.gz
fslmaths Insula_bin.nii.gz -mul 2 Insula2.nii.gz

tck2connectome -force -quiet -symmetric -zero_diagonal \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "BSInsula.nii.gz"  \
    -out_assignments BSInsula.txt \
    "BSInsula.tsv"


connectome2tck -exclusive -files single \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "BSInsula.txt" \
    BrainStemInsula.tck -nodes "1,2"






fslmaths Insula_bin -mul 68 Insula68.nii.gz
fslmaths Insula68.nii.gz -add concat_Insula.nii.gz Insulaupdate.nii.gz
fslmaths brainstem_atlas.nii.gz -add Insulaupdate.nii.gz BS2Insula.nii.gz




tck2connectome -force -symmetric -zero_diagonal \
    BrainStemInsula.tck \
    BS2Insula.nii.gz  \
    "BrainStem2Insula_sc.tsv"


tck2connectome -force -symmetric -zero_diagonal \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    BS2Insula.nii.gz  \
    "BrainStem2Insula_sc_full.tsv"
