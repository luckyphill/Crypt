close all
x = linspace(-2,2,1000);
f = nan(size(x));
f(x>0) = log(x(x>0));
f(x<0) = log(-x(x<0));
f(x<-1) = -(x(x<-1)+1).*exp((x(x<-1)+1));
f(x>1) = (x(x>1)-1).*exp(-(x(x>1)-1));

h=figure;
hold on
plot(zeros(1000,1),linspace(-10,10,1000),'k','LineWidth',8)
plot(linspace(-4,4,1000),zeros(1000,1),'k','LineWidth',2)

% axis equal
plot(-2*repmat([nan,nan,1,1,1,nan,nan,nan],1,125),linspace(-10,10,1000),'k','LineWidth',4)
plot(-1*ones(1000,1),linspace(-10,10,1000),'k--','LineWidth',3)
plot(ones(1000,1),linspace(-10,10,1000),'k--','LineWidth',3)
plot(2*repmat([nan,nan,1,1,1,nan,nan,nan],1,125),linspace(-10,10,1000),'k','LineWidth',4)
plot(x,f,'Color',[0 0.4470 0.7410],'LineWidth',8);
xlim([-2.2, 2.2])
ylim([-3.2, 1.2]);
set(gca,'YTick',[])
set(gca,'XTick',[])
set(gca, 'XAxisLocation', 'origin')
set(gca, 'YAxisLocation', 'origin')

box off

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

print('RodForce','-dpdf')







x = linspace(-1,2,1000);
f = nan(size(x));
f(x>1) = (x(x>1)-1).*exp(-(x(x>1)-1));
f(x<1) = 2*log((x(x<1)+1)/2);

h=figure;
hold on
fill([0,0,-4,-4],[-4,4,4,-4],[0.9375 0.7383 0.6562]);
plot(linspace(-4,4,1000),zeros(1000,1),'k','LineWidth',2)
plot(zeros(1000,1),linspace(-10,10,1000),'k','LineWidth',8)

% axis equal
plot(ones(1000,1),linspace(-10,10,1000),'k--','LineWidth',3)
plot(2*repmat([nan,nan,1,1,1,nan,nan,nan],1,125),linspace(-10,10,1000),'k','LineWidth',4)
plot(x,f,'Color',[0 0.4470 0.7410],'LineWidth',8);
plot(-1*repmat([nan,nan,1,1,1,nan,nan,nan],1,125),linspace(-10,10,1000),'k','LineWidth',1)

xlim([-2.2, 2.2])
ylim([-3.2, 1.2]);

set(gca,'YTick',[])
set(gca,'XTick',[])
set(gca, 'XAxisLocation', 'origin')
set(gca, 'YAxisLocation', 'origin')

box off

set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

print('CellForce','-dpdf')



tend = 25;
t = linspace(0,tend,1000);
f = nan(size(t));
S0 = 0.5;
Sg = 1;
t0 = 5;
tg = 15;

f = S0 * ones(size(t));
f(t>t0) = S0 + (Sg-S0) * (  t(t>t0) - t0  ) / ( tg - t0 );
f(t>tg) = Sg * ones(size(t(t>tg)));

h=figure;
hold on

% axis equal
plot(t,0.1*ones(1000,1),'k','LineWidth',2)
plot(zeros(1000,1),linspace(0,10,1000),'k','LineWidth',2)
plot(t0*repmat([nan,1,1,1,nan],1,200),linspace(-10,10,1000),'k','LineWidth',2)
plot(tg*repmat([nan,1,1,1,nan],1,200),linspace(-10,10,1000),'k','LineWidth',2)
plot(linspace(0, tg, 50), Sg*repmat([nan,1,1,1,nan],1,10),'k','LineWidth',2)

plot(t,f,'Color',[0 0.4470 0.7410],'LineWidth',8);
xlim([-1, tend])
ylim([0, 1.4]);
set(gca,'YTick',[])
set(gca,'XTick',[])
set(gca, 'XAxisLocation', 'origin')
set(gca, 'YAxisLocation', 'origin')

box off
axis off
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

print('SizeFunction','-dpdf')