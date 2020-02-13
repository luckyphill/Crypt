function penalty = processBasin(crypt)

	cryptName = getCryptName(crypt);
	objectiveFunction = str2func(cryptName);

	nM = 0.8:0.1:1.2;
	npM = 0.8:0.1:1.2;
	eesM = 0.8:0.1:1.2;
	msM = 0.8:0.1:1.2;
	cctM = 0.8:0.1:1.2;
	wtM = 0.8:0.1:1.2;
	vfM = 0.8:0.1:1.2;

	penalty = nan(5,5,5,5,5,5,5);

	for i = 1:5
		for j = 1:5
			for k = 1:5
				for l = 1:5
					for m = 1:5
						for n = 1:5
							for o = 1:5
								try
									basin = basinObjective(objectiveFunction, crypt, nM(i), npM(j), eesM(k), msM(l), cctM(m), wtM(n), vfM(o), 'varargin');
									penalty(i,j,k,l,m,n,o) = basin.getPenalty('varargin');
								end
							end
						end
					end
				end
			end
		end
    end
    
    
    
    for a=1:5
        for b=1:5
            for c=1:5
                for d=1:5
                    for e=1:5  
                        for I = 1:6
                            for J = (I+1):7
                                A = {a,b,c,d,e};
                                A = {A{1:(I-1)},1:5,A{I:end}};
                                A = {A{1:(J-1)},1:5,A{J:end}};

                                space = squeeze(penalty(A{1},A{2},A{3},A{4},A{5},A{6},A{7}));
                                if nnz(a) < 25
                                    makePSpacePlot(space, A);
                                end
                            end
                        end
                    end
                end
            end
        end
    end


end


