close all
% plot_fraction({'msM'}, 0.3:0.01:1, 'modifier', 'adhesion strength',1);
plot_fraction({'eesM'}, 0.5:0.02:2, 'modifier', 'cell stiffness',1);
% plot_fraction({'Mvf'}, 0.5:0.01:0.75, 'mutant value', 'CI fraction', 0.675);
% plot_fraction({'Mnp'}, 8:16, 'mutant value', 'proliferative zone', 12);
plot_fraction({'cctM', 'wtM'}, 0.5:0.02:2, 'modifier', 'cell cycle time (fully scaled)', 1);

function plot_fraction(flag, p_range, xlab, tit, vert)

p.input_flags = {};
p.input_flags = horzcat(p.input_flags, flag);

p.static_flags = {'t','n','np','ees','ms','vf','cct','wt','dt'};
p.static_params= [400, 29, 12, 58, 216, 0.675, 15, 9, 0.001];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumnClonal';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonDescMutations;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.process = 'ParameterOptimisation';
p.output_file_prefix = 'parameter_search';


frac = [];
coun = [];
runn = [];

for fr = p_range
    
    p.input_values = fr * ones(size(p.input_flags));
    total = 0;
    count = 0;
    for run_number = 1:101
        
        p.run_number = run_number;
        file_name = generate_file_name(p);
        try
            total = total + csvread(file_name);
            count = count + 1;
        catch
            fprintf('Skipped %g at run %g\n', fr, run_number);
        end
        
    end
    fraction = total / count;
    runn = [runn, run_number];
    coun = [coun, count];
    frac = [frac, fraction];
end

h = figure();
plot(p_range, frac, 'LineWidth',4);
title(['Clonal conversion rate for ', tit], 'Interpreter','latex');
ylabel('fraction', 'Interpreter','latex');
xlabel(xlab, 'Interpreter','latex');
ylim([0 1.1]);

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

hold on
plot(vert * ones(size(0:0.02:1.1)), 0:0.02:1.1, '.k')

print([flag{1},'_dt001'],'-dpdf');

figure
plot(p_range, coun, '.');

end
    