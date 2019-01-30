
cct = 2:2:8;
vf = 0.6:0.05:0.9;

for i = 1:length(cct)
    for j = 1:length(vf)
        file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste/PopUpLimit/limit_n_20_VF_%g_CCT_%d.txt', 100 * vf(j), cct(i));
        try
            data = csvread(file);
            ees = data(:,1);
            ms = data(:,2);
            for k = 1: length(ees)
                plot_cell_velocity(ees(k), ms(k), cct(i), vf(j));
            end
        catch
            fprintf('No file - limit_n_20_VF_%g_CCT_%d.txt\n', 100 * vf(j), cct(i));
        end
    end
end
