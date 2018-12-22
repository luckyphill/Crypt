% plots a parameter space sweep to see what parameter pair gives the 
% most appropriate combination of cell death by anoikis and by sloughing
% we expecct to get ~100 deaths by sloughing and ~5 deaths by anoikis
% the plot shows the difference between the two, which ideally should sit
% around 100

close all;
clear all;

es = 20:60;
n = length(es);
ms = 1:100;
m = length(ms);

pspace = zeros(n,m);

for i = 1:n
    for j = 1:m
        file_name =[ '/Users/phillip/Research/Crypt/Data/Chaste/CellKillCount/kill_count_n_20_EES_' num2str(es(i)) '_MS' num2str(ms(j)) '.txt'];
        try
            data = csvread(file_name,1,0);
            pspace(i,j) = data(2) - data(3);
        catch e
            e
        end
    end
end

imagesc(pspace);
