

p.input_flags = {'Mnp', 'msM'};
p.input_values = [14, 0.7];


p.static_flags = {'sm','t','n','np','ees','ms','vf','cct','wt','dt'};
p.static_params= [100, 10, 29, 12, 58, 216, 0.675, 15, 9, 0.001];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumnMutation';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonDescMutations;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.process = 'PairCorrelation';
p.output_file_prefix = 'position_data';



data = run_position_data(p);

data = data(:,4:3:end);



dr = 1;
rmax = 29;

figure()
data1 = data(1,:);
[pcf, edges] = simple_pcf(data1, dr, rmax);
l = line(edges, pcf);

for i = 2:length(data(:,1))
    data1 = data(i,:);
    [pcf, edges] = simple_pcf(data1, dr, rmax);
    l.YData = pcf;
    ylim([0 1]);
    xlim([0 rmax]);
    drawnow;
    pause(1)
end

