

p.input_flags= {'n','np','ees','ms','vf','cct','wt'};

p.static_flags = {'t'};
p.static_params= [400];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.repetitions = 5;

p.step_size = [1,1,1,1,0.02,1,1];



p.obj = @HumanColon;
p.input_values = [60, 56, 50, 150, 0.8, 26, 7.5];
move_plots(p);



p.obj = @MouseColonAsc;
p.input_values = [19, 8, 50, 200, 0.85, 19,  8];
move_plots(p);

p.obj = @MouseColonTrans;
p.input_values = [37, 12, 100, 200, 0.9, 21, 11];
move_plots(p);

p.obj = @MouseColonDesc;
p.input_values = [29, 12, 58, 216, 0.675, 15, 9];
move_plots(p);

p.obj = @MouseColonCaecum;
p.input_values = [24, 8, 100, 200, 0.6125, 15.5, 7.5];
move_plots(p);



p.obj = @RatColonAsc;
p.input_values = [32, 16, 68, 200, 0.65, 39, 13];
move_plots(p);

p.obj = @RatColonTrans;
p.input_values = [36, 20, 50, 208, 0.6, 42, 9];
move_plots(p);

p.obj = @RatColonDesc;
p.input_values = [42, 28, 100, 134, 0.7, 57, 8];
move_plots(p);

p.obj = @RatColonCaecum;
p.input_values = [33, 12, 58, 392, 0.8, 25, 8];
move_plots(p);