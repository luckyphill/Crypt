function smooth_pop_up_phoenix_bomb
% Smooth pop-up phoenix bomb
% A matlab script that controls sbatch to dump a load of simulations on Phoenix


	vf = 0.65:0.05:0.9;
	cct = [2, 4, 6, 8];


	for i = 1:6
	    for j=1:4
	        bomb(cct(j), vf(i));
	    end
	end

end


function bomb(cct, vf)

	% This is where all the parameter sets get called

	ms = ms_regression(cct, vf);
	[~, ees] = read_data(cct, vf);

	for i = 1:length(ees)
		ms_range = (ms(i) - 20):4:(ms(i) + 20);
		ms_pos = ms_range(ms_range>0); % Only take the values that are greater than zero

		for j = 1:length(ms_pos)
			run_sbatch(ees(i), ms_pos(j), cct, vf);
		end
	end




end

function run_sbatch(ees, ms ,cct, vf)
	% Calls the sbatch file which creates 10 simulations for each point

	% [status,cmdout] = system(['sbatch /home/a1738927/fastdir/chaste_build/projects/ChasteMembrane/bash/smooth_pop_up.sh' num2str(ees) ' ' num2str(ms) ' ' num2str(cct) ' ' num2str(vf) ]);
	fprintf('Phoenix bomb for EES = %g, MS = %g, CCT = %g, VF = %g\n',ees, ms ,cct, vf);

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

    file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste/PopUpLimit/limit_n_20_VF_%g_CCT_%d.txt', 100 * vf, cct);
    data = csvread(file);
    ees = data(:,1);
    ms_limit = data(:,2);


end