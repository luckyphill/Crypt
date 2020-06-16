#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --time=10:00:00
#SBATCH --mem=1GB 
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load matlab/2019a

matlab -nodisplay -nodesktop -r "cd ../../; addpath(genpath(pwd)); t = FreeCellTest(10,10,10);t.RunToTime(200); quit()"
