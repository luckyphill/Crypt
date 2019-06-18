#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=02:00:00 
#SBATCH --mem=1GB 
#SBATCH --array=0-9261%120
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
while IFS=, read n np ees ms vf cct wt
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "Parameter optimisation with: -t 400 -n ${n} -np ${np} -ees ${ees} -ms ${ms} -vf ${vf} -cct ${cct} -wt ${wt}"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < $1

if [ $found = 1 ]; then

	echo "/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -t 400 -n ${n} -np ${np} -ees ${ees} -ms ${ms} -vf ${vf} -cct ${cct} -wt ${wt} -run 1";
	/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCryptColumn -t 400 -n ${n} -np ${np} -ees ${ees} -ms ${ms} -cct ${cct} -vf ${vf} -wt ${wt} -run 1

else 
  echo "$1 does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi