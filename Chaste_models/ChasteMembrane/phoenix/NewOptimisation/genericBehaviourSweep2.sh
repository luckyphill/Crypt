#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=24:00:00 
#SBATCH --mem=1GB 
#SBATCH --array=0-9999
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load netCDF-Fortran
module unload OpenMPI
module unload HDF5

echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
crypt=$1

i=0 
found=0
while IFS=, read n np ees ms cct wt vf r
do 
    if [ $i = $SLURM_ARRAY_TASK_ID - 1001 ]; then 
        echo "LHS sweep with: -n ${n} -np ${np} -ees ${ees} -ms ${ms} -cct ${cct} -wt ${wt} -vf ${vf}"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < $crypt

if [ $found = 1 ]; then
	echo "matlab -nodisplay -nodesktop -r cd ../../; addpath(genpath(pwd)); behaviourObjective(@MouseColonDesc,$n,$np,$ees,$ms,$cct,$wt,$vf,2000,0.0005,200,$r); quit()"
    matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); behaviourObjective(@MouseColonDesc,$n,$np,$ees,$ms,$cct,$wt,$vf,2000,0.0005,200,$r); quit()"
else 
  echo "$crypt does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi