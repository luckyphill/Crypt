%% Test that the ouput from force and move matches what Chaste gives
format short
p.x = [0, 0.5, 0.9, 1.6, 2.0, 2.7, 3.2];

% This is what we should get from the given inputs to match Chaste
out_force = [0, -4.46287, 11.19231, -11.19231, 11.19231, -6.72944, 13.86294];
out_pos = [0, 0.455371, 1.01192, 1.48808, 2.11192, 2.63271, 3.33863];

p.ages = ones(length(p.x));
p.n = length(p.x);
p.n_dead = 0;
p.dt = 0.01;
p.damping = 1;
p.k = 20;
p.l = 1;
p.growth_time = 1;
p.cut_out_height = 15;
p.top = 20;

output = force(p.x,p);
p = move(p);

tol = 1e-5;
assert( prod( abs( out_force - output)< tol) == 1);
assert( prod( abs( out_pos - p.x     )< tol) == 1);


%% Test that division works the same

p.x = [0, 0.5, 0.9, 1.6, 2.0, 2.7, 3.2];
p.divide_age = [2,2,2,0,2,2,2];
p.t = 0;
p.ci = false;
p.cell_IDs = [1,2,3,4,5,6,7];
p.next_ID = 8;
p.division_spring_length = 0.01;
p.labelling_index = [];
p = divide(p);
output = force(p.x,p)
p = move(p);
p.x

