function [D] = gb_spm2csv(hReg,xSwE, out_dir)
%GB_SPM2CSV saves results of SPM contrast (activation or deactivation) obtained via 
%GUI on SPM to a csv file in current directory D (result directory)
% 
%     [D] = GB_SPM2CSV(hReg, xSwE) returns output directory D.
%
%     [D] = GB_SPM2CSV(..., OUT_DIR) specifies output directory (not
%     implemented)
% 
%     GB_SPM2CSV is called by gb_run_swe()
%     Author: Hannah Sophie Heinrichs <heinrichs@cbs.mpg.de>

if nargin < 3
    % uses current directory
    D = pwd;
else
    D = out_dir;
end

TabDat = swe_list('List',xSwE,hReg);

if contains(xSwE.title, "Deactivation")
    % Deactivation
    direction = 'deact';
else
    % Activation
    direction = 'act';
end

%% Print a csv files of the results
% if there are any results create csv file starting with result
if size(TabDat.dat,1) > 0
    % myfile = fullfile(D, sprintf('results_%s.csv', direction));
    myfile = sprintf('results_%s.csv', direction);
    fid = fopen (myfile, 'w');
    % print header
    for j=1:size(TabDat.hdr,2)
        fprintf(fid, '%s', TabDat.hdr{1,j});
        if strcmp(TabDat.hdr{1,11},' ') fprintf(fid, '_'); end
        fprintf(fid, '%s,', TabDat.hdr{2,j});
    end
    fprintf(fid,'\n');
    %%
    % print data
    for i=1:size(TabDat.dat,1)
        for j=1:size(TabDat.dat,2)
            fprintf(fid, '%6.3f,', TabDat.dat{i,j});
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end

%% Print a csv files of result settings
% myfile2 = fullfile(D, 'info.csv');
myfile2 = 'info.csv';
fid2 = fopen(myfile2, 'w');
% print info text
fprintf(fid2, '%s,', D);
fprintf(fid2, '%s,', xSwE.title);
fprintf(fid2, '%s', TabDat.tit);
fprintf(fid2, '\n');
for i = 1:size(TabDat.ftr,1)
    fprintf(fid2, TabDat.ftr{i,1},TabDat.ftr{i,2});
    fprintf(fid2, '\n\n');
end

disp('...done.')
fclose(fid2);
end
