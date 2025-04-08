




docker run -it -v /mnt/h/Research/ROI2ROI/Data:/data roi2roi:dev bash

Path='/data'
atlas="MAPA"






# ---- get tract length ---- #

# 1. check if parcellation volume present
# 2. adjust parcellation volume to have continuous numbering  (checl leapp code) / save LUT
# 3. compute tract lengths / save connectome lengths file
 
if [ ! -f "${Path}/${atlas}/${atlas}_MNI152.nii.gz" ]; then
    log_msg "ERROR | ${atlas} parcellation volume not found."
fi



get_connection_length(){
    # $1 input track file (i.e. normative tractogram)
    # $2 parcellation image (i.e. atlas parcellation)
    # $3 output filename
    if [ -z ${3} ]; then
        outfile="${2%.nii.gz}_lengths.tsv"
    else
        outfile="${3}"
    fi
    tck2connectome -scale_length -force -zero_diagonal -symmetric -stat_edge mean \
        "${1}" \
        "${2}" \
        "${3}"
}

get_connection_length \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "${Path}/${atlas}/${atlas}_mrtrix3.nii.gz" \
    "${Path}/testing_length.tsv"


missing=$(python -c "import numpy; empty=numpy.where(numpy.genfromtxt('${Path}/${atlas}/${atlas}_tract_lengths.tsv').sum(axis=0)==0)[0]+1; print(f'No tracts found for ROIs: {empty}.')")

missing=$(python -c "import numpy; empty=numpy.where(numpy.genfromtxt('${Path}/${atlas}/${atlas}_tract_lengths.tsv').sum(axis=0)==-1)[0]+1; print(f'No tracts found for ROIs: {empty}.')")


tck2connectome: [WARNING] The following nodes do not have any streamlines assigned:
tck2connectome: [WARNING] 17, 50, 206, 251, 290, 300, 325, 328, 340, 341, 353, 360, 385, 389, 402, 409, 429, 434, 437




missing=[51.0, 130.0, 258.0, 413.0, 414.0, 3214.0, 4150.0, 4151.0, 4163.0, 4164.0, 5013.0, 6608.0, 6623.0, 6642.0, 6649.0, 6671.0, 6677.0, 6680.0]
missing = [17, 50, 206, 251, 290, 300, 325, 328, 340, 341, 353, 360, 385, 389, 402, 409, 429, 434, 437]

out_img = numpy.zeros(data.shape)

for r in missing:
    out_img = out_img + numpy.where(data==r,r,0)

numpy.unique(out_img)


save_image(out_img, '/data/missing_tracts_rois.nii.gz', affine)






seed_list="${Path}/${seed}/roi_masks/*.nii.gz"
target_list="${Path}/${target}/roi_masks/*.nii.gz"




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


tckedit -force -quiet \
    "/data/MAPA/run_8834/target/target.tck" \
    "${TempDir}/tmp.tck" \
    -include /data/MAPA/run_8834/seed/roi_masks/3b.nii.gz


tckedit -force -quiet \
    "${TempDir}/tmp.tck" \
    "${TempDir}/out.tck" \
    -maxlength \
    -minlength \
    -include /data/MAPA/run_8834/target/roi_masks/occipital_cortex.nii.gz





Path=/data/MAPA/run_8834
seed="seed"
target="target"



    cp ${TEMPLATEDIR}/Empty.nii.gz \
    ${TempDir}/${target}_ribbon.nii.gz
    # ---- concatenate ROI masks
    files="${Path}/${1}/roi_masks/*.nii.gz"
    for f in $files; do
        fslmaths ${TempDir}/${1}_ribbon.nii.gz \
            -add ${f} \
            ${TempDir}/${1}_ribbon.nii.gz 2>/dev/null
    done
    # ---- binarize volume
    fslmaths ${TempDir}/${1}_ribbon.nii.gz \
        -bin \
        ${TempDir}/${1}_ribbon_bin.nii.gz
