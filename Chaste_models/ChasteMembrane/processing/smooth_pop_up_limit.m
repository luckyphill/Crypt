function smooth_pop_up_limit(ees, ms, cct, vf)
% Load the pop up limit file, get the limit, simulate either side several times to smooth

ms_range = 5;
ms = (ms_guess - ms_range):1:(ms_guess + ms_range);

n_runs = 10;

ms = ms_regression(cct, vf);
[ms_calculated, ~] = read_data(cct, vf);

figure
plot(ms);
hold on
plot(floor(ms_calculated))
% Need to do 10(?) runs for each point with a different seed value
% Need to count the number that experience a pop up event
% Store the fraction of simulations that pop up for each point
% Plot this as a surface


end

function ms = ms_regression(cct, vf)
    % Takes the data from file, runs a regression to smooth, then returns the predicted ms values
    [ms_limit, ees] = read_data(cct, vf);

    % Only take the linear looking part - by estimate this is after the first 3 entries
    I = 4:length(ees);
    X = [ones(length(ees(I)),1) ees(I)];
    b = X\ms_limit(I);

    ms = ms_limit;
    ms(I) = b(1) + b(2) * ees(I);

end

function [ms_limit, ees] = read_data(cct, vf)

    file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste/PopUpLimit/limit_n_20_VF_%g_CCT_%d.txt', 100 * vf, cct);
    data = csvread(file);
    ees = data(:,1);
    ms_limit = data(:,2);


end