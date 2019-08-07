Mnp = 9:18;
eesM = 0.8:0.1:2;
msM = 0.3:0.1:1.2;
cctM = 0.5:0.1:1.2;
wtM = 0.5:0.1:1.2;
Mvf = [0.5:.05:0.65, 0.675, 0.7:0.1:1];

cct = 15;
wt = 9;

fid = fopen('detail_mutations.txt', 'w');

for a = Mnp
    fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f\n',a,1,1,1,1,0.675);
end
for b = eesM
    fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f\n',12,b,1,1,1,0.675);
end
for c = msM
    fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f\n',12,1,c,1,1,0.675);
end
for d = cctM
    if cct*d > wt + 1
        fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f\n',12,1,1,d,1,0.675);
    end
end
for e = wtM
    fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f\n',12,1,1,1,e,0.675);
end
for d = cctM
    fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f\n',12,1,1,d,d,0.675);
end

for f = Mvf
	fprintf(fid,'%d, %1.1f, %1.1f, %1.1f, %1.1f, %1.3f\n',12,1,1,1,1,f);
end
    


                        