sbatch --array=0-10000 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaBvsSPE2_1.txt 
sbatch --array=0-10000 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaBvsSPE2_2.txt 
sbatch --array=0-10000 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaBvsSPE2_3.txt 
sbatch --array=0-5200 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaBvsSPE2_4.txt 