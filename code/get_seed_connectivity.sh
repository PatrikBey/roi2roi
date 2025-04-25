#!/bin/bash
#
#
# # get_single_seed_connectivities.sh
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
# * last update: 2025.04.22
#
#
#
# ## Description
#
# This script extractes ROI based tractograms from the template normative connectome (1) 
# using ROI volume masks. 
#
#
#############################################
#                                           #
#            CHECK INPUT                    #
#                                           #
#############################################

# ---- loading I/O & logging functionality ---- #
source ${SRCDIR}/utils.sh
source ${SRCDIR}/functions.sh

# ---- parse input ---- #
Path=`getopt1 "--path" $@`  # "$1" working directory 
TractFile=`getopt1 "--tck" $@`  # "$2" tract file to extract connectivity from
Atlas=`getopt1 "--atlas" $@`  # "$3" atlas name 
OutDir=`getopt1 "--outdir" $@`  # "$4"output directory

if [[ ! -d "${OutDir}/tracts" ]]; then
    mkdir -p "${OutDir}/tracts"
fi


#############################################
#                                           #
#            PREPROCESSING                  #
#                                           #
#############################################

# ---- EXTRACTING ROI MASKS BASED CONNECTIONS ---- #

log_msg "START | Extracting seed based connectivity."

