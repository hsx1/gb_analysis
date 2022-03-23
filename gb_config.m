function gb_config(preset, action, parprocess)
%GB_CONFIG	Runs SwE models for gut-brain project.
%     
%     GB_CONFIG(PRESET,...) specifies predefined configuration settings for
%     the SwE models. PRESET must be:
%       "prereg"   - Selects only few cases to test the script but not get
%                    interpretable results.
%       "all"      - Tests all configuration settings relevant to gut-brain 
%                    study 
%       "select"   - (default) Select configurations to estimate/display 
%                    via dialog.
%       "manual"   - Test manually, i.e. within script, defined configuration 
%                    settings. Relevant for example for displaying results of a 
%                    selection of estimated models.
%       "nomask"   - no explicit mask
%       "rawmask"  - neurosynthraw mask as explicit mask
%       "peakmask" - neurosynthpeak mask as explicit mask
%       "confound" - Test all models and contrast images for all subjects 
%                    (no exclusion) regarding interaction effect 
%                    considering the confounders age, sex, and SES index
%       "sexes"    - Separated Analyses for male and female
% 
%     GB_CONFIG(..., ACTION) specifies the action carried out by the SwE 
%     toolbox. ACTION must be:
%       "estimate"  - Estimates model if not estimated before.
%       "display"   - (default) Displays results of previously estimated 
%                     model.
%       "overwrite" - Overwrites previously estimated results.
% 
%     GB_CONFIG(..., PARPROCESS) is a bool.
%       false - (default) Starts sequential processing of all configuration
%               settings.
%       true  - Initializes parallel processing for all configuration
%               settings, only relevant or "estimate" or "overwrite".
% 
%     Usage:
%           1. Change to server with sufficient CPU
%           2. Start screen in terminal (make sure to initialize logging of
%           screen output)
%           3. Open MATLAB with matlab -nodisplay -nodesktop
%           4. Change to directory with gb functions
%           4. Call function gb_config
%     
%     Examples:
%           Example 1: Estimate all configurations with parallel processes.
%               gb_config("all", "estimate", true)
%
%           Example 2: Estimate configurations for neurosynthraw mask and
%           overwrite any existing results.
%               gb_config("prereg", "overwrite", true)
%
%           Example 3: Display results of previously estimated analyses for
%           preregistration.
%               gb_config("prereg", "display")
%
%     Information on configuration settings (for detailed information view 
%     source code, beware that number of models will rise expontentially):
%           * max. 5 models
%           * max. 5 different first-level contrast images
%           * 2 potential effects of interest (main effect, interaction effect)
%           * 3 different masks
%           * 6 different input data variations, i.e. exclusion of
%             subjects with compliance problems
%           * 2 for with vs. without confounders
%
%     Author: Hannah Sophie Heinrichs <heinrichs@cbs.mpg.de>

%% usage
% not enough input arguments
if nargin < 3 
    parprocess = false;
    if nargin < 2
        action = "display";
        if nargin < 1
            preset = "select";
        end
    end
end


% for safety
config_param.VIEW = false;

if action == "display"
    shin = input("Displaying results...\nOption to view results for? (yes/No)", 's');
    if strcmp(shin, "yes")
        config_param.VIEW = true;
    end
    parprocess = false;
else
    if action == "overwrite"
        shin = input("Existing folders of model configurations will be overwritten. Proceed? (yes/No)", 's');
        if (~strcmp(shin, "yes"))
            disp("...aborted.");
            return;
        end
    end
    
    if parprocess
        shin = input("Parallel processing is enabled. Proceed? (yes/No)", 's');
        if (~strcmp(shin, "yes"))
            disp("...aborted.");
            return;
        end
    end
end


%% configure paths for SPM (toolboxes)
addpath('/data/pt_02020/MRI_data/software/spm12/toolbox/SwE-toolbox-2.2.2/')  
addpath('/data/pt_02020/MRI_data/software/spm12/')  
addpath('/data/pt_02020/MRI_data/scripts/1_FUNCTIONAL/3_2nd_level_fmri_swe')

%% configure input parameters

config_param.ACTION = action;

% configs of lists and strings
config_param.DATA_DIR = "/data/pt_02020/MRI_data/fmri_wanting_results/1st_level/";
config_param.DESIGNMATRIX_PATH = ...
    "/data/pt_02020/MRI_data/scripts/1_FUNCTIONAL/3_2nd_level_fmri_swe/Design_Matrix_with_all_confounders.csv"; % scans, also to filter design matrix
config_param.OUT_DIR = ...
    "/data/pt_02020/MRI_data/fmri_wanting_results/2nd_level/";
cd(config_param.OUT_DIR)
config_param.CONFOUND = ["no_confound", "incl_confound"]; 
config_param.EXCLUDED = ["allsubs", "excluded_sub-30", ...
    "excluded_sub-47_ses-04", "excluded_sub-30_sub-47_ses-04", ...
    "only_male", "only_female"]; %% adapt for different group of subjects included

config_param.FIRST_LEVEL_CONTRASTS = ["con_0001", "con_0002", "con_0003", "con_0004", "con_0005"]; 

% effects configs
effects_keys = {'interaction', 'main'};
effects_values = {[-1 1 1 -1], [0.25 0.25 0.25 0.25]};
effects_map = containers.Map(effects_keys, effects_values);

% roi configurations
rois_keys = {'nomask',  'neurosynthraw', 'neurosynthpeak'};
rois_values = {'', ...
        '/data/pt_02020/MRI_data/software/ROI_analysis/neurosynth/reward_hypothalamus_merged.nii,1', ...
        '/data/pt_02020/MRI_data/software/ROI_analysis/neurosynth_peak/reward_hypothalamus_merged_spheres_only.nii,1'};
rois_map = containers.Map(rois_keys, rois_values);

% posthoc setting
posthoc_keys = {'SES','FM','VAIAK','PREH','POSTH','WELL', 'FIBER'};
posthoc_values = {'SES_index', 'FM_stand', 'VAIAK_sum', 'hunger_pre_wanting', 'hunger_post_wanting', 'well_being', 'Fibre_per_1000kcal'};
posthoc_map = containers.Map(posthoc_keys, posthoc_values);


%% presets
config_param.SELECT = false;

if preset == "prereg"
    config_param.MODELS = ["modelA","modelB1"]; 
    config_param.FIRST_LEVEL_CONTRASTS = ["con_0001", "con_0002","con_0003"];
    effects_keys = {'interaction'};
    
elseif preset == "nomask"
    config_param.MODELS = ["modelA", "modelB1", "modelB2", "modelC1", "modelC2"];
    config_param.FIRST_LEVEL_CONTRASTS = ["con_0001", "con_0002", "con_0003", "con_0004", "con_0005"]; 
    effects_keys = {'interaction', 'main'};
    rois_keys = {'nomask'};
    
elseif preset == "rawmask"
    config_param.MODELS = ["modelA", "modelB1", "modelB2", "modelC1", "modelC2"]; 
    config_param.FIRST_LEVEL_CONTRASTS = ["con_0001", "con_0002", "con_0003", "con_0004", "con_0005"];
    effects_keys = {'interaction', 'main'};
    rois_keys = {'neurosynthraw'};
    
elseif preset == "peakmask"
    config_param.MODELS = ["modelA", "modelB1", "modelB2", "modelC1", "modelC2"]; 
    config_param.FIRST_LEVEL_CONTRASTS = ["con_0001", "con_0002", "con_0003", "con_0004", "con_0005"];
    effects_keys = {'interaction', 'main'};
    rois_keys = {'neurosynthpeak'};
    
elseif preset == "manual"
    config_param.CONFOUND = ["no_confound"]; 
    config_param.EXCLUDED = ["allsubs"];
    config_param.MODELS = ["modelB2"];
    config_param.FIRST_LEVEL_CONTRASTS = ["con_0001","con_0002","con_0003"]; 
    effects_keys = {'interaction', 'main'};
    rois_keys = {'neurosynthraw'};
    
elseif preset == "confound"
    config_param.MODELS = ["modelC1", "modelC2"];
    config_param.FIRST_LEVEL_CONTRASTS = ["con_0001", "con_0002", "con_0003", "con_0004", "con_0005"]; 
    effects_keys = {'interaction', 'main'};
    rois_keys = {'neurosynthraw'};
    config_param.EXCLUDED = ["only_male", "only_female"];
    config_param.CONFOUND = ["incl_confound"]; 
    
elseif preset == "sexes"
    config_param.MODELS = ["modelA", "modelB1", "modelB2", "modelC1", "modelC2"];
    config_param.FIRST_LEVEL_CONTRASTS = ["con_0001", "con_0002", "con_0003", "con_0004", "con_0005"]; 
    effects_keys = {'interaction'};
    rois_keys = {'neurosynthraw'};
    config_param.EXCLUDED = ["only_male", "only_female"];
    config_param.CONFOUND = ["no_confound"]; 
    
elseif preset == "posthoc"
    config_param.MODELS = ["modelA"];
    config_param.FIRST_LEVEL_CONTRASTS = ["con_0001", "con_0002", "con_0003", "con_0004", "con_0005"]; 
    effects_keys = {'interaction', 'main'};
    config_param.CONFOUND = ["no_confound"]; 
    rois_keys = {'neurosynthraw'};
    config_param.CONFOUND = ["no_confound"];
    
elseif preset == "all" || preset == "select"
    config_param.MODELS = ["modelA", "modelB1", "modelB2", "modelC1", "modelC2"];
    config_param.FIRST_LEVEL_CONTRASTS = ["con_0001", "con_0002", "con_0003", "con_0004", "con_0005"]; 
    effects_keys = {'interaction', 'main'};
    rois_keys = {'nomask',  'neurosynthraw', 'neurosynthpeak'};
    config_param.CONFOUND = ["no_confound", "incl_confound"]; 
    
    if preset == "select"
        sumok = 0;
        [indx,tf] = listdlg('ListString', config_param.MODELS);
        config_param.MODELS = config_param.MODELS(indx);
        sumok = sumok + tf;

        [indx,tf] = listdlg('ListString', config_param.FIRST_LEVEL_CONTRASTS);
        config_param.FIRST_LEVEL_CONTRASTS = config_param.FIRST_LEVEL_CONTRASTS(indx);
        sumok = sumok + tf;

        [indx,tf] = listdlg('ListString', effects_keys);
        effects_keys = effects_keys(indx);
        sumok = sumok + tf;

        [indx,tf] = listdlg('ListString', rois_keys);
        rois_keys = rois_keys(indx);
        sumok = sumok + tf;
        
        confounder_map = containers.Map(cellstr(config_param.CONFOUND), {'none', 'age/ sex/ SES index'});
        [indx,tf] = listdlg('ListString', confounder_map.values);
        tmpvar = confounder_map.keys;
        config_param.CONFOUND = convertCharsToStrings(tmpvar(indx));
        sumok = sumok + tf;
        
        [indx,tf] = listdlg('ListString', config_param.EXCLUDED);
        config_param.EXCLUDED = config_param.EXCLUDED(indx);
        sumok = sumok + tf;

        if sumok < 6
            fprintf("Selection is incomplete\n...aborted.\n");
        end
        
        answer = questdlg('For preliminary analysis: inclusion of limited case number?', ...
            'prereg', ...
            'Yes','No','Cancel','Yes');
        switch answer
            case 'Yes'
                disp("Use only a selection of cases...")
                config_param.SELECT = true;
            case 'No'
                disp("Use complete cases...")
            case 'Cancel'
                disp('...aborted')
                return
        end
        
        % question for parallel processing
        answer = questdlg('Enable parallel processing?', ...
            'prereg', ...
            'Yes','No','Cancel','No');
        switch answer
            case 'Yes'
                disp("Parallel processing...")
                parprocess = true;
            case 'No'
                disp("Sequential processing...")
                parprocess = false;
            case 'Cancel'
                disp('...aborted')
                return
        end
    end
else
    disp("Please define a valid preset, e.g. 'all'.")
    return
end

%% selected configurations
config_param.EFFECTS = containers.Map(effects_keys, values(effects_map, effects_keys));
config_param.POSTHOC = containers.Map(posthoc_keys, values(posthoc_map, posthoc_keys));
config_param.ROIS = containers.Map(rois_keys, values(rois_map, rois_keys));


%% create separate runs
runs = gb_build_runs(config_param);
disp("...done.")
%gb_process_runs(runs, parprocess)

end
