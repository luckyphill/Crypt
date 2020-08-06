sbatch --array=0-10000 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaPhaseTest_1.txt 
sbatch --array=0-10000 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaPhaseTest_2.txt 
sbatch --array=0-5500 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaPhaseTest_3.txt 