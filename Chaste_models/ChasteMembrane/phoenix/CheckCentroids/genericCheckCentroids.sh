#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00
#SBATCH --mem=4GB 
#SBATCH --array=1-20
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

module load matlab/2019b

data=$1
crypt=$2

echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
i=1 
found=0 
while IFS=, read n np ees ms cct wt vf
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "Running mutation, n, $n, np $np, ees $ees, ms $ms, cct $cct, wt $wt, vf $vf"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < $data

if [ $found = 1 ]; then
	echo "matlab -nodisplay -nodesktop -r cd ../../../; addpath(genpath(pwd)); setBehaviour(@$crypt,$n,$np,$ees,$ms,$cct,$wt,$vf,'varargin'); quit()"
    matlab -nodisplay -nodesktop -r "cd ../../../; addpath(genpath(pwd)); setBehaviour(@$crypt,$n,$np,$ees,$ms,$cct,$wt,$vf,'varargin'); quit()"
else 
  echo "$data  does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi

setBehaviour(objectiveFunction,n,np,ees,ms,cct,wt,vf,varargin)