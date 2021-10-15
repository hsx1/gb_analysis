function gb_swe_action(crun)
%GB_SWE_ACTION  Run SwE analysis for a specific configuration setting.
%Runs SPM and SwE toolbox.
% 
%     GB_SWE_ACTION(CRUN) specifies configuration setting for current run of SwE 
%     toolbox within a struct.
% 
%     Called by gb_process_run(), uses funtion of SwE toolbox.
%     Author: Hannah Sophie Heinrichs <heinrichs@cbs.mpg.de>

% - for debugging - 
% crun.OUT_DIR
% - - - - - - - - -
if crun.ACTION == "display" 
    if is_estimated(crun)
        fprintf("Access folder to display results...\n\t%s\n", crun.OUT_DIR)
        display_and_view(crun)
    elseif is_interrupted(crun)
        fprintf("No viable results in\n\t%s\n%s.\nPlease select 'estimate'.\n", crun.OUT_DIR)
    else
        fprintf("No results in\n\t%s\n%s.\nPlease select 'estimate'.\n", crun.OUT_DIR)
    end
elseif crun.ACTION == "estimate" 
    if is_estimated(crun)
        fprintf("Model has already been estimated in\n\t%s\nSkipping...", crun.OUT_DIR)
    elseif is_interrupted(crun)
        fprintf("Previous estimations has been interrupted.\n\tOverwriting folder...\n\t%s\n", crun.OUT_DIR)
        overwrite_estimation(crun)
    else
        fprintf("Initializing estimation...\n\t%s\n", crun.OUT_DIR)
        regular_estimation(crun)
    end
elseif crun.ACTION == "overwrite" 
    if is_estimated(crun) || is_interrupted(crun)
        fprintf("Overwriting existing results...\n\t%s\n", crun.OUT_DIR)
        overwrite_estimation(crun)
    else
        fprintf("Initializing estimation...\n\t%s\n", crun.OUT_DIR)
        regular_estimation(crun)
    end
else
    fprintf("%s is not a valid action. Please select 'estimate', 'overwrite' or 'display'.", crun.ACTION)
end

end


function [estimated] = is_estimated(crun)
    % check if directory exists and if it contains more than two files and
    % none of them are temporary files that contain "fit_y"
    estimated = exist(crun.OUT_DIR, 'dir') && length(dir(crun.OUT_DIR)) > 2 && isempty(dir(fullfile(crun.OUT_DIR, "*fit_y*")));
end

function [interrupted] = is_interrupted(crun)
    % check if the directory exist but still contains temporary files
    interrupted = exist(crun.OUT_DIR, 'dir') && ~isempty(dir(fullfile(crun.OUT_DIR, "*fit_y*")));
end

function regular_estimation(crun)
    [status, msg] = mkdir(crun.OUT_DIR);
    clear matlabbatch
    spm('defaults', 'FMRI');
    matlabbatch = gb_mkbatch(crun);
    fprintf("REGULAR ESTIMATION OF %s", crun.OUT_DIR)
    spm_jobman('run', matlabbatch)
end

function overwrite_estimation(crun)
    rmdir(crun.OUT_DIR, 's')
    mkdir(crun.OUT_DIR)
    clear matlabbatch
    spm('defaults', 'FMRI');
    matlabbatch = gb_mkbatch(crun);
    fprintf("OVERWRITING OF %s", crun.OUT_DIR)
    spm_jobman('run', matlabbatch)
end

function display_and_view(crun)
    cd(crun.OUT_DIR)
    [hReg,xSwE,SwE] = swe_results_ui("Setup"); % calls SwE Gui directly
    gb_spm2csv(hReg,xSwE);
    if crun.VIEW
        h=questdlg('Please press OK to continue or Pause to inspect.','Proceed','OK','Pause','OK');
        switch h
            case 'OK'
                return
            case 'Pause'
                b = inputdlg('How long to you want to pause (sec)?','Pause',1,{'60'});
                b = str2double(b);
                pause(b)
            otherwise
                return
        end
    end
end
