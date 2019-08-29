
#!/bin/bash


# cd to the MouseColonDesc directory
cd /Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnMutation/MouseColonDesc/

#loop through all the folders

for d in */;
do
	
	cd $d/numerics_bt_100_dt_0.0005_t_6000/
	# If we successfully changed directory
	if [ $? -eq 0 ]; then
		echo Entered folder $d/numerics_bt_100_dt_0.0005_t_6000/
	    # rename the folders that somehow ended up with a control sequence in their name
		rename -v 's/run_([[:cntrl:]])/sprintf("run1_%i",ord($1))/e' run_*/

		# Transfer all of the files to the correct folder
		for i in 1 2 3 4 5 6 7 8 9 10; do mv "run1_$i/popup_location.txt" "run_$i/popup_location.txt"; done

		# Delete the empty folders
		rm -r -f run1_*
	else
	    echo Folder does not exist $d/numerics_bt_100_dt_0.0005_t_6000/
	fi
	cd /Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnMutation/MouseColonDesc/
done


	