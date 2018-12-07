#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=06:00:00 
#SBATCH --mem=4GB 
#SBATCH --array=2001-4000
#SBATCH --err="output/LI_S_5_%a.err" 
#SBATCH --output="output/LI_S_5_%a.out" 
#SBATCH --job-name="LI_S_5_experiment"
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load CMake
module unload OpenMPI

echo "array_job_index: $SLURM_ARRAY_TASK_ID"

echo "Labelling Index Experiment"
echo "/home/a1738927/fastdir/chaste_build/projects/CellBasedComparison2017/test/TestPhaseLabellingIndex -run " $SLURM_ARRAY_TASK_ID "-S" 5
/home/a1738927/fastdir/chaste_build/projects/CellBasedComparison2017/test/TestPhaseLabellingIndex -run $SLURM_ARRAY_TASK_ID -S 5 -t 800
