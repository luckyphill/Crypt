
% Pulling together all the parts to make the plots



p.input_flags= {'n','np','ees','ms','vf','cct','wt'};

p.static_flags = {'t'};
p.static_params= [400];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonCaecum;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.repetitions = 5;

ees = 100;
ms = 200;

e = (ees-35):5:(ees+35);
m = (ms-35):5:(ms+35);


p.input_values = [24,8, ees, ms, 0.6125, 15.5, 7.5];

plot_loop(e, m, p);
% plot_stiffness_space(e, m, p);