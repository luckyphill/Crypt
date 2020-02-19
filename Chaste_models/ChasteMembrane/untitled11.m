
modifiers = [];
for a = 1:7
    for b = 0.5:0.01:1.5
        mods = ones(1,7);
        mods(a) = b;
        modifiers = [modifiers; mods];
    end
end

modifiers = unique(modifiers, 'rows');
    
csvwrite('phoenix/BasinSweep/modifiersShort.txt', modifiers);
        
        