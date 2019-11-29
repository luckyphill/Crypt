#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 16 
#SBATCH --time=12:00:00 
#SBATCH --mem=1GB 
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

export TZ=Australia/Adelaide

module load matlab/2019a

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

mkdir -p output

objectiveFunction=$1
n=$2
np=$3
ees=$4
ms=$5
cct=$6
wt=$7
vf=$8

echo "-nodisplay -nodesktop -r cd ../../; addpath(genpath(pwd)); parObjectiveFunction([n,np,ees,ms,cct,wt,vf], $objectiveFunction, 16); quit()"
matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); parObjectiveFunction([n,np,ees,ms,cct,wt,vf], $objectiveFunction, 16); quit()"