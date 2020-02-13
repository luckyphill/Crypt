function generateBasinPlots(crypt)

	cryptName = getCryptName(crypt);
	objectiveFunction = str2func(cryptName);

	nM = 0.8:0.1:1.2;
	npM = 0.8:0.1:1.2;
	eesM = 0.8:0.1:1.2;
	msM = 0.8:0.1:1.2;
	cctM = 0.8:0.1:1.2;
	wtM = 0.8:0.1:1.2;
	vfM = 0.8:0.1:1.2;    
	
	for a=nM
		for b=nM
			for c=nM
				for d=nM
					for e=nM
						for I = 1:6
							for J = (I+1):7
								% There will always be 5 fixed parameters and 2 free parameters
								% Insert the free parameters inside the fixed ones.
								A = {a,b,c,d,e};
								A = {A{1:(I-1)},nM,A{I:end}};
								A = {A{1:(J-1)},nM,A{J:end}};

								basin = basinAnalysisGrid(crypt, A);
								
								if nnz(basin.griD) < 25
									basin.savePlot();
								end

							end
						end
					end
				end
			end
		end
	end


end


