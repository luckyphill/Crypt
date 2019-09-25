function viewFftAvgPosition(key, value, runs, pos)


	mutantParams = containers.Map({'Mnp','eesM','msM','cctM','wtM','Mvf'}, {12,1,1,1,1,0.675});
	mutantParams(key) = value;

	f = fftPosition(1, mutantParams,6000,100,1000,2);
	f.fftAnalysis();
	[min_m,min_n] = size(f.fftData);
	sumFft = f.fftData;
	sumMagFft = f.fftMagData;

	for i = 2:runs
		f = fftPosition(1, mutantParams,6000,100,1000,i);

		[m,n] = size(f.fftData);
		if m < min_m ; min_m = m; end
		if n < min_n ; min_n = n; end

		sumFft = sumFft(1:min_m, 1:min_n);

		sumFft = sumFft + f.fftData(1:min_m, 1:min_n);

		sumMagFft = sumMagFft(1:(min_m/2 +1), 1:min_n);

		sumMagFft = sumMagFft + f.fftMagData(1:(min_m/2 +1), 1:min_n);
	end

	sumFft = sumFft/runs;

	sumMagFft = sumMagFft/runs;

	figure()
    freq = f.freq(1:length(sumMagFft));
	plot(freq, sumMagFft(:,pos));


end
