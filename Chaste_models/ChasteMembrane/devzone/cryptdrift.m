% MouseColonCaecum

% params = [24, 8, 1, 1, 1, 1, 0.6125;
%           25, 9,0.92,1.01,0.994,1.04,0.625;
%           26, 10,0.84,1.025, 0.988,1.08,0.6375;
%           27, 11, 0.76,1.05,0.982,1.12,0.65;
%           28, 12,0.67,1.07,0.975,1.16,0.6625;
%           29, 12,0.58,1.08,0.968,1.2,0.675];
          
 % MouseColonDesc
 params = [24, 8,1.72,0.92,1.0333,0.8333, 0.6125;
          25, 9,1.576,0.936,1.0333,0.86,0.625;
          26, 10,1.432,0.952,1.015,0.895,0.6375;
          27, 11,1.288,0.968,1,0.93,0.65;
          28, 12,1.144,0.984,1,0.97,0.6625;
          29, 12,1,1,1,1,0.675];

% For each parameter set, load all the pop up data and plot it

% first = '/Users/phillipbrown/testoutput/TestCryptColumnFullMutation/MouseColonCaecum/';
first = '/Users/phillipbrown/testoutput/TestCryptColumnFullMutation/MouseColonDesc/';

last = '/results_from_time_100/popup_location.txt';

each_line = {};
for i = 1:5
    all_data= [];
    for j = 1:9
        file = sprintf('%sMnp_%g_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/run_%d%s',first,params(i,2:end),j,last);
        data = csvread(file);
        data = data(:,2:end);
        data = data(:);
        data(data==0) = [];
        all_data = [all_data; data];
    end
    each_line{end+1} = all_data;
    
end

h = figure(1);
ax = gca;

for i = 1:length(each_line)
    data = each_line{i};
    edges = 1:19;
    counts = histcounts(data,edges)/1000;
    figure(h);
    hold on;
    plot(ax, 1:18 ,counts, 'LineWidth', 4, 'DisplayName',num2str(params(i,1)));
end
legend;

% function out = makepui(params)

      