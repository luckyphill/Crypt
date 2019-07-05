

p.input_flags = {'msM'};
p.input_values = [0.9];


p.static_flags = {'sm','t','n','np','ees','ms','vf','cct','wt','dt'};
p.static_params= [100, 211, 29, 12, 58, 216, 0.675, 15, 9, 0.001];

p.run_flag = 'run';
p.run_number = 2;

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
times = data(:,1);
data = data(:,4:3:end);



dr = 2;
rmax = 29;

h1 = figure();
h1.Position = [1 385 560 420];
point = 2;
data1 = data(point,:);
[pcf, edges] = simple_pcf(data1, dr, rmax);
l = line(edges, pcf);

h2 = figure();
h2.Position = [562 385 560 420];
imN = times(point) * 10 - 399;
imPath = '/Users/phillip/Chaste/anim/image0';
imFile = [imPath, sprintf('%04d', imN), '.png'];
image(imread(imFile));

for i = 2:50:length(data(:,1))
    data1 = data(i,:);
    [pcf, edges] = simple_pcf(data1, dr, rmax);
    figure(h1);
    l.YData = pcf;
    ylim([0 1]);
    xlim([0 rmax]);
    title(sprintf('Y Position PCF at time = %3.fh',times(i)));
    figure(h2);
    imFile = [imPath, sprintf('%04d',(times(i)* 10 - 399 )),'.png'];
    image(imread(imFile));
    drawnow;
    pause(0.1)
end

