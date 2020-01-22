function stepFromOptimal(crypt, nM, npM, eesM, msM, cctM, wtM, vfM)

    cryptName = getCryptName(crypt);
    params = getNewCryptParams(crypt, 1);
    n = params(1);
    np = params(2);
    ees = params(3);
    ms = params(4);
    cct = params(5);
    wt = params(6);
    vf = params(7);
    
    outputTypes = behaviourData();
	simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf'}, {n*nM, np*npM, ees*eesM, ms*msM, cct*cctM, wt*wtM, vfM*vf});
    solverParams = containers.Map({'t', 'bt', 'dt'}, {1000, 100, 0.0005});
    seedParams = containers.Map({'run'}, {1});
    if verifyParams(n,np,ees,ms,cct,wt,vf,nM,npM,eesM,msM,cctM,wtM,vfM)
        fprintf('Parameters are valid, starting simulation\n');
        sim = simulateCryptColumn(simParams, solverParams, seedParams, outputTypes);
        sim.generateSimulationData();
    else
        fprintf('Parameters invalid. Stopping.\n');
    end
end

function physical = verifyParams(n,np,ees,ms,cct,wt,vf,nM,npM,eesM,msM,cctM,wtM,vfM)
    % Need to make sure the parameters are physically possible
    physical = true;
    if wtM*wt < 2
        % The minimum we can have is a growing time of 2
        physical = false;
    else
        if wtM*wt > cctM*cct - 2
            % wt must be at least 2 hours less than cct
            physical = false;
        end
    end

    if npM*np > nM*n - 4
        % Need at least some space where the crypt has differentiated cells
        physical = false;
    end
    
    if vfM*vf >1
        % Makes no sense for CI volume fraction to be greater than 1
        physical = false;
    end
end

