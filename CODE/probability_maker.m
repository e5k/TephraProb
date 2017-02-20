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
Updates:    April 2015
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

function probability_maker
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

project = load_run;

if project.run_pth == -1
    return
end

% Check if seasonality was activated
if isdir(fullfile(project.run_pth, 'SUM', 'rainy'))
    runs = {'all', 'dry', 'rainy'};
elseif isdir(fullfile(project.run_pth, 'SUM', 'all'))
    runs = {'all'};
end

% Check if model was run
if isempty(dir(fullfile(project.run_pth, 'OUT', 'all', '1', '*.out')))    
    errordlg('No output file found. Did you already run the model?', ' ');
    return
end

% Check if sum folder already exists
if ~isempty(dir(fullfile(project.run_pth, 'SUM', 'all', '*.out')))
    choice = questdlg('It seems that results have been summed already. Do you wish to proceed to probability calculations?', ...
        '', ...
        'Sum','Probabilities','Probabilities');

    switch choice
        case 'Sum'
            sum_files(project.run_pth, project.grd_pth, runs, project.grd_type);
        case 'Probabilities'
            prob_files(project.run_pth, project.grd_pth, runs, project.grd_type);
    end 
else
    sum_files(project.run_pth, project.grd_pth, runs, project.grd_type);
end

% Function to sum files constituting a long-lasting eruption
function sum_files(run_pth, grd_pth, runs, grd_type)

disp('Summing files...');

for iR = 1:length(runs)

    folds = dir([run_pth, 'OUT', filesep, runs{iR}, filesep]);
    count = 1;
    wb = waitbar(0, sprintf('Summing files for season: %s - %.0f/%.0f\n', runs{iR}, iR, length(runs)));
    for j = 3:size(folds,1)
        if strcmp(folds(j).name, '.') || strcmp(folds(j).name, '..') || strcmp(folds(j).name, '.DS_Store')
        else
            files = dir(fullfile(run_pth, 'OUT', runs{iR}, folds(j).name, '*.out'));
            if length(files) == 1
                copyfile(fullfile(run_pth, 'OUT', runs{iR}, folds(j).name, files(1).name),...
                    fullfile(run_pth, 'SUM', runs{iR}, [num2str(count, '%04d'), '.out']));
            else
                count2 = 1;
                while ~exist('refF', 'var') || isempty(refF)
                    refF    = load(fullfile(run_pth, 'OUT', runs{iR}, folds(j).name, files(count2).name));
                    count2  = count2 + 1;
                end
                for k = count2:size(files,1)
                    tmpF        = load(fullfile(run_pth, 'OUT',runs{iR}, folds(j).name, files(k).name));
                    refF(:,4)   = refF(:,4) + tmpF(:,4);
                end
                dlmwrite(fullfile(run_pth, 'SUM', runs{iR}, [num2str(count, '%04d'), '.out']),...
                    refF, 'delimiter', '\t', 'precision', 7);
            end
            count = count + 1;
            clear refF;
        end
        waitbar(j/size(folds,1));
    end   
    close(wb)
end
prob_files(run_pth, grd_pth, runs, grd_type);  
    
function prob_files(run_pth, grd_pth, runs, grd_type)
disp('Calculate probabilities...');
load(fullfile('CODE', 'VAR', 'prefs'));
massLimit = prefs.prob.mass_thresh;

if grd_type == 0 % Calculation grid is a grid
    % Create output directories
    mkdir(fullfile(run_pth, 'PROB', '3C'));
    mkdir(fullfile(run_pth, 'PROB', 'MAT'));
    mkdir(fullfile(run_pth, 'PROB', 'GIS'));
    
    % Load grid
    XX          = load(fullfile('GRID', grd_pth, [grd_pth, '_utmx.dat']));
    YY          = load(fullfile('GRID', grd_pth, [grd_pth, '_utmy.dat']));
    sX          = size(XX, 2);
    sY          = size(XX, 1);
    
    for iR = 1:length(runs)   
        % Mass vector for probability calculation
        files       = dir(fullfile(run_pth, 'SUM', runs{iR}, '*.out'));
        nz          = length(massLimit);   % Lenght of mass limit vector

        filetest    = load(fullfile(run_pth, 'SUM', runs{iR}, files(1).name));
        nb_points   = size(filetest,1);

        % Check if the size of the grid corresponds to the number of points
        if nb_points == sX*sY

            filetest(:,4)= 0;

            % 4 columns
            probability_matrix = zeros(size(filetest, 1), size(filetest,2), nz);
            % Matrix
            prob_mat           = zeros(sY, sX, nz);
            for j = 1:nz
                probability_matrix(:,:,j) = filetest;
            end

            count=0;
            wb = waitbar(0, sprintf('Processing files for season: %s - %.0f/%.0f\n', runs{iR}, iR, length(runs)));
            for k=1:size(files, 1) 
                fl = load(fullfile(run_pth, 'SUM', runs{iR}, files(k).name));
                if ~isempty(fl)
                    display([files(k).name, ' - Maximum accumulation = ', num2str(max(fl(:,4)))]);

                    % Probability in a 3 columns format
                    count = count + 1;
                    for j = 1:nb_points
                        for iZ = 1:nz
                            if fl(j,4) >= massLimit(iZ)
                                probability_matrix(j,4,iZ) = probability_matrix(j,4,iZ)+1;
                            end
                        end
                    end

                    % Probability in a matrix columns format
                    count2 = 1;
                    for yy = 1:sY
                        for xx = 1:sX
                            for iZ = 1:nz
                                if fl(count2,4) >= massLimit(iZ)
                                    prob_mat(yy,xx,iZ) = prob_mat(yy,xx,iZ)+1;
                                end
                            end   
                            count2 = count2 + 1;
                        end
                    end
                end
                waitbar(k/size(files,1));
            end
            close(wb);
            disp([num2str(count), ' files']);
            disp('Writing probability matrices...')
            
            wb = waitbar(0, 'Probability calculations...');
            for iZ = 1:nz
                fprintf('\t %.2f kg/m2\n', massLimit(iZ));

                % 3 columns
                probability_matrix(:,4, iZ) = probability_matrix(:, 4, iZ)/count;
                output = fullfile(run_pth, 'PROB', '3C',  [runs{iR}, '_', num2str(massLimit(iZ)), '.prb']);
                dlmwrite(output, probability_matrix(:,1:4,iZ), 'delimiter', '\t', 'precision', 7);  % I write a file containing informatin about the probability map.

                % ArcGIS
                output = fullfile(run_pth, 'PROB', 'GIS', [runs{iR}, '_', num2str(massLimit(iZ)), '.txt']);
                prob_mat(:,:,iZ) = prob_mat(:,:,iZ)./count;
                writeDEM(output, XX,YY,prob_mat(:,:,iZ));

                % Grid
                output = fullfile(run_pth, 'PROB', 'MAT', [runs{iR}, '_', num2str(massLimit(iZ)), '.prb']);
                dlmwrite(output, prob_mat(:,:,iZ), 'delimiter', '\t', 'precision', 7);
                waitbar(iZ / nz);
            end
            close(wb);
        else
            errordlg('The size of the grid does not correspond to the size of the output files', ' ');
        end
    end
    
else % Calculation grid is a list of points made for hazard curves only 
    % Create output directories
    mkdir(fullfile(run_pth, 'PROB', '3C'));

    for iR = 1:length(runs)   
        % Mass vector for probability calculation
        % massLimit   = [0.01, 0.05, 0.5, 1, 5, 10, 25, 50, 75, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 950, 1000];

        files       = dir(fullfile(run_pth, 'SUM', runs{iR}, '*.out'));
        nz          = length(massLimit);   % Lenght of mass limit vector

        filetest    = load(fullfile(run_pth, 'SUM', runs{iR}, files(1).name));
        nb_points   = size(filetest,1);

        filetest(:,4)= 0;

        % 4 columns
        probability_matrix = zeros(size(filetest, 1), size(filetest,2), nz);

        for j = 1:nz
            probability_matrix(:,:,j) = filetest;
        end

        count=0;
        wb = waitbar(0, sprintf('Processing files for season: %s - %.0f/%.0f\n', runs{iR}, iR, length(runs)));
        for k=1:size(files, 1) 
            fl = load(fullfile(run_pth, 'SUM', runs{iR}, files(k).name));
            if ~isempty(fl)
                display([files(k).name, ' - Maximum accumulation = ', num2str(max(fl(:,4)))]);

                % Probability in a 3 columns format
                count = count + 1;
                for j = 1:nb_points
                    for iZ = 1:nz
                        if fl(j,4) >= massLimit(iZ)
                            probability_matrix(j,4,iZ) = probability_matrix(j,4,iZ)+1;
                        end
                    end
                end

            end
            waitbar(k/size(files,1));
        end
        close(wb);
        disp([num2str(count), ' files']);
        disp('Writing probability matrices...')
        for iZ = 1:nz
            fprintf('\t %.2f kg/m2\n', massLimit(iZ));

            % 3 columns
            probability_matrix(:,4, iZ) = probability_matrix(:, 4, iZ)/count;
            output = fullfile(run_pth, 'PROB', '3C', [runs{iR}, '_', num2str(massLimit(iZ)), '.prb']);
            dlmwrite(output, probability_matrix(:,1:4,iZ), 'delimiter', '\t', 'precision', 7);  % I write a file containing informatin about the probability map.
        end
    end
end
msgbox('Probability calculations finished!')
