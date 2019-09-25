function multiplot(keys, values)
    h = figure();
    ha = axes;
    cla(ha)
    ylim([0 0.1]);
    hold on
    leg = {};
    for val = values
        figure(h);
        hold on
        [counts, edges, hours, pops] = viewPopUpIndex(keys, {val}, 10);
        if pops > 1000
            plot(ha,edges(2:end),counts./hours, 'LineWidth',3);
            leg{end+1} = num2str(val);
        end
    end
    legend(ha,leg);
    plot_title = 'Popup index for different strength mutations:';
    for i = 1:length(keys)
        plot_title = [plot_title, ' ', keys{i}];
    end
    title(plot_title);
    ylim([0 0.1]);
    set(h,'Units','Inches');
	pos = get(h,'Position');
	set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    
    imageFile = [getenv('HOME'), '/Research/Crypt/Images/PopUpIndex/popup_index'];
    for i = 1:length(keys)
        imageFile = [imageFile, sprintf('_%s', keys{i})];
    end
    print(imageFile,'-dpdf');
end
