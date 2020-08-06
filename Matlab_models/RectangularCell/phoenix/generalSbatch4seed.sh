#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --mem=4GB
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

simName=$1 
paramFile=$2

module load matlab/2019a

mkdir -p output

echo "array_job_index: $SLURM_ARRAY_TASK_ID"

i=1 
found=0 
while IFS=, read a b c d seed
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then
        echo "Running $simName with [$a, $b, $c, $d] seed $seed"
        found=1 

        break 
    fi 
    i=$((i + 1)) 
done < $paramFile

if [ $found = 1 ]; then
	echo "matlab -nodisplay -nodesktop -r cd ../../../; addpath(genpath(pwd)); obj = $simName($a, $b, $c, $d, $seed); obj.RunSimulation(); quit()"
    matlab -nodisplay -nodesktop -r "cd ../../../; addpath(genpath(pwd)); obj = $simName($a, $b, $c, $d, $seed); obj.RunSimulation(); quit()"
else 
  echo "SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_ID is outside range of input file $paramFile" 
fi