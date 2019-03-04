FILE=$1
echo "$FILE"

for ID in $(seq 1 1 100)
do
	i=1 
	found=0 
	while IFS=, read n ees ms vf
	do 
	    if [ $i = $ID ]; then 
	        echo "pop up rate: -n ${n} -ees ${ees} -ms ${ms} -cct 5 -vf ${vf}"
	        found=1 
	        break 
	    fi 
	    i=$((i + 1)) 
	done < $FILE 
done
