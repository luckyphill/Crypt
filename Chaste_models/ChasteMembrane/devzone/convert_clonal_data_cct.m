
mutfile = '/Users/phillipbrown/Research/Crypt/Chaste_models/ChasteMembrane/phoenix/MutationSweep/mutation_sweep_cct.txt';
mutations = csvread(mutfile);

old_path = '/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterOptimisation/TestCryptColumnClonal/MouseColonDescMutations/';

simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});
mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {1,12,1,1,1,1,0.675});
solverParams = containers.Map({'t', 'bt', 'dt'}, {400, 40, 0.001});
seedParams = containers.Map({'run'}, {1});
outputTypes = clonalData;

chastePath = [getenv('HOME'), '/'];
chasteTestOutputLocation = '/tmp/phillipbrown/';

runs = 100;
i=1;
j=1;
for i = 1:length(mutations)
    for j = 1:runs
        seedParams = containers.Map({'run'}, {j});

        mutantParams('cctM') = mutations(i);
        mutantParams('wtM') = mutations(i);
        sim = simulateCryptColumnMutation(simParams, mutantParams, solverParams, seedParams, outputTypes, chastePath, chasteTestOutputLocation);
        new_file = sim.outputTypes{1}.getFullFileName(sim);
        
        old_file = [old_path, 'parameter_search_t_400_n_29_np_12_ees_58_ms_216_vf_0.675_cct_15_wt_9_dt_0.001_cctM_', num2str(mutations(i)),'_wtM_', num2str(mutations(i)),'_run_',num2str(j),'.txt'];
        [~,~] = system(['cp ', old_file, ' ', new_file]);
    end
end


        
        
        
        