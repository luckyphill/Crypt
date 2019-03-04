% This script determines the popup limit from a previous simulation and
% uses the resulting values to create a parameter space region for
% a full sweep to determine the average pop up rate
% It uses previous data to help narrow down the search space and give
% hopefull some useful limits

n = [25,26,27];
ees = 35:5:85;
cct = 5;
vf = 0.71:0.01:0.77;

N = length(n);
E = length(ees);
V = length(vf);

ms_limit = nan(E,V,N);

cct = 5;

file_number = 1;
file = '../../phoenix/PopUpRate/pop_up_rate_1.txt';
fid = fopen(file,'w');
counter = 0;
steps = 2;

for i = 1:N
	for k = 1:V
		for j = 1:E
		

			ms = steps * floor(pop_up_limit(ees(j), n(i), cct, vf(k), 39, 9, 7)/steps);
			fprintf('Done n = %d, ees = %d, vf = %g gives ms = %d\n', n(i), ees(j), vf(k), ms);
			ms_range = (ms-50):steps:(ms+50);
			for l = 0:4
				for m = 1:length(ms_range)
				
					fprintf(fid,'%d,%d,%d,%g\n',n(i), ees(j) + l, ms_range(m), vf(k));
					counter = counter + 1;
					if counter == 6000
						% Close file and open a new one
						fclose(fid);
						file_number = file_number + 1;
						file = ['../../phoenix/PopUpRate/pop_up_rate_' num2str(file_number) '.txt'];
						fid = fopen(file,'w');
						counter = 0;
					end
				end
			end

		end
	end
end


fclose(fid);



