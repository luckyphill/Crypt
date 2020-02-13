function makePSpacePlot(a, A)
    % Takes a 5x5 slice of parameter space and plots it with the correct
    % axes and stuff
    ticklabel_x = {0.8, 0.9, 1.0, 1.1, 1.2};
    ticklabel_y = {0.8, 0.9, 1.0, 1.1, 1.2};

    
    % Plot the figure and set axis labels etc.
    h = figure();
%     set(gcf,'Visible', 'off');
    imagesc(a,'AlphaData',~isnan(a), [0,10])
    colormap parula
    set(gca, 'XTick', linspace(0.5, 5.5, 5))
    set(gca, 'XTickLabel', ticklabel_x)
    set(gca, 'YTick', linspace(0.5, 5.5, 5))
    set(gca, 'YTickLabel', ticklabel_y)
    xlabel('$np$','Interpreter','latex','FontSize',20)
    ylabel('$ees$','Interpreter','latex','FontSize',20)
    colorbar;
end