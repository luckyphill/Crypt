function ms_upper = pop_up_limit(ees, n, cct, vf, n_trials, ms_upper_power_guess, ms_lower_power_guess)

    % This script uses the Chaste program TestPopUpLimit to determine the
    % limiting adhesion force that completely prevents cells popping up.
    % The simulations are stochastic, so mulitple simulations are run for each
    % trial

    % A bracketing root finding method is used since this is essentially
    % finding the step in a step function

    % Just to get things started, set the initial guesses        
    ms_lower = 2 ^ ms_lower_power_guess;
    ms_upper = 2 ^ ms_upper_power_guess;
    

    result_lower = run_simulation(ms_lower, n, ees, cct, vf, n_trials);
    result_upper = run_simulation(ms_upper, n, ees, cct, vf, n_trials);
    
    
    % The lower bound must fail, so make sure it's low enough
    while (result_lower)
        fprintf('Decreased lower, trying again\n');
        ms_lower = ms_lower/2;
        result_lower = run_simulation(ms_lower, n, ees, cct, vf, n_trials);
    end
    
    % The upper bound must pass, so make sure it's high enough
    while (~result_upper)
        fprintf('Increased upper, trying again\n');
        ms_upper = 2 * ms_upper;
        ms_lower = ms_upper / 2; % If ms_upper fails, use it as the lower
        result_upper = run_simulation(ms_upper, n, ees, cct, vf, n_trials);
    end
    
    
    fprintf('Starting with upper of %g and lower of %g\n', ms_upper, ms_lower);
    
    % Set a fairly wide tolerance
    tol = 1;
    difference = ms_upper - ms_lower;
    ms_trial = difference/2 + ms_lower;
    it_limit = 10;
    it = 1;
    
    while (tol < difference && it < it_limit)
        result_trial = run_simulation(ms_trial, n, ees, cct, vf, n_trials);
        
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
        
end

function result = run_simulation(ms, n, ees, cct, vf, n_trials)
    
    % The simulation outputs PASSED or FAILED to a file named by the
    % parameter set used. First check if it already exists, if not, run the
    % actual simulation to generate it.

    % We want to run simulations until we are certain (beyond a given threshold) that 
    % the parameter set will result in no cells popping up OR we are certain that
    % the parameter set will NOT pass
    result = false;
    successes = 0;
    for trial = 1:n_trials
        file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste/PopUpLimit/pop_up_n_%d_EES_%g_MS_%g_VF_%g_CCT_%d_run_%d.txt', n, ees, ms, 100 * vf, cct, trial);
    %     file = sprintf('/Users/phillip/Research/Crypt/Data/Chaste/PopUpLimit/pop_up_n_20_EES_%g_MS_%g_VF_%g_CCT_%d.txt', ees, ms, 100 * vf, cct);
        try
            successes = successes + read_data(file);
            fprintf('Found existing data: n = %d, EES = %g, MS = %g, VF = %g, CCT = %d, run %d\n', n, ees, ms, vf, cct, trial);
        catch
            fprintf('Running simulation: n = %d, EES = %g, MS = %g, VF = %g, CCT = %d, run %d\n', n, ees, ms, vf, cct, trial);
        	[status,cmdout] = system(['/Users/phillipbrown/chaste_build/projects/ChasteMembrane/test/TestPopUpLimit -n ' num2str(n) ' -cct ' num2str(cct) ' -ees ' num2str(ees) ' -ms ' num2str(ms) ' -vf ' num2str(vf) ' -run ' num2str(trial)]);
    %         [status,cmdout] = system(['/Users/phillip/chaste_build/projects/ChasteMembrane/test/TestPopUpLimit -cct ' num2str(cct) ' -ees ' num2str(ees) ' -ms ' num2str(ms) ' -vf ' num2str(vf)]);
            successes = successes + read_data(file);
        end

        failures = trial - successes;

        % Here we use the Beta distribution to check if the bulk of the probability mass
        % is past a certain threshold

        % The probability mass that is below p = 0.95
        mass_95 = betacdf(0.95, successes + 1, failures + 1);

        if (trial > 3 && mass_95 > 0.98)
            % No chance of passing
            result = false;
            fprintf('After %d runs: %d successes and %d failures. More than 98%% sure that cell pop up in more than 5%% of simulations\n', trial, successes, failures)
            break;
        end

        if (mass_95 < 0.4)
            % We are 60% sure that the probility of no pop-ups is above 0.95
            result = true;
            fprintf('After %d runs: %d successes and %d failures. More than 60%% sure cells pop up in less than 5%% of simulations\n', trial, successes, failures)
            break;
        end

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

