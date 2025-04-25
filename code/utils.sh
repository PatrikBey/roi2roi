#!/bin/bash
#
#
# # utils.sh
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
# This script contains utility functions.
#
#
# FUNCTIONS: 
# 1. show_usage     :   help function to display usage of analysis framework
# 2. log_msg        :   printing logging statements to std_out
# 3. get_list_size  :   Extracting the length of a given list of strings
# 4. get_temp_dir   :   creating a temporary directory with random naming
# 5. progress_bar   :   provide progressbar functionality for visual progress tracking

#############################################
#                                           #
#            HELPER FUNCTIONS               #
#                                           #
#############################################


# 1. show_usage

show_usage() {
  figlet "ROI2ROI" | lolcat 
	cat <<EOF

* author:       Patrik Bey
* last update:  2024/10/14

STRUCTURAL CONNECTIVITY FOR FUNCTIONAL NETWORKS OF PAIN


--- documentation ---

--- usage ---

docker run \
    -v /PATH/TO/STUDYFOLDER:/data \
    -e seed="SeedROIs" \
    -e target="TargetROIs" \
    roi2roi

--- variables ---

<<seed>>        name of set of ROIs to use as initial ROIs for connectivity
                    {required} | [represents rows in conenctivity matrix]

<<target>>      name of set of ROIs to use as secondary ROIs 
                for connectivity
                    {optional} | [represents columns in connectivity matrix]

<<tracts>>      boolean whether to extract subtracts for all seed:target ROI pairs
                    {optional} | [default="False"; increases computation time]

<<masks>>       boolean whether to only prepare seed & target masks for a given atlas
                    {optional} | [default="False"; requires <<atlas>> to be set]

<<atlas>>       Atlas name as provided in STUDYFOLDER for use in mask preparation
                    {optional} | [default=MAPA; only used if <<masks>> = True]

<<OutDir>>      Output directory for mask preparation step
                    {optional} | [will contain seed/target roi_masks directories]

<<roi>>     filename of a given ROI volume mask to use in given container call
                {optional} | [only used in parallelized container calls]

<<connectome>>      boolean whether to only perform combination of single weight files
                into a single connectome.
                        {optional} | [default="only"; only used in parallelized container calls]

<<preproc>>     boolean whether to only perform preprocessing to enable downstream parallalization.
                    {optional} | [default="only"; only used in parallelized container calls]

<<template>>        template tractogram in same space as <seed> and <target>. Path relative to /data
                        {optional} | [default: dTOR_full_tractogram.tck (Elias et al. (2024))]

<<cleanup>>         boolean whether to remove temporary files
                        {optional} | [default: True >> removing temp-directory]

<<CLUSTER>>         boolean whether container is run on HPC cluster to adjust logging functions.
                        {optional} | [default: False >> ussing color coded logging]

--- input ---

expected input file structure for mask preparation:

/STUDYFOLDER
    |_<<ATLASNAME>>
        |_lut.tsv
        |_<<ATLASNAME>>_MNI152.nii.gz


expected input file structure for connectivity extraction:
[created during mask preparation]

/STUDYFOLDER
    |_seed
        |_roi_masks
    |_target
        |_roi_masks

EOF
	exit 1
}


# 2. log_msg
log_msg() {
    # print out text for logging
    _type=$( echo ${1} | cut -d'|' -f1 )
    _message=${1}
    if [[ ${CLUSTER,,} = "true" ]]; then
        echo -e "\n$(date) $(basename  -- "$0") | ${_message}"
    else
        if [[ ${_type,,} = "start " ]] || [[ ${_type,,} = "finished " ]] || [[ ${_type,,} = "error " ]]; then
            echo -e "\n$(date) $(basename  -- "$0") | ${_message}" | lolcat
        else
            echo -e "\n$(date) $(basename  -- "$0") | ${_message}"
        fi
    fi
}


getopt1() {
    sopt="$1"
    shift 1
    for fn in $@ ; do
	if [ `echo $fn | grep -- "^${sopt}=" | wc -w` -gt 0 ] ; then
	    echo $fn | sed "s/^${sopt}=//"
	    return 0
	fi
    done
}


# 3. get_list_size
get_list_size() {
    # return length of given ROI list
    # ${1}: roi list
    count=0
    for r in ${target_list}; do
        count=$((count+1))
    done
    export list_size=${count}
}

# 4. get_temp_dir

get_temp_dir(){
# create temporary directory
    randID=$RANDOM
    export TempDir="${1}/temp-${randID}"
    mkdir ${TempDir}
}

# 5. progress_bar
progress_bar() {
    # print a progress bar during loops
    # ${1} current iteration of loop
    # ${2} total length of loop
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")
    printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"
}



# return length of a (single or multiple) given array

get_array_len() {
    # return length of provided input
    # arrays
    # $1:N arrays to count elements from
    len=($( echo $#));
}

