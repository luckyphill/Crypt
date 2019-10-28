function make_params(np,vf,cct,wt,Mnp,Mvf,name)

	Mnp = (np-3):(np+4);
	eesM = 0.6:0.1:1.8;
	eesM(eesM==1) = [];
	msM = 0.4:0.1:1.3;
	msM(msM==1) = [];
	cctM = 0.5:0.1:1.2;
	cctM(cctM==1) = [];
	wtM = 0.5:0.1:1.2;
	wtM(wtM==1) = [];




	fid = fopen(name, 'w');

	runs = 10;


	for a = Mnp
		for i = 1:runs
			fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',a,1,1,1,1,vf,i);
		end
	end
	for b = eesM
		for i = 1:runs
			fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',np,b,1,1,1,vf,i);
		end
	end
	for c = msM
		for i = 1:runs
			fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',np,1,c,1,1,vf,i);
		end
	end
	for d = cctM
		if cct*d > wt + 1
			for i = 1:runs
				fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',np,1,1,d,1,vf,i);
			end
		end
	end
	for e = wtM
		for i = 1:runs
			fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',np,1,1,1,e,vf,i);
		end
	end
	for d = cctM
		for i = 1:runs
			fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',np,1,1,d,d,vf,i);
		end
	end

	for f = Mvf
		for i = 1:runs
			fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',np,1,1,1,1,f,i);
		end
	end
		
end
							