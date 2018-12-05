for N in $(seq 1 1 10)
do
	for MS in 0.1 0.2 0.5
	do
		for EMS in 5 10 15 20
		do
			for EES in 5 10 15 20
			do
				for YF in $(seq 1 1 20)
				do

					echo "Driving force: YF" ${YF} ", MS" ${MS} ", EMS" ${EMS} ", EES" ${EES} ", N" ${N};
					#/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestMultipleCellDrivingForce -x .7 -y 1 -ms ${MS} -ems ${EMS} -ees ${EES} -mir 2 -eir 2 -mpr .25 -epr .75 -xf 0 -yf ${YF} -n ${N} -t 10 -wh 60
					python /Users/phillipbrown/Chaste/projects/ChasteMembrane/driving_force.py "n_"${N}"_MS_"${MS}"_EMS_"${EMS}"_MIR_2_MPR_0.25_EES_"${EES}"_EIR_2_EPR_0.75_YF_"${YF}
				done
			done
		done
	done
done
