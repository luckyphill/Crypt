function find_pop_up_limit(cct, vf)

    % This script uses the Chaste program TestPopUpLimit to determine the
    % limiting adhesion force that completely prevents cells popping up.
    % The simulations are stochastic, so the limit found may not be the
    % precise limit, but it should give a decent approximation.
    % Due to this, the limit for detecting convergence will be fairly slack


    % Use a bracketing root finding method

    ees = 5:5:100;

    ms_limit = nan(size(ees));

    % cct = 2;
    % vf = 0.7;

    % Just to get things started
    ms_upper_power = 5;
    ms_lower_power = -inf;

    for i = 1:length(ees)
        
        ms_lower = 2 ^ ms_lower_power;
        ms_upper = 2 ^ ms_upper_power;
        
        result_lower = run_simulation(cct, ees(i), ms_lower, vf);
        result_upper = run_simulation(cct, ees(i), ms_upper, vf);
        
        
        % The lower bound must fail, so make sure it's low enough
        while (result_lower)
            fprintf('Decreased lower, trying again\n');
            ms_lower = ms_lower/2;
            result_lower = run_simulation(cct, ees(i), ms_lower, vf);
        end
        
        % The upper bound must pass, so make sure it's high enough
        while (~result_upper)
            fprintf('Increased upper, trying again\n');
            ms_upper = 2 * ms_upper;
            ms_lower = ms_upper / 2; % If ms_upper fails, use it as the lower
            result_upper = run_simulation(cct, ees(i), ms_upper, vf);
        end
        
        
        fprintf('Starting with upper of %g and lower of %g\n', ms_upper, ms_lower);
        % Set a fairly wide tolerance
        tol = 1;
        difference = ms_upper - ms_lower;
        ms_trial = difference/2 + ms_lower;
        it_limit = 10;
        it = 1;
        
        while (tol < difference && it < it_limit)
            result_trial = run_simulation(cct, ees(i), ms_trial, vf);
            
            if result_trial
                ms_upper = ms_trial;
                fprintf('Set %g as new upper\n', ms_trial);
            else
                ms_lower = ms_trial;
                fprintf('Set %g as new lower\n', ms_trial);
            end
            
            difference = ms_upper - ms_lower;
            assert(difference > 0);
            ms_trial = difference/2 + ms_lower;
            it = it + 1;
        end
        
        ms_upper_power = ceil(log2(ms_upper));
        ms_lower_power = floor(log2(ms_lower));
        
        ms_limit(i) = ms_upper;
        fprintf('Logged the limit for EES = %g as %g\n', ees(i), ms_upper);
        
    end

    % Output result to file
    write_to_file(ees, ms_limit, cct, vf);
end

function result = run_simulation(cct, ees, ms, vf)
    
    % The simulation outputs PASSED or FAILED to a file named by the
    % parameter set used. First check if it already exists, if not, run the
    % actual simulation to generate it.
    
    file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste/PopUpLimit/pop_up_n_20_EES_%g_MS_%g_VF_%g_CCT_%d.txt', ees, ms, 100 * vf, cct);
%     file = sprintf('/Users/phillip/Research/Crypt/Data/Chaste/PopUpLimit/pop_up_n_20_EES_%g_MS_%g_VF_%g_CCT_%d.txt', ees, ms, 100 * vf, cct);
    try
        result = read_data(file);
        fprintf('Found existing data: EES = %g, MS = %g, VF = %g, CCT = %d\n', ees, ms, vf, cct);
    catch
        fprintf('Running simulation: EES = %g, MS = %g, VF = %g, CCT = %d\n', ees, ms, vf, cct);
    	[status,cmdout] = system(['/Users/phillipbrown/chaste_build/projects/ChasteMembrane/test/TestPopUpLimit -cct ' num2str(cct) ' -ees ' num2str(ees) ' -ms ' num2str(ms) ' -vf ' num2str(vf)]);
%         [status,cmdout] = system(['/Users/phillip/chaste_build/projects/ChasteMembrane/test/TestPopUpLimit -cct ' num2str(cct) ' -ees ' num2str(ees) ' -ms ' num2str(ms) ' -vf ' num2str(vf)]);
        result = read_data(file);
    end

end

function result = read_data(file)
    
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

function write_to_file(ees, ms_limit, cct, vf)
    % Writes the results to file

    file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste/PopUpLimit/limit_n_20_VF_%g_CCT_%d.txt', 100 * vf, cct);
%     file = sprintf('/Users/phillip/Research/Crypt/Data/Chaste/PopUpLimit/limit_n_20_VF_%g_CCT_%d.txt', 100 * vf, cct);
    csvwrite(file, [ees' ms_limit']);
    
    h = figure;
    l = plot(ees, ms_limit);
    ylim([0 400]);
    
    l.LineWidth = 4;
    
    ylabel('Adhesion stiffness limit','Interpreter','latex');
    xlabel('Epithelial stiffness','Interpreter','latex');
    title(['Adhesion force to stop cells popping up with G1 length = ' num2str(cct) ', CI fraction = ' num2str(100 * vf) '\%' ],'Interpreter','latex');

    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    
    print(['/Users/phillipbrown/Research/Crypt/Images/Chaste/PopUpLimit/PopUpLimit_VF_' num2str(100 * vf), '_CCT_' num2str(cct) ''],'-dpdf');
%     print(['/Users/phillip/Research/Crypt/Images/Chaste/PopUpLimit/PopUpLimit_VF_' num2str(100 * vf), '_CCT_' num2str(cct) ''],'-dpdf');


end

