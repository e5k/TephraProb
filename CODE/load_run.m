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

Name:       load_run.m
Purpose:    Load TephraProb project files
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

function project = load_run

% If tmp file exist, then load it
if exist('tmp.mat', 'file')
    load('tmp.mat');
    project.run_pth = tmp.run_pth;
    project.grd_pth = tmp.grd_pth;
    project.vent    = tmp.vent;
    if isfield(tmp, 'points')
        project.points = tmp.points;
    else
        project.points = -9999;
    end
    project.grd_type = tmp.grd_type;
    project.run_name = tmp.run_name;
    project.par      = tmp.par;
    project.cores    = tmp.cores;
else
    % Select run file
    [flname, flpath] = uigetfile('*.mat', 'Select a RUN file to open');
    run_pth = [flpath, filesep, flname];

    if  flname > 0
        load(run_pth);

        % Get grid
        project.grd_pth     = fileparts(data.grid_pth);
        project.vent.east   = data.vent_easting;
        project.vent.north  = data.vent_northing;
        project.vent.zone   = data.vent_zone;

        % Check grid or points
        if length(dir(['GRID/', project.grd_pth, filesep, '*.dat'])) == 5
            project.grd_type = 0;
        else
            project.grd_type = 1;
        end
        
        project.run_pth     = flpath;
        project.run_name    = data.run_name;
        
        if isfield(data, 'points')
            project.points = data.points;
        else
            project.points = -9999;
        end
        
        % Parallel
        project.par     = data.par;
        project.cores   = data.par_cpu;
    else
        project.run_pth = -1;
        project.grd_pth = -1;
        project.vent    = -1;
        project.points	= -1;
        project.grd_type= -1;
        project.run_name= -1;
        project.par     = -1;
        project.cores   = -1;
    end
end
