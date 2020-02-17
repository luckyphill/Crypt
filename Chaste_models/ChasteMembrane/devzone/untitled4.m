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
for i = 1:length(optimals)
    optimals{i,1} = optimals{i,1}(1:96);
end



params = [0,0,0,0,0,0,0,0];
for i = 1:length(optimals)
    t = split(optimals{i,1},'/');
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

[P,q,r] = unique(params,'rows');

O1 = P(P(:,8)==1,:);
O2 = P(P(:,8)==2,:);
O3 = P(P(:,8)==3,:);
O4 = P(P(:,8)==4,:);
O5 = P(P(:,8)==5,:);
O6 = P(P(:,8)==6,:);
O7 = P(P(:,8)==7,:);
O8 = P(P(:,8)==8,:);
O9 = P(P(:,8)==9,:);


