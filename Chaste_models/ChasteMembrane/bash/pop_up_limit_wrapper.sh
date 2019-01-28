for CCT in $(seq 2 2 8)
  do
  	for VF in $(seq 0.65 0.05 0.85)
  	do
  		echo "sh pop_up_limit.sh ${CCT} ${VF}" ;
  		sbatch pop_up_limit.sh ${CCT} ${VF}
  	done
done