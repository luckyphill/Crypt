#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00
#SBATCH --mem=4GB 
#SBATCH --array=1-10000
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

echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
i=1 
found=0 
while IFS=, read n np ees ms cct wt vf
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
    	echo "Crypt $crypt, version $vers"
        echo "Running mutation, n $n np $np ees $ees ms $ms cct $cct wt $wt vf $vf"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < optimalWalkPoints.txt

if [ $found = 1 ]; then

	echo "matlab -nodisplay -nodesktop -r cd ../../../; addpath(genpath(pwd)); setBehaviour(1,$n,$np,$ees,$ms,$cct,$wt,$vf); quit()"
    matlab -nodisplay -nodesktop -r "cd ../../../; addpath(genpath(pwd)); setBehaviour(1,$n,$np,$ees,$ms,$cct,$wt,$vf); quit()"
else 
  echo "optimalWalkPoints.txt  does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi