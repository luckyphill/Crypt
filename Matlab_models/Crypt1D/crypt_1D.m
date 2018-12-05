function p = crypt_1D(p)

    % A script that solves the 1D column of proliferating cells model
    % The positions of the cells are stored in the vector p.x

    % Only one time step is stored in memory, the previous time steps are
    % continuously written to file

    % Cells are killed above a certain limit - p.top

    
    if ~isfield(p,'seed'), rng('shuffle'); else, rng(p.seed); end
    
    if ~isfield(p,'n'), p.n = 20;end % the initial number of cells
    if ~isfield(p,'top'), p.top = 20;end % The position of the top of the wall
    if ~isfield(p,'limit'), p.limit = p.top * 5 ;end % limit the number of cells to catch exponential growth
    
    if ~isfield(p,'cut_out_height'), p.cut_out_height = 15; end % the height where proliferation stops
    
    
    if ~isfield(p,'t_start'), p.t_start = 0; end % starting time
    if ~isfield(p,'t_end'), p.t_end = 300; end
    if ~isfield(p,'dt'), p.dt = 0.01; end
    
    if ~isfield(p,'k'), p.k = 20; end % The spring constant
    if ~isfield(p,'l'), p.l = 1; end % The natural spring length of the connection between two mature cells
    if ~isfield(p,'x'), p.x = 0:p.l:(p.n-1)*p.l; end % intial positions
    
    p.rest_lengths = p.l * ones(1,p.n-1); % Tracks the individual spring rest lengths so that cell division can be managed
    
    if ~isfield(p,'ci')
        p.ci = true;
        p.ci_fraction = 0.88; % the compression on the cell that induces contact inhibition as a fraction of the free volume
        p.ci_type = 1; % type 1 is restart cycle, type 2 is wait set time, type 3 is divide as soon as compression gone
        p.ci_pause_time = 4; % time to wait in type 2
    else
        if ~isfield(p,'ci_fraction')
            p.ci_fraction = 0.88;
            warning('ci_fraction not set, using default of 0.88')
        end
    end
    
    p.fid = false; % file ID for writing cell positions to file
    if ~isfield(p,'write'), p.write = false; end % Set write to false if not specified

    p.n_dead = 0; % number of cells that have died
    p.Nt = p.n; % count over time of the number of live cells

    p.cell_IDs = 1:p.n; % initial cell IDs
    p.next_ID = p.n + 1; % store the next ID to assign

    
    p.v = zeros(size(p.x)); % initial velocities for plotting only

    p.ages = 10 * rand(1,p.n); % randomly assign ages at the start
    p.divide_age = get_a_divide_age(p.n); % randomly assign an age when division occurs
    p.divide_age(1) = p.t_end + 14; % a quick hack to stop bottom cell dividing

    if ~isfield(p,'division_separation'), p.division_separation = 0.3; end;
    if ~isfield(p,'division_rest_length'), p.division_rest_length = 0.5; end; % after a cell divides, the new cells will be this far apart
    p.growth_time = 1.0; % time it takes for newly divided cells to grow to normal disatance apart
    
    p.labelling_index = []; %stores the location of a cell division
    p.labelling_position = []; %stores the position in the vector of a cell division

    p.damping = 1.0; % The damping constant

    assert(p.top>=p.cut_out_height);

    
    p.t = p.t_start;
    if p.write
        assert(isfield(p,'output_file'));
        cell_pos_file = strcat(p.output_file, '.txt');
        p.fid = fopen(cell_pos_file,'w');
    end

    while p.t < p.t_end && p.n < p.limit

        % Next time step, and age the cells
        p.t = p.t + p.dt;
        p.ages = p.ages + p.dt;
   
        p = grow(p);
        p = move(p);
        p = divide(p);
        p = slough(p);

        if p.write
            write_cells(p);
        end

        p.Nt = [p.Nt p.n];


    end
    
    if p.write
        fclose(p.fid);
        save(p.output_file,'p');
    end

end

