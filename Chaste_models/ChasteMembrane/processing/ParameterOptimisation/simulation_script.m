input_flags= {'n','np','ees','ms','cct','vf','run'};
input_values = [26,12,50,200,15,0.7,1];
fixed_parameters = ' -sm 1 -t 2';

run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);