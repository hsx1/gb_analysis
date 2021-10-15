function [runs] = gb_build_runs(config_param)
%GB_BUILD_RUNS  Loops over parameter lists, i.e. settings of each parameter and makes 
% 
%     RUNS = GB_BUILD_RUNS(CONFIG_PARAM) for a struct CONFIG_PARAM that 
%     specifies all possible values of each configuration parameter and returns
%     a list RUNS of structs that each specify a unique configuration setting
%     (parameter combination) that will be used as input for the SwE toolbox.
%     Maximum number of runs in RUNS: 
%     5 models * 5 contrast images * 2 effects * 3 masks = 150 separate runs
% 
%     GB_BUILD_RUNS is called by gb_config() and creates input for 
%     process_runs()
%     Author: Hannah Sophie Heinrichs <heinrichs@cbs.mpg.de>

runs = [];
for m = config_param.MODELS
    for c = config_param.FIRST_LEVEL_CONTRASTS
        % check availability of contrast images
        d = dir(fullfile(config_param.DATA_DIR, m, "sub-*", "ses-0*", c + ".nii"));
        if isempty(d)
            fprintf("No contrast %s for %s. Skipping...\n", c, m)
            continue % skip model
        end
        for f = config_param.CONFOUND
            for e = config_param.EFFECTS.keys
                for r = config_param.ROIS.keys
                    for s = config_param.EXCLUDED
                        crun.DATA_DIR = config_param.DATA_DIR;
                        crun.DESIGNMATRIX_PATH = config_param.DESIGNMATRIX_PATH;
                        if config_param.SELECT
                            crun.OUT_DIR = fullfile(config_param.OUT_DIR, "test_" + f, s, r, e, m, c); 
                        else
                            crun.OUT_DIR = fullfile(config_param.OUT_DIR, f, s, r, e, m, c);
                        end
                        crun.MASK = config_param.ROIS.values(r);
                        crun.MODEL = m;
                        crun.FIRST_LEVEL_CONTRAST = c;
                        crun.CONFOUND = f;
                        crun.EFFECT = cell2mat(config_param.EFFECTS.values(e));
                        crun.ACTION = config_param.ACTION;
                        crun.VIEW = config_param.VIEW;
                        crun.EXCLUDED = s;

                        % scans + design matrix / input
                        scans = cell(size(d, 1), 1);
                        sub_ses = cell(size(d, 1), 1);
                        for i = 1:size(d, 1)
                            scans{i} = [d(i).folder,'/',d(i).name];
                            sub_ses{i} = d(i).folder(end-12:end);
                        end
                        dm = readtable(config_param.DESIGNMATRIX_PATH);
                        dm.sub_ses = strcat(dm.subj, filesep , dm.session);
                        % select only cases with mri images
                        dm = dm(ismember(dm.sub_ses, sub_ses), :);
                        dm.scans = cell(size(dm,1), 1);
                        for s = 1:size(dm, 1)
                            dm.scans(s) = scans(contains(scans, dm.sub_ses(s)));
                        end
                        % select only cases with complete data
                        dm = dm(~isnan(dm.SES_index),:);
                        
                        % exclude lines with invalid subjects/sessions
                        if crun.EXCLUDED == "only_male"
                            dm = dm(dm.spm_sex == 0,:);
                        elseif crun.EXCLUDED == "only_female"
                            dm = dm(dm.spm_sex == 1,:);
                        elseif crun.EXCLUDED == "excluded_sub-30"
                            dm = dm(not(ismember(dm.subj,'sub-30')),:);
                        elseif crun.EXCLUDED == "excluded_sub-47_ses-04"
                            dm = dm(not(ismember(dm.subj,'sub-47_ses-04') & ismember(dm.session,'ses-04')),:);
                        elseif crun.EXCLUDED == "excluded_sub-30_sub-47_ses-04"
                            dm = dm(not(ismember(dm.subj,'sub-30') | (ismember(dm.subj,'sub-47') & ismember(dm.session,'ses-04'))),:);
                        end

                        % select preliminary cases to try out for preregistration
                        if config_param.SELECT
                            dm.subjc = categorical(dm.subj);
                            dm = dm(1:find(dm.subjc == 'sub-10',1), :);
                        end
                        % check columns
                        crun.DESIGNMATRIX = dm;

                        % 
                        if crun.ACTION == "estimate" && is_estimated(crun)
                            continue
                        else
                            runs = [runs, crun];
                        end
                    end
                end
            end
        end
    end
end

end


function [estimated] = is_estimated(crun)
    estimated = exist(crun.OUT_DIR, 'dir') && length(dir(crun.OUT_DIR)) > 2 && isempty(dir(fullfile(crun.OUT_DIR, "*fit_y*")));
end

function [interrupted] = is_interrupted(crun)
    interrupted = exist(crun.OUT_DIR, 'dir') && ~isempty(dir(fullfile(crun.OUT_DIR, "*fit_y*")));
end