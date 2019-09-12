
% Cut out the 1 because we don't want to run it mutliptle times
eesM = [0.9,0.92,0.94,0.96,0.98,1.02:0.02:2.1];
msM = [0.6:0.02:0.98, 1.02,1.04,1.06,1.08,1.1];

Mvf = [0.5:0.01:0.75];

cctwtM = [0.5:0.02:0.98, 1.02,1.04,1.06,1.08,1.1];

cctM = [0.68:0.02:0.98, 1.02,1.04,1.06,1.08,1.1];

wtM = [0.5:0.02:0.98, 1.02,1.04,1.06,1.08,1.1];

fid = fopen('clonal_sweep_1.txt', 'w');

runs = 50;

for i = 1:runs
    fprintf(fid,'%d, %1.2f, %1.2f, %1.2f, %1.2f, %1.3f, %d\n',12,1,1,1,1,0.675,i);
end

for b = eesM
	for i = 1:runs
    	fprintf(fid,'%d, %1.2f, %1.2f, %1.2f, %1.2f, %1.3f, %d\n',12,b,1,1,1,0.675,i);
    end
end

for c = msM
	for i = 1:runs
    	fprintf(fid,'%d, %1.2f, %1.2f, %1.2f, %1.2f, %1.3f, %d\n',12,1,c,1,1,0.675,i);
    end
end
for d = cctM

    for i = 1:runs
        fprintf(fid,'%d, %1.2f, %1.2f, %1.2f, %1.2f, %1.3f, %d\n',12,1,1,d,1,0.675,i);
    end

end
for e = wtM
	for i = 1:runs
    	fprintf(fid,'%d, %1.2f, %1.2f, %1.2f, %1.2f, %1.3f, %d\n',12,1,1,1,e,0.675,i);
    end
end
for d = cctwtM
	for i = 1:runs
    	fprintf(fid,'%d, %1.2f, %1.2f, %1.2f, %1.2f, %1.3f, %d\n',12,1,1,d,d,0.675,i);
    end
end

for f = Mvf
	for i = 1:runs
		fprintf(fid,'%d, %1.2f, %1.2f, %1.2f, %1.2f, %1.3f, %d\n',12,1,1,1,1,f,i);
	end
end