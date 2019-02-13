% This script randomly samples the parameter space and creates a list of parameters
% for input into a sbatch array


n = 20:1:40;
ees = 1:1:1000;
ms = 0:1:1000;
vf = 0.6:0.01:0.95;


cct = 5;

file = '../random_search.txt';
fid = fopen(file,'w');

for i = 1:1000

    j = randi(length(n));
    k = randi(length(ees));
    l = randi([k, length(ms)]); % Always choose ms larger than ees
    m = randi(length(vf));

    fprintf(fid,'%d,%d,%d,%g\n',n(j), ees(k), ms(l), vf(m));

end

fclose(fid);
