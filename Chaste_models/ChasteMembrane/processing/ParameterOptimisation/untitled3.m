close all;
clear all;

input_flags = {'n','np','ees','ms','cct','vf','run'};
input_values = [26;14;100;328;15;0.8;1];

for i = 1:100
    input_values(end) = i;
    penalties(i) = run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, false);
    fprintf('\nRunning average: %.4f\n\n',mean(penalties));
end

hist(penalties);