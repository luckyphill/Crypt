% 
% 
% files = getAllFiles('/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnFullMutation/');
% 
% popupfiles = {};
% 
% for i = 1:length(files)
%     if strcmp(files{i}(end-17:end),'popup_location.txt')
%         % load the data, check if its got any pop ups, store the file
%         % location then move to the next one
%         
%         temp = csvread(files{i});
%         
%         [m, n] = size(temp);
%         
%         if (m > 1 && n > 1)
%             popupfiles{end+1} = files{i};
%         end
%         
%     end
% end


numpops = [];
notmousecolondesc = {};

for i = 1:length(popupfiles)
    if ~strcmp(popupfiles{i}(1:90),'/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnFullMutation/MouseColonDesc/')
        
        notmousecolondesc{end+1} = popupfiles{i};
        temp = csvread(popupfiles{i});

        temp = temp(:,2:end);
        temp = temp(:);
        temp(temp == 0) = [];

        numpops(end+1) = length(temp);
    end
end

            

