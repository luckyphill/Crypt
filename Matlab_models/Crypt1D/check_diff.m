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
    
        str_chaste = sprintf('/Users/phillipbrown/Chaste/projects/ChasteMembrane/CI_test_data/EES_%d_VF_%d.dat',stiffness(i),vol_frac(j));
        str = sprintf('CI_sweep/power_run_%d_%d_%d.mat',stiffness(i),vol_frac(j),wait_time);
        str2 = sprintf('CI_sweep/power_run_li_%d_%d_%d.csv',stiffness(i),vol_frac(j),wait_time);
        
        prop_chaste = 0;
        prop_mat = 0;
        try
            all_li = csvread(str_chaste);
            prop_chaste = histcounts(all_li(all_li>0),nbins,'Normalization','probability');

        end
        
        try
            load(str);
            prop_mat = histcounts(all_li,nbins,'Normalization','probability');
            
        catch
            try
                all_li = csvread(str2);
                [mm,nn]=size(all_li);
                if mm>nn, num = nn; else, num = mm; end;
                if num > 5
                    prop_mat = histcounts(all_li(all_li>0),nbins,'Normalization','probability');
                end
            end
        end
        
        subplot(m,n, (i-1)*n + j);

        prop = prop_chaste - prop_mat;
        if length(prop_chaste) > 1 && length(prop_mat) > 1
            plot(prop);
        end

        
        xlim([0, 10])
        ylim([-0.2, 0.2])
        %set(gca,'YTick',[]);
        set(gca,'XTick',[]);
        
        if j == 1
            ylabel(sprintf('%d',stiffness(i)));
        end

        if i == m
            xlabel(sprintf('%.2f',vol_frac(j)/100));
        end
        
    end
end

% h.PaperSize = [40,30];
% print('-dpdf')
 