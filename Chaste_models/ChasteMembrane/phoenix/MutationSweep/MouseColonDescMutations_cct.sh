#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00 
#SBATCH --mem=1GB 
#SBATCH --array=0-182
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

mkdir -p output


echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
i=1 
found=0 
while IFS=, read frac
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "Running mutation flag ${param} with value ${value}"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < mutation_sweep_cct.txt 

if [ $found = 1 ]; then
    matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); ClonalRate_MouseColonDesc({'cctM', 'wtM'}, [${value}, ${value}], 100); quit()"
else 
  echo "mutation_sweep.txt does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi