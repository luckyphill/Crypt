

% run simulation
% find the file with the positions
% move it to the data store
% go through each time step and generate the pcf


function data = run_position_data(p)

    % The data file were are expecting
    file = generate_file_name(p);
    data_path = generate_temp_output_path(p);
    data_file = [data_path, 'cell_positions.dat'];
    input_string = generate_input_string(p);
    simulation_command = [p.base_path, 'chaste_build/projects/ChasteMembrane/test/', p.chaste_test];

    data = nan;
    try
        % See if the data already exists
        data = csvread(file);
        if data(end,1) < 99
            error('Not enough existing data, need to run simulation\n');
        end
        fprintf('Found sufficient existing data for simulation %s\n', input_string);
    catch
        % If not ...
        try
            % Perhaps it hasn't been moved yet ...
            % Get the data from the temp folder and put it in the Data folder
            
            [status,cmdout] = system(['mv ' data_file ' ' file]);
            data = csvread(file);
            if data(end,1) < 99
                fprintf('Not enough existing data, need to run simulation\n');
                error('Not enough existing data, need to run simulation\n');
            end
        catch
            % If all else fails, run the simulation
            
            fprintf('Data does not exist. Simulating with input: %s\n', input_string);
            [status,cmdout] = system([simulation_command, input_string],'-echo');
            [status,cmdout] = system(['mv ' data_file ' ' file]);
            data = csvread(file);
        end
    end
           
        
end

