function make_movie(p)

    [t_steps, n] = size(p.x);
    xlim([0 t_steps])
    ylim([0 p.top])

    figure('pos',[962   165   960   892])
    ax = gca;
    cla;
    X = zeros(n,1);
    radii = (p.l/2) * ones(n,1);

    lims = ((p.top+1)*p.l +1)/2;

    xlim([-lims lims])
    ylim([-1 (p.top+1)*p.l])
    axis square
    
    v = VideoWriter('crypt.avi','Motion JPEG AVI');
    v.Quality = 1;
%     v.CompressionRatio = 10;
    open(v);
    
    for t=1:2:t_steps
        cla(ax)
        centres = [X p.x(t,:)'];
        viscircles(ax,centres,radii);
        title(ax,(t-1)*p.dt)
        %pause(p.dt/5);
        frame = getframe(gcf);
        writeVideo(v,frame);
    end


    close(v);

end