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

Name:       hazCurve_make.m
Purpose:    Retrieves output files of the TEPHRA2 model and computes them
            into hazard curves 
Author:     Sebastien Biass
Created:    April 2015
Updates:    November 2015
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


function hazCurve_maker
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

if isempty(dir(fullfile(project.run_pth, 'OUT', 'all', '1', '*.out')))    
    errordlg('No output file found. Did you already run the model?', ' ');
    return
end

make_curves(project.run_pth, runs, project.run_name)

function make_curves(run_pth, runs, run_name)

if ~exist('CURVES', 'dir')
    mkdir('CURVES')
end

coor    = load_file;
if ~isstruct(coor)
    return
end
coor    = coor.grid;
points  = coor.stor_points;


for iR = 1:length(runs)
    fprintf('Season:\t%s\n', runs{iR})
    files       = dir(fullfile(run_pth, 'SUM', runs{iR},'*.out'));
    nb_files    = 0;
    
    stor = [];
       
    h = waitbar(0,'Reading files...');
    for k=1:size(files, 1) 
        fl = load(fullfile(run_pth, 'SUM', runs{iR}, files(k).name));
        if ~isempty(fl)
            stor(:,:,k) = fl;
            nb_files    = nb_files+1;
        end
        waitbar(k/size(files,1));
    end
    close(h);
    
    disp('Creating hazard curves')
    for j = 1:size(points,1)
        fprintf('\t %s\n', points{j,1});
        
        % Locate the line in the output tephra files corresponding to the location coordinates
        [~, idxtmpx]     = min(abs(fl(:,1)-points{j,2}));
        [~, idxtmpy]     = min(abs(fl(:,2)-points{j,3}));
        utm_line         = find(fl(:,1)==fl(idxtmpx,1) & fl(:,2)==fl(idxtmpy,2));
        
        mass = zeros(nb_files,1);
        % Parameters for the log-logistic distribution
        a = 1;
        b = 8;
        x = 0:0.02:2;
        y = x.^b./(a.^b+x.^b);

        for in=1:nb_files 
            mass(in) = stor(utm_line,4,in);
        end
        
        max_mass = max(mass);

        mass_vec = y.*max_mass';
        prob_vec = zeros(length(mass_vec),1);

        k = 1;
        for l = mass_vec
            prb = 0;
            for m = 1:size(mass,1)
                if mass(m) >= l
                    prb = prb+1;
                end
            end
            
            prob_vec(k) = prb./nb_files*100;    
            k = k+1;
        end
        dlmwrite(fullfile('CURVES', [points{j,1}, '_',  run_name, '_', runs{iR}, '.out']), [mass_vec', prob_vec], 'delimiter', '\t');
    end
end
        
function C = load_file

[FileName,PathName] = uigetfile('*.points','Select the .points file with the coordinates');
if FileName == 0
    C = 0;
else
    C = load(fullfile(PathName, FileName), '-mat');
end