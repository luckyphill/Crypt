function plot_from_file(p)


    data_file = [p.output_file '.txt'];

    data = csvread(data_file);

    [t_steps, n] = size(data);
    

    figure('pos',[962   165   960   892])
    
    ax = gca;
    cla;
    X = zeros(n,1);
    

    lims = ((p.top+1)*p.l +1)/2;

    xlim([-lims lims])
    ylim([-1 (p.top+1)*p.l])
    axis square
    for t=1:t_steps
        mm = length(data(t,:));
        plot_data = data(t,3:2:mm);
        m = length(plot_data);
        
        
        X = zeros(m,1);
        radii = (p.l/2) * ones(m,1);
        cla(ax)
        centres = [X plot_data'];
        viscircles(ax,centres,radii);
        title(ax,(t-1)*p.dt)
        pause(p.dt/10);

    end


end