close all;
clear all;

simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});

params = dlmread('../phoenix/MutationFirst/detail_mutations.txt');
params2 = params(1:10:end,:);

for i = 1:length(params2)
	Mnp = params2(i,1);
	eesM = params2(i,2);
	msM = params2(i,3);
	cctM = params2(i,4);
	wtM = params2(i,5);
	Mvf = params2(i,6);

	max_run = nan(10,1);
	min_run = nan(10,1);
	mean_run = nan(10,1);

	for j = 1:10
		fprintf('Mutation %d, %f, %f, %f, %f, %f run %d\n',Mnp,eesM,msM,cctM,wtM,Mvf,j);
		run_number = j;
		mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {1,Mnp,eesM,msM,cctM,wtM,Mvf});
		
		% load each simulation, get the averages, collate over parameter range
		h = heightAnalysis(simParams,mutantParams,4000,0.0005,100,1000,run_number);
		try
            h.heightOverTime();

			if length(h.h_crypt_max_t) > 6000
				max_run(j) = h.mean_h_max;
				min_run(j) = h.mean_h_min;
				mean_run(j) = h.mean_h_mean;
			end


			r_max(i) = nanmean(max_run);
			r_min(i) = nanmean(min_run);
			r_mean(i) = nanmean(mean_run);
		end
	end
end

plot_pics(1,1:10,r_max,r_mean,r_min,params2,'Prolif')
plot_pics(2,11:23,r_max,r_mean,r_min,params2,'Cell stiff')
plot_pics(3,24:33,r_max,r_mean,r_min,params2,'membrane stiff')
plot_pics(4,34:39,r_max,r_mean,r_min,params2,'cycle length')
plot_pics(5,40:47,r_max,r_mean,r_min,params2,'growth')
plot_pics(6,48:55,r_max,r_mean,r_min,params2,'cycle and growth')
plot_pics(7,56:64,r_max,r_mean,r_min,params2,'contact inhibition')


    
function plot_pics(col,ran,r_max,r_mean,r_min,params2,name)
    

    g = figure;
    plot(params2(ran,col),r_max(ran), params2(ran,col),r_min(ran), params2(ran,col),r_mean(ran),'LineWidth' , 4)
    title(name)
    set(g,'Units','Inches');
    pos = get(g,'Position');
    set(g,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(name,'-dpdf');

end