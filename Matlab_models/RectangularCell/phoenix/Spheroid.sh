#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=72:00:00
#SBATCH --array=0-20
#SBATCH --mem=1GB 
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load arch/haswell
module load matlab/2019a

matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); t = Spheroid(10, 20, 10, 5, $SLURM_ARRAY_TASK_ID);t.RunToTime(200); quit()"
