% Exports the content of dataProb and dataT2 matrices to ascii files
function exportASCII

% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

% Load preference file
load(['CODE', filesep, 'VAR', filesep, 'prefs'], 'prefs');

% Load project file
project = load_run;
if project.run_pth == -1
    return
end

% Check that simulations were done on a matrix
if project.grd_type == 1
    errordlg('ASCII outputs can only be produced if simulations were performed on a grid')
    return
end

% Request
s1 = {'Summed Tephra2 outputs', 'Probability outputs', 'Probabilistic isomass'};
s2 = {'Columns', 'ASCII Grids', 'ArcMap ASCII Rasters'};

r1 = listdlg('PromptString','Choose a type of file to extract:',...
                'SelectionMode','multiple',...
                'ListString',s1);            
if isempty(r1); return; end

r2 = listdlg('PromptString','Choose the format:',...
                'SelectionMode','multiple',...
                'ListString',s2);            
if isempty(r2); return; end

% Folder names
f1 = {'SUM', 'PROB', 'IM'};
f2 = {'COL', 'GRID', 'RASTER'};


% Load grid
XX      = load(['GRID', filesep, project.grd_pth, filesep, project.grd_pth, '_utmx.dat']);
YY      = load(['GRID', filesep, project.grd_pth, filesep, project.grd_pth, '_utmy.dat']);
UTM     = load(['GRID', filesep, project.grd_pth, filesep, project.grd_pth, '.utm']);
UTM     = UTM(:,1:2);
UTM     = sortrows(UTM, 1);

% Loop through type of files
for iT = 1:length(r1)       % Type of file
    fold1 = f1{r1(iT)};
    mkdir(fullfile(project.run_pth, fold1)); % Create type directory
    
    if r1(iT) > 1 % If any other type than sum, load prob data
        fprintf('- Loading probability data...\n')
        load(fullfile(project.run_pth, 'DATA', 'dataProb.mat'),'dataProb');
    end
    
    % Loop through seasons
    for iS = 1:length(project.seasons)
        mkdir(fullfile(project.run_pth, fold1, project.seasons{iS})); % Create season directory
    
        if r1(iT) == 1 % If sum, load tephra2 data
            fprintf('- Loading Tephra2 data for season %s...\n', project.seasons{iS})
            load(fullfile(project.run_pth, 'DATA', ['dataT2_', project.seasons{iS}, '.mat']),'dataT2');
        end
        
        % Loop through formats
        for iF = 1:length(r2)   % Format of file
            fold2  = f2{r2(iF)};
            target = fullfile(project.run_pth, fold1, project.seasons{iS}, fold2);
            mkdir(target) % Create format directory
            
            fprintf('- Writing %s - %s - %s...\n', s1{r1(iT)}, s2{r2(iF)}, project.seasons{iS});
            
            %%
            % Sum
            if r1(iT) == 1 
                for i = 1:size(dataT2,3)
                    tmp = dataT2(:,:,i);
                    fl  = [num2str(i, '%04.0f'), '.txt'];
                    if r2(iF) == 1 % Columns
                        dlmwrite(fullfile(target, fl), [UTM, reshape(tmp, numel(XX),1)], 'delimiter', '\t');
                    elseif r2(iF) == 2 % Grid
                        dlmwrite(fullfile(target, fl), tmp, 'delimiter', '\t');
                    elseif r2(iF) == 3 % RASTER
                        writeDEM(fullfile(target, fl), XX, YY, tmp);
                    end
                end
                
            % Probability maps    
            elseif r1(iT) == 2
                for i = 1:size(dataProb.prob.(project.seasons{iS}),3)
                    tmp = dataProb.prob.(project.seasons{iS})(:,:,i);
                    fl  = ['prob_', project.seasons{iS}, '_', num2str(dataProb.massT(i)), '_kgm2.txt'];
                    if r2(iF) == 1 % Columns
                        dlmwrite(fullfile(target, fl), [UTM, reshape(tmp, numel(XX),1)], 'delimiter', '\t');
                    elseif r2(iF) == 2 % Grid
                        dlmwrite(fullfile(target, fl), tmp, 'delimiter', '\t');
                    elseif r2(iF) == 3 % RASTER
                        writeDEM(fullfile(target, fl), XX, YY, tmp);
                    end
                end
                
            % ISOMASS maps    
            elseif r1(iT) == 3
                for i = 1:size(dataProb.IM.(project.seasons{iS}),3)
                    tmp = dataProb.IM.(project.seasons{iS})(:,:,i);
                    fl  = ['IM_', project.seasons{iS}, '_', num2str(dataProb.probT(i)), '_kgm2.txt'];
                    if r2(iF) == 1 % Columns
                        dlmwrite(fullfile(target, fl), [UTM, reshape(tmp, numel(XX),1)], 'delimiter', '\t');
                    elseif r2(iF) == 2 % Grid
                        dlmwrite(fullfile(target, fl), tmp, 'delimiter', '\t');
                    elseif r2(iF) == 3 % RASTER
                        writeDEM(fullfile(target, fl), XX, YY, tmp);
                    end
                end
            end
        end
    end
end