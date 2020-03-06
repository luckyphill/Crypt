% rootdir = [getenv('HOME'),'/Research/Crypt/Data/Chaste/TestCryptColumn/'];
% filelist = dir(fullfile(rootdir, '**/*.*'));  %get list of files and folders in any subfolder
% filelist = filelist(~[filelist.isdir]);
% 
% fprintf('Found %d files\n', length(filelist));
% serrated = {};
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
%         if data(1) >= 0.09
%             fprintf('Found a set with serrations\n');
%             serrated{end+1,1} = fullpath;
%             serrated{end,2} = data(1);
%         end
%     end
% end

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
        t = [str2num(t{9}),str2num(t{11}),str2num(t{5}),str2num(t{7}),str2num(t{3}),str2num(t{15}),str2num(t{13})];
        params(i,:) = t;
    end
end

[P,q,r] = unique(params,'rows');

S = sortrows(P);
avgOptimal = [];
for i=1:8
    oParams = [];
    for j=1:27
        try
            oParams(end+1,:) = getOptimalParams(i, j);
        end
    end
    avgOptimal(end+1,:) = mean(oParams);
end

XS1 = S - avgOptimal(1,:);
XS2 = S - avgOptimal(2,:);
XS3 = S - avgOptimal(3,:);
XS4 = S - avgOptimal(4,:);
XS5 = S - avgOptimal(5,:);
XS6 = S - avgOptimal(6,:);
XS7 = S - avgOptimal(7,:);
XS8 = S - avgOptimal(8,:);

DXS1 = vecnorm(XS1(:,[1,2,5,6]) ,2,2);
DXS2 = vecnorm(XS2(:,[1,2,5,6]) ,2,2);
DXS3 = vecnorm(XS3(:,[1,2,5,6]) ,2,2);
DXS4 = vecnorm(XS4(:,[1,2,5,6]) ,2,2);
DXS5 = vecnorm(XS5(:,[1,2,5,6]) ,2,2);
DXS6 = vecnorm(XS6(:,[1,2,5,6]) ,2,2);
DXS7 = vecnorm(XS7(:,[1,2,5,6]) ,2,2);
DXS8 = vecnorm(XS8(:,[1,2,5,6]) ,2,2);

DXS = [DXS1,DXS2,DXS3,DXS4,DXS5,DXS6,DXS7,DXS8];


[M,I] = min(DXS,[],2);

S1 = S(I==1,:);
S2 = S(I==2,:);
S3 = S(I==3,:);
S4 = S(I==4,:);
S5 = S(I==5,:);
S6 = S(I==6,:);
S7 = S(I==7,:);
S8 = S(I==8,:);
% save(P, 'serratedParams.mat');

closest1 = getClosest(1, S1);
closest2 = getClosest(2, S2);
closest3 = getClosest(3, S3);
closest4 = getClosest(4, S4);
closest5 = getClosest(5, S5);
closest6 = getClosest(6, S6);
closest7 = getClosest(7, S7);
closest8 = getClosest(8, S8);


[~,C1,~] = kmeans(S1, 5);
[~,C2,~] = kmeans(S2, 1);
[~,C3,~] = kmeans(S3, 4);
[~,C4,~] = kmeans(S4, 3);
[~,C5,~] = kmeans(S5, 7);
[~,C6,~] = kmeans(S6, 2);
[~,C7,~] = kmeans(S7, 2);
[~,C8,~] = kmeans(S8, 7);

DC1 = [round(C1(:,[1,2,]),1),round(C1(:,[3,4])),round(C1(:,[5,6]),1),round(C1(:,7),3)];
DC2 = [round(C2(:,[1,2,]),1),round(C2(:,[3,4])),round(C2(:,[5,6]),1),round(C2(:,7),3)];
DC3 = [round(C3(:,[1,2,]),1),round(C3(:,[3,4])),round(C3(:,[5,6]),1),round(C3(:,7),3)];
DC4 = [round(C4(:,[1,2,]),1),round(C4(:,[3,4])),round(C4(:,[5,6]),1),round(C4(:,7),3)];
DC5 = [round(C5(:,[1,2,]),1),round(C5(:,[3,4])),round(C5(:,[5,6]),1),round(C5(:,7),3)];
DC6 = [round(C6(:,[1,2,]),1),round(C6(:,[3,4])),round(C6(:,[5,6]),1),round(C6(:,7),3)];
DC7 = [round(C7(:,[1,2,]),1),round(C7(:,[3,4])),round(C7(:,[5,6]),1),round(C7(:,7),3)];
DC8 = [round(C8(:,[1,2,]),1),round(C8(:,[3,4])),round(C8(:,[5,6]),1),round(C8(:,7),3)];

csvwrite([getCryptName(1), '.txt'], closest1);
csvwrite([getCryptName(2), '.txt'], closest2);
csvwrite([getCryptName(3), '.txt'], closest3);
csvwrite([getCryptName(4), '.txt'], closest4);
csvwrite([getCryptName(5), '.txt'], closest5);
csvwrite([getCryptName(6), '.txt'], closest6);
csvwrite([getCryptName(7), '.txt'], closest7);
csvwrite([getCryptName(8), '.txt'], closest8);

function closest = getClosest(i, S1)

    % Finds the closest serrated point to each optimal point
    closest = [];
    for j=1:27
        try
            oParams = getOptimalParams(i, j);
            XS1 = S1 - oParams;
            DXS1 = vecnorm(XS1(:,[1,2,5,6]) ,2,2);
            [M,I] = min(DXS1);
            closest(j,:) = S1(I,:);
        end
    end

end


