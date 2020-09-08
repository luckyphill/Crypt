sbatch --array=0-10000 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaPhaseTest2_1.txt 
sbatch --array=0-10000 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaPhaseTest2_2.txt 
sbatch --array=0-1840 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaPhaseTest2_3.txt 