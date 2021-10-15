function matlabbatch = gb_mkbatch(crun)
%GB_MKBATCH   Creates matlabbatch for SwE toolbox
% 
%     GB_MKBATCH(CRUN) specifies input parameters for current run.
% 
%     GB_MKBATCH is called by gb_run_swe()
%     Author: Hannah Sophie Heinrichs <heinrichs@cbs.mpg.de>

dm = crun.DESIGNMATRIX;

%% SwE specify model
% output directory
smodel.dir = cellstr(crun.OUT_DIR);
% input scans
smodel.scans = cellstr(dm.scans); 
% other
smodel.ciftiAdditionalInfo.ciftiGeomFile = struct('brainStructureLabel', {}, 'geomFile', {}, 'areaFile', {});
smodel.ciftiAdditionalInfo.volRoiConstraint = 1;
smodel.giftiAdditionalInfo.areaFileForGiftiInputs = {};
% swe modifications
smodel.type.modified.groups = ones(size(dm,1), 1);
smodel.type.modified.visits = dm.spm_visit; 
smodel.type.modified.ss = 4; % small sample adjustment type C2
smodel.type.modified.dof_mo = 3; % approx II
smodel.subjects = dm.spm_subj;
% design matrix 
r = 1;
smodel.cov(r).c = dm.spm_A_BL; 
smodel.cov(r).cname = 'A_BL';
r = r + 1;
smodel.cov(r).c = dm.spm_A_FU;
smodel.cov(r).cname = 'A_FU'; 
r = r + 1;
smodel.cov(r).c = dm.spm_B_BL; 
smodel.cov(r).cname = 'B_BL';
r = r + 1;
smodel.cov(r).c = dm.spm_B_FU; 
smodel.cov(r).cname = 'B_FU';
% optionally include covariates age/sex/ses
if crun.CONFOUND == "incl_confound"
    r = r + 1;
    smodel.cov(r).c = dm.age; 
    smodel.cov(r).cname = 'age';
    if not(crun.EXCLUDED == "only_male" || crun.EXCLUDED == "only_female")
        r = r + 1;
        smodel.cov(r).c = dm.spm_sex; 
        smodel.cov(r).cname = 'sex';
    end
    r = r + 1;
    smodel.cov(r).c = dm.SES_index; 
    smodel.cov(r).cname = 'SES_index';
end
smodel.multi_cov.files = struct('files', {}); 
% masking
smodel.masking.tm.tm_none = 1;
smodel.masking.im = 1; % implicit mask YES
smodel.masking.em = crun.MASK;
% Wild Bootstrap
smodel.WB.WB_yes.WB_ss = 4; 
smodel.WB.WB_yes.WB_nB = 999; % default: non-parametric bootstrapping 
smodel.WB.WB_yes.WB_SwE = 0;
smodel.WB.WB_yes.WB_stat.WB_T.WB_T_con = crun.EFFECT; % [ ] check if additional zeros necessary
% TFCE seetings
smodel.WB.WB_yes.WB_infType.WB_TFCE.WB_TFCE_E = 0.5;
smodel.WB.WB_yes.WB_infType.WB_TFCE.WB_TFCE_H = 2; 
% other
smodel.globalc.g_omit = 1;
smodel.globalm.gmsca.gmsca_no = 1;
smodel.globalm.glonorm = 1;

%% create matlabbatch
% SwE run model (estimation)
matlabbatch{1}.spm.tools.swe.smodel = smodel;
% SwE display model results
matlabbatch{2}.spm.tools.swe.rmodel.des = cellstr(fullfile(crun.OUT_DIR, 'SwE.mat'));


end
