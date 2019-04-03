close all;
clear all;

input_flags = {'n','np','ees','ms','cct','vf','run'};
input_values = [26;14;100;328;15;0.8;1];
% input_values = [26;14;100;200;15;0.8;1];
base_path = '/Users/phillipbrown/';

for i = 1:100
    input_values(end) = i;
    data_file = generate_file_name('TestCryptColumn', @MouseColonDesc, input_flags, input_values, base_path);
    
    penalties(i) = run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, false);
    data = get_data_from_file(data_file);
    
    slough(i) = data(1);
    anoikis(i) = data(2);
    total_end(i) = data(3) + data(5) + data(4)/2;
    max_pos(i) = data(6);
    fprintf('\nRunning average: %.4f\n',mean(penalties));
    fprintf('\nRunning varance: %.4f\n',var(penalties));
    fprintf('\nRunning stdev  : %.4f\n\n',var(penalties)^(0.5));
end

make_plots(penalties, 'penalties');
make_plots(slough, 'slough');
make_plots(anoikis, 'anoikis');
make_plots(max_pos, 'max_pos');
make_plots(total_end, 'total_end');


function make_plots(data, name)
    figure
    hist(data);
    title(name);

    for i = 1:100
        v(i) = var(data(1:i));
        avg(i) = mean(data(1:i));
    end
    figure
    plot(avg)
    hold on
    plot(avg - v.^0.5)
    plot(avg + v.^0.5)
    title(name);
end