for CCT in $(seq 2 2 8)
  do
  	for VF in $(seq 0.6 0.05 0.9)
  	do
  		echo "sbatch smooth_pop_up.sh ${CCT} ${VF}" ;
  		sbatch smooth_pop_up.sh ${CCT} ${VF}
  	done
done