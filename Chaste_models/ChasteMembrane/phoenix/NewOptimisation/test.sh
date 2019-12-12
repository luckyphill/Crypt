i=0
SLURM_ARRAY_TASK_ID=997
found=0
while IFS=, read n np ees ms cct wt vf r
do
    if [ $i = $((SLURM_ARRAY_TASK_ID+1001)) ]; then 
        echo "LHS sweep with: -n ${n} -np ${np} -ees ${ees} -ms ${ms} -cct ${cct} -wt ${wt} -vf ${vf}"
        found=1 
        break 
    fi 
    i=$((i + 1)) 
done < HumanColon.txt