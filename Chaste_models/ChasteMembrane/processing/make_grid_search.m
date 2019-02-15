% This script takes a coarse grid over the parameter space and creates a list of parameters
% for input into a sbatch array


n = 24:28;
ees = 25:5:100;
ms = 150:5:250;
vf = 0.68:0.01:0.82;


cct = 5;

file_number = 1;
file = '../grid_search_1.txt';
fid = fopen(file,'w');
counter = 0;

for j = 1:length(n)
	for k = 1:length(ees)
		for l = 1:length(ms)
			for m = 1:length(vf)
				fprintf(fid,'%d,%d,%d,%g\n',n(j), ees(k), ms(l), vf(m));
				counter = counter + 1;
				if counter == 10000
					% Close file and open a new one
					fclose(fid);
					file_number = file_number + 1;
					file = ['../grid_search_' num2str(file_number) '.txt'];
					fid = fopen(file,'w');
					counter = 0;
				end
			end
		end
	end
end


fclose(fid);
