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

Name:       conf_points.m
Purpose:    Set points of interest for either i) use as a calculation grid
            or ii) use as points to compute hazard curves
Author:     S�bastien Biass
Created:    April 2015
Updates:    April 2015
Copyright:  S�bastien Biass, University of Geneva, 2015
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


function conf_points
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

scr = get(0,'ScreenSize');
w   = 600;
h   = 550;
cdp.fig = figure(...
    'position', [scr(3)/2-w/2 scr(4)/2-h/2 w h],...
    'Color', [.25 .25 .25],...
    'Resize', 'off',...
    'Tag', 'Configuration',...
    'Toolbar', 'none',...
    'Menubar', 'none',...
    'Name', 'TephraProb: Points configuration',...
    'NumberTitle', 'off');

% Menu
        cdp.menu0 = uimenu(cdp.fig, 'Label', 'File');
            cdp.load = uimenu(cdp.menu0, 'Label', 'Load points', 'Accelerator','O');
            cdp.import = uimenu(cdp.menu0, 'Label', 'Import points in a text file', 'Accelerator', 'I', 'Separator', 'on');

cdp.main = uipanel(...
    'units', 'normalized',...
    'position', [.025 .025 .95 .95],...
    'title', 'Points configuration',...
    'BackgroundColor', [.25 .25 .25],...
    'ForegroundColor', [.9 .5 0],...
    'HighlightColor', [.9 .5 0],...
    'BorderType', 'line');

            cdp.save = uicontrol(...
                'parent',cdp.main,...
                'Style', 'pushbutton',...
                'units', 'normalized',...
                'position', [.825 .025 .15 .075],...
                'BackgroundColor', [.3 .3 .3],...
                'ForegroundColor', [.9 .5 .0],...
                'String', 'Save');
            
%             cdp.load = uicontrol(...
%                 'parent',cdp.main,...
%                 'Style', 'pushbutton',...
%                 'units', 'normalized',...
%                 'position', [.665 .025 .15 .075],...
%                 'BackgroundColor', [.3 .3 .3],...
%                 'ForegroundColor', [.9 .5 .0],...
%                 'String', 'Load',...
%                 'Tooltip', 'Load points');

            cdp.map = uicontrol(...
                'parent',cdp.main,...
                'Style', 'pushbutton',...
                'units', 'normalized',...
                'position', [.665 .025 .15 .075],...
                'BackgroundColor', [.3 .3 .3],...
                'ForegroundColor', [.9 .5 .0],...
                'String', 'Plot map',...
                'Tooltip', 'Plot on a map');



            cdp.description = uicontrol(...
                'parent', cdp.main,...
                'style', 'text',...
                'units', 'normalized',...
                'position', [.025 .915 .8 .05],...
                'HorizontalAlignment', 'left',...
                'BackgroundColor', [.25 .25 .25],...
                'ForegroundColor', [1 1 1],...
                'String', 'Define points to use either as a calculation grid or as reference points for hazard curves');
            
            % Table panel
            cdp.view1 = uipanel(...
                'parent', cdp.main,...
                'units', 'normalized',...
                'position', [.025 .14 .95 .775],...
                'BackgroundColor', [.25 .25 .25],...
                'ForegroundColor', [.5 .5 .5],...
                'HighlightColor', [.3 .3 .3],...
                'BorderType', 'line');

            
                    cdp.name_txt = uicontrol(...
                        'parent', cdp.view1,...
                        'style', 'text',...
                        'units', 'normalized',...
                        'position', [.025 .895 .125 .05],...
                        'HorizontalAlignment', 'left',...
                        'BackgroundColor', [.25 .25 .25],...
                        'ForegroundColor', [1 1 1],...
                        'String', 'Name:');

                    cdp.name = uicontrol(...
                        'parent', cdp.view1,...
                        'style', 'edit',...
                        'unit', 'normalized',...
                        'position', [.175 .875 .3 .1],...
                        'HorizontalAlignment', 'left',...
                        'ForegroundColor', [1 1 1],...
                        'BackgroundColor', [.35 .35 .35]);

            
                    cdp.vent_txt = uicontrol(...
                        'parent', cdp.view1,...
                        'style', 'text',...
                        'units', 'normalized',...
                        'position', [.525 .895 .125 .05],...
                        'HorizontalAlignment', 'left',...
                        'BackgroundColor', [.25 .25 .25],...
                        'ForegroundColor', [1 1 1],...
                        'String', 'Vent zone:');

                    cdp.vent = uicontrol(...
                        'parent', cdp.view1,...
                        'style', 'edit',...
                        'unit', 'normalized',...
                        'position', [.675 .875 .3 .1],...
                        'HorizontalAlignment', 'left',...
                        'ForegroundColor', [1 1 1],...
                        'BackgroundColor', [.35 .35 .35],...
                        'Tooltip', 'The zone should be positive in the Northen hemisphere and negative in the Southern',...
                        'String', 'e.g. -18');


                    cdp.points_table = uitable(...
                        'Parent', cdp.view1,...
                        'Units', 'normalized',...
                        'Position', [.025 .125 .95 .725],...
                        'ColumnName', {'Name', 'Latitude', 'Longitude'},...
                        'ColumnFormat', {'char', 'numeric', 'numeric'},...
                        'ColumnEditable', [true true true],...
                        'ColumnWidth', {110 110 110},...
                        'BackgroundColor', [.5 .5 .5; .6 .6 .6],...
                        'RowStriping', 'on',...
                        'ForegroundColor', [1 1 1]);

                    
                    cdp.table_del = uicontrol(...
                        'parent',cdp.view1,...
                        'Style', 'pushbutton',...
                        'units', 'normalized',...
                        'position', [.9 .025 .075 .1],...
                        'BackgroundColor', [.3 .3 .3],...
                        'ForegroundColor', [.9 .5 .0],...
                        'String', '-',...
                        'Tooltip', 'Remove point');
                    
                    cdp.table_add = uicontrol(...
                        'parent',cdp.view1,...
                        'Style', 'pushbutton',...
                        'units', 'normalized',...
                        'position', [.825 .025 .075 .1],...
                        'BackgroundColor', [.3 .3 .3],...
                        'ForegroundColor', [.9 .5 .0],...
                        'String', '+',...
                        'Tooltip', 'Add point');
                    

% Callbacks
set(cdp.table_del, 'callback', {@but_table_del, cdp})
set(cdp.table_add, 'callback', {@but_table_add, cdp})
set(cdp.save, 'Callback', {@but_save, cdp})
set(cdp.load, 'Callback', {@but_load, cdp})
set(cdp.import, 'Callback', {@import_csv, cdp})
set(cdp.map, 'Callback', {@but_map, cdp})

% Adapt display accross plateforms
set_display



% Map button
function cdp = but_map(~, ~, cdp)
points = get(cdp.points_table, 'Data');

figure; hold on; xlabel('Longitude'); ylabel('Latitude');

x = [points{:,3}];
y = [points{:,2}];
xx = [min(x), max(x)];
yy = [min(y), max(y)];
xE = 0.25*(max(x)-min(x));
yE = 0.25*(max(y)-min(y));

plot(xx(1)-xE, yy(1)-yE, '.k', 'MarkerSize', 0.1);
plot(xx(2)+xE, yy(2)+yE, '.k', 'MarkerSize', 0.1);
plot_openstreetmap('scale', 2);

for i = 1:size(points,1)
    plot(points{i,3}, points{i,2}, 'or', 'MarkerSize', 7, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r');
    text(points{i,3}, points{i,2}, ['  \leftarrow  ', points{i,1}]);
end

% plot_google_map('maptype','terrain', 'MapScale', 1);

set(gca, 'Layer', 'top');

% Load button
function cdp = but_load(~, ~, cdp)
[flname, dirname] = uigetfile(fullfile('GRID','*.points'), 'Select a .points file to load');

if flname == 0
    return
else
    load(fullfile(dirname, flname), '-mat', 'grid');
end

set(cdp.points_table, 'Data', grid.points);
set(cdp.name, 'String', grid.grd_name);
set(cdp.vent, 'String', grid.vent_zone);

function cdp = import_csv(~, ~, cdp)
fprintf('Choose a 3-columns tab delimited text file file containing site name, latitude, longitude.\nNote that the file should have no header!\n')

[fl,pth] = uigetfile('*.txt');
if fl == 0; return; end

fid = fopen(fullfile(pth,fl));
data = textscan(fid, '%s %.04f %.04f');
fclose(fid);
set(cdp.points_table, 'Data', [data{1}, num2cell(data{2}), num2cell(data{3})]);

% Save button
function cdp = but_save(~, ~, cdp)

% Retrieve parameters
points      = get(cdp.points_table, 'Data');
grd_name    = get(cdp.name, 'String');
vent_zone   = get(cdp.vent, 'String');

% Check inputs
if isempty(points) || isempty(grd_name) || strcmp('e.g.', vent_zone)
    errordlg('Please fill all parameters', ' ');
    return
end

% Storage matrices
stor_grid   = zeros(size(points,1),3);
stor_points = cell(size(points,1), 3);

% Fills storage matrices
for i = 1:size(points, 1)
    %[e, n]              = ll2utm(points{i,2}, points{i,3}, str2double(regexp(vent_zone,'\d+', 'match')));
    [e, n]              = ll2utm(points{i,2}, points{i,3}, str2double(regexp(vent_zone,'\d+', 'match')));
    stor_grid(i,1:2)    = [e,n];
    stor_points{i,1}    = points{i,1};
    stor_points{i,2}    = e;
    stor_points{i,3}    = n;
end

% Save grid file
check = 1;
if exist(['GRID/', grd_name], 'dir') == 7
    choice = questdlg('A grid with the same name already exists. Overwrite?', ...
        '', ...
        'No','Yes','No');
    % Handle response
    switch choice
        case 'Yes'
            rmdir(fullfile('GRID', grd_name), 's');
            check = 1;
        case 'No'
            return
    end    
end

if check == 1
    mkdir(fullfile('GRID', grd_name));
    % Write grid file
    fid = fopen(fullfile('GRID', grd_name, [grd_name, '.utm']), 'wt');
    for i = 1:size(points,1)
        fprintf(fid, '%05.1f\t%06.1f\t%.0f\n', stor_grid(i,1), stor_grid(i,2), stor_grid(i,3));
    end
    fclose(fid);
    % Save
    grid.points     = points;
    grid.grd_name   = grd_name;
    grid.vent_zone  = vent_zone;
    grid.stor_points= stor_points;
    save(fullfile('GRID', grd_name, [grd_name, '.points']), 'grid');
    warndlg('Points successfully saved!');
end

% Delete row
function cdp =  but_table_del(~, ~, cdp)
        dta = get(cdp.points_table, 'Data');
        dta(length(dta(:,1)),:) = [];
        set(cdp.points_table, 'Data', dta);
        
% Add row
function cdp =  but_table_add(~, ~, cdp)
        dta = get(cdp.points_table, 'Data');
        dta = [dta; {'', [], []}];
        set(cdp.points_table, 'Data', dta);
