cell.position = nan;
cell.age = nan;
cell.phase = 'G1';
cell.divide_age = nan;
cell.g1_length = nan;
cell.s_length = nan;
cell.g2_length = nan;
cell.m_length = nan;

p.n = 10;

p.cells(p.n) = cell;

for i = 1:p.n
   p.cells(i).position = i; 
   p.cells(i).age = 10*rand;
   p.cells(i).phase = get_phase(p.cells(i));
   p.cells(i).g1_length = 2 + 4*rand;
   p.cells(i).s_length = 6;
   p.cells(i).g2_length = 1;
   p.cells(i).m_length = 1;
   p.cells(i).ID = i;
   
end

p.n_dead = 0; % number of cells that have died
p.Nt = p.n; % count over time of the number of live cells

p.next_ID = 21; % store the next ID to assign

p.t_end = 100;
p.dt = 0.02;


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