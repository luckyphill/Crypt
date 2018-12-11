clear all
close all

% A script that solves the 1D layer of proliferating cells model
% The positions of the cells are stored in the vector p.x

% Only one time step is stored in memory, the previous time steps are
% continuously written to file

% When a new cell is added, the vector shifts its columns (rows?) across to
% accommodate the new cell.
% Cells are killed above a certain limit - p.cut_out_height
% When a cell is killed is no longer passed into the force calculation but
% it still takes space in the vector.
% In order to plot things correctly, the positions of new cells before they
% divide and the positions of old cells after they are killed are stored as
% nans.
% 

rng(04092018);

p.n = 20; % the initial number of cells
p.n_dead = 0; % number of cells that have died
p.Nt = p.n; % count over time of the number of live cells

p.cell_IDs = 1:20; % initial cell IDs
p.next_ID = 21; % store the next ID to assign

p.t_end = 100;
p.dt = 0.02;

p.x = 0:p.n-1; % intial positions
p.v = zeros(size(p.x)); % initial velocities for plotting only

p.ages = 10 * rand(1,p.n); % randomly assign ages at the start
p.divide_age = get_a_divide_age(p.n); % randomly assign an age when division occurs
p.divide_age(1) = p.t_end + 14; % a quick hack to stop bottom cell dividing

p.division_spring_length = 0.01; % after a cell divides, the new cells will be this far apart
p.growth_time = 1.0; % time it takes for newly divided cells to grow to normal disatance apart
p.cut_out_height = 15; % the height where proliferation stops
p.labelling_index = []; %stores the location of a cell division

p.ci = true;
p.ci_fraction = 0.88; % the compression on the cell that induces contact inhibition as a fraction of the free volume
p.ci_type = 1; % type 1 is restart cycle, type 2 is wait set time, type 3 is divide as soon as compression gone
p.ci_pause_time = 4; % time to wait in type 2

p.l = 1; % The natural spring length of the connection between two mature cells
p.k = 20; % The spring constant
p.damping = 1.0; % The damping constant
p.top = 20; % The position of the top of the wall

assert(p.top>=p.cut_out_height);

p.t_start = 0; % starting time

p.t = p.t_start;

p.fid = fopen('cells.txt','w');

while p.t < p.t_end
    
    % Next time step, and age the cells
    p.t = p.t + p.dt;
    p.ages = p.ages + p.dt;
       
    p = move(p);   
    p = divide(p);
    p = slough(p);
    write_cells(p);
    
    p.Nt = [p.Nt p.n];
    
    
end
fclose(p.fid);

%plot_cells(p)
hist(p.labelling_index,p.cut_out_height)
figure()
plot(p.Nt)
