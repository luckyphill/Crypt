
col  =1;
ran = 1:10;

g = figure;
plot(params2(ran,col),r_max(ran), params2(ran,col),r_min(ran), params2(ran,col),r_mean(ran),'LineWidth' , 4)
title('Prolif compartment')
set(g,'Units','Inches');
pos = get(g,'Position');
set(g,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print('Prolif','-dpdf');


col =2;
ran = 11:23;

g = figure;
plot(params2(ran,col),r_max(ran), params2(ran,col),r_min(ran), params2(ran,col),r_mean(ran),'LineWidth' , 4)
title('Cell stiffness')
set(g,'Units','Inches');
pos = get(g,'Position');
set(g,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print('Cell stiff','-dpdf');

g = figure;
col =3;
ran = 24:33;

plot(params2(ran,col),r_max(ran), params2(ran,col),r_min(ran), params2(ran,col),r_mean(ran),'LineWidth' , 4)
title('Membrane stiffness')
set(g,'Units','Inches');
pos = get(g,'Position');
set(g,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print('membrane stiff','-dpdf');