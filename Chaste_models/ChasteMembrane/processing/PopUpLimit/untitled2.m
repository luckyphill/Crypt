

close all

n = 1000;

l = linspace(0.025,1,n);
max_theta(2) = 0;

for i = 1:n
    max_theta(i) = find_max(l(i));
end

figure()
plot(l, max_theta, 'LineWidth',3);
title('$\theta$ producing the largest $\frac{k_m}{k_e}$', 'Interpreter', 'latex', 'FontSize', 24);
xlabel('$l$', 'Interpreter', 'latex', 'FontSize', 24);
ylabel('$\theta$', 'Interpreter', 'latex', 'FontSize', 24);


f = @(x,l) (l < cos(x)) * 2*log(2 - l * sec(x)) * sin(x) * exp( 5*l*tan(x) ) / ( l * tan(x));


max_ratio = nan(n,1);
for i = 1:n
    max_ratio(i) = f(max_theta(i), l(i));
end

figure()
plot(l, max_ratio, 'LineWidth',3);
title('Maximum $\frac{k_m}{k_e}$ vs $l$', 'Interpreter', 'latex', 'FontSize', 24);
xlabel('$l$', 'Interpreter', 'latex', 'FontSize', 24);
ylabel('$\frac{k_m}{k_e}$', 'Interpreter', 'latex', 'FontSize', 24);

figure()
plot(l, 2*log(2-l)./l, 'LineWidth',3);
title('$\frac{k_m}{k_e}$ vs $l$ at $\theta=0$', 'Interpreter', 'latex', 'FontSize', 24);
xlabel('$l$', 'Interpreter', 'latex', 'FontSize', 24);
ylabel('$\frac{k_m}{k_e}$', 'Interpreter', 'latex', 'FontSize', 24);

X = linspace(0,1.5,n);
L = linspace(0.1, 0.9, n);

F = nan(n);

for i =1:n
    for j =1:n
        F(i,j) = f(X(i),L(j));
    end
end

figure()
imagesc(F);
figure
surf(X,L,F,'EdgeColor', 'none');
xlabel('$\theta$', 'Interpreter', 'latex', 'FontSize', 24);
ylabel('$l$', 'Interpreter', 'latex', 'FontSize', 24);
zlabel('$\frac{k_m}{k_e}$', 'Interpreter', 'latex', 'FontSize', 24);
zlim([0, 25]);
colorbar;
