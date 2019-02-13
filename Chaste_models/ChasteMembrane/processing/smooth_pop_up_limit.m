% function out = smooth_pop_up_limit(cct, vf)
    % Load the pop up limit file, get the limit, simulate either side several times to smooth

    ms = ms_regression(cct, vf);
    [~, ees] = read_data(cct, vf);

    out = nan (100, 400);

    for i = 1:length(ees)
        ms_range = (ms(i) - 20):4:(ms(i) + 20);
        ms_pos = ms_range(ms_range>0); % Only take the values that are greater than zero

        for j = 1:length(ms_pos)
            result = run_simulation(ees(i), ms_pos(j), cct, vf);
            out(uint8(ees(i)),uint8(ms_pos(j))) = result;
            if result == 1
                break;
            end
        end
    end


% end


function result = run_simulation(ees, ms ,cct, vf)
    % Runs 10 simulations for each point
    n = 10;
    fprintf('Phoenix bomb for EES = %g, MS = %g, CCT = %g, VF = %g\n',ees, ms ,cct, vf);
    
    result = 0;
    
    for i = 1:n
%         file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste/PopUpLimit/pop_up_n_20_EES_%g_MS_%g_VF_%g_CCT_%d_run_%d.txt', ees, ms, 100 * vf, cct, i);
        file = sprintf('/Users/phillip/Research/Crypt/Data/Chaste/PopUpLimit/pop_up_n_20_EES_%g_MS_%g_VF_%g_CCT_%d_run_%d.txt', ees, ms, 100 * vf, cct, i);
        try
            result = result + read_data_file(file);
            fprintf('Found existing data: EES = %g, MS = %g, VF = %g, CCT = %d Run %d\n', ees, ms, vf, cct, i);
        catch
            fprintf('Running simulation: EES = %g, MS = %g, VF = %g, CCT = %d Run %d\n', ees, ms, vf, cct, i);
%             [status,cmdout] = system(['/Users/phillipbrown/chaste_build/projects/ChasteMembrane/test/TestPopUpLimit -cct ' num2str(cct) ' -ees ' num2str(ees) ' -ms ' num2str(ms) ' -vf ' num2str(vf) ' -run ' num2str(i)]);
            [status,cmdout] = system(['/Users/phillip/chaste_build/projects/ChasteMembrane/test/TestPopUpLimit -cct ' num2str(cct) ' -ees ' num2str(ees) ' -ms ' num2str(ms) ' -vf ' num2str(vf) ' -run ' num2str(i)]);
            result = result + read_data_file(file);
        end
    end

    result = result / n;

end

function result = read_data_file(file)
    
    fid = fopen(file);
    txt = textscan(fid,'%s','delimiter','\n');

    if strcmp(txt{1}, 'PASSED')
        result = true;
    elseif strcmp(txt{1}, 'FAILED')
        result = false;
    else
        error('Something failed')
    end
    
    fclose(fid);
            
end

function ms = ms_regression(cct, vf)
    % Takes the data from file, runs a regression to smooth, then returns the predicted ms values
    [ms_limit, ees] = read_data(cct, vf);

    % Only take the linear looking part - by estimate this is after the first 3 entries
    I = 4:length(ees);
    X = [ones(length(ees(I)),1) ees(I)];
    b = X\ms_limit(I);

    ms = floor(ms_limit);
    ms(I) = floor(b(1) + b(2) * ees(I));

end

function [ms_limit, ees] = read_data(cct, vf)

%     file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste/PopUpLimit/limit_n_20_VF_%g_CCT_%d.txt', 100 * vf, cct);
    file = sprintf('/Users/phillip/Research/Crypt/Data/Chaste/PopUpLimit/limit_n_20_VF_%g_CCT_%d.txt', 100 * vf, cct);
    data = csvread(file);
    ees = data(:,1);
    ms_limit = data(:,2);


end