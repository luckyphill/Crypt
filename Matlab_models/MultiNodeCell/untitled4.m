clear all;
close all;


% Cell positions
cell1 = [0,0];
cell2 = [1.5,0];

cellA = [0.6, .4];
cellB = [0.8, .4];

%plot the cells
centres = [cellA;cellB;cell1;cell2];
radii = 0.5 * [1,1,1,1];
figure();
ax = gca;
axis square
xlim([-0.5 2.5]);
ylim([-0.5 2.5]);

viscircles(ax,centres,radii);

% Spring constants
ke = 50; % between epithelial cells
km = 100; % with the membrane
ki = 100; % within a growing cell

theta1 = atan( cellA(2) / ( cellA(1) - cell1(1) )  );
theta2 = atan( cellB(2) / ( cell2(1) - cellB(1) )  );

L = 1; % natural spring length of full cells
dt = 0.001;
T0 = 5;

l = @(t) (0.01 + ((2 * sqrt(2) - 2) - 0.01) * t/10 ) * (t < 10) + (t >= 10);

f = @(x, k, t) k * l(t) *log(1 + x/l(t)) * (x < 0)  +  k * x * exp(-5 * x/l(t)) * (x > 0);

timesteps = 100;

for i = 0:timesteps
    cla(ax)
    x_1_A = norm(cell1 - cellA);
    x_2_B = norm(cell2 - cellB);
    x_A_B = norm(cellA - cellB);

    T = T0 + i * dt;
    f_A_net_i = f(x_1_A - L, ke, 10) * cos(theta1) - f(x_A_B - l(T), ki, T);
    f_A_net_j = f(x_1_A - L, ke, 10) * sin(theta1) - f(cellA(2), km, 10);

    f_B_net_i = f(x_2_B - L, ke, 10) * cos(theta2) + f(x_A_B - l(T), ki, T);
    f_B_net_j = f(x_2_B - L, ke, 10) * sin(theta2) - f(cellB(2), km, 10);


    dxA = dt * [f_A_net_i, f_A_net_j];
    dxB = dt * [f_B_net_i, f_B_net_j];

    cellA = cellA + dxA;
    cellB = cellB + dxB;

    centres = [cellA;cellB];
    radii = 0.5 * [1,1];
    viscircles(ax,centres,radii, 'Color','b');
    pause(1);
end






