% This script uses the pattern search optimisation algorithm to find the
% point in parameter space that gives the best column crypt behaviour.
% See https://en.wikipedia.org/wiki/Pattern_search_(optimization)
%
% Briefly, in a multidimensional problem, the algorithm takes steps along
% one axis until the objective function fails to improve. When it fails, it
% halves the step size in that coordinate, then moves to the next axis and
% repeats the process. This continues until the objective function reaches
% it target.

close all;
clear all;

input_vars = [10, 100, 0.7]; % ees, ms, vf
step_sizes = [5, 5, 0.05];
index = 1; % tracking the index of the variable we are optimising

cct = 4;

target_value = 100 * 15/ (10 + cct); % an estimate of the number of cells that would be produced in a healthy crypt

% Run the first guess to get the ball rolling
first_step = true;
direction = +1; % +1 means increase, -1 means decrease

fprintf('Simulating initial point\n');
obj = run_simulation(input_vars, cct);
fprintf('Done\n');
fprintf('Objective = %d, with params: EES = %g, MS = %g, VF = %g,\n', obj,input_vars(1),input_vars(2),input_vars(3));

iterations = 0;

fprintf('Starting loop\n');
% Start the optimisation procedure
while obj < target_value && iterations < 20
    % choose an axis, choose a direction, take steps until no improvement
    % if no improvement, halve the step size, try a new axis
    temp_vars = input_vars;
    
    temp_vars(index) = input_vars(index) + direction * step_sizes(index);
    
    % enforce ranges
    if index==1 && temp_vars(index) < 1; temp_vars(index) = 1; end
    if index==2 && temp_vars(index) < 0; temp_vars(index) = 0; end
    if index==3 && temp_vars(index) < 0; temp_vars(index) = 0; end
    if index==3 && temp_vars(index) > 1; temp_vars(index) = 1; end
    
    fprintf('Simulating\n');
    new_obj = run_simulation(temp_vars, cct);
    fprintf('Done\n');
    
    if first_step
        % Run again, but this time stepping in the oposite direction
        temp_vars = input_vars;
    
        temp_vars(index) = input_vars(index) - step_sizes(index);
        
        if ( index==1 && temp_vars(index) < 1 ); temp_vars(index) = 1; end
        if ( index==2 && temp_vars(index) < 0 ); temp_vars(index) = 0; end
        if ( index==3 && temp_vars(index) < 0 ); temp_vars(index) = 0; end
        if ( index==3 && temp_vars(index) > 1 ); temp_vars(index) = 1; end
        
        fprintf('Simulating opposite direction\n');
        new_obj_2 = run_simulation(temp_vars, cct);
        fprintf('Done\n');
        
        if new_obj_2 > new_obj
            fprintf('Opposite direction better, stepping that direction\n');
            new_obj = new_obj_2;
            direction = -1;
        end
        first_step = false;

    end
    
    % if the result is better...
    if new_obj > obj
        fprintf('Step produced improvement\n');
        obj = new_obj;
        input_vars(index) = input_vars(index) + direction * step_sizes(index);
    else
        % if it is not better, halve the step size, move to the next
        % axis, reset the stepping direction and reset the first step tracker
        step_sizes(index) = step_sizes(index)/2;
        if (index == 3); index = 1; else; index = index + 1; end
        fprintf('Step was worse, moving to variable %d\n', index);
        first_step = true;
        direction = +1;
    end
    fprintf('Objective = %d, with params: EES = %g, MS = %g, VF = %g,\n', obj,input_vars(1),input_vars(2),input_vars(3));
    iterations = iterations + 1;
        
end

function out = objective(slough, anoikis, total)
    % A way to determine if the new position is better
    out = (slough - anoikis);
end

function [slough, anoikis, total] = get_data(cmdout)
    % Extracts the slough, anoikis and total cell numbers from the output
    % of the simulation
    temp = strsplit(cmdout, 'DEBUG');
    
    temp_slough = temp{end-2};
    temp_anoikis = temp{end-1};
    temp_total = temp{end};
    
    temp_slough2 = strsplit(temp_slough, '=');
    temp_anoikis2 = strsplit(temp_anoikis, '=');
    temp_total2 = strsplit(temp_total, '=');
    temp_total3 = strsplit(temp_total2{2}, '\n');
    
    [slough, a] = str2num(strip(temp_slough2{2}));
    [anoikis, b] = str2num(strip(temp_anoikis2{2}));
    [total,c] = str2num(strip(temp_total3{1}));
    
    if (~a || ~b || ~c)
        error('Something went wrong with the simulation')
    end
    

end

function obj_val = run_simulation(vars, cct)
    % First checks data folder to see if the specific simulation has run before
    % If so, grabs the data from there, rather than run the simulation again

    file_name = sprintf('/Users/phillip/Research/Crypt/Data/Chaste/CellKillCount/kill_count_n_20_EES_%g_MS_%g_VF_%g_CCT_%d.txt', vars(1), vars(2), 100 * vars(3), cct);
    try
        data = csvread(file_name,1,0);
        total = data(1);
        slough = data(2);
        anoikis = data(3);
        fprintf('Found existing data: EES = %g, MS = %g, VF = %g, CCT = %d\n', vars(1), vars(2), vars(3), cct);
    catch
        fprintf('Running simulation for: EES = %g, MS = %g, VF = %g, CCT = %d\n', vars(1), vars(2), vars(3), cct);
        [status,cmdout] = system(['/Users/phillip/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -cct ' num2str(cct) ' -ees ' num2str(vars(1)) ' -ms ' num2str(vars(2)) ' -vf ' num2str(vars(3))]);
        [slough, anoikis, total] = get_data(cmdout);
    end

    obj_val = objective(slough, anoikis, total);

end