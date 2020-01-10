% Script to compare the movement from the force method to the torsion
% (rotation) method
close
theta = 3*pi/2;
theta_0 = pi;
k = 10;
dt = 0.05;
eta = 1;

r_old = [-1,1];
h_old = line([0,r_old(1)], [0,r_old(2)], 'Color','red');

lr_old = sqrt(r_old(1)^2 + r_old(2)^2);
pr_old = [-r_old(2), r_old(1)]/lr_old;

T = k * (theta_0 - theta);

% New position from Force method
F = T / lr_old;

drF = dt*F * pr_old/eta;

rF_new = r_old + drF;

hF = line([0,rF_new(1)], [0,rF_new(2)], 'Color','black');

% New position from rotation method

d_theta = dt*T/eta/2;

rot = [cos(d_theta), -sin(d_theta); sin(d_theta), cos(d_theta)];

rT_new = rot * r_old';

hT = line([0,rT_new(1)], [0,rT_new(2)], 'Color','green');

axis equal
norm(r_old);
norm(rT_new);
norm(rF_new);
norm(r_old)-norm(rT_new);
norm(r_old)-norm(rF_new);

norm(r_old - rT_new');
norm(r_old - rF_new);
norm(rF_new - rT_new');

% If the direction of the force method was tweaked to keep the length of
% the new position vector the same as r_old

AtoB = rT_new' - r_old;
AtoB = -F * dt * AtoB / norm(AtoB)/eta + r_old;



h_AtoB = line([r_old(1), AtoB(1)], [r_old(2), AtoB(2)], 'Color','black');

