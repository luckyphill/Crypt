close all;
clear all;

stiffness = 3:4:40;

m = length(stiffness);

vol_frac = 10:10:100;

n = length(vol_frac);

wait_time = 0;

h = figure('pos',[962   165   960   892]);

nbins = 10;


for i = 1:m
    for j = 1:n
    
        str = sprintf('/Users/phillipbrown/Chaste/projects/ChasteMembrane/divisions/EES_%d_VF_%d.dat',stiffness(i),vol_frac(j));
        try
            all_li = csvread(str);

            subplot(m,n, (i-1)*n + j);

                histogram(all_li(all_li>0),nbins,'Normalization','probability');

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
            disp(str)
        end
        
    end
end

h.PaperSize = [40,30];
print('-dpdf')
 