function modifiers = makeStepParams()

    % This function takes a crypt type and produces a set of parameters
    % representing progressive steps from the 'optimal' as determined by the
    % surrogate method. The crypt type argument is because some crypts need the
    % ranges specially modified to prevent unphysical combinations

    % It specifes the range of the parameters and creates parameters sets
    % for each combination, thereby exploring a 7-rectangular region about
    % the point.

    % The range that the modifiers can fall in
    RnM = 0.8:0.1:1.2;
    RnpM = 0.8:0.1:1.2;
    ReesM = 0.8:0.1:1.2;
    RmsM = 0.8:0.1:1.2;
    RcctM = 0.8:0.1:1.2;
    RwtM = 0.8:0.1:1.2;
    RvfM = 0.8:0.1:1.2;
   
    modifiers = [];

    for nM = RnM
        for npM = RnpM
            for eesM = ReesM
                for msM = RmsM
                    for cctM = RcctM
                        for wtM = RwtM
                            for vfM = RvfM
                                modifiers = [modifiers;nM,npM,eesM,msM,cctM,wtM,vfM];
                            end
                        end
                    end
                end
            end
        end
    end


    modifiers = unique(modifiers, 'rows');
    
    csvwrite('phoenix/BasinSweep/modifiers.txt', modifiers);

end


