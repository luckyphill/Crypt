% rootdir = '/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumn/';
% filelist = dir(fullfile(rootdir, '**/*.*'));  %get list of files and folders in any subfolder
% filelist = filelist(~[filelist.isdir]);

% objectives = {@MouseColonAsc, @MouseColonTrans, @MouseColonDesc, @MouseColonCaecum,...
%                 @RatColonAsc, @RatColonTrans, @RatColonDesc, @RatColonCaecum, @HumanColon};
% 
% optimals = {};
% 
% for i = 1:length(filelist)
% %     fprintf('%s\n',filelist(i).name(1));
%     if strcmp(filelist(i).name(1),'b')
% %         fprintf('Behaviour stats\n');
%         % Load the file
%         % Run it through the objecive functions
%         % If the result is 0, store the full file path and the crypt
%         fullpath = [filelist(i).folder,'/',filelist(i).name];
%         data = csvread(fullpath);
%         for j = 1:9
% %             fprintf('Applying objective function %s\n',func2str(f));
%             f = objectives{j};
% %             fprintf('Objective value %g\n',f(data));
%             if f(data) == 0
%                 optimals{end+1,1} = fullpath;
%                 optimals{end,2} = f;
%                 fprintf('Objective value %g\n',f(data));
%                 fprintf('Optimal for %s\n', func2str(f));
%             end
%         end
%     end
% end

% load('optimals.mat');

% params = [0,0,0,0,0,0,0,0];
% for i = 1:length(optimals)
%     t = split(optimals{i,1},'/');
%     s = split(t{10},'_');
%     if length(s{7}) > 2 % At least a 3 digit number
%         t = split(t{9},'_');
%         % t =
% 
%         %   15×1 cell array
% 
%         %     {'params'}
%         %     {'cct'   }
%         %     {'11.564'}
%         %     {'ees'   }
%         %     {'230'   }
%         %     {'ms'    }
%         %     {'410'   }
%         %     {'n'     }
%         %     {'34.1'  }
%         %     {'np'    }
%         %     {'12.3'  }
%         %     {'vf'    }
%         %     {'0.656' }
%         %     {'wt'    }
%         %     {'8.1'   }
%         t = [str2num(t{9}),str2num(t{11}),str2num(t{5}),str2num(t{7}),str2num(t{3}),str2num(t{15}),str2num(t{13}), getCryptNumber(optimals{i,2})];
%         params(i,:) = t;
%     end
% end

[P,q,r] = unique(params,'rows');

O1 = sortrows(P(P(:,8)==1,1:7),5);
O2 = sortrows(P(P(:,8)==2,1:7),5);
O3 = sortrows(P(P(:,8)==3,1:7),5);
O4 = sortrows(P(P(:,8)==4,1:7),5);
O5 = sortrows(P(P(:,8)==5,1:7),5);
O6 = sortrows(P(P(:,8)==6,1:7),5);
O7 = sortrows(P(P(:,8)==7,1:7),5);
O8 = sortrows(P(P(:,8)==8,1:7),5);

% The optimal points stripped of too many close ones
PO1 = stripTooClose(O1);
PO2 = stripTooClose(O2);
PO3 = stripTooClose(O3);
PO4 = stripTooClose(O4);
PO5 = stripTooClose(O5);
PO6 = stripTooClose(O6);
PO7 = stripTooClose(O7);
PO8 = stripTooClose(O8);

function PO8 = stripTooClose(O8)

    % Strips out optimal points that are too close together

    % Find the norm of the distance between each optimal point
    % Give the stiffness and adhesion a lower weight because if ms = 100
    % is optimal, then ms = 1000 will too, without need to modify the other params
    % This could be considered a pop up limit if anoikis is uniformly zero

    % Normalise the values to the maximum value in the column in order to find the 
    % Maximum distances between points using the euclidean norm
    SO8 = O8./max(O8);

    weight = [1,1,0.8,0.2,1,1,0.5];
    for i = 1:size(SO8,1)
        for j = i:size(SO8,1)
            XSO8(i,j) = norm(  ( SO8(i,:) - SO8(j,:) ).* weight  );
        end
    end

    % XSO8 will be diagonal, and the irrelevant entries will be zero
    % so to avoid them getting caught by the min function, set them
    % all to nans
    XSO8(XSO8==0) = nan;

    % Find the value and location of the smallest distances
    [M,I] = min(XSO8,[],'all','linear');

    while M < 0.25
        old1 = ceil(I/size(XSO8,1));
        old2 = mod(I,size(XSO8,1));
        
        if old2 == 0
            old2 = size(XSO8,1);
        end

        % Randomly choose one of the points to be deleted
        % and remove the distance rows and columns depending on that
        try
            if rand > 0.5
                SO8(old2,:) = [];
                XSO8(old2,:) = [];
                XSO8(:,old2) = [];
            else
                SO8(old1,:) = [];
                XSO8(old1,:) = [];
                XSO8(:,old1) = [];
            end
        catch
            SO8
            XSO8
            old1
            old2
            error('sdfsa')
        end
        
        % Find the new minimum
        [M,I] = min(XSO8,[],'all','linear');
    end

    % Rescale back to the normal range
    PO8 = SO8 .* max(O8);
    PO8(:,[1,2,5,6]) = round(PO8(:,[1,2,5,6]),1);
    PO8(:,[3,4]) = round(PO8(:,[3,4]));
    PO8(:,7) = round(PO8(:,7),3);
    
    PO8 = sortrows(PO8);

end

% If these new ones are in the optimal file already, don't add
% If the new ones are too close, get rid of them too
rootdir = '/Users/phillipbrown/Research/Crypt/Chaste_models/ChasteMembrane/optimal/';
temp{1} = PO1;
temp{2} = PO2;
temp{3} = PO3;
temp{4} = PO4;
temp{5} = PO5;
temp{6} = PO6;
temp{7} = PO7;
temp{8} = PO8;
for i = 1:8
    file = [rootdir, getCryptName(i), '.txt'];
    currentParams = csvread(file);
    t = temp{i};
    for j = 1:size(t,1)
        if ~ismember(t(j,:),currentParams,'rows')
            currentParams(end+1,:) = t(j,:);
        end
    end
    CP{i} = currentParams;
end

% Use kmeans clustering to find the centroid of the optimal points
% since there are several hundered optimal points, and many of them
% are probably in the same basin
% THIS IS DONE, DON'T NEED TO DO IT AGAIN. HERE AS A RECORD

% [~,C1,~] = kmeans(O1, 34);
% [~,C2,~] = kmeans(O2, 5);
% [~,C3,~] = kmeans(O3, 5);
% [~,C4,~] = kmeans(O4, 24);
% [~,C5,~] = kmeans(O5, 5);
% % [~,C6,~] = kmeans(O6, 10);
% [~,C7,~] = kmeans(O7, 5);
% [~,C8,~] = kmeans(O8, 10);

% for i = 1:length(C1)
%     for j = i+1:length(C1)
%         XC1(i,j) = norm( (C1(i,:) - C1(j,:))./max(C1).* [1,1,0.8,0.2,1,1,1] );
%     end
% end
% XC1(XC1==0) = nan;
% [M,I] = min(XC1,[],'all','linear');

% while M < 0.2
%     old1 = ceil(I/size(XC1,1));
%     old2 = mod(I,size(XC1,1));
    
%     new = mean( [C1(old1,:); C1(old2,:)] );
%     C1(old1,:) = new;
%     C1(old2,:) = [];
    
%     XC1 = [];
%     for i = 1:length(C1)
%         for j = i+1:length(C1)
%             XC1(i,j) = norm( (C1(i,:) - C1(j,:))./max(C1).* [1,1,0.8,0.2,1,1,1] );
%         end
%     end
%     XC1(XC1==0) = nan;
%     [M,I] = min(XC1,[],'all','linear');
% end

% DC1 = C1;
% DC1(:,[1,2,5,6]) = round(DC1(:,[1,2,5,6]),1);
% DC1(:,[3,4]) = round(DC1(:,[3,4]));
% DC1(:,7) = round(DC1(:,7),3)





% Search through the centroids to find the set of points that are at least 0.2 scaled distance apart
% [~,C8,~] = kmeans(O8, 20);
% for i = 1:length(C8)
%     for j = i+1:length(C8)
%         XC8(i,j) = norm( (C8(i,:) - C8(j,:))./max(O8).* [1,1,0.8,0.2,1,1,1] );
%     end
% end
% XC8(XC8==0) = nan;
% [M,I] = min(XC8,[],'all','linear');

% while M < 0.2
%     old1 = ceil(I/size(XC8,1));
%     old2 = mod(I,size(XC8,1));
    
%     new = mean( [C8(old1,:); C8(old2,:)] );
%     C8(old1,:) = new;
%     C8(old2,:) = [];
    
%     XC8 = [];
%     for i = 1:size(C8,1)
%         for j = i+1:size(C8,1)
%             XC8(i,j) = norm( (C8(i,:) - C8(j,:))./max(O8).* [1,1,0.8,0.2,1,1,1] );
%         end
%     end
%     XC8(XC8==0) = nan;
%     [M,I] = min(XC8,[],'all','linear');
% end

% DC8 = C8;
% DC8(:,[1,2,5,6]) = round(DC8(:,[1,2,5,6]),1);
% DC8(:,[3,4]) = round(DC8(:,[3,4]));
% DC8(:,7) = round(DC8(:,7),3)
