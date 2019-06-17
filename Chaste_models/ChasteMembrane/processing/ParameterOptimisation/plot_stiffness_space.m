function plot_stiffness_space(ees, ms, p)

% expects ees and ms to be vectors of the stiffness space where values are known
% p is the standard parameter structure used in all the scripts


for i = 1:length(ees)
	for j = 1:length(ms)
		% This is not great practise because it assumes the position of ees and ms in the
		% vectors, but within the scope of the work here, I should be able to get away with it
		fprintf('Getting results at ees=%d, ms=%d\n',ees(i),ms(j));
		p.input_values(3) = ees(i);
		p.input_values(4) = ms(j);

		penalty(i,j) = run_simulation(p);
	end
end



imagesc(ms, ees, penalty);
colorbar




end