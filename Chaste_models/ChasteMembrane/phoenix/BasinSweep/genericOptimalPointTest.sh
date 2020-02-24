#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00
#SBATCH --mem=4GB
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

echo "array_job_index: $SLURM_ARRAY_TASK_ID" 

echo "Crypt $crypt, version $vers"
echo "Running optimal point"

echo "matlab -nodisplay -nodesktop -r cd ../../../; addpath(genpath(pwd)); basinObjective($crypt,$vers,1,1,1,1,1,1,1); quit()"
matlab -nodisplay -nodesktop -r "cd ../../../; addpath(genpath(pwd)); basinObjective($crypt,$vers,,1,1,1,1,1,1,1); quit()"
