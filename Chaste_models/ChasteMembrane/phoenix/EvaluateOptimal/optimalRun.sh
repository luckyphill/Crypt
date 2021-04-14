#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=06:00:00
#SBATCH --mem=4GB 
#SBATCH --array=1-10000
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module load Boost
module unload OpenMPI/gcc/3.1.1
module load Python/3.6.6


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
done < optimalRun.txt

if [ $found = 1 ]; then

    echo '/hpcfs/users/a1738927/Research/chaste_build/projects/ChasteMembrane/test/TestCryptColumn -bt 100 -t 400 -n $n -np $np -ees $ees -ms $ms -cct $cct -wt $wt -vf $vf';
    /hpcfs/users/a1738927/Research/chaste_build/projects/ChasteMembrane/test/TestCryptColumn -n $n -np $np -ees $ees -ms $ms -cct $cct -wt $wt -vf $vf
	
else 
  echo "optimalWalkPoints.txt  does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi