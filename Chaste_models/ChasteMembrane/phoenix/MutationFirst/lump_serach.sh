#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00 
#SBATCH --mem=1GB 
#SBATCH --array=0-14
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
while IFS=, Mnp eesM msM cctM wtM Mvf
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "Running mutation, Mnp $Mnp, eesM $eesM, msM $msM, cctM $cctM, wtM $wtM, Mvf $Mvf"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < mut_params.txt 

if [ $found = 1 ]; then
	echo "-nodisplay -nodesktop -r cd ../../; addpath(genpath(pwd)); runVisualiserAnalysis($Mnp,$eesM,$msM,$cctM,$wtM,$Mvf); quit()"
    matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); runVisualiserAnalysis($Mnp,$eesM,$msM,$cctM,$wtM,$Mvf); quit()"
else 
  echo "mut_params.txt  does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi