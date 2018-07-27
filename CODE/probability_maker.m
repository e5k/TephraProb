%{
 ______                __                     ____               __        
/\__  _\              /\ \                   /\  _`\            /\ \       
\/_/\ \/    __   _____\ \ \___   _ __    __  \ \ \_\ \_ __   ___\ \ \____  
   \ \ \  /'__`\/\ '__`\ \  _ `\/\`'__\/'__`\ \ \ ,__/\`'__\/ __`\ \ '__`\ 
    \ \ \/\  __/\ \ \_\ \ \ \ \ \ \ \//\ \_\.\_\ \ \/\ \ \//\ \_\ \ \ \_\ \
     \ \_\ \____\\ \ ,__/\ \_\ \_\ \_\\ \__/.\_\\ \_\ \ \_\\ \____/\ \_,__/
      \/_/\/____/ \ \ \/  \/_/\/_/\/_/ \/__/\/_/ \/_/  \/_/ \/___/  \/___/ 
                   \ \_\                                                   
                    \/_/                                                   
___________________________________________________________________________

Name:       probability_maker.m
Purpose:    Retrieves output files of the TEPHRA2 model and computes them
            into probability matrices 
Author:     Sebastien Biass
Created:    April 2015
Updates:    Jul 2018
Copyright:  Sebastien Biass, University of Geneva, 2015
License:    GNU GPL3

This file is part of TephraProb

TephraProb is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    TephraProb is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with TephraProb.  If not, see <http://www.gnu.org/licenses/>.
%}

function probability_maker(varargin)
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

% Load inputs and checks
project = load_run;
load(fullfile('CODE', 'VAR', 'prefs'), 'prefs'); % Load prefs
if project.run_pth == -1; return; end
mkdir(fullfile(project.run_pth, 'DATA'));

% Check if matrix or curve shape
if nargin == 0; mode = 0; 
else mode = varargin{1};
end

% Check if seasonality was activated
runs = project.seasons;

% Check if model was run
if isempty(dir(fullfile(project.run_pth, 'OUT', 'all', '1', '*.out')))    
    errordlg('No output file found. Did you already run the model?', ' ');
    return
end

% Check if preprocessing was done already
for iR = 1:length(runs)
    if length(dir([project.run_pth, 'DATA', filesep, 'dataT2_*.mat'])) < length(runs)
        preProcess(project, runs, prefs);
    else
        fprintf('Tephra2 files have already been post processed. To re-process them, delete the dataT2_*.mat files from the DATA/ folder of your run\n')
    end
end
    
computeProbs(project, runs, prefs, mode)


% Pre-processing of Tephra2 output files, including summing
function preProcess(project, runs, prefs)

% Load utm grid to retrieve output
grd_tmp     = load(fullfile('GRID', project.grd_pth, [project.grd_pth, '.utm']));    
disp('- Summing files...');

for iR = 1:length(runs)
    folds   = dir(fullfile(project.run_pth, 'OUT', runs{iR}));
    folds   = folds(~ismember({folds.name},{'.','..'}));  % Remove . and ..
    % Check output folders
    if isempty(folds); errordlg('No ouput file was found. Did you run Tephra2?'); return; end

    nbRuns = size(folds,1); % Number of runs
    dataT2 = zeros(size(grd_tmp,1),nbRuns); % Main storage
    
    wb      = waitbar(0, sprintf('Summing files for season: %s - %.0f/%.0f\n', runs{iR}, iR, length(runs)));
    for j = 1:nbRuns
        if strcmp(folds(j).name, '.') || strcmp(folds(j).name, '..') || strcmp(folds(j).name, '.DS_Store')
        else
            files = dir(fullfile(project.run_pth, 'OUT', runs{iR}, folds(j).name, '*.out'));
            
            for k = 1:length(files)
                tmpF        = dlmread(fullfile(project.run_pth, 'OUT',runs{iR}, folds(j).name, files(k).name));
                dataT2(:,j) = dataT2(:,j)+tmpF(:,4);
            end
        end
        waitbar(j/nbRuns);
    end   
    
    % Reduce size of original Tephra2 data
    dataT2(dataT2<10^(-prefs.files.nbDigits)) = 0;     % Remove accumulations < what specified in preferences
    dataT2 = single(dataT2);    % Transform data to single
    dataT2 = round(dataT2,prefs.files.nbDigits);
    
    % If Tephra2 was ran on a grid, modify the 3 col format to matrix
    if project.grd_type == 0
        [~,idxSort] = sortrows(grd_tmp(:,1:2), [2,1], {'descend','ascend'}); % Sort T2 output in increasing easting and decreasing northing
        % Note: columns order varies from plotT2, but that is due to the
        % way the grid is defined
        dataT2 = dataT2(idxSort, :); % Sort 
        dataT2 = reshape(dataT2, length(unique(grd_tmp(:,1))), length(unique(grd_tmp(:,2))), nbRuns); % Reshape
        dataT2 = permute(dataT2, [2,1,3]); % Permute
    end
    fprintf('- Saving project file\n');
    save([project.run_pth, 'DATA', filesep, 'dataT2_', runs{iR}, '.mat'], 'dataT2')
    close(wb)  
end


function computeProbs(project, runs, prefs, mode)
% Mode: 0 = prob maps, 1 = curves

% If curves, get a larger amount of mass thresholds for smooth curve
if mode == 0
    massT = prefs.prob.mass_thresh;
    probT = prefs.prob.prob_thresh;
else
    massT = logspace(-prefs.files.nbDigits,4,250);
    
    % Load points
    if project.grd_type == 1
        pth = fullfile('GRID', project.grd_pth, [project.grd_pth, '.points']);
    else
        fprintf('\t SELECT the .points file\n')
        [fl,pth] = uigetfile('*.points','Select the .points file with the coordinates');
        if fl == 0; return
        else pth = fullfile(pth, fl);
        end
    end
    load(pth, '-mat', 'grid');
    
    points.name = grid.stor_points(:,1);
    points.x    = [grid.stor_points{:,2}]';
    points.y    = [grid.stor_points{:,3}]';
    points.lat  = [grid.points{:,2}]';
    points.lon  = [grid.points{:,3}]';
    
    % In case hazard curves based on matrices, also need to retrieve the
    % grid to calculate indices
    if project.grd_type == 0
        XX = load(fullfile('GRID', project.grd_pth, [project.grd_pth, '_utmx.dat']));
        YY = load(fullfile('GRID', project.grd_pth, [project.grd_pth, '_utmy.dat']));
    
        % Test if poins are in the grid
        idx = points.x<=max(XX(1,:)) & points.x>=min(XX(1,:)) & ...
            points.y<=max(YY(:,1)) & points.y>=min(YY(:,1));
        
        if nnz(~idx)>0
            warning('Some points are outside of the computation grid and are ignored');
            points.name = points.name(idx);
            points.x    = points.x(idx);
            points.y    = points.y(idx);
            points.lat  = points.lat(idx);
            points.lon  = points.lon(idx);
        end
    end
end


%% Main loop through runs
if exist([project.run_pth, 'DATA', filesep, 'dataProb', '.mat'], 'file')
    load([project.run_pth, 'DATA', filesep, 'dataProb', '.mat'], 'dataProb');
end

for iR = 1:length(runs)
    fprintf('- Computing Season %s\n', runs{iR})
    %% Calculate probabilities
    fprintf('\t_Loading Tephra2 data for season %s\n', runs{iR})
    load([project.run_pth, 'DATA', filesep, 'dataT2_', runs{iR}, '.mat'], 'dataT2');
    
    % Case 1: Maps
    if mode == 0
        fprintf('\t_Computing probability maps \n');
        md = 'prob';
        dataProb.(md).(runs{iR}) = zeros(size(dataT2,1), size(dataT2,2), length(massT));
        for iT = 1:length(massT)
            dataProb.(md).(runs{iR})(:,:,iT) = sum(dataT2 >= massT(iT),3)/size(dataT2,3);
        end
        dataProb.massT = massT;
    
        % Calculate percentile
        sprintf('\t_Computing isomass maps \n');
        md = 'IM';
        dataProb.(md).(runs{iR})= prctile(dataT2, (100-probT), 3);    % Taking 100-pct
        dataProb.probT = probT;
        
    % Case 2: Hazard curves from probability maps
    elseif mode == 1 && project.grd_type == 0
        fprintf('\t_Interpolating hazard curves \n')
        md = 'curve';
        dataProb.(md).(runs{iR}) = zeros(size(points.x,1), length(massT));
        for iT = 1:length(massT)
            tmp = sum(dataT2 >= massT(iT),3)/size(dataT2,3);
            dataProb.(md).(runs{iR})(:,iT) = interp2(XX,YY,tmp, points.x, points.y);
        end
        dataProb.massTc = massT;
        dataProb.points = points;
        
    % Case 3: Hazard curves, no grid
    elseif mode == 1 && project.grd_type == 1 
        fprintf('\t_Processing hazard curves \n');
        md = 'curve';
        dataProb.(md).(runs{iR}) = zeros(size(points.x,1), length(massT));
        for iT = 1:length(massT)
            dataProb.(md).(runs{iR})(:,iT) = sum(dataT2 >= massT(iT),2)/size(dataT2,2);
        end
        dataProb.massTc = massT;
        dataProb.points = points;   
    end
        
    %% Write hazard curves
    if mode == 1
        fprintf('\t_Writing hazard curves \n')
        for iP = 1:length(dataProb.points.x)
            dlmwrite(fullfile('CURVES', [dataProb.points.name{iP}, '_',  project.run_name, '_', runs{iR}, '.out']), [dataProb.massTc', dataProb.curve.(runs{iR})(iP,:)'.*100], 'delimiter', '\t');
        end
    end
end

% Save matrices
save([project.run_pth, 'DATA', filesep, 'dataProb', '.mat'], 'dataProb');
