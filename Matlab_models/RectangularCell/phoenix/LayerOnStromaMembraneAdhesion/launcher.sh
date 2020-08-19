sbatch --array=0-10000 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaMembraneAdhesion_1.txt 
sbatch --array=0-10000 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaMembraneAdhesion_2.txt 
sbatch --array=0-200 --time=24:00:00 ../generalSbatch7seed.sh RunLayerOnStroma LayerOnStromaMembraneAdhesion_3.txt 