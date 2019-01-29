function plot_cell_velocity(ees, ms, cct, vf)

    file = sprintf('/tmp/phillipbrown/testoutput/TestCryptBasicWnt/n_20_EES_%g_VF_%g_MS_%g_CCT_%g/results_from_time_0/cell_force.dat',ees, vf, ms, cct);

    data = csvread(file);
    
    times = data(:,1);
    dt = times(2);
    nt = length(times);
    pos_data = data(:,2:end);
    max_cell_ID = max(pos_data(:));
    
    y_pos = nan(length(times), max_cell_ID);
    
    for i = 1:nt
       % At each time step, read all the IDs and y positions
       % Put these into y_pos using the ID as the index
       entries = length(pos_data(i,:));
       IDs = pos_data(i, 1:5:entries);
       nz = find(IDs, 1, 'last');
       positions = pos_data(i, 3:5:entries);
       % Start from 2 here because the first cell ID is always 0 and matlab
       % doesn't like 0 indices. Luckily this cell is the fixed cell that
       % doesn't divide
       y_pos(i,IDs(2:nz)) = positions(2:nz);
        
    end

    y_vel = nan(size(y_pos));
    for i = 2:nt
        y_vel(i, :) = (y_pos(i, :) - y_pos(i-1, :))/dt; % could be vectorised, but matlab will handle this
    end
    
    velocity_profile = [0; 0];
    [m,n] = size(y_vel);
    
    
    for i = ceil(nt/2):nt
        ind = ~isnan(y_vel(i,:));
        
        pos = y_pos(i,ind);
        vel = y_vel(i,ind);
             
        velocity_profile = cat(2, velocity_profile, cat(1,pos,vel));
        
    end
    max(velocity_profile(2,:))
    scatter(velocity_profile(1,:), velocity_profile(2,:));
        
        
        
end