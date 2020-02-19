% % rootdir = '/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumn/';
% % filelist = dir(fullfile(rootdir, '**/*.*'));  %get list of files and folders in any subfolder
% % filelist = filelist(~[filelist.isdir]);
% 
% % objectives = {@MouseColonAsc, @MouseColonTrans, @MouseColonDesc, @MouseColonCaecum,...
% %                 @RatColonAsc, @RatColonTrans, @RatColonDesc, @RatColonCaecum, @HumanColon};
% % 
% % optimals = {};
% % 
% % for i = 1:205425
% % %     fprintf('%s\n',filelist(i).name(1));
% %     if strcmp(filelist(i).name(1),'b')
% % %         fprintf('Behaviour stats\n');
% %         % Load the file
% %         % Run it through the objecive functions
% %         % If the result is 0, store the full file path and the crypt
% %         fullpath = [filelist(i).folder,'/',filelist(i).name];
% %         data = csvread(fullpath);
% %         for j = 1:9
% % %             fprintf('Applying objective function %s\n',func2str(f));
% %             f = objectives{j};
% % %             fprintf('Objective value %g\n',f(data));
% %             if f(data) == 0
% %                 optimals{end+1,1} = fullpath;
% %                 optimals{end,2} = f;
% %                 fprintf('Objective value %g\n',f(data));
% %                 fprintf('Optimal for %s\n', func2str(f));
% %             end
% %         end
% %     end
% % end
% 
% load('optimals.mat');
% 
% params = [0,0,0,0,0,0,0,0];
% for i = 1:length(optimals)
%     t = split(optimals{i,1},'/');
%     s = split(t{2},'_');
%     if length(s{7}) > 2 % At least a 3 digit number
%         t = split(t{1},'_');
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
%         t = [str2num(t{9}),str2num(t{11}),str2num(t{5}),str2num(t{7}),str2num(t{3}),str2num(t{15}),str2num(t{13}), getFuncNumber(optimals{i,2})];
%         params(i,:) = t;
%     end
% end
% 
% [P,q,r] = unique(params,'rows');
% 
% O1 = sortrows(P(P(:,8)==1,1:7),5);
% O2 = sortrows(P(P(:,8)==2,1:7),5);
% O3 = sortrows(P(P(:,8)==3,1:7),5);
% O4 = sortrows(P(P(:,8)==4,1:7),5);
% O5 = sortrows(P(P(:,8)==5,1:7),5);
% O6 = sortrows(P(P(:,8)==6,1:7),5);
% O7 = sortrows(P(P(:,8)==7,1:7),5);
% O8 = sortrows(P(P(:,8)==8,1:7),5);
% 
% % Normalise the values to th emaximum value in the column in order to find the 
% % Maximum distances between points using the euclidean norm`
% SO1 = O1./max(O1);
% SO2 = O2./max(O2);
% SO3 = O3./max(O3);
% SO4 = O4./max(O4);
% SO5 = O5./max(O5);
% SO6 = O6./max(O6);
% SO7 = O7./max(O7);
% SO8 = O8./max(O8);
% 
% 
% [~,C1,~] = kmeans(O1, 34);
% [~,C2,~] = kmeans(O2, 5);
% [~,C3,~] = kmeans(O3, 5);
% [~,C4,~] = kmeans(O4, 24);
% [~,C5,~] = kmeans(O5, 5);
% % [~,C6,~] = kmeans(O6, 10);
% [~,C7,~] = kmeans(O7, 5);
% [~,C8,~] = kmeans(O8, 10);
% 
% for i = 1:length(C1)
%     for j = i+1:length(C1)
%         XC1(i,j) = norm( (C1(i,:) - C1(j,:))./max(C1).* [1,1,0.8,0.2,1,1,1] );
%     end
% end
% XC1(XC1==0) = nan;
% [M,I] = min(XC1,[],'all','linear');
% 
% while M < 0.2
%     old1 = ceil(I/size(XC1,1));
%     old2 = mod(I,size(XC1,1));
%     
%     new = mean( [C1(old1,:); C1(old2,:)] );
%     C1(old1,:) = new;
%     C1(old2,:) = [];
%     
%     XC1 = [];
%     for i = 1:length(C1)
%         for j = i+1:length(C1)
%             XC1(i,j) = norm( (C1(i,:) - C1(j,:))./max(C1).* [1,1,0.8,0.2,1,1,1] );
%         end
%     end
%     XC1(XC1==0) = nan;
%     [M,I] = min(XC1,[],'all','linear');
% end
% 
% DC1 = C1;
% DC1(:,[1,2,5,6]) = round(DC1(:,[1,2,5,6]),1);
% DC1(:,[3,4]) = round(DC1(:,[3,4]));
% DC1(:,7) = round(DC1(:,7),3)






[~,C8,~] = kmeans(O8, 20);
for i = 1:length(C8)
    for j = i+1:length(C8)
        XC8(i,j) = norm( (C8(i,:) - C8(j,:))./max(O8).* [1,1,0.8,0.2,1,1,1] );
    end
end
XC8(XC8==0) = nan;
[M,I] = min(XC8,[],'all','linear');

while M < 0.2
    old1 = ceil(I/size(XC8,1));
    old2 = mod(I,size(XC8,1));
    
    new = mean( [C8(old1,:); C8(old2,:)] );
    C8(old1,:) = new;
    C8(old2,:) = [];
    
    XC8 = [];
    for i = 1:size(C8,1)
        for j = i+1:size(C8,1)
            XC8(i,j) = norm( (C8(i,:) - C8(j,:))./max(O8).* [1,1,0.8,0.2,1,1,1] );
        end
    end
    XC8(XC8==0) = nan;
    [M,I] = min(XC8,[],'all','linear');
end

DC8 = C8;
DC8(:,[1,2,5,6]) = round(DC8(:,[1,2,5,6]),1);
DC8(:,[3,4]) = round(DC8(:,[3,4]));
DC8(:,7) = round(DC8(:,7),3)
