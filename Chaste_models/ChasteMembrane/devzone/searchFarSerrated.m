rootdir = [getenv('HOME'),'/Research/Crypt/Data/Chaste/TestCryptColumn/'];
filelist = dir(fullfile(rootdir, '**/*.*'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);

fprintf('Found %d files\n', length(filelist));
serrated = {};

for i = 1:length(filelist)
%     fprintf('%s\n',filelist(i).name(1));
    a1 = split(filelist(i).name, '.');
    a2 = split(a1{1},'_');
    if strcmp(filelist(i).name(1),'b')
        if strcmp(a2{3},'1')
%         fprintf('Behaviour stats\n');
            % Load the file
            % Run it through the objecive functions
            % If the result is 0, store the full file path and the crypt
            fullpath = [filelist(i).folder,'/',filelist(i).name];
            data = csvread(fullpath);
            if data(1) >= 0.09
                fprintf('Found a set with serrations\n');
                serrated{end+1,1} = fullpath;
                serrated{end,2} = data(1);
            end
        end
    end
    if mod(i,1000) == 0
        fprintf('%.1f%% Complete\n',100*i/length(filelist));
    end
end

fprintf('Found a total of %d serrated crypts\n',length(serrated));

% load('serrated.mat');

params = [];
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
        t = [str2num(t{9}),str2num(t{11}),str2num(t{5}),str2num(t{7}),str2num(t{3}),str2num(t{15}),str2num(t{13}),serrated{i,2}];
        params(i,:) = t;
    end
end

[P,q,r] = unique(params,'rows');

S = sortrows(P);

AllS = {};
for i=1:8
    for j=1:27
        S = sortrows(P);
        try
            oParams = getOptimalParams(i, j);
            oParams(end+1) = 0;
            diff = [0.1,0.1,0.2,0.2,0.2,0.2,0.2,1];
            diffParams = diff.*oParams;
            XS = abs(S - oParams);
            
            % Select only the parameter sets that are a minimum of 10% away
            S = S(XS(:,1) > diffParams(1),:);
            XS = XS(XS(:,1) > diffParams(1),:);
            
            S = S(XS(:,1) < 2 * diffParams(1),:);
            XS = XS(XS(:,1) < 2 * diffParams(1),:);
            
            S = S(XS(:,2) > diffParams(2),:);
            XS = XS(XS(:,2) > diffParams(2),:);
            
            S = S(XS(:,3) > diffParams(3),:);
            XS = XS(XS(:,3) > diffParams(3),:);
            
            S = S(XS(:,4) > diffParams(4),:);
            XS = XS(XS(:,4) > diffParams(4),:);
            
            S = S(XS(:,5) > diffParams(5),:);
            XS = XS(XS(:,5) > diffParams(5),:);
            
            S = S(XS(:,6) > diffParams(6),:);
            XS = XS(XS(:,6) > diffParams(6),:);
            
            S = S(XS(:,7) > diffParams(7),:);
            XS = XS(XS(:,7) > diffParams(7),:);
            % Don't apply this method to the last value because that is the
            % associated anoikis rate measurement
            AllS{i,j} = S;
        end
        
        
    end
end

for i=1:8
    for j=1:27
        XSAllS = [];
        try
            oParams = getOptimalParams(i, j);
            oParams(end+1) = 1;
            SAllS = AllS{i,j};
            SAllS = SAllS(:,1:7)./max(SAllS(:,1:7));
            weight = [2,1,0.1,0.1,0.3,0.3,0.8];
            for k=1:size(SAllS,1)
                for l = k+1:size(SAllS,1)
                    XSAllS(k,l) = norm( (SAllS(k,:) - SAllS(l,:)).*weight );
                end
            end
            
            [M,I] = max(XSAllS,[],'all','linear');
            
            I1 = ceil(I/size(SAllS,1));
            I2 = mod(I,size(SAllS,1));
            
            if I2 == 0
                I2 = size(SAllS,1);
            end
            
            Sets{i,j} = [AllS{i,j}(I1,:);AllS{i,j}(I2,:)];
        end
    end
end


for i = 1:8
filename = getCryptName(i);
data1 = [];
data2 = [];
try
for j = 1:20
data1 = [data1; Set{i,j}(1,:)];
data2 = [data2; Set{i,j}(2,:)];
end
end
csvwrite([filename,'_1.txt'], data1);
csvwrite([filename,'_2.txt'], data2);
end