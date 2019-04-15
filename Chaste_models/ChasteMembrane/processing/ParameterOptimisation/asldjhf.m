input_flags= {'n','np','ees','ms','cct','vf','run'};
input_values = [26,12,50,200,15,0.7,4];
fixed_parameters = ' -t 400';

run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);

input_values = [26,12,50,200,15,0.7,11];

run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);

input_values = [26,12,50,200,15,0.7,101];

run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);