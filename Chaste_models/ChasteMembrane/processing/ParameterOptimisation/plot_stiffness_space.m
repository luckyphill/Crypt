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

		penalty(i,j) = get_simulation_output(p);
	end
end


h = figure('visible', 'off');

imagesc(ms, ees, penalty, 'AlphaData',~isnan(penalty), [0, 20]);
set(gca,'YDir','normal')
colorbar

image_file = generate_image_file_name(p);

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

xlabel('Adhesion stiffness', 'Interpreter', 'latex');
ylabel('Epithelial stiffness', 'Interpreter', 'latex');


plot_title{1} = [func2str(p.obj), ' with'];
plot_title{2} = sprintf('n=%d, np= %d, vf=%g, cct=%g, wt=%g', p.input_values(1), p.input_values(2), p.input_values(5), p.input_values(6), p.input_values(7));
title(plot_title, 'Interpreter','latex','FontSize',14);

print(image_file,'-dpdf');


end