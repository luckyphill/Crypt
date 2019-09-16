Mnp = 9:18;
eesM = 0.8:0.1:2;
msM = 0.3:0.1:1.2;
cctM = 0.5:0.1:1.2;
wtM = 0.5:0.1:1.2;
Mvf = [0.5:.05:0.65, 0.675, 0.7:0.1:1];

cct = 15;
wt = 9;


runs = 10;
firstbit = '/Users/phillipbrown/testoutput/TestCryptColumnFullMutation/MouseColonDesc/';
secondbit = '/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnFullMutation/MouseColonDesc/'

files = {'results.vizboundarynodes','results.vizcelltypes', 'results.viznodes', 'results.vizsetup','popup_location.txt'};

for a = Mnp
	for i = 1:runs
    	% look in the chaste test output folder, if files are there, move them to the data base
    	old = sprintf('%sMnp_%d_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/run_%d/results_from_time_100/',firstbit,a,1,1,1,1,0.675,i);
    	new = sprintf('%smutant_Mnp_%d_Mvf_%g_cctM_%g_eesM_%g_msM_%g_wtM_%g/numerics_bt_100_t_6000/run_%d/',secondbit,a,0.675,1,1,1,1,i);
        mkdir(new);
        for j=1:length(files)
    		system(['cp ', [old,files{j}], ' ',  [new,files{j}]],'-echo');
    	end
    end
end
for b = eesM
	for i = 1:runs
    	old = sprintf('%sMnp_%d_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/run_%d/results_from_time_100/',firstbit,12,b,1,1,1,0.675,i);
    	new = sprintf('%smutant_Mnp_%d_Mvf_%g_cctM_%g_eesM_%g_msM_%g_wtM_%g/numerics_bt_100_t_6000/run_%d/',secondbit,12,0.675,1,b,1,1,i);
    	mkdir(new);
        for j=1:length(files)
    		system(['cp ', [old,files{j}], ' ',  [new,files{j}]],'-echo');
    	end
    end
end
for c = msM
	for i = 1:runs
    	old = sprintf('%sMnp_%d_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/run_%d/results_from_time_100/',firstbit,12,1,c,1,1,0.675,i);
    	new = sprintf('%smutant_Mnp_%d_Mvf_%g_cctM_%g_eesM_%g_msM_%g_wtM_%g/numerics_bt_100_t_6000/run_%d/',secondbit,12,0.675,1,1,c,1,i);
    	mkdir(new);
        for j=1:length(files)
    		system(['cp ', [old,files{j}], ' ',  [new,files{j}]],'-echo');
    	end
    end
end
for d = cctM
    if cct*d > wt + 1
    	for i = 1:runs
        	old = sprintf('%sMnp_%d_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/run_%d/results_from_time_100/',firstbit,12,1,1,d,1,0.675,i);
        	new = sprintf('%smutant_Mnp_%d_Mvf_%g_cctM_%g_eesM_%g_msM_%g_wtM_%g/numerics_bt_100_t_6000/run_%d/',secondbit,12,0.675,d,1,1,1,i);
        	mkdir(new);
            for j=1:length(files)
    		system(['cp ', [old,files{j}], ' ',  [new,files{j}]],'-echo');
    	end
        end
    end
end
for e = wtM
	for i = 1:runs
    	old = sprintf('%sMnp_%d_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/run_%d/results_from_time_100/',firstbit,12,1,1,1,e,0.675,i);
    	new = sprintf('%smutant_Mnp_%d_Mvf_%g_cctM_%g_eesM_%g_msM_%g_wtM_%g/numerics_bt_100_t_6000/run_%d/',secondbit,12,0.675,1,1,1,e,i);
    	mkdir(new);
        for j=1:length(files)
    		system(['cp ', [old,files{j}], ' ',  [new,files{j}]],'-echo');
    	end
    end
end
for d = cctM
	for i = 1:runs
    	old = sprintf('%sMnp_%d_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/run_%d/results_from_time_100/',firstbit,12,1,1,d,d,0.675,i);
    	new = sprintf('%smutant_Mnp_%d_Mvf_%g_cctM_%g_eesM_%g_msM_%g_wtM_%g/numerics_bt_100_t_6000/run_%d/',secondbit,12,0.675,d,1,1,d,i);
    	mkdir(new);
        for j=1:length(files)
    		system(['cp ', [old,files{j}], ' ',  [new,files{j}]],'-echo');
    	end
    end
end

for f = Mvf
	for i = 1:runs
		old = sprintf('%sMnp_%d_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/run_%d/results_from_time_100/',firstbit,12,1,1,1,1,f,i);
		new = sprintf('%smutant_Mnp_%d_Mvf_%g_cctM_%g_eesM_%g_msM_%g_wtM_%g/numerics_bt_100_t_6000/run_%d/',secondbit,12,f,1,1,1,1,i);
		mkdir(new);
        for j=1:length(files)
    		system(['cp ', [old,files{j}], ' ',  [new,files{j}]],'-echo');
    	end
	end
end

