
file = '/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnFullMutation/MouseColonDesc/mutant_Mnp_15_Mvf_0.675_cctM_1_eesM_1_msM_1_wtM_1/numerics_bt_100_t_6000/run_4/results.viznodes';
data = dlmread(file);

times = data(:,1);


steps = -0.5:29.5;
nn = length(steps)-1;

pos_max_t = nan(length(times),nn);


for i=1:length(data)
    clear sortedbypos;
    nz = find(data(i,:), 1, 'last');
    x = data(i,2:2:nz);
    y = data(i,3:2:nz);
    sortedbypos{nn} = [];
    for j = 1:length(x)
        for k=2:length(steps)
            if steps(k) >= y(j) && y(j) > steps(k-1)
                sortedbypos{k-1}(end + 1) = x(j);
            end
        end
    end
    
    for j = 1:nn
        temp = max(sortedbypos{j});
        if ~isempty(temp)
            pos_max_t(i,j) = temp;
        end
    end

end

filter = 0.0;

L = times(end);
test = pos_max_t(:,1:29);
out = fft(test);
out = out(1:length(out)/2 + 1, : );
out = abs(out / L);
out(2:end -1, :) = 2*out(2:end-1, :);
f = (1:length(out)-1)/30/L;
out2 = out;
out2(out < filter) = nan;
figure(1)
lim = max(max(out2(2:end,:)));
plot(f, out2(2:end,:));
ylim([0 lim]);
figure(2)
plot(f, nanmean(out2(2:end,:),2));
ylim([0 lim]);
figure(3)
plot(f, max(out2(2:end,:),[],2));
ylim([0 lim]);
figure(4)
plot(f, min(out2(2:end,:),[],2));
ylim([0 lim]);
figure(5)
surf(out2(2:end,:));
zlim([0 lim]);

figure(6);
plot(times, pos_max_t(:,10));
figure(7);
plot(f, out2(2:end,10));
ylim([0 lim]);

f10 = fft(pos_max_t(:,10));
f101 = abs(f10)/L;
f102 = f10;
f102(f101< 0.05) = 0;
r10 = ifft(f102);
figure(8)
plot(r10)

% 
% best = 100000000000;
% first = 5;
% last = 25;
% for i=1:4000
%     test = sum( abs(  pos_max_t(1:(end-i),first)-pos_max_t((i+1):end,last) ) );
%     if test < best
%         best = test;
%         best_i = i;
%     end
% end
% plot(pos_max_t(1:(end-best_i),first)-pos_max_t((best_i +1):end,last))