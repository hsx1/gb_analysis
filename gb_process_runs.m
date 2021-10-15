function gb_process_runs(runs, process_parallel)
%GB_PROCESS_RUNS  Determines whether computations are parallelized or 
%sequential
% 
%     GB_PROCESS_RUNS(RUNS,...) is a list containing one struct of each 
%     input configuration for the SwE toolbox.
% 
%     GB_PROCESS_RUNS(...,PARALLEL) is a bool.
%       true  - initializes parallel processing for different configuration
%               settings in RUNS.
%       false - starts sequential processing of all configuration settings in 
%               RUNS.
% 
%     GB_PROCESS_RUNS is called by gb_config()
%     Author: Hannah Sophie Heinrichs <heinrichs@cbs.mpg.de>

if nargin < 2
    process_parallel = false;
end
fprintf("Total number of runs: %i.\n", length(runs))

i = 0;
if process_parallel
    % parallel processing
    parfor i = 1:length(runs)
        fprintf("* * * * * * * * * * * * * * * * * * * *\nProcessing run %i/%i ...\n* * * * * * * * * * * * * * * * * * * *\n", i, length(runs))
        crun = runs(i);
        gb_swe_action(crun)
    end
else
    % sequential processing
    for i = 1:length(runs)
        fprintf("* * * * * * * * * * * * * * * * * * * *\n\nProcessing run %i/%i ...\n\n* * * * * * * * * * * * * * * * * * * *\n", i, length(runs))
        crun = runs(i);
        gb_swe_action(crun)
    end
end
%quit_matlab(i, runs)
%exit

end

function quit_matlab(number_crun, runs)
    crun = runs(number_crun);
    if number_crun == length(runs) && not(crun.ACTION == "display")
        fprintf("Completed estimation. Quit SPM and exit MATLAB...\n")
    end
end
