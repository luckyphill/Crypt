close all
clear all

n = 500;

times = randi(100,n) + 100;
pop.seed = 'shuffle';



for i=n:-1:1
    pop.t_end= times(i);
    p(i) = crypt_1D(pop);
    fprintf('%d\n',i);
end

all_li = [];
all_lp = [];
all_x = [];
all_v = [];

for i=1:n
    all_li = [all_li p(i).labelling_index];
    all_lp = [all_lp p(i).labelling_position];
    all_x = [all_x p(i).x];
    all_v = [all_v p(i).v];
end

% all_x = all_x(~isnan(all_x));
% all_v = all_v(~isnan(all_x));

hist(all_li,15)
figure()
hist(all_lp)
figure()
plot(all_x,all_v,'*');

bins = ceil(all_x);
for i = 1:20
    avg(i) = mean(all_v(bins == i));
end
figure;
plot(avg);
    