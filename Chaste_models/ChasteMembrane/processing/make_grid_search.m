% This script takes a coarse grid over the parameter space and creates a list of parameters
% for input into a sbatch array


n = 20:2:36;
ees = 25:25:250;
ms = 50:50:800;
vf = 0.6:0.05:0.95;


cct = 5;

file = '../grid_search.txt';
fid = fopen(file,'w');

for j = 1:length(n)
	for k = 1:length(ees)
		for l = 1:length(ms)
			for m = 1:length(vf)
				if ees(k) < ms(l)
					fprintf(fid,'%d,%d,%d,%g\n',n(j), ees(k), ms(l), vf(m));
				end
			end
		end
	end
end


fclose(fid);
