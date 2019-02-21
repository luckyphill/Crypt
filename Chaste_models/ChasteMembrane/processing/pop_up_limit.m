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
    

    result_lower = run_simulation(ms_lower, n, ees, cct, vf, n_trials, 0, 0);
    result_upper = run_simulation(ms_upper, n, ees, cct, vf, n_trials, 0, 0);
    
    
    % The lower bound must fail, so make sure it's low enough
    while (result_lower)
        fprintf('Decreased lower, trying again\n');
        ms_lower = ms_lower/2;
        result_lower = run_simulation(ms_lower, n, ees, cct, vf, n_trials, 0, 0);
    end
    
    % The upper bound must pass, so make sure it's high enough
    while (~result_upper)
        fprintf('Increased upper, trying again\n');
        ms_upper = 2 * ms_upper;
        ms_lower = ms_upper / 2; % If ms_upper fails, use it as the lower
        result_upper = run_simulation(ms_upper, n, ees, cct, vf, n_trials, 0, 0);
    end
    
    
    fprintf('Starting with upper of %g and lower of %g\n', ms_upper, ms_lower);
    
    % Set a fairly wide tolerance
    tol = 1;
    difference = ms_upper - ms_lower;
    ms_trial = difference/2 + ms_lower;
    it_limit = 10;
    it = 1;
    
    while (tol < difference && it < it_limit)
        result_trial = run_simulation(ms_trial, n, ees, cct, vf, n_trials, 0, 0);
        
        if result_trial
            ms_upper = ms_trial;
            fprintf('Set %g as new upper\n', ms_trial);
        else
            ms_lower = ms_trial;
            prior_s_trial = 0;
            prior_f_trial = 0;
            fprintf('Set %g as new lower\n', ms_trial);
        end
        
        difference = ms_upper - ms_lower;
        assert(difference > 0);
        ms_trial = difference/2 + ms_lower;
        it = it + 1;
    end
        
end

function result = run_simulation(ms, n, ees, cct, vf, n_trials, prior_s, prior_f)
    
    % The simulation outputs PASSED or FAILED to a file named by the
    % parameter set used. First check if it already exists, if not, run the
    % actual simulation to generate it.

    % We want to run simulations until we are certain (beyond a given threshold) that 
    % the parameter set will result in no cells popping up OR we are certain that
    % the parameter set will NOT pass
    result = false;
    s = 0; % successes
    f = 0; % failures

    f_limit = 0;
    s_limit = n_trials;
    while(betacdf(0.95, s_limit + 1, f_limit + 1) < 0.4)
        f_limit = f_limit + 1;
        s_limit = s_limit - 1;
    end

    for trial = 1:n_trials
        file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste/PopUpLimit/pop_up_n_%d_EES_%g_MS_%g_VF_%g_CCT_%d_run_%d.txt', n, ees, ms, 100 * vf, cct, trial);
        % file = sprintf('/Users/phillip/Research/Crypt/Data/Chaste/PopUpLimit/pop_up_n_%d_EES_%g_MS_%g_VF_%g_CCT_%d_run_%d.txt', n, ees, ms, 100 * vf, cct, trial);
        % file = sprintf('/home/a1738927/fastdir/Chaste/data/PopUpLimit/pop_up_n_%d_EES_%g_MS_%g_VF_%g_CCT_%d_run_%d.txt', n, ees, ms, 100 * vf, cct, trial);
        try
            outcome =  read_data(file);
            fprintf('Found existing data: n = %d, EES = %g, MS = %g, VF = %g, CCT = %d, run %d\n', n, ees, ms, vf, cct, trial);
        catch
            fprintf('Running simulation: n = %d, EES = %g, MS = %g, VF = %g, CCT = %d, run %d\n', n, ees, ms, vf, cct, trial);
        	[status,cmdout] = system(['/Users/phillipbrown/chaste_build/projects/ChasteMembrane/test/TestPopUpLimit -n ' num2str(n) ' -cct ' num2str(cct) ' -ees ' num2str(ees) ' -ms ' num2str(ms) ' -vf ' num2str(vf) ' -run ' num2str(trial)]);
            % [status,cmdout] = system(['/Users/phillip/chaste_build/projects/ChasteMembrane/test/TestPopUpLimit -n ' num2str(n) ' -cct ' num2str(cct) ' -ees ' num2str(ees) ' -ms ' num2str(ms) ' -vf ' num2str(vf) ' -run ' num2str(trial)]);
            % [status,cmdout] = system(['/home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/test/TestPopUpLimit -n ' num2str(n) ' -cct ' num2str(cct) ' -ees ' num2str(ees) ' -ms ' num2str(ms) ' -vf ' num2str(vf) ' -run ' num2str(trial)]);
            outcome = read_data(file);
        end
        % outcome is boolean, true means no pop ups (i.e. a success)
        s = s + outcome;
        f = f + (1 - outcome);

        % Here we use the Beta distribution to check if the bulk of the probability mass
        % is past a certain threshold

        % The probability mass that is below p = 0.95
        mass_95 = betacdf(0.95, s + prior_s + 1, f + prior_f + 1);

        if (f >= f_limit)
            % No chance of passing
            result = false;
            fprintf('After %d runs: %d successes and %d failures. At least %.1f%% sure that cells pop up in more than 5%% of simulations\n', trial, s, f, 100 * mass_95);
            fprintf('Pasing not possible given the number of trials permitted (%d)\n', n_trials);
            break;
        else
            if (mass_95 < 0.4)
                % We are 60% sure that the probility of no pop-ups is above 0.95
                result = true;
                fprintf('After %d runs: %d successes and %d failures. At least %.1f%% sure cells pop up in less than 5%% of simulations\n', trial, s, f, 100 * (1 - mass_95));
                break;
            elseif trial == n_trials
                result = false;
                fprintf('After %d runs: %d successes and %d failures. %.1f%% sure cells pop up in more than 5%% of simulations\n', trial, s, f, 100 * mass_95);
                break;
            end
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
