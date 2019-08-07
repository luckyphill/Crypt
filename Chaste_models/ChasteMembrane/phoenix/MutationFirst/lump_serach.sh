#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00 
#SBATCH --mem=1GB 
#SBATCH --array=0-64
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
while IFS=, read mnp eesM msM cctM wtM mvf
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "Running mutation, mnp $mnp, eesM $eesM, msM $msM, cctM $cctM, wtM $wtM, mvf $mvf"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < detail_mutations.txt 

if [ $found = 1 ]; then
	echo "matlab -nodisplay -nodesktop -r cd ../../; addpath(genpath(pwd)); runVisualiserAnalysis($mnp,$eesM,$msM,$cctM,$wtM,$mvf); quit()"
    matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); runVisualiserAnalysis($mnp,$eesM,$msM,$cctM,$wtM,$mvf); quit()"
else 
  echo "detail_mutations.txt  does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi