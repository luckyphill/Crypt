% DO NOT USE!!!!!!
% This was needed for a short script an some how I got the numbers completely wrong
% Use, or modify the numbering in getCryptName

function number = getFuncNumber(I)
    I = func2str(I);
    switch I
        case 'MouseColonAsc'
            number = 1;
        case 'MouseColonTrans'
            number = 2;
        case 'MouseColonDesc'
            number = 3;
        case 'MouseColonCaecum'
            number = 4;
        case 'RatColonAsc'
            number = 5;
        case 'RatColonTrans'
            number = 6;
        case 'RatColonDesc'
            number = 7;
        case 'RatColonCaecum'
            number = 8;
        case 'HumanColon'
            number = 9;
        otherwise
            error('Parameter type not found');
    end
end