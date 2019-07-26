#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00 
#SBATCH --mem=2GB 
#SBATCH --array=0-220
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

module load matlab/2019a

mkdir -p output


echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
i=1 
found=0 
while IFS=, read mut val
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "Running clonal conversion rate for $mut = $val"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < mut_params.txt 

crypt=$1


if [ $found = 1 ]; then
	echo "matlab -nodisplay -nodesktop -r cd ../../; addpath(genpath(pwd)); runClonalConversion({'$mut'}, [$val], 100, $crypt); quit()"
    matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); runClonalConversion({'$mut'}, [$val], 100, '$crypt'); quit()"
else 
  echo "mut_params.txt  does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi