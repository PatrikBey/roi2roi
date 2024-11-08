# roi2roi
Generating ROI 2 ROI structural connectivity


## ABOUT

This containerized framework contains all the encessary code to extract roi2roi connectivity weights for any two sets of ROIs.

Author:
Patrik Bey, <a href="https://github.com/PatrikBey" target="_blank">Patrik Bey</a>

## DESCRIPTION

### REQUIREMENTS
Certain data formating requirements exist for the automated usage:
1. For each ROI list binary ROI volume masks need to be provided.
3. ROI masks need to be in the same space as the used normative tractogram. If the default normative tractogram (1) is used, this is equivalent to MNI152 standard space with a 1mm voxelsize and 182x218x182 resolution.
4. Docker / Singularity containerization software.


0. INITIALIZATION
Preparing variables for downstream functionality and validate correct data formatting

Data storage formatting:

/STUDYFOLDER
  |_SEEDROIS
    |_roi_masks
      |_roi_1.nii.gz
  |_TARGETROIS
    |_roi_masks
      |_roi_1.nii.gz




### FULLY AUTOMATED

REQUIRED VARIABLES
```bash
STUDYFOLDER="/PATH/TO/YOUR/DATA"
SEEDROIS="Name of seed ROI data set"
TARGETROIS="Name of target ROI data set"
```

```bash
docker run \
  -v "${STUDYFOLDER}":"/data" \
  -e seed="${SEEDROIS}" \
  -e target="${TARGETROIS}" \
  roi2roi
```

### ROI PARALLELIZATION

REQUIRED VARIABLES
```bash
STUDYFOLDER="/PATH/TO/YOUR/DATA"
SEEDROIS="Name of seed ROI data set"
TARGETROIS="Name of target ROI data set"
ROILIST="List of filenames of individual seed ROIs"
```

1. PREPROCESSING

Only perform preprocessing to enable downstream parallelization.
```bash
docker run -v "${STUDYFOLDER}":"/data" \
    -e seed="${Seed}" \
    -e target="${Target}" \
    -e preproc="only" \
    roi2roi 
```

2. CONNECTIVITY STRENGTH

Extracting individual connection strength for a given seed ROI to all target ROIs.

```bash
for roi in ${ROILIST}; do
  docker run -v "${STUDYFOLDER}":"/data" \
      -e seed="${Seed}" \
      -e target="${Target}" \
      -e roi="${roi}" \
      roi2roi
```

4. CONNECTOME CREATION

Combining the previously generated ROI specific connection strengths into a single structural connectome file.

```bash
docker run -v "${STUDYFOLDER}":"/data" \
    -e seed="${Seed}" \
    -e target="${Target}" \
    -e connectome="only" \
    roi2roi
```

## BUILDING CONTAINER

To build this container download the github repository as well as the corresponding template tractogram (see 1.).
The tractogram needs to be converted into .tck format before integration into the container. In this project this was achieved using the Tramplolino container (2.).
After preparing the tractogram file and adding it to the Templates directory of the downloaded repository, the container can be build from inside the directory via

```bash
docker build . -t "roi2roi" -f "code/Dockerfile"
```

## REFERENCES

* 1. Lozano, Andres; Elias, Gavin; Germann, Jürgen; Joel, Suresh; Li, Ningfei; Horn, Andreas; et al. (2024). A large normative connectome for exploring the tractographic correlates of focal brain interventions. figshare. Collection. https://doi.org/10.6084/m9.figshare.c.6844890.v1
* 2.  Matteo Mancini, https://trampolino.readthedocs.io/en/latest/authors.html#development-lead
