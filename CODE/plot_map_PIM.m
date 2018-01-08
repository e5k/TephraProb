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

Name:       plot_map_PIM.m
Purpose:    Plot isomass maps
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


function plot_map_PIM
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

% Load preference file
load(['CODE', filesep, 'VAR', filesep, 'prefs']);

% Load project file
project = load_run;
if project.run_pth == -1
    return
end

d       = dir([project.run_pth, 'IM', filesep, 'MAT', filesep, '*.prb']);
str     = {d.name};

if isempty(str)
    errordlg('No probabilistic isomass map found! Did you already run the post-processing?', ' ');
    return
end

s       = listdlg('PromptString','Select one or multiple files to plot:',...
                'SelectionMode','multiple',...
                'ListString',str);
           
if ~isempty(s)
    
    display(sprintf('_____________________________________________________________________________________________\nTip: To save maps:\n\t1. Click on the map to save\n\t2. in the Matlab command line, type\n\t  >> print(gcf, ''-dpdf'', ''mapname.pdf'')\n\twhich will save the map under TephraProb/mapname.pdf\nYou can also type\n\t  >> saveAllMaps\n\tto save all opened maps to the root folder.\n _____________________________________________________________________________________________\n'))
    
    XX      = load(['GRID', filesep, project.grd_pth, filesep, project.grd_pth, '_lon.dat']);
    YY      = load(['GRID', filesep, project.grd_pth, filesep, project.grd_pth, '_lat.dat']);
    res     = (XX(1,2)-XX(1,1))/2;
    
    [vent_lat, vent_lon] = utm2ll(project.vent.east, project.vent.north, project.vent.zone);

    for i = 1:length(s)
        file    = load([project.run_pth, 'IM', filesep, 'MAT', filesep, str{s(i)}]);
        file(file<prefs.maps.min_mass) = nan;
        % Plot
        figure('Name',[project.run_name, '_IM_', str{s(i)}]);
        contours    = prefs.maps.mass_contour;                
        hd          = pcolor(XX-res,YY-res,file); shading flat; hold on;
        [c,h]       = contour(XX,YY,file,contours, 'Color', 'k');
        clabel(c,h, contours, 'LabelSpacing', 1000, 'FontWeight', 'bold')
        set(hd, 'FaceAlpha', 0.5)
        
        % Define scaling
        if prefs.maps.scale_pim == 1
           caxis([min(prefs.maps.mass_contour), max(prefs.maps.mass_contour)]); 
        end
        
        title(str{s(i)},'Interpreter', 'none');
        xlabel('Longitude');
        ylabel('Latitude');
        c = colorbar;
        ylabel(c, 'Tephra accumulation (kg m^-^2)');
        plot_google_map('maptype', 'terrain');
        
        plot(vent_lon, vent_lat, '^k', 'LineWidth', 2, 'MarkerFaceColor', 'r', 'MarkerSize', 15);
        
        % Plot grid extent
        if prefs.maps.plot_extent == 1
            gX = [XX(1,1), XX(1,end), XX(end,end), XX(end,1), XX(1,1)];
            gY = [YY(1,1), YY(1,end), YY(end,end), YY(end,1), YY(1,1)];
            plot(gX, gY, '-r', 'linewidth',0.5);
        end
        
        set(gca, 'Layer', 'top');
    end
end
