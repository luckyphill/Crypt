#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00 
#SBATCH --mem=1GB 
#SBATCH --array=0-243%60
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
EES=$2
MS=$3
OBJ=$4
while IFS=, read n np vf cct wt
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "Parameter sweep of $OBJ with: -t 400 -n ${n} -np ${np} -vf ${vf} -cct ${cct} -wt ${wt}"
        echo "About the points EES=${EES} and MS=${MS}"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < $1

if [ $found = 1 ]; then
	matlab -nodisplay -nodesktop -r "loop_simulation(@$OBJ, 400, $n, $np, $EES, $MS, $vf, $cct, $wt); quit()"
else 
  echo "$1 does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi