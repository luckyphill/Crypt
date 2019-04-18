script=$1
VF=$2

module load matlab/2016b
matlab -nodisplay -nodesktop -r "${script}; quit()"