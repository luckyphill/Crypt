n = 20;
cct = 6:2:8;
vf = 0.6:0.05:0.9;

for i = 1:length(cct)
    for j = 1:length(vf)
        file = sprintf('/Users/phillip/Research/Crypt/Data/Chaste/PopUpLimit/limit_n_%d_VF_%g_CCT_%d.txt', n, 100 * vf(j), cct(i));
        try
            data = csvread(file);
            ees = data(:,1);
            ms = data(:,2);
            for k = 1: length(ees)
                plot_cell_velocity(n, ees(k), floor(ms(k)), cct(i), vf(j));
            end
        catch
            fprintf('No file - limit_n_20_VF_%g_CCT_%d.txt\n', 100 * vf(j), cct(i));
        end
    end
end
