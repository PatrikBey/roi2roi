





docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3-agranular" -e seed="agranular" -e target="brain" -e OutDir="/data/MAPA3-ROI2BRAIN-agranular" roi2roi:dev



Rois="Id8 Id3 Ia3 Ig2 Id4 Id6 Ia1 Id7 Ig3 Ig1 Id10 Id2 Ia2 Id1 Id5 Id9 AAIC Op2 Op3 pOFC Fo3"

for r in ${Rois}; do
    docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3" -e seed="${r}" -e target="brain" -e OutDir="/data/MAPA3-ROI2BRAIN-${r}" roi2roi:dev
done


Areas="dysgranular agranular granular"

for a in ${Areas}; do
    docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3-${a}" -e seed="${a}" -e target="brain" -e OutDir="/data/MAPA3-ROI2BRAIN-${a}" roi2roi:dev
done




seed="Id8,Id3,Ia3,Ig2,Id4,Id6,Ia1,Id7,Ig3,Ig1,Id10,Id2,Ia2,Id1,Id5,Id9"
target="Id8,Id3,Ia3,Ig2,Id4,Id6,Ia1,Id7,Ig3,Ig1,Id10,Id2,Ia2,Id1,Id5,Id9"

docker run -v /mnt/h/Research/ROI2ROI/Data:/data -e atlas="MAPA3" -e seed="${seed}" -e target="${target}" -e OutDir="/data/MAPA3-ROI2ROI-Insula" roi2roi:dev
