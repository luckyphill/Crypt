% rootdir = '/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumn/';
% filelist = dir(fullfile(rootdir, '**/*.*'));  %get list of files and folders in any subfolder
% filelist = filelist(~[filelist.isdir]);

objectives = {@MouseColonAsc, @MouseColonTrans, @MouseColonDesc, @MouseColonCaecum,...
                @RatColonAsc, @RatColonTrans, @RatColonDesc, @RatColonCaecum, @HumanColon};

optimals = {};

for i = 1:205425
%     fprintf('%s\n',filelist(i).name(1));
    if strcmp(filelist(i).name(1),'b')
%         fprintf('Behaviour stats\n');
        % Load the file
        % Run it through the objecive functions
        % If the result is 0, store the full file path and the crypt
        fullpath = [filelist(i).folder,'/',filelist(i).name];
        data = csvread(fullpath);
        for j = 1:9
%             fprintf('Applying objective function %s\n',func2str(f));
            f = objectives{j};
%             fprintf('Objective value %g\n',f(data));
            if f(data) == 0
                optimals{end+1,1} = fullpath;
                optimals{end,2} = f;
                fprintf('Objective value %g\n',f(data));
                fprintf('Optimal for %s\n', func2str(f));
            end
        end
    end
end

for i = 1:length(optimals)
    optimals{i,1}(1:63)='';
end





params = [0,0,0,0,0,0,0,0];
for i = 1:length(optimals)
    t = split(optimals{i,1},'/');
    s = split(t{2},'_');
    if length(s{7}) > 2 % At least a 3 digit number
        t = split(t{1},'_');
        % t =

        %   15×1 cell array

        %     {'params'}
        %     {'cct'   }
        %     {'11.564'}
        %     {'ees'   }
        %     {'230'   }
        %     {'ms'    }
        %     {'410'   }
        %     {'n'     }
        %     {'34.1'  }
        %     {'np'    }
        %     {'12.3'  }
        %     {'vf'    }
        %     {'0.656' }
        %     {'wt'    }
        %     {'8.1'   }
        t = [str2num(t{9}),str2num(t{11}),str2num(t{5}),str2num(t{7}),str2num(t{3}),str2num(t{15}),str2num(t{13}), getFuncNumber(optimals{i,2})];
        params(i,:) = t;
    end
end

[P,q,r] = unique(params,'rows');

O1 = sortrows(P(P(:,8)==1,:),5);
O2 = sortrows(P(P(:,8)==2,:),5);
O3 = sortrows(P(P(:,8)==3,:),5);
O4 = sortrows(P(P(:,8)==4,:),5);
O5 = sortrows(P(P(:,8)==5,:),5);
O6 = sortrows(P(P(:,8)==6,:),5);
O7 = sortrows(P(P(:,8)==7,:),5);
O8 = sortrows(P(P(:,8)==8,:),5);

% Normalise the values to th emaximum value in the column in order to find the 
% Maximum distances between points using the euclidean norm`
SO1 = O1./max(O1);
SO2 = O2./max(O2);
SO3 = O3./max(O3);
SO4 = O4./max(O4);
SO5 = O5./max(O5);
SO6 = O6./max(O6);
SO7 = O7./max(O7);
SO8 = O8./max(O8);

TO1 = (O1 - min(O1))./ (max(O1) - min(O1));

for i=1:length(SO1)
    for j = i+1:length(SO1)
        XSO1(i,j) = norm(SO1(i,:)-SO1(j,:));
    end
end

for i=1:length(SO2)
    for j = i+1:length(SO2)
        XSO2(i,j) = norm(SO2(i,:)-SO2(j,:));
    end
end


for i=1:length(SO3)
    for j = i+1:length(SO3)
        XSO3(i,j) = norm(SO3(i,:)-SO3(j,:));
    end
end


for i=1:length(SO4)
    for j = i+1:length(SO4)
        XSO4(i,j) = norm(SO4(i,:)-SO4(j,:));
    end
end


for i=1:length(SO5)
    for j = i+1:length(SO5)
        XSO5(i,j) = norm(SO5(i,:)-SO5(j,:));
    end
end


for i=1:length(SO6)
    for j = i+1:length(SO6)
        XSO6(i,j) = norm(SO6(i,:)-SO6(j,:));
    end
end


for i=1:length(SO7)
    for j = i+1:length(SO7)
        XSO7(i,j) = norm(SO7(i,:)-SO7(j,:));
    end
end


for i=1:length(SO8)
    for j = i+1:length(SO8)
        XSO8(i,j) = norm(SO8(i,:)-SO8(j,:));
    end
end


for i =1:100
[~,~,sumd] = kmeans(SO1,i);
test(i) = sum(sumd);
end
plot( abs(test(1:end-1)-test(2:end))./test(1:end-1))



