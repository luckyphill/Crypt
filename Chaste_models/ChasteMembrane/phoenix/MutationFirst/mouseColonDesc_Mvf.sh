#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00 
#SBATCH --mem=1GB 
#SBATCH --array=0-10
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

module load matlab/2019a

mkdir -p output
export CHASTE_TEST_OUTPUT="/tmp/a1738927/testoutput/"

echo "array_job_index: $SLURM_ARRAY_TASK_ID" 

echo "matlab -nodisplay -nodesktop -r cd ../../; addpath(genpath(pwd)); runVisualiserAnalysis('MouseColonDesc', 12,1,1,1,1,0.55, $SLURM_ARRAY_TASK_ID); quit()"
matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); runVisualiserAnalysis('MouseColonDesc', 12,1,1,1,1,0.55, $SLURM_ARRAY_TASK_ID); quit()"