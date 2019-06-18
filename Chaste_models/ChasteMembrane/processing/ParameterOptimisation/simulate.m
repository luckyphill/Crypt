
% Run a specific instance
function simulate(obj, time, n, np, ees, ms, vf, cct, wt)


	fprintf('Simulation for %s with parameters n = %g, np = %g, ees = %g, ms = %g, vf = %g, cct = %g, wt = %g\n', func2str(obj), n, np, ees, ms, vf, cct, wt);

	p.input_flags  = {'n','np','ees','ms','vf','cct','wt'};
	p.input_values = [n, np, ees, ms, vf, cct, wt];
 
	p.static_flags = {'t'};
	p.static_params= [time];

	p.run_flag = 'run';
	p.run_number = 1;

	p.chaste_test = 'TestCryptColumn';

	p.obj = obj;

	p.ignore_existing = false;

	p.base_path = [getenv('HOME'), '/'];

	penalty = run_simulation(p)

end