for RUN in $(seq 1 1 100)
do
	echo "Contact Inhibition" ;
	/Users/phillipbrown/chaste_build/projects/ChasteMembrane/test/TestCrypt1DUniform -ees 20 -vf 0.6 -t 1000 -run ${RUN}

done