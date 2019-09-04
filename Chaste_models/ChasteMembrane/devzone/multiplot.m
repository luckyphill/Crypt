function multiplot(keys, values)
    h = figure(1);
    ha = axes;
    hold on
    leg = {};
    for val = values
        figure(1);
        hold on
        [counts, edges, hours, pops] = viewPopUpIndex({keys}, {val}, 10);
        if pops > 1000
            plot(ha,edges(2:end),counts./hours, 'LineWidth',3);
            leg{end+1} = num2str(val);
        end
    end
    legend(ha,leg);
    title(['Popup index for different strength mutations:', keys]);
    ylim([0 0.05]);
    set(h,'Units','Inches');
	pos = get(h,'Position');
	set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    
    imageFile = [getenv('HOME'), '/Research/Crypt/Images/PopUpIndex/popup_index'];
    imageFile = [imageFile, sprintf('_%s', keys)];
    print(imageFile,'-dpdf');
end
