% This script hard codes the parameter sets where I will search for the pop up limit
% It uses the function pop_up_limit.m to find the pop up limit
% This function in turn runs TestPopUpLimit in Chaste
% In order to speed up the results, this runs sbatch scripts to start the simulations on phoenix
% Each parameter set has it's own phoenix job, i.e. there is no job array

n = [25,26,27];
ees = 35:5:85;
cct = 5;
vf = 0.71:0.01:0.77;


for i = 1:length(n)
	for j = 1:length(ees)
		for k = 1:length(vf)

			% Run the sbatch script with arguments
			system(['sbatch ../bash/pop_up_limit_sbatch.sh ' num2str(ees(j)) ' ' num2str(n(i)) ' ' num2str(cct) ' ' num2str(vf(k))]);

		end
	end
end