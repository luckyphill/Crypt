len = 5678;
tLen = 24;
fileNumber = 2;
simName = 'RunBeamMembrane';
paramFile = 'CritcalWiggleRatioBeamMembrane_1.txt';
nRuns = 5;
nInputs = 4;


command = 'sbatch ';
command = [command, sprintf('--array=0-%d ',len)];
command = [command, sprintf('--time=%d:00:00 ',tLen)];
command = [command, sprintf('--err="output/error_%%a.err" ')];
command = [command, sprintf('--output="output/slurm-%%A_%d_%%a.out" ',fileNumber)];
command = [command, sprintf('generalSbatch%d ',nInputs)];
command = [command, sprintf('%s ', simName)];
command = [command, sprintf('%s ', paramFile)];
command = [command, sprintf('%d ', nRuns)];