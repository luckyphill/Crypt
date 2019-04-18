#!/bin/bash
script=$1

module load matlab/2016b
matlab -nodisplay -nodesktop -r "${script}; quit()"