pg = [10,15,20,25,30];

wl = 5:20;
bl = 0:10;

fid = fopen('BeamMembraneSweep.txt','w');

for p = pg
for w = wl
for b = bl
fprintf(fid,'%d, %d, %d, %d\n', p, p, w, b);
end
end
end

fclose(fid);
