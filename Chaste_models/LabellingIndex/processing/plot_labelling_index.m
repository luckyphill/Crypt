close all;
clear all;

data_s = [];
data_m = [];
data_wc = [];

s_length = 5;
count = 0;
for i = 0:4000
   
    s_file = ['/Users/phillipbrown/Research/Crypt/Data/Chaste/LabellingIndex/s' num2str(s_length) '/sphase_s' num2str(s_length) 'run_' num2str(i) '.txt'];
    m_file = ['/Users/phillipbrown/Research/Crypt/Data/Chaste/LabellingIndex/s' num2str(s_length) '/mphase_s' num2str(s_length) 'run_' num2str(i) '.txt'];
    wc_file = ['/Users/phillipbrown/Research/Crypt/Data/Chaste/LabellingIndex/s' num2str(s_length) '/whole_crypt_s' num2str(s_length) 'run_' num2str(i) '.txt'];

    try
        data_s_temp = dlmread(s_file);
        data_m_temp = dlmread(m_file);
        data_wc_temp = dlmread(wc_file);

        data_s = cat(1, data_s, data_s_temp(2:end,1));
        data_m = cat(1, data_m, data_m_temp(2:end,1));
        data_wc = cat(1, data_wc, [data_wc_temp(:,2), data_wc_temp(:,4)]);
        count = count + 1;
    catch e
        e
        s_file
    end

end

max_pos_s = max(data_s);
edges_s = -0.5:1:(max_pos_s + 0.5);
figure;
histogram(data_s,edges_s,'Normalization' ,'probability');
title('Labelling index from S phase', 'Interpreter' ,'latex');
xlim([-0.5 (max_pos_s + 0.5)]);
xlabel('Cell position number', 'Interpreter' ,'latex');
ylabel('Cell proportion', 'Interpreter' ,'latex');
xlim([-0.5 11.5]);
ylim([0 .14]);

h = gcf;
h.Units = 'centimeters';
fig_size = h.Position;
h.PaperSize = fig_size(3:4);
h.PaperUnits = 'centimeters';
file_name = ['LI_S_s' num2str(s_length)];
print(file_name,'-dpdf');

max_pos_m = max(data_m);
edges_m = -0.5:1:(max_pos_m + 0.5);
figure;
histogram(data_m,edges_m,'Normalization' ,'probability');
title('Labelling index from M phase', 'Interpreter' ,'latex');
xlim([-0.5 (max_pos_m + 0.5)]);
xlabel('Cell position number', 'Interpreter' ,'latex');
ylabel('Cell proportion', 'Interpreter' ,'latex');
xlim([-0.5 11.5]);
ylim([0 .14]);


h = gcf;
h.Units = 'centimeters';
fig_size = h.Position;
h.PaperSize = fig_size(3:4);
h.PaperUnits = 'centimeters';
file_name = ['LI_M_s' num2str(s_length)];
print(file_name,'-dpdf');


nbins = 10;
bins = linspace(-0.5,6.5,nbins+1);


max_pos_wc = max(data_wc);
edges_m = -0.5:1:(max_pos_wc + 0.5);
figure;
p = histogram(data_wc(data_wc(:,1)==2,2),bins,'Normalization' ,'probability');
title('Whole crypt S Phase', 'Interpreter' ,'latex');
% xlim([-0.5 (max_pos_wc + 0.5)]);
xlabel('Cell distance', 'Interpreter' ,'latex');
ylabel('Cell proportion', 'Interpreter' ,'latex');
ylim([0 .14]); xlim([bins(1) bins(end)]);

h = gcf;
h.Units = 'centimeters';
fig_size = h.Position;
h.PaperSize = fig_size(3:4);
h.PaperUnits = 'centimeters';
file_name = ['WC_S_s' num2str(s_length)];
print(file_name,'-dpdf');

figure;
histogram(data_wc(data_wc(:,1)==4,2),bins,'Normalization' ,'probability');
title('Whole crypt M Phase', 'Interpreter' ,'latex');
xlabel('Cell distance', 'Interpreter' ,'latex');
ylabel('Cell proportion', 'Interpreter' ,'latex');
ylim([0 .14]); xlim([bins(1) bins(end)]);

h = gcf;
h.Units = 'centimeters';
fig_size = h.Position;
h.PaperSize = fig_size(3:4);
h.PaperUnits = 'centimeters';
file_name = ['WC_M_s' num2str(s_length)];
print(file_name,'-dpdf');

figure;
histogram(data_wc(data_wc(:,1)==1,2),bins,'Normalization' ,'probability');
title('Whole crypt G1 Phase', 'Interpreter' ,'latex');
% xlim([-0.5 (max_pos_wc + 0.5)]);
xlabel('Cell distance', 'Interpreter' ,'latex');
ylabel('Cell proportion', 'Interpreter' ,'latex');
ylim([0 .14]); xlim([bins(1) bins(end)]);

h = gcf;
h.Units = 'centimeters';
fig_size = h.Position;
h.PaperSize = fig_size(3:4);
h.PaperUnits = 'centimeters';
file_name = ['WC_G1_s' num2str(s_length)];
print(file_name,'-dpdf');

figure;
histogram(data_wc(data_wc(:,1)==3,2),bins,'Normalization' ,'probability');
title('Whole crypt G2 Phase', 'Interpreter' ,'latex');
xlabel('Cell distance', 'Interpreter' ,'latex');
ylabel('Cell proportion', 'Interpreter' ,'latex');
ylim([0 .14]); xlim([bins(1) bins(end)]);

h = gcf;
h.Units = 'centimeters';
fig_size = h.Position;
h.PaperSize = fig_size(3:4);
h.PaperUnits = 'centimeters';
file_name = ['WC_G2_s' num2str(s_length)];
print(file_name,'-dpdf');
count


hsl = uicontrol('Style','slider','Min',1,'Max',20,...
'SliderStep',[1 1]/20,'Value',8,...
'Position',[20 20 200 20]);
set(hsl,'Callback',@(hObject,eventdata) ...
set(p,'NumBins',round(get(hObject,'Value'))));

