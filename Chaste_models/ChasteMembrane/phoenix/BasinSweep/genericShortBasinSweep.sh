#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00
#SBATCH --mem=4GB 
#SBATCH --array=1-701
#SBATCH --output=/dev/null
#SBATCH --error=/dev/null
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

module load matlab/2019b

crypt=$1
vers=$2
data=$3

echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
i=1 
found=0 
while IFS=, read nM npM eesM msM cctM wtM vfM
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
    	echo "Crypt $crypt, version $vers"
        echo "Running mutation, nM, $nm, npM $npM, eesM $eesM, msM $msM, cctM $cctM, wtM $wtM, vfM $vfM"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < $data

if [ $found = 1 ]; then
	echo "matlab -nodisplay -nodesktop -r cd ../../../; addpath(genpath(pwd)); basinObjective($crypt,$vers,$nM,$npM,$eesM,$msM,$cctM,$wtM,$vfM); quit()"
    matlab -nodisplay -nodesktop -r "cd ../../../; addpath(genpath(pwd)); basinObjective($crypt,$vers,$nM,$npM,$eesM,$msM,$cctM,$wtM,$vfM); quit()"
else 
  echo "$data  does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi