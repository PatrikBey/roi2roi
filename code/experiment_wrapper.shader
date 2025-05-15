




#############################
#                           #
#          ROI2BRAIN        #
#                           #
#############################

docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3H" -e seed="agranular" -e target="brain" -e OutDir="/data/MAPA3-ROI2BRAIN-agranular" roi2roi:dev



Rois="Id8 Id3 Ia3 Ig2 Id4 Id6 Ia1 Id7 Ig3 Ig1 Id10 Id2 Ia2 Id1 Id5 Id9 AAIC Op2 Op3 pOFC Fo3"

for r in ${Rois}; do
    docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Hemi" -e seed="${r}" -e target="brain" -e OutDir="/data/MAPA3-ROI2BRAIN-${r}" roi2roi:dev
done


Areas="dysgranular agranular granular"

for a in ${Areas}; do
    docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Hemi-${a}" -e seed="${a}" -e target="brain" -e OutDir="/data/MAPA3-ROI2BRAIN-${a}" roi2roi:dev
done




seed="Id8,Id3,Ia3,Ig2,Id4,Id6,Ia1,Id7,Ig3,Ig1,Id10,Id2,Ia2,Id1,Id5,Id9"
target="Id8,Id3,Ia3,Ig2,Id4,Id6,Ia1,Id7,Ig3,Ig1,Id10,Id2,Ia2,Id1,Id5,Id9"

docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3" -e seed="${seed}" -e target="${target}" -e OutDir="/data/MAPA3-ROI2ROI-Insula" roi2roi:dev






// # atlas

// docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="AAL3" -e seed="Precentral_L" -e target="Precentral_R" -e OutDir="/data/AAL3-ROI2ROI-PRECENTRAL" roi2roi:dev

// Precentral_L





###################### RERUN 06.05.2025 ############################

#############################
#                           #
#          ROI2BRAIN        #
#                           #
#############################

# I. ROI2BRAIN

seed_list="p24_L p24ab_L p24c_L p24pr_L s24_L a24pr_L AAIC_L Id8_L Id3_L Ia3_L Ig2_L Id4_L Id6_L Ia1_L Id7_L Ig3_L Ig1_L Id10_L Id2_L Ia2_L Id1_L Id5_L Id9_L p24_R p24ab_R p24c_R p24pr_R s24_R a24pr_R AAIC_R Id8_R Id3_R Ia3_R Ig2_R Id4_R Id6_R Ia1_R Id7_R Ig3_R Ig1_R Id10_R Id2_R Ia2_R Id1_R Id5_R Id9_R"

for roi in ${seed_list}; do
    docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3H" -e seed="${roi}" -e target="brain" -e OutDir="/data/ROI2BRAIN-${roi}" roi2roi:dev
done


# II. ROI2ROI

# II.a) L:L
seed="p24_L,p24ab_L,p24c_L,p24pr_L,s24_L,a24pr_L,AAIC_L,Id8_L,Id3_L,Ia3_L,Ig2_L,Id4_L,Id6_L,Ia1_L,Id7_L,Ig3_L,Ig1_L,Id10_L,Id2_L,Ia2_L,Id1_L,Id5_L,Id9_L"
target="p24_L,p24ab_L,p24c_L,p24pr_L,s24_L,a24pr_L,AAIC_L,Id8_L,Id3_L,Ia3_L,Ig2_L,Id4_L,Id6_L,Ia1_L,Id7_L,Ig3_L,Ig1_L,Id10_L,Id2_L,Ia2_L,Id1_L,Id5_L,Id9_L"

docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Hemi" -e seed="${seed}" -e target="${target}" -e OutDir="/data/ROI2ROI-Left2Left" roi2roi:dev



# II.b) L:R
seed="p24_L,p24ab_L,p24c_L,p24pr_L,s24_L,a24pr_L,AAIC_L,Id8_L,Id3_L,Ia3_L,Ig2_L,Id4_L,Id6_L,Ia1_L,Id7_L,Ig3_L,Ig1_L,Id10_L,Id2_L,Ia2_L,Id1_L,Id5_L,Id9_L"

target="p24_R,p24ab_R,p24c_R,p24pr_R,s24_R,a24pr_R,AAIC_R,Id8_R,Id3_R,Ia3_R,Ig2_R,Id4_R,Id6_R,Ia1_R,Id7_R,Ig3_R,Ig1_R,Id10_R,Id2_R,Ia2_R,Id1_R,Id5_R,Id9_R"

docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Hemi" -e seed="${seed}" -e target="${target}" -e OutDir="/data/ROI2ROI-Left2Right-RERUN" roi2roi:dev


# II.c) R:R
seed="p24_R,p24ab_R,p24c_R,p24pr_R,s24_R,a24pr_R,AAIC_R,Id8_R,Id3_R,Ia3_R,Ig2_R,Id4_R,Id6_R,Ia1_R,Id7_R,Ig3_R,Ig1_R,Id10_R,Id2_R,Ia2_R,Id1_R,Id5_R,Id9_R"

target="p24_R,p24ab_R,p24c_R,p24pr_R,s24_R,a24pr_R,AAIC_R,Id8_R,Id3_R,Ia3_R,Ig2_R,Id4_R,Id6_R,Ia1_R,Id7_R,Ig3_R,Ig1_R,Id10_R,Id2_R,Ia2_R,Id1_R,Id5_R,Id9_R"

docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Hemi" -e seed="${seed}" -e target="${target}" -e OutDir="/data/ROI2ROI-Right2Right" roi2roi:dev




#######################
#
#    VALIDATION 24ab
#
#######################


 rechte 24ab mit rechter ventralen agranularen insula
 weist aber viel interhemi auf zur linken. eher innerhalb nicht quer!!

docker run -it -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3H" roi2roi:dev bash


import numpy, os, nibabel, argparse, sys

atlas = nibabel.load(os.path.join('MAPA3H_mrtrix3.nii.gz'))
img = atlas.get_fdata()
ids = numpy.unique(img[img>0]).astype(int)
lut = numpy.genfromtxt('lut_mrtrix3.tsv', dtype=str, delimiter = ';')
rois = list(lut[1:,1])



########## LEFT ############
roi='p24ab_L'

rids = rois.index(roi)

roiimg = numpy.where(img==rids,1,0)

// rois.index('Ig1_L') # 241
// rois.index('Ig2_L') # 242
// rois.index('Ig3_L') # 243
// rois.index('Ig1_R') # 648
// rois.index('Ig2_R') # 649
// rois.index('Ig3_R') # 650

// rois.index('Ia1_L') # 228
// rois.index('Ia2_L') # 229
// rois.index('Ia3_L') # 230
// rois.index('Ia1_R') # 635
// rois.index('Ia2_R') # 636
// rois.index('Ia3_R') # 637


targetimg = roiimg.copy()
targetimg = targetimg + numpy.where(img == 241,2,0)
targetimg = targetimg + numpy.where(img == 242,3,0)
targetimg = targetimg + numpy.where(img == 243,4,0)
targetimg = targetimg + numpy.where(img == 648,5,0)
targetimg = targetimg + numpy.where(img == 649,6,0)
targetimg = targetimg + numpy.where(img == 650,7,0)

targetimg = targetimg + numpy.where(img == 228,8,0)
targetimg = targetimg + numpy.where(img == 229,9,0)
targetimg = targetimg + numpy.where(img == 230,10,0)
targetimg = targetimg + numpy.where(img == 635,11,0)
targetimg = targetimg + numpy.where(img == 636,12,0)
targetimg = targetimg + numpy.where(img == 637,13,0)


save_image(targetimg.astype(float), 'p24ab_L_a_granular_L_R', atlas.affine)




tck2connectome -force \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "p24ab_L_a_granular_L_R.nii" \
    "p24ab_L_a_granular_L_R.tsv"


tckedit "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    -include p24ab_L.nii.gz \
    p24ab_L.tck

tck2connectome -force \
    p24ab_L.tck \
    "p24ab_L_a_granular_L_R.nii" \
    "p24ab_L_a_granular_L_R_subset.tsv"


########## RIGHT ############
roi='p24ab_R'

rids = rois.index(roi)

roiimg = numpy.where(img==rids,1,0)

// rois.index('Ig1_L') # 241
// rois.index('Ig2_L') # 242
// rois.index('Ig3_L') # 243
// rois.index('Ig1_R') # 648
// rois.index('Ig2_R') # 649
// rois.index('Ig3_R') # 650

// rois.index('Ia1_L') # 228
// rois.index('Ia2_L') # 229
// rois.index('Ia3_L') # 230
// rois.index('Ia1_R') # 635
// rois.index('Ia2_R') # 636
// rois.index('Ia3_R') # 637


targetimg = roiimg.copy()
targetimg = targetimg + numpy.where(img == 241,2,0)
targetimg = targetimg + numpy.where(img == 242,3,0)
targetimg = targetimg + numpy.where(img == 243,4,0)
targetimg = targetimg + numpy.where(img == 648,5,0)
targetimg = targetimg + numpy.where(img == 649,6,0)
targetimg = targetimg + numpy.where(img == 650,7,0)

targetimg = targetimg + numpy.where(img == 228,8,0)
targetimg = targetimg + numpy.where(img == 229,9,0)
targetimg = targetimg + numpy.where(img == 230,10,0)
targetimg = targetimg + numpy.where(img == 635,11,0)
targetimg = targetimg + numpy.where(img == 636,12,0)
targetimg = targetimg + numpy.where(img == 637,13,0)


save_image(targetimg.astype(float), 'p24ab_R_a_granular_L_R', atlas.affine)




tck2connectome -force \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "p24ab_R_a_granular_L_R.nii" \
    "p24ab_R_a_granular_L_R.tsv"


tckedit "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    -include p24ab_R.nii.gz \
    p24ab_R.tck

tck2connectome -force \
    p24ab_R.tck \
    "p24ab_R_a_granular_L_R.nii" \
    "p24ab_R_a_granular_L_R_subset.tsv"





import numpy, os, nibabel, argparse, sys

atlas = nibabel.load(os.path.join('MAPA3_MNI152.nii.gz'))
img = atlas.get_fdata()
ids = numpy.unique(img[img>0]).astype(int)

targetimg = numpy.zeros(img.shape)
targetimg = targetimg + numpy.where(img == 233,1,0)
targetimg = targetimg + numpy.where(img == 257,2,0)
targetimg = targetimg + numpy.where(img == 258,3,0)
targetimg = targetimg + numpy.where(img == 259,4,0)
targetimg = targetimg + numpy.where(img == 270,5,0)
targetimg = targetimg + numpy.where(img == 271,6,0)
targetimg = targetimg + numpy.where(img == 272,7,0)


// 233 p24ab
// 257	Ia1
// 258	Ia2
// 259	Ia3
// 270	Ig1
// 271	Ig2
// 272	Ig3

save_image(targetimg, 'p24ab_a_granular.nii.gz', atlas.affine)


p24ab = numpy.where(img==233,1,0)
save_image(p24ab.astype(float), 'p24ab.nii.gz',atlas.affine)

tck2connectome -force \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "p24ab_a_granular.nii.gz" \
    "p24ab_a_granular.tsv"

tckedit "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    -include p24ab.nii.gz \
    p24ab.tck

tck2connectome -force \
    p24ab.tck \
    "p24ab_a_granular.nii.gz" \
    "p24ab_a_granular_subset.tsv"










############ FULL brain

tck2connectome -force \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "MAPA3H_mrtrix3.nii.gz"  \
    "full_brain_sc.tsv"



tck2connectome -force -symmetric -zero_diagonal \
    "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
    "MAPA3H_mrtrix3.nii.gz"  \
    -out_assignments MAPA3assignments.txt \
    "full_brain_sc_sym.tsv"




206	p24ab_L
229	Ia1_L
230	Ia2_L
231	Ia3_L
242	Ig1_L
243	Ig2_L
244	Ig3_L
636	Ia1_R
637	Ia2_R
638	Ia3_R
649	Ig1_R
650	Ig2_R
651	Ig3_R

targets="229 230 231 242 243 244 636 637 638 649 650 651"

for t in $targets; do
    connectome2tck -exclusive -files single \
        "${TEMPLATEDIR}/dTOR_full_tractogram.tck" \
        "MAPA3assignments.txt" \
        tracts_p24ab_${t}.tck -nodes "206,${t}"
done

cc = numpy.genfromtxt('full_brain_sc_sym.tsv')
ccth = numpy.where(cc>=numpy.quantile(cc,0.9),numpy.quantile(cc,0.9),cc)
plt.imshow(ccth)
plt.colorbar()
plt.savefig('full_brain_sc.png')
plt.close()


ccins = cc[,(206,229, 230, 231, 242, 243, 244, 636, 637, 638, 649, 650, 651)]
ids = (206,229, 230, 231, 242, 243, 244, 636, 637, 638, 649, 650, 651)

ccins = cc[206,ids]
.reshape(1,-1)

for i in ids[1:]:
    ccins = numpy.concatenate([ccins,cc[i,ids].reshape(1,-1)], axis = 1)








############################
# CREATE SYMMETRIC HEMI SPLIT MAPA3



docker run -it -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Sym" roi2roi:dev bash


fslmaths MAPA3_MNI152.nii.gz -mul right.nii.gz MAPA3right.nii.gz

fslswapdim MAPA3right.nii.gz -x y z MAPA3left.nii.gz



fslmaths MAPA3right.nii.gz -bin MAPA3Rightbin.nii.gz
fslmaths MAPA3right.nii.gz -add 1000 MAPA3right1000.nii.gz 
fslmaths MAPA3right1000.nii.gz -mul MAPA3Rightbin.nii.gz MAPA3rightupdate.nii.gz

fslmaths MAPA3rightupdate.nii.gz -add MAPA3left.nii.gz MAPA3Sym.nii.gz




docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Sym" -e seed="p24ab_L" -e target="brain" -e OutDir="/data/ROI2BRAIN-p24ab_L" roi2roi:dev

docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3Sym" -e seed="p24ab_R" -e target="brain" -e OutDir="/data/ROI2BRAIN-p24ab_R" roi2roi:dev





thalamus2insula x thalamus2insula

brainstem2insula x brainstem2insula
