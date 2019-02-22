function plot_pop_up_limit(cct, vf)
    % Writes the results to file

    file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste/PopUpLimit/limit_n_20_VF_%g_CCT_%d.txt', 100 * vf, cct);
    data = csvread(file);
    ees = data(:,1);
    ms_limit = data(:,2);
    % Writes the results to file
   
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

end