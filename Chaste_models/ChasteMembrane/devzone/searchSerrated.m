rootdir = [getenv('HOME'),'/Research/Crypt/Data/Chaste/TestCryptColumn/'];
filelist = dir(fullfile(rootdir, '**/*.*'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);

fprintf('Found %d files', length(filelist));
serrated = {};

for i = 1:length(filelist)
%     fprintf('%s\n',filelist(i).name(1));
    if strcmp(filelist(i).name(1),'b')
%         fprintf('Behaviour stats\n');
        % Load the file
        % Run it through the objecive functions
        % If the result is 0, store the full file path and the crypt
        fullpath = [filelist(i).folder,'/',filelist(i).name];
        data = csvread(fullpath);
        if data(1) >= 0.05
            fprintf('Found a set with serrations');
            serrated{end+1,1} = fullpath;
            serrated{end,2} = 1;
        end
    end
end

fprintf('Found a total of %d serrated crypts',length(serrated));

% load('serrated.mat');

params = [0,0,0,0,0,0,0,0];
for i = 1:length(serrated)
    t = split(serrated{i,1},'/');
    s = split(t{10},'_');
    if length(s{7}) > 2 % At least a 3 digit number
        t = split(t{9},'_');
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
        t = [str2num(t{9}),str2num(t{11}),str2num(t{5}),str2num(t{7}),str2num(t{3}),str2num(t{15}),str2num(t{13})];
        params(i,:) = t;
    end
end

[P,q,r] = unique(params,'rows');

S = sortrows(P);

save(serrated,'serrated.mat');
save(P, 'serratedParams.mat');
