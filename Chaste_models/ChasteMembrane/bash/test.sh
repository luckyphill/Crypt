# i=1 
# found=0 
# while IFS=, read s vf w
# do 
#     if [ $i = 200 ]; then 
#         echo "ci_server_sweep($s,$f,$w,1000)"
#         found=1 
#         break 
#     fi 
#     i=$((i + 1)) 
# done < sweep.txt 
# if [ $found = 1 ]; then 

	for RUN in $(seq 1 1 100)
	do
  		echo "Contact Inhibition" ;
  		echo "/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestCrypt1DUniform -ees 28 -vf 0.9 -run " ${RUN};
		/Users/phillipbrown/chaste_build/projects/ChasteMembrane/test/TestCrypt1DUniform -ees 28 -vf 0.9 -run ${RUN} -t 1000

  	done
# else 
#   echo "sweep.txt does not have enough parameters for $SLURM_ARRAY_TASK_ID index" 
# fi