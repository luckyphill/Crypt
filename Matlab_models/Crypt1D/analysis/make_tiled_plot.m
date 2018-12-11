close all;
clear all;

stiffness = 4:4:40;

m = length(stiffness);

vol_frac = 10:10:100;

n = length(vol_frac);

wait_time = 0;

h = figure('pos',[962   165   960   892]);

nbins = 10;


for i = 1:m
    for j = 1:n
    
        str = sprintf('CI_sweep/power_run_%d_%d.mat',stiffness(i),vol_frac(j));
        str2 = sprintf('CI_sweep/power_run_li_%d_%d.csv',stiffness(i),vol_frac(j));
        try
            load(str);
            subplot(m,n, (i-1)*n + j);
            histogram(all_li,nbins,'Normalization','probability');
            xlim([0, 16])
            ylim([0, 0.4])
            set(gca,'YTick',[]);
            set(gca,'XTick',[]);
            if j == 1
                ylabel(sprintf('%d',stiffness(i)));
            end

            if i == m
                xlabel(sprintf('%.2f',vol_frac(j)/100));
            end
        catch
            try
                all_li = csvread(str2);
                [mm,nn]=size(all_li);
                if mm>nn, num = nn; else, num = mm; end;

                
                subplot(m,n, (i-1)*n + j);
                if num > 5
                    histogram(all_li(all_li>0),nbins,'Normalization','probability');
                end
                xlim([0, 16])
                ylim([0, 0.4])
                set(gca,'YTick',[]);
                set(gca,'XTick',[]);
                if j == 1
                    ylabel(sprintf('%d',stiffness(i)));
                end

                if i == m
                    xlabel(sprintf('%.2f',vol_frac(j)/100));
                end
                disp(str);
                
            end
        end
    end
end

h.PaperSize = [40,30];
print('-dpdf')
 