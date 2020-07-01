#!/bin/bash 
#SBATCH -p batch 
#SBATCH -N 1 
#SBATCH -n 1 
#SBATCH --mem=4GB
#SBATCH --time=72:00:00
# NOTIFICATIONS
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phillip.j.brown@adelaide.edu.au

module load matlab/2019a

echo "matlab -nodisplay -nodesktop -r cd ../../../; addpath(genpath(pwd)); b = CritcalWiggleRatioBeamMembrane; b.PlotData; quit()"
matlab -nodisplay -nodesktop -r "cd ../../../; addpath(genpath(pwd)); b = CritcalWiggleRatioBeamMembrane; b.PlotData; quit()"