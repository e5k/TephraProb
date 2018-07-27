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

% if exist('tmp.mat', 'file')
%     load('tmp.mat', 'data');
%     run_pth = data.run_pth;
%     grd_pth = data.grd_pth;
% else
%     [flname, flpath] = uigetfile('*.mat', 'Select a RUN file to open');
%     if flname == 0
%         project.run_pth = -1;
%         return
%     end
%     run_pth = [flpath, filesep, flname];
%     load(run_pth, 'data');
%     [~,grd_pth] = fileparts(data.grid_pth);
% end
% 
% 
% 
% 
% 
% % Get grid
% %[~,project.grd_pth] = fileparts(data.grid_pth);
% project.grd_pth     = grd_pth;
% project.vent.east   = data.vent_east;
% project.vent.north  = data.vent_northing;
% project.vent.zone   = data.vent_zone;
% 
% % Seasonality
% project.seasonality = data.seasonality;
% rainy_start = datenum(['01-', data.wind_start_rainy, '-2018']);
% dry_start   = datenum(['01-', data.wind_start_dry, '-2018']);
% rainy_end   = datestr(dry_start-20, 'mmm');
% dry_end     = datestr(rainy_start-20, 'mmm');
% 
% if project.seasonality == 1
%     project.seasons     = {'all', 'dry', 'rainy'};
%     project.seasons_tag = {'All months', [datestr(dry_start,'mmm'),'-',dry_end], [datestr(rainy_start,'mmm'),'-',rainy_end]};
% else
%     project.seasons     = {'all'};
%     project.seasons_tag = {'All months'};
% end
% 
% % Check grid or points
% if isempty(dir(fullfile('GRID/', project.grd_pth, '*.dat')))
%     project.grd_type = 1;
% else
%     project.grd_type = 0;
% end
% 
% project.run_pth     = run_pth;
% project.run_name    = data.run_name;
% 
% if isfield(data, 'points')
%     project.points = data.points;
% else
%     project.points = -9999;
% end
% 
% % Parallel
% project.par     = data.par;
% project.cores   = data.par_cpu;


% If tmp file exist, then load it
if exist('tmp.mat', 'file')
    load('tmp.mat', 'tmp');
    project.run_pth = tmp.run_pth;
    project.grd_pth = tmp.grd_pth;
    project.run_name = tmp.run_name;
    project.vent    = tmp.vent;
    if isfield(tmp, 'points')
        project.points = tmp.points;
    else
        project.points = -9999;
    end
    
    project.seasons     = tmp.seasons;
    project.seasons_tag = tmp.seasons_tag;
    
    project.grd_type    = tmp.grd_type;
    
    project.par     = tmp.par; 
    project.cores   = tmp.cores;
    
else
    % Select run file
    [flname, flpath] = uigetfile('RUNS/*.mat', 'Select a RUN file to open');
    run_pth = [flpath, filesep, flname];

    if  flname > 0
        load(run_pth, 'data');

        % Get grid
        [~,project.grd_pth] = fileparts(data.grid_pth);
        project.vent.east   = data.vent_easting;
        project.vent.north  = data.vent_northing;
        project.vent.zone   = data.vent_zone;
        
        % Seasonality
        project.seasonality = data.seasonality;
            rainy_start = datenum(['01-', data.wind_start_rainy, '-2018']);
            dry_start   = datenum(['01-', data.wind_start_dry, '-2018']);
            rainy_end   = datestr(dry_start-20, 'mmm');
            dry_end     = datestr(rainy_start-20, 'mmm');
        
        if project.seasonality == 1
            project.seasons     = {'all', 'dry', 'rainy'};
            project.seasons_tag = {'All months', [datestr(dry_start,'mmm'),'-',dry_end], [datestr(rainy_start,'mmm'),'-',rainy_end]};
        else
            project.seasons     = {'all'};
            project.seasons_tag = {'All months'};
        end
        
        % Check grid or points
        if isempty(dir(fullfile('GRID/', project.grd_pth, '*.dat')))
            project.grd_type = 1;
        else
            project.grd_type = 0;
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
