Mnp = 9:18;
eesM = 0.8:0.1:2;
msM = 0.3:0.1:1.2;
cctM = 0.5:0.1:1.2;
wtM = 0.5:0.1:1.2;
Mvf = [0.5:.05:0.65, 0.675, 0.7:0.1:1];

cct = 15;
wt = 9;

fid = fopen('detail_mutations.txt', 'w');

runs = 10;


for a = Mnp
	for i = 1:runs
    	fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',a,1,1,1,1,0.675,i);
    end
end
for b = eesM
	for i = 1:runs
    	fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',12,b,1,1,1,0.675,i);
    end
end
for c = msM
	for i = 1:runs
    	fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',12,1,c,1,1,0.675,i);
    end
end
for d = cctM
    if cct*d > wt + 1
    	for i = 1:runs
        	fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',12,1,1,d,1,0.675,i);
        end
    end
end
for e = wtM
	for i = 1:runs
    	fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',12,1,1,1,e,0.675,i);
    end
end
for d = cctM
	for i = 1:runs
    	fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',12,1,1,d,d,0.675,i);
    end
end

for f = Mvf
	for i = 1:runs
		fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f, %d\n',12,1,1,1,1,f,i);
	end
end
    


                        