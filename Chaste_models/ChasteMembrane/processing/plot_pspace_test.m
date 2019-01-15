% plots a parameter space sweep to see what parameter pair gives the 
% most appropriate combination of cell death by anoikis and by sloughing
% we expecct to get ~100 deaths by sloughing and ~5 deaths by anoikis (with cct of 12)
% the plot shows the difference between the two, which ideally should sit
% around 100 (different for other ccts)

close all;
clear all;

es = 20:59;
n = length(es);
ms = 1:100;
m = length(ms);

vf = 75;

pspace = nan(n,m);

for i = 1:n
    for j = 1:m
        file_name =[ '/Users/phillipbrown/Research/Crypt/Data/Chaste/CellKillCount/kill_count_n_20_EES_' num2str(es(i)) '_MS_' num2str(ms(j)) '_VF_' num2str(vf) '_CCT_8.txt'];
        try
            data = csvread(file_name,1,0);
            pspace(i,j) = data(2) - data(3);
        catch e
            e
        end
    end
end

h = figure();
imagesc(flipud(pspace),'AlphaData',~isnan(flipud(pspace)), [-120 120]);
set(gca, 'XTick', linspace(0, 100, 11))
set(gca, 'XTickLabel',  0:10:100)
set(gca, 'YTick', linspace(0, 40, 9))
set(gca, 'YTickLabel', fliplr(20:5:60))
ylabel('Epithelial stiffness','Interpreter','latex');
xlabel('Adhesion stiffness','Interpreter','latex');
title('Parameter space showing cell death cause difference','Interpreter','latex');
colorbar;

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(['/Users/phillipbrown/Research/Crypt/Images/CellKillCountVF' num2str(vf), '_CCT_8'],'-dpdf');