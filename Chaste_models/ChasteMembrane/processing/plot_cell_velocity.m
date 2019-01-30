function v = plot_cell_velocity(ees, ms, cct, vf)

    file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste/CellVelocity/cell_positions_EES_%g_VF_%g_MS_%g_CCT_%g.txt',ees, 100 * vf, ms, cct);

    try
        % See if the data already exists
        data = csvread(file);
        if data(end,1) < 99
            error('Not enough existing data, need to run simulation\n');
        end
        fprintf('Found sufficient existing data for EES = %g, VF = %g, MS = %g, CCT = %g\n',ees, vf, ms, cct);
    catch
        % If not ...
        try
            % Perhaps it hasn't been moved yet ...
            data_file = sprintf('/tmp/phillipbrown/testoutput/TestCryptBasicWnt/n_20_EES_%g_VF_%g_MS_%g_CCT_%g/results_from_time_0/cell_force.txt',ees, vf, ms, cct);
            [status,cmdout] = system(['mv ' data_file ' ' file]);
            data = csvread(file);
            if data(end,1) < 99
                error('Not enough existing data, need to run simulation\n');
            end
        catch
            % If all else fails, run the simulation
            fprintf('Running simulation for EES = %g, VF = %g, MS = %g, CCT = %g\n',ees, vf, ms, cct);
            [status,cmdout] = system(['/Users/phillipbrown/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -sm 100 -cct ' num2str(cct) ' -ees ' num2str(ees) ' -ms ' num2str(ms) ' -vf ' num2str(vf)]);
            data_file = sprintf('/tmp/phillipbrown/testoutput/TestCryptBasicWnt/n_20_EES_%g_VF_%g_MS_%g_CCT_%g/results_from_time_0/cell_force.txt',ees, vf, ms, cct);
            [status,cmdout] = system(['mv ' data_file ' ' file]);
            data = csvread(file);
        end
    end
    
    v = velocity_by_height(data);
    
    [upper, average, lower] = get_quantiles(v);
    
    plot_velocity_data(upper, average, lower, ees, ms, cct, vf);
       
        
end

function v = velocity_by_height(data)
    % Clean the data and match cell velocity to its height (continuous variable)
    
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
    
    v = [0; 0];
    [m,n] = size(y_vel);
    
    
    % Construct a 2 x n array
    for i = ceil(nt/2):nt
        ind = ~isnan(y_vel(i,:));
        
        pos = y_pos(i,ind);
        vel = y_vel(i,ind);
             
        v = cat(2, v, cat(1,pos,vel));
        
    end
    
    
end

function v = velocity_by_position(data)
    % Clean the data and match cell velocity to postion (discrete)
    v = 1;
end

function [upper, average, lower] = get_quantiles(v)
    % This function takes the velocity data with a position (continuous or discrete)
    % and returns lines that represent the 75th, 50th and 25th quantiles
    
    q_u = 0.75;
    q_a = 0.50;
    q_l = 0.25;
    
    n_points = length(v);
    
    top = ceil(max(v(1,:)));
    
    edges = 0.5:1:(top + 0.5);
    
    n = length(edges);
    
    bins{n} = [];
    
    for i = 1:n_points
        for j = 1:n-1
            if v(1,i) > edges(j) && v(1,i) < edges(j+1)
                bins{j} = [bins{j},v(2,i)];
                break;
            end
        end
    end
    
    for i = 1:21
        output = quantile(bins{i}, [q_u, q_a, q_l]);
        upper(i) = output(1);
        average(i) = output(2);
        lower(i) = output(3);
    end

end

function plot_velocity_data(upper, average, lower, ees, ms, cct, vf)

    h = figure;
    hold on;
    plot(average, 'LineWidth', 4);
    plot(upper,'k:');
    plot(lower,'k:');
    
    ylim([-0.1 1]);
    
    ylabel('Cell velocity','Interpreter','latex');
    xlabel('Cell height','Interpreter','latex');
    title({['Cell velocity as a function of height from the crypt base'] ; ['G1 length = ' num2str(cct) ', CI fraction = ' num2str(100 * vf) '\%, Epithelial stiffness = ' num2str(ees) ', Adhesion Stiffness = ' num2str(ms)]},'Interpreter','latex');

    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    
    print(['/Users/phillipbrown/Research/Crypt/Images/Chaste/CellVelocity/Cell_Velocity_VF_' num2str(100 * vf), '_CCT_' num2str(cct) '_EES_' num2str(ees) '_MS_' num2str(ms)],'-dpdf');

end