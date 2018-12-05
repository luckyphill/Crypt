#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00 
#SBATCH --mem=4GB 
#SBATCH --array=0-400
#SBATCH --err="output/ci_sweep_%a.err" 
#SBATCH --output="output/ci_sweep_%a.out" 
#SBATCH --job-name="ci_sweep"
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module unload OpenMPI
mkdir -p output 

echo "array_job_index: $SLURM_ARRAY_TASK_ID" 
i=1 
found=0 
while IFS=, read s vf
do 
    if [ $i = $SLURM_ARRAY_TASK_ID ]; then 
        echo "ci_server_sweep($s,$vf)"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < sweep.txt 
if [ $found = 1 ]; then 
	for RUN in $(seq 1 1 100)
	do
  		echo "Contact Inhibition" ;
  		echo "/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCrypt1DUniform -ees" ${s} "-vf" ${vf} "-run " ${RUN};
		/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCrypt1DUniform -ees ${s} -vf ${vf} -run ${RUN} -t 100

  	done
else 
  echo "sweep.txt does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
fi