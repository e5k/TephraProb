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

Name:       prob2IM.m
Purpose:    Transforms probability matrices of exceeding a given tephra 
            accumulation into a isomass maps for a given probability 
            of occurrence
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


function prob2IM
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

% Check if probabilities are already calculated
if isempty(dir(fullfile(project.run_pth, 'SUM', 'all', '*.out')))    
    errordlg('No probability file found. Did you already compute probabilities?', ' ');
    return
end

make_IM(project.run_pth, project.grd_pth, runs)

function make_IM(run_pth, grd_pth, runs)
load(fullfile('CODE', 'VAR', 'prefs'));
mass_thres  = prefs.prob.mass_thresh;
prob        = prefs.prob.prob_thresh;

% Create output directories
mkdir(fullfile(run_pth, 'IM', '3C'));
mkdir(fullfile(run_pth, 'IM', 'MAT'));
mkdir(fullfile(run_pth, 'IM', 'GIS'));

utm             = load(fullfile('GRID', grd_pth, [grd_pth, '.utm']));
XI              = load(fullfile('GRID', grd_pth, [grd_pth, '_utmx.dat']));
YI              = load(fullfile('GRID', grd_pth, [grd_pth, '_utmy.dat']));
res             = XI(1,2)-XI(1,1);                                                                   % Grid resolution

x0 = min(utm(:,1));
y0 = min(utm(:,2));

for iR = 1:length(runs)
    wb = waitbar(0, sprintf('Reading probability matrices for season: %s - %.0f/%.0f\n', runs{iR}, iR, length(runs)));
    for l = 1:length(prob)
        contour_mat = [];                                                       % Initializes contour matrix
        for j = 1:length(mass_thres)                                            % Loop through available tephra accumulations

            file    = load(fullfile(run_pth, 'PROB', 'MAT', [runs{iR}, '_', num2str(mass_thres(j)), '.prb'])); % Loads probability matrix for given tephra accumulation  
            c       = contourcs(file, [1 prob(l)]);                             % Contours the .5 probability line
            nx      = size(c, 1);                                               % Counts the number of segments for a given contour

            if nx == 1 && c(1).Level ~= prob(l)                                 % Checks if 0.5 contour exists
            else
                contour_mat_tmp = [];                                           % Temporary storage matrix, updated at each contour value¨
                for i=1:nx                                                      % Loop through the segments of given contour
                    if c(i).Level == prob(l) 
                        X = permute(c(i).X, [2 1]);                             % Gets X values and transpose    
                        Y = permute(c(i).Y, [2 1]);                             % Gets Y values and transpose
                        Z = zeros(size(X,1),1);                                 % Creates a vector for the mass value of the contour...
                        Z(:,1) = mass_thres(j);                                 % ... and fills it up with the mass value
                        contour_mat_tmp = [contour_mat_tmp; [X, Y, Z]];         % Updates the contour matrix for the given contour
                    end
                end
                contour_mat = [contour_mat; contour_mat_tmp];
            end
        end
        
        contour_mat(:,1) = contour_mat(:,1)*res+x0-10;
        contour_mat(:,2) = contour_mat(:,2)*res+y0-10;
        
        F = scatteredInterpolant(contour_mat(:,1), contour_mat(:,2), contour_mat(:,3));
        ZI = F(XI,YI);
        ZI = flipud(ZI);

        % 3 columns
        output  = fullfile(run_pth, 'IM', '3C', [runs{iR}, '_', num2str(prob(l)*100), '.prb']);
        mat_tmp = [reshape(XI, size(XI,1)*size(XI,2), 1),...
            reshape(YI, size(XI,1)*size(XI,2), 1),...
            zeros(size(XI,1)*size(XI,2), 1),...
            reshape(ZI, size(XI,1)*size(XI,2), 1)];
        dlmwrite(output, mat_tmp, 'delimiter', '\t', 'precision', 7);  % I write a file containing informatin about the probability map.

        % ArcGIS
        output  = fullfile(run_pth, 'IM', 'GIS', [runs{iR}, '_', num2str(prob(l)*100), '.txt']);
        writeDEM(output, XI, YI, ZI);
        
        % Grid
        output  = fullfile(run_pth, 'IM', 'MAT', [runs{iR}, '_', num2str(prob(l)*100), '.prb']);
        dlmwrite(output, ZI, 'delimiter', '\t', 'precision', 7);
        
        waitbar(l/length(prob));
    end
    close(wb);
end