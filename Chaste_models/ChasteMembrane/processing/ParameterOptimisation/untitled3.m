
input_flags = {'n','np','ees','ms','cct','vf','run'};
input_values = [26;14;100;328;15;0.8;1];

for i = 1:10
    input_values(end) = i;
    penalties(i) = run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, false);
end