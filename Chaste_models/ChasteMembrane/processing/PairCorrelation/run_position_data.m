

% run simulation
% find the file with the positions
% move it to the data store
% go through each time step and generate the pcf


function v = run_position_data(p)

    % The data file were are expecting
    file = generate_file_name(p);

    try
        % See if the data already exists
        data = csvread(file);
        if data(end,1) < 99
            error('Not enough existing data, need to run simulation\n');
        end
        fprintf('Found sufficient existing data for n = %d, EES = %g, VF = %g, MS = %g, CCT = %g\n', n, ees, vf, ms, cct);
    catch
        % If not ...
        try
            % Perhaps it hasn't been moved yet ...
            % Get the data from the temp folder and put it in the Data folder
            generate_temp_output_path(p);
            data_file = sprintf('/tmp/phillipbrown/testoutput/TestCryptDivisionBoundaryCondition/n_%d_EES_%g_VF_%g_MS_%g_CCT_%g_run_%d/results_from_time_0/cell_force.txt',n , ees, vf, ms, cct, run_number);
            [status,cmdout] = system(['mv ' data_file ' ' file]);
            data = csvread(file);
            if data(end,1) < 99
                fprintf('Not enough existing data, need to run simulation\n');
                error('Not enough existing data, need to run simulation\n');
            end
        catch
            % If all else fails, run the simulation
            input_string = generate_input_string(p);
            fprintf('Data does not exist. Simulating with input: %s\n', input_string);


            [status,cmdout] = system([simulation_command, input_string],'-echo');


            [status,cmdout] = system(['/Users/phillipbrown/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -sm 100 -n ' num2str(n) ' -cct ' num2str(cct) ' -ees ' num2str(ees) ' -ms ' num2str(ms) ' -vf ' num2str(vf), ' -run ' num2str(run_number)]);
            data_file = sprintf('/tmp/phillipbrown/testoutput/TestCryptDivisionBoundaryCondition/n_%d_EES_%g_VF_%g_MS_%g_CCT_%g_run_%d/results_from_time_0/cell_force.txt',n , ees, vf, ms, cct, run_number);
            [status,cmdout] = system(['mv ' data_file ' ' file]);
            data = csvread(file);
        end
    end
           
        
end

