% Archive Tephra2 output files
function archiveFiles

% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

% Load project file
project = load_run;
if project.run_pth == -1
    return
end

% Request
s1 = {'Tephra2 output files', 'Tephra2 configuration files', 'Tephra2 grainsize files'};
s2 = {'OUT', 'CONF', 'GS'};

r1 = listdlg('PromptString','Choose a folder to compress:',...
                'SelectionMode','multiple',...
                'ListString',s1);            
if isempty(r1); return; end

for iR = 1:length(r1)
    fprintf('- Compressing folder %s\n', s2{r1(iR)})
    target = fullfile(project.run_pth, s2{r1(iR)});
    zip([project.run_pth, s2{r1(iR)}, '.zip'], target);
    fprintf('- Removing folder %s\n', s2{r1(iR)})
    rmdir(target, 's');
end
