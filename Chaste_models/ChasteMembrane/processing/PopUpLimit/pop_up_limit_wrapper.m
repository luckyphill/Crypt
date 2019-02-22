% This script hard codes the parameter sets where I will search for the pop up limit
% It uses the function pop_up_limit.m to find the pop up limit
% This function in turn runs TestPopUpLimit in Chaste
% The result of each parameter set will be a limiting value of ms that stops popping up
% The condition for 'no pop up' is 95% of 100 hour simulations will not experience popping up
% after the first 30 hours

n = [25,26,27];
ees = 35:5:85;
cct = 5;
vf = 0.71:0.01:0.77;

N = length(n);
E = length(ees);
V = length(vf);

% ms_limit = nan(E,V,N);

% for i = 1:N
% 	for j = 1:E
% 		for k = 1:V

% 			ms_limit(j,k,i) = pop_up_limit(ees(j), n(i), cct, vf(k), 39, 9, 7);

% 		end
% 	end
% end

close all;

for i = 1:N
	h = figure;
	plot(ees,ms_limit(:,:,i),'linewidth', 3);
	leg = [];
	for j = 1:V
		leg = [leg; sprintf('vf = %g', vf(j))];
	end
	legend(leg)
	title(sprintf('Plot of pop up limit for n = %d', n(i)));
	xlabel('Epithelial stiffness');
	ylabel('Membrane adhesion stiffness')
	ylim([200,360]);

	set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    
    print(['/Users/phillipbrown/Research/Crypt/Images/PopUpLimit/PopUpLimit_VFvaries_N_' num2str(n(i)) '_CCT_' num2str(cct)],'-dpdf');

end

data = permute(ms_limit, [1,3,2]);
for i = 1:V
	h = figure;
	plot(ees,data(:,:,i),'linewidth', 3);
	leg = [];
	for j = 1:N
		leg = [leg; sprintf('n = %g', n(j))];
	end
	legend(leg)
	title(sprintf('Plot of pop up limit for vf = %g', vf(i)));
	xlabel('Epithelial stiffness');
	ylabel('Membrane adhesion stiffness')
	ylim([200,360]);

	set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    
    print(['/Users/phillipbrown/Research/Crypt/Images/PopUpLimit/PopUpLimit_Nvaries_VF_' num2str(100 * vf(i)) '_CCT_' num2str(cct)],'-dpdf');

end