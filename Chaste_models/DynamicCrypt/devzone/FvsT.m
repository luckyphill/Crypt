%% Script to compare the movement from the force method to the torsion
% (rotation) method
close all
clear all
theta_0 = pi;
k = 10;
dt = 0.05;
eta = 1;

h = figure(1);

r = [1,2];
theta = atan(r(2)/r(1));
h_old = line([0,r(1)], [0,r(2)], 'Color','red');

pr_old = [-r(2), r(1)]/norm(r);

T = k * (theta_0 - theta);

% New position from Force method
F = T / norm(r);
F_mag = abs(dt*F/eta);

drF = dt*F * pr_old/eta;

rF_new = r + drF;

hF = line([0,rF_new(1)], [0,rF_new(2)], 'Color','black');

% New position from rotation method

d_theta = dt*T/eta;

rot = [cos(d_theta), -sin(d_theta); sin(d_theta), cos(d_theta)];

rT_new = rot * r';

hT = line([0,rT_new(1)], [0,rT_new(2)], 'Color','green');

axis equal

% If the direction of the force method was tweaked to keep the length of
% the new position vector the same as r

AtoB = rT_new' - r;
AtoB = -F * dt * AtoB / norm(AtoB)/eta + r;



% h_AtoB = line([r(1), AtoB(1)], [r(2), AtoB(2)], 'Color','black');

viscircles([0,0],norm(r),'Color','blue', 'LineWidth', 1, 'LineStyle', '--');
%%
% The exact line with magnitude F that keeps the distance between membrane
% cells constant. The problem boils down to finding the intercept of a line
% and a circle. Using the formula from:
% http://mathworld.wolfram.com/Circle-LineIntersection.html

% Need two points on the line, can trivially choose them to be at the axes
% so one component is zero
% x1 = 0;
% y1 = F_mag / 2 * r(2);
% x2 = F_mag / 2 * r(1);
% y2 = 0;
% 
% dx = x2 - x1;
% dy = y2 - y1;
% dr2 = dx^2 + dy^2;
% D = x1*y2 - x2*y1;
% 
% % In general, there can be zero, one or two solutions, but by design, in
% % our problem, there must be two. Designate +ve solution u, -ve solution v
% 
% ux = (  D*dy + sign(dy) * dx * sqrt( dr2 - D^2 )  ) / dr2;
% 
% uy = ( -D*dx + abs(dy) * sqrt( dr2 - D^2 )  ) / dr2;
% 
% 
% vx = (  D*dy - sign(dy) * dx * sqrt( dr2 - D^2 )  ) / dr2;
% 
% vy = ( -D*dx - abs(dy) * sqrt( dr2 - D^2 )  ) / dr2;
% 
% u = [ux,uy];
% v = [vx,vy];
% 
% ru = -F_mag * u + r;
% rv = -F_mag * v + r;
% 
% h_special_u = line([r(1), ru(1)], [r(2), ru(2)], 'Color','blue');
% h_special_v = line([r(1), rv(1)], [r(2), rv(2)], 'Color','blue');
% 
% 
% abs(norm(u) - 1) < 1e-8
% abs(norm(v) - 1) < 1e-8
% 
% abs(u(1)*r(1) + u(2)*r(2) - F_mag/2) < 1e-8
% abs(v(1)*r(1) + v(2)*r(2) - F_mag/2) < 1e-8
% 
% 
% figure('Position',[1400 1400 600 600]);
% hold on
% a = linspace(-10,10);
% plot(a, (F_mag/2 - a*r(1))/r(2));
% viscircles([0,0],1);
% xlim([-2,2]);
% ylim([-2,2]);
% scatter([ux,vx],[uy,vy])
% axis equal
% 
% % Try using my own solution
% figure
% D = r(1)/r(2);
% 
% px = (  F_mag*D/r(2) + 2 * sqrt(   D^2 - F_mag^2/4*r(2)^2 - 1)  ) / 2*(1 +   D^2);
% py = (  F_mag/D*r(1) + 2 * sqrt( 1/D^2 - F_mag^2/4*r(1)^2 - 1)  ) / 2*(1 + 1/D^2);
% 
% qx = (  F_mag*D/r(2) - 2 * sqrt(   D^2 - F_mag^2/4*r(2)^2 - 1)  ) / 2*(1 +   D^2);
% qy = (  F_mag/D*r(1) - 2 * sqrt( 1/D^2 - F_mag^2/4*r(1)^2 - 1)  ) / 2*(1 + 1/D^2);
% 
% p = [px,py];
% q = [qx,qy];
% 
% rp = -p + r;
% rq = -q + r;
% 
% viscircles([0,0],norm(r),'Color','blue', 'LineWidth', 1, 'LineStyle', '--');
% h_special_p = line([r(1), rp(1)], [r(2), rp(2)], 'Color','blue');
% h_special_q = line([r(1), rq(1)], [r(2), rq(2)], 'Color','blue');
% axis equal


%% Trying now with a rotation. We have a completely determined triangle, so
% can find the angle of rotation and use a rotation matrix
% Because the angle relates to the side lengths, the matrix doesn't require
% any trig functions, but it does have a square root sign that could take
% +ve or -ve values

b = F_mag / norm(r);

R = [1-b^2/2,         b*sqrt(1-b^2/4);
     -b*sqrt(1-b^2/4),          1-b^2/2];
 
 r_new = R * r';
 
 figure
 h_old = line([0,r(1)], [0,r(2)], 'Color','red');
 h_new = line([0,r_new(1)], [0,r_new(2)], 'Color','blue');

 viscircles([0,0],norm(r),'Color','blue', 'LineWidth', 1, 'LineStyle', '--');
 
 dr = r_new - r';
 h_dr = line([0,dr(1)], [0,dr(2)], 'Color','black');
 h_move = line([r(1), r_new(1)], [r(2), r_new(2)], 'Color','black');
 axis equal
 