function run_crypt(stiffness, vol_frac, t_end)

% Takes a number of variables and runs a simulation based on them
% This will save them to file, then play the animation
% The main pupose of this funcion is for inspecting specific simulations

p.ci = true;

p.ci_type = 3;

p.t_end = t_end;

p.dt = 0.001;

p.k = stiffness;

p.l = 1;

p.ci_fraction = vol_frac/100;

p.n = 20;

p.cut_out_height = 15; 

p.top = 20;

p.write = true;

p.limit = p.top * 5;

p.division_spring_length = 0.05;

p.division_separation = 0.05; % The separation after it initially divides

p.output_file = sprintf('simulation/EES_%d_VF_%d_T_%d', stiffness, vol_frac, t_end)


p = crypt_1D(p);
% If this fails, p does not get assigned

%p.t
% read in the saved file and run the animation
plot_trajectories(p.output_file)
figure()
plot_from_file(p);




end