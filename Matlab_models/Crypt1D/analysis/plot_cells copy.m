function plot_cells(p)
% takes a struct containing all the data about the cell population

figure('pos',[1 165 960 892])
plot(0:p.dt:p.t_end,p.x)

[t_steps, n] = size(p.x);

figure('pos',[962   165   960   892])
ax = gca
cla
X = zeros(n,1);
radii = (p.l/2) * ones(n,1);

lims = ((p.top+1)*p.l +1)/2;

xlim([-lims lims])
ylim([-1 (p.top+1)*p.l])
axis square
for t=1:t_steps
    cla(ax)
    centres = [X p.x(t,:)'];
    viscircles(ax,centres,radii);
    title(ax,(t-1)*p.dt)
    pause(p.dt);

end
end