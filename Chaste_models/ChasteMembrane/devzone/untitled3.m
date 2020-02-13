for a=1:5
    for b=1:5
        for c=1:5
            for d=1:5
                for e=1:5  
                    for I = 1:6
                        for J = (I+1):7
                            A = {a,b,c,d,e};
                            A = {A{1:(I-1)},1:5,A{I:end}};
                            A = {A{1:(J-1)},1:5,A{J:end}};
                            
                            space = squeeze(penalty(A{1},A{2},A{3},A{4},A{5},A{6},A{7}));
                            if nnz(space) < 25
                                A
                            end
                            
                            
                        end
                    end
                end
            end
        end
    end
end


                            
                            
                            
                    
                    