data = csvread('phoenix/BasinSweep/modifiers.txt');

missing = [];

for i = 1:length(data)
	nM = data(i,1);
	npM = data(i,2);
	eesM = data(i,3);
	msM = data(i,4);
	cctM = data(i,5);
	wtM = data(i,6);
	vfM = data(i,7);
	
	try
		basinObjective(@MouseColonCaecum, 2, nM, npM, eesM, msM, cctM, wtM, vfM, 'varargin');
	catch
		missing(end+1, :) = data(i,:);
	end
	
end

csvwrite('phoenix/BasinSweep/missingAsc.txt', missing);

		