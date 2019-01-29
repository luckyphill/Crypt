for CCT in $(seq 2 2 8)
  do
  	for VF in $(seq 0.6 0.05 0.9)
  	do
  		echo "sbatch pop_up_limit.sh ${CCT} ${VF}" ;
  		sbatch pop_up_limit.sh ${CCT} ${VF}
  	done
done