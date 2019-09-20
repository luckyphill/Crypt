function viewFftAvgPosition(key, value, runs)


	mutantParams = containers.Map({'Mnp','eesM','msM','cctM','wtM','Mvf'}, {12,1,1,1,1,0.675})
	mutantParams(key) = value;

	f = fftPosition(1, mutantParams,6000,100,1000,2);
	f.fftAnalysis();
	sumFft = f.fftData;

	for i = 2:runs
		f = fftPosition(1, mutantParams,6000,100,1000,i);
		f.fftAnalysis();
		sumFft = sumFft + f.fftData;
	end

	sumFft = sumFft/runs;

	r = ifft(sumFft);

	surf(r)

end
