
chastePath =  [getenv('HOME'),'/'];
mutfile = [getenv('HOME'),'/Research/Crypt/Chaste_models/ChasteMembrane/phoenix/MutationSweep/mutation_sweep_cct.txt'];
mutations = readtable(mutfile);

old_path = [getenv('HOME'),'/Research/Crypt/Data/Chaste/ParameterOptimisation/TestCryptColumnClonal/MouseColonDescMutations/'];

simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});
mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {1,12,1,1,1,1,0.675});
solverParams = containers.Map({'t', 'bt', 'dt'}, {400, 40, 0.001});
seedParams = containers.Map({'run'}, {1});
outputTypes = clonalData;


chasteTestOutputLocation = '/tmp/phillipbrown/';

runs = 100;

for i = 1:height(mutations)
    for j = 1:runs
        seedParams = containers.Map({'run'}, {j});
        temp = mutations.Var1(i);
        mutation = temp{1};
        mutantParams(mutation) = mutations.Var2(i);
        sim = simulateCryptColumnMutation(simParams, mutantParams, solverParams, seedParams, outputTypes, chastePath, chasteTestOutputLocation);
        new_file = sim.outputTypes{1}.getFullFileName(sim);
        
        old_file = [old_path, 'parameter_search_t_400_n_29_np_12_ees_58_ms_216_vf_0.675_cct_15_wt_9_dt_0.001_',mutation,'_', num2str(mutations.Var2(i)),'_run_',num2str(j),'.txt'];
        [~,~] = system(['cp ', old_file, ' ', new_file]);
    end
end


        
        
        
        