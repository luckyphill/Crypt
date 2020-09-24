N = 50;

x = randi([0 1], N,1);

h = sum(x);
flips = 10000;

for i = 1:flips
    j = randi([1 N]);
    x(j) = ~x(j);
    h(i) = sum(x);
end

figure;
plot(h);
histogram(h, -0.5:1:(N + .5),'Normalization','probability');

m = mean(h);
std = sqrt(var(h));

y = 0:0.1:N;
hold on
plot(y,normpdf(y,m,std));