# Runs a full basin sweep for MouseColonAsc and MouseColonCaecum

sbatch genericMissingBasinSweep.sh 2 1 missingAsc.txt
sbatch genericMissingBasinSweep.sh 2 10000 missingAsc.txt
sbatch genericMissingBasinSweep.sh 2 20000 missingAsc.txt
sbatch genericMissingBasinSweep.sh 2 30000 missingAsc.txt
sbatch genericMissingBasinSweep.sh 4 1 missingCaecum.txt
sbatch genericMissingBasinSweep.sh 4 10000 missingCaecum.txt
sbatch genericMissingBasinSweep.sh 4 20000 missingCaecum.txt
sbatch genericMissingBasinSweep.sh 4 30000 missingCaecum.txt