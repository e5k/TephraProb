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

Name:       analyze_wind.m
Purpose:    Main GUI to analyze wind conditions
Author:     Sebastien Biass
Created:    April 2015
Updates:    Octobre 2015    Updated wind_rose by WindRose for compatibility,
                            corrected bug in error bars
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


function analyze_wind
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

global w2 stor_data stor_time

[FileName, FilePath] = uigetfile('WIND/*.mat', 'Load a wind project', 'wind.mat');

if FileName==0
    return
end
    
load([FilePath, filesep, FileName]);

% Make sure time is as datevec
if size(stor_time, 2) == 1
    stor_time = datevec(stor_time);
end

scr = get(0,'ScreenSize');
w   = 650;
h   = 600;
w2.fig = figure(...
    'position', [scr(3)/2-w/2 scr(4)/2-h/2 w h],...
    'Color', [.25 .25 .25],...
    'Resize', 'off',...
    'Tag', 'Configuration',...
    'Toolbar', 'none',...
    'Menubar', 'none',...
    'Name', 'Wind analysis',...
    'NumberTitle', 'off');

    w2.wind1 = uipanel(...
        'units', 'normalized',...
        'position', [.03 .03 .94 .94],...
        'title', 'Analyse Wind',...
        'BackgroundColor', [.25 .25 .25],...
        'ForegroundColor', [.9 .5 0],...
        'HighlightColor', [.9 .5 0],...
        'BorderType', 'line');

        % TYPE PANNEL
        w2.type = uibuttongroup(...
            'parent', w2.wind1,...
            'units', 'normalized',...
            'position', [.05 .18 .2062 .27],...
            'BackgroundColor', [.25 .25 .25],...
            'ForegroundColor', [.5 .5 .5],...
            'HighlightColor', [.3 .3 .3],...
            'BorderType', 'line',...
            'Title', 'Type',...
            'SelectionChangeFcn', @TYPE_SCF);

                w2.type_profiles = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.type,...
                    'units', 'normalized',...
                    'position', [.2 .735 .78 .17],...
                    'BackgroundColor', [.25 .25 .25],...
                    'ForegroundColor', [1 1 1],...
                    'String', 'Profiles');

                w2.type_roses = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.type,...
                    'units', 'normalized',...
                    'position', [.2 .54 .78 .17],...
                    'BackgroundColor', [.25 .25 .25],...
                    'ForegroundColor', [1 1 1],...
                    'String', 'Roses');


        % SUBTYPE PANNEL
        w2.subtype = uibuttongroup(...
            'parent', w2.wind1,...
            'units', 'normalized',...
            'position', [.2812 .18 .2062 .27],...
            'BackgroundColor', [.25 .25 .25],...
            'ForegroundColor', [.5 .5 .5],...
            'HighlightColor', [.3 .3 .3],...
            'BorderType', 'line',...
            'Title', 'Average',...
            'SelectionChangeFcn', @AVRG_SCF);

                w2.subtype_average = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.subtype,...
                    'units', 'normalized',...
                    'position', [.2 .735 .78 .17],...
                    'BackgroundColor', [.25 .25 .25],...
                    'ForegroundColor', [1 1 1],...
                    'String', 'Averaged');

                w2.subtype_separate = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.subtype,...
                    'units', 'normalized',...
                    'position', [.2 .54 .78 .17],...
                    'BackgroundColor', [.25 .25 .25],...
                    'ForegroundColor', [1 1 1],...
                    'String', 'Separate');


        % Altitude PANNEL    
        str_alt = cell(size(stor_data,1),1);
        for iA = 1:size(stor_data,1)
            tmp_mean    = mean(stor_data(iA,1,:),3)/1000; 
            tmp_std     = std(stor_data(iA,1,:),0,3)/1000;
            str_alt{iA} = [num2str(tmp_mean, '%.1f'), ' +- ', num2str(tmp_std, '%.2f'), ' km'];
        end

        w2.altitude = uibuttongroup(...
            'parent', w2.wind1,...
            'units', 'normalized',...
            'position', [.2812 .18 .2062 .27],...
            'BackgroundColor', [.25 .25 .25],...
            'ForegroundColor', [.5 .5 .5],...
            'HighlightColor', [.3 .3 .3],...
            'BorderType', 'line',...
            'Title', 'Altitude',...
            'Visible', 'off');

                w2.altitude_table = uicontrol(...
                    'style', 'listbox',...
                    'Parent', w2.altitude,...
                    'units', 'normalized',...
                    'position', [.05 .05 .9 .9],...
                    'BackgroundColor', [.3 .3 .3],...
                    'ForegroundColor', [1 1 1],...
                    'String', str_alt,...
                    'Max', 10);


        % TIME PANNEL   
        w2.time = uibuttongroup(...
            'parent', w2.wind1,...
            'units', 'normalized',...
            'position', [.5124 .18 .2062 .27],...
            'BackgroundColor', [.25 .25 .25],...
            'ForegroundColor', [.5 .5 .5],...
            'HighlightColor', [.3 .3 .3],...
            'BorderType', 'line',...
            'Title', 'Time',...
            'SelectionChangeFcn', @TIME_SCF);

                w2.time_all = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.time,...
                    'units', 'normalized',...
                    'position', [.2 .735 .78 .17],...
                    'BackgroundColor', [.25 .25 .25],...
                    'ForegroundColor', [1 1 1],...
                    'String', 'All');

                w2.time_years = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.time,...
                    'units', 'normalized',...
                    'position', [.2 .54 .78 .17],...
                    'BackgroundColor', [.25 .25 .25],...
                    'ForegroundColor', [1 1 1],...
                    'String', 'Years');

                w2.time_months = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.time,...
                    'units', 'normalized',...
                    'position', [.2 .345 .78 .17],...
                    'BackgroundColor', [.25 .25 .25],...
                    'ForegroundColor', [1 1 1],...
                    'String', 'Months');

                w2.time_separate = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.time,...
                    'units', 'normalized',...
                    'position', [.2 .15 .78 .17],...
                    'BackgroundColor', [.25 .25 .25],... 
                    'ForegroundColor', [1 1 1],...
                    'String', 'Profiles',...
                    'Enable', 'off');


        % SUBTIME PANNEL      
        w2.subtime = uibuttongroup(...
            'parent', w2.wind1,...
            'units', 'normalized',...
            'position', [.7436 .18 .2062 .27],...
            'BackgroundColor', [.25 .25 .25],...
            'ForegroundColor', [.5 .5 .5],...
            'HighlightColor', [.3 .3 .3],...
            'BorderType', 'line',...
            'Title', 'Subset');

                w2.subtime_table = uicontrol(...
                    'style', 'listbox',...
                    'Parent', w2.subtime,...
                    'units', 'normalized',...
                    'position', [.05 .05 .9 .9],...
                    'BackgroundColor', [.3 .3 .3],...
                    'ForegroundColor', [1 1 1],...
                    'String', {},...
                    'Max', 10);

         % OPTIONS MEAN/MEDIAN PANNEL
         w2.opt1 = uibuttongroup(...
            'parent', w2.wind1,...
            'units', 'normalized',...
            'position', [.05 .035 .2062 .13],...
            'BackgroundColor', [.25 .25 .25],...
            'ForegroundColor', [.5 .5 .5],...
            'HighlightColor', [.3 .3 .3],...
            'BorderType', 'line',...
            'Title', 'Average type');

                w2.opt_median = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.opt1,...
                    'units', 'normalized',...
                    'position', [.2 .55 .78 .4],...
                    'BackgroundColor', [.25 .25 .25],...
                    'ForegroundColor', [1 1 1],...
                    'String', 'Median');

                w2.opt_mean = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.opt1,...
                    'units', 'normalized',...
                    'position', [.2 .15 .78 .4],...
                    'BackgroundColor', [.25 .25 .25],...
                    'ForegroundColor', [1 1 1],...
                    'String', 'Mean');


         % OPTIONS PLOT PANNEL
         w2.opt2 = uibuttongroup(...
            'parent', w2.wind1,...
            'units', 'normalized',...
            'position', [.2812 .035 .2062 .13],...
            'BackgroundColor', [.25 .25 .25],...
            'ForegroundColor', [.5 .5 .5],...
            'HighlightColor', [.3 .3 .3],...
            'BorderType', 'line',...
            'Title', 'Direction',...
            'SelectionChangeFcn', @CHG_DIR);

                w2.opt_direction = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.opt2,...
                    'units', 'normalized',...
                    'position', [.2 .55 .78 .4],...
                    'BackgroundColor', [.25 .25 .25],...
                    'ForegroundColor', [1 1 1],...
                    'String', 'Direction');

                w2.opt_provenance = uicontrol(...
                    'style', 'radiobutton',...
                    'parent', w2.opt2,...
                    'units', 'normalized',...
                    'position', [.2 .15 .78 .4],...
                    'BackgroundColor', [.25 .25 .25],...
                    'ForegroundColor', [1 1 1],...
                    'String', 'Provenance'); 

        w2.plot = uicontrol(...
            'style', 'pushbutton',...
            'parent', w2.wind1,...
            'units', 'normalized',...
            'position', [.5124 .035 .2062 .113],...
            'BackgroundColor', [.3 .3 .3],...
            'ForegroundColor', [.9 .5 .0],...
            'String', 'Plot',...
            'Callback', @PREP_DATA);

        w2.export = uicontrol(...
            'style', 'pushbutton',...
            'parent', w2.wind1,...
            'units', 'normalized',...
            'position', [.7436 .035 .2062 .113],...
            'BackgroundColor', [.3 .3 .3],...
            'ForegroundColor', [.9 .5 .0],...
            'String', 'Zoom/export',...
            'Callback', @PREP_DATA);
        
        w2.m = uimenu(w2.fig,'Label','Tools');
           uimenu(w2.m,'Label','Find similar profile', 'Callback', @similar);
        
        average_whole(0);

%% Callback functions

function similar(~, ~)
global w2 stor_data stor_time

if w2.type_roses.Value == 1 || w2.subtype_separate.Value == 1
    errordlg('To use this function, you must plot averaged profiles')
    return
end

% Make sure the data is ploted
PREP_DATA(w2.plot);

% Check if user data already defined
if isfield(w2.fig.UserData, 'hts')
    inpt = w2.fig.UserData.hts;
else
    inpt = {'1','30'};
end

answer = inputdlg({'Minimum height (km asl)', 'Maximum height (km asl)'},...
    'Heights',...
    [1 35],...
    inpt);

if isempty(answer)
    return
end

% Filter elevation
alt     = mean(stor_data(:,1,:),3)./1e3;
aIdx    = alt >= str2double(answer{1}) & alt <= str2double(answer{2});

% Filter time
if strcmp(w2.time.SelectedObject.String, 'All')
    tIdx    = ones(size(stor_time,1), 1);
elseif strcmp(w2.time.SelectedObject.String, 'Years')
    sel_val = get(w2.subtime_table, 'Value');
    sel_str = get(w2.subtime_table, 'String');
    tIdx    = str2double(sel_str(sel_val))';
    tIdx    = sum(stor_time(:,1) == tIdx,2);
elseif strcmp(w2.time.SelectedObject.String, 'Months')
    tIdx    = w2.subtime_table.Value;
    tIdx    = sum(stor_time(:,2) == tIdx,2);
end

% Filter data
data_tmp = stor_data(aIdx, 2:3, logical(tIdx));
time_tmp = stor_time(logical(tIdx), :);
time_idx = 1:size(stor_time,1);

% Retrieve averaged data from plots
vel = w2.s1.Children(1).XData'; vel = vel(aIdx);
dir = w2.s2.Children(1).XData'; dir = dir(aIdx);

% Calculate the RMSE
% Shitty loop to correct the direction
for i = 1:size(data_tmp,3)
    data_tmp(data_tmp(:,2,i)>180,2,i) = -(360-data_tmp(data_tmp(:,2,i)>180,2,i));
end
dir(dir>180) = -(360-dir(dir>180));

velRMSE = squeeze(sqrt((sum(data_tmp(:,1,:)-vel,1).^2)/numel(aIdx)));
dirRMSE = squeeze(sqrt((sum(abs(data_tmp(:,2,:)-dir),1).^2)/numel(aIdx)));
sqr = velRMSE.^2 + dirRMSE.^2;
[~, idx] = sort(sqr);

windNb      = cellstr(num2str(time_idx(idx)','%05.0f'));
windTime    = cellstr(datestr(time_tmp(idx,:), 'yyyy-mm-dd hhz'));

scr = get(0,'ScreenSize');
w   = 250;
h   = 350;


w3.fig = figure(...
    'position', [scr(3)/2-w/2 scr(4)/2-h/2 w h],...
    'Color', [.25 .25 .25],...
    'Resize', 'off',...
    'Tag', 'Configuration',...
    'Toolbar', 'none',...
    'Menubar', 'none',...
    'Name', 'Similar wind profiles',...
    'NumberTitle', 'off');

    w3.pan = uipanel(...
        'units', 'normalized',...
        'position', [.03 .03 .94 .94],...
        'title', 'Profile selection',...
        'BackgroundColor', [.25 .25 .25],...
        'ForegroundColor', [.9 .5 0],...
        'HighlightColor', [.9 .5 0],...
        'BorderType', 'line');
    
    w3.txt = uicontrol(...
                'parent', w3.pan,...
                'style', 'text',...
                'units', 'normalized',...
                'position', [.05 .8 .9 .15],...
                'HorizontalAlignment', 'left',...
                'BackgroundColor', [.25 .25 .25],...
                'ForegroundColor', [1 1 1],...
                'String', 'Select the profile(s) to plot. Profiles are ordered in decreasing similarity.');
            
    w3.tbl = uicontrol(...
                    'style', 'listbox',...
                    'Parent', w3.pan,...
                    'units', 'normalized',...
                    'position', [.05 .2 .9 .6],...
                    'BackgroundColor', [.3 .3 .3],...
                    'ForegroundColor', [1 1 1],...
                    'Max', 100,...
                    'String', strcat(windTime(1:100), ' -  ', windNb(1:100), '.gen'));
                
                
    w3.plot = uicontrol(...
        'style', 'pushbutton',...
        'parent', w3.pan,...
        'units', 'normalized',...
        'position', [.525 .025 .425 .15],...
        'BackgroundColor', [.3 .3 .3],...
        'ForegroundColor', [.9 .5 .0],...
        'String', 'Plot',...
        'Callback', @pltSim);
    
%     w3.clear = uicontrol(...
%         'style', 'pushbutton',...
%         'parent', w3.pan,...
%         'units', 'normalized',...
%         'position', [.05 .025 .425 .15],...
%         'BackgroundColor', [.3 .3 .3],...
%         'ForegroundColor', [.9 .5 .0],...
%         'String', 'Clear',...
%         'Callback', @pltSim);

data2plot = stor_data(:,:,time_idx(idx(1:100)));
    
w3data.idx = idx(1:100);
w3data.windNb = windNb(1:100);
w3data.data = data2plot;
guidata(w3.fig, w3data);

function pltSim(~, ~)
global w2

data = guidata(w2.fig);

if isempty(findobj('tag','similar'))
    delete(findobj('tag','similar'))
end

f = figure('tag', 'similar');
ax1 = subplot(1,2,1, 'tag','ax1');
errorbar_x(data(:,2,1), data(:,1,1)./1000, data(:,2,2), data(:,2,3));
title('Wind velocity','FontWeight','Bold');
xlabel('Velocity (m/s)');
ylabel('Height (km)');
hold on

ax2 = subplot(1,2,2, 'tag','ax2');
errorbar_x(data(:,3,1), data(:,1,1)./1000, data(:,3,2), data(:,3,3));
title('Wind direction','FontWeight','Bold');
xlabel('Direction (degrees)');
ylabel('Height (km)');
hold on

a1 = get(ax1, 'Children');
set(a1(1), 'Color', [0 0 0], 'LineWidth', 1); set(a1(2), 'Color', [.7 .7 .7]);
ax1.YLim(1)=0;
a2 = get(ax2, 'Children');
set(a2(1), 'Color', [0 0 0], 'LineWidth', 1); set(a2(2), 'Color', [.7 .7 .7]);
ax2.YLim(1)=0;
ax2.XLim = [0, 359];
ax2.XTick = [0,90,180,270];

[~,w3] = gcbo;
dataw3 = guidata(w3);
lst = findobj(w3, 'Style', 'listbox');
lstI = lst.Value;

cmap = lines(numel(lstI));
for i = 1:numel(lstI)
    hdl(i) = plot(ax1, dataw3.data(:,2,lstI(i)), dataw3.data(:,1,lstI(i))./1000, 'color', cmap(i,:));
    plot(ax2, dataw3.data(:,3,lstI(i)), dataw3.data(:,1,lstI(i))./1000, 'color', cmap(i,:));
end
legend(hdl,cellstr(strcat(num2str(dataw3.idx(lstI),'%05.0f'),'.gen')), 'Location', 'SouthEast');

% Selection change function for type pannel
function TYPE_SCF(~, eventdata)
global w2
if strcmp(get(eventdata.NewValue, 'String'), 'Roses')
    set(w2.subtype_average, 'Value', 1);
    set(w2.subtype, 'Visible', 'off');
    set(w2.altitude, 'Visible', 'on');
    set(w2.time_separate, 'Enable', 'off');
    if get(w2.time_separate, 'Value') == 1
        set(w2.time_all, 'Value', 1);
        set(w2.subtime_table, 'String', {});
    end
elseif strcmp(get(eventdata.NewValue, 'String'), 'Profiles')
    set(w2.subtype, 'Visible', 'on');
    set(w2.altitude, 'Visible', 'off');
    set(w2.time_separate, 'Enable', 'on');
end

% Selection change function for average pannel
function AVRG_SCF(~, eventdata)
global w2 stor_time
if strcmp(get(eventdata.NewValue, 'String'), 'Separate')
    set(w2.time_all, 'Enable', 'off');
    if get(w2.time_all, 'Value') == 1
        set(w2.time_years, 'Value', 1);
        set(w2.subtime_table, 'String', cellstr(num2str(unique(stor_time(:,1)))));
    end
else
    set(w2.time_all, 'Enable', 'on');
end
if strcmp(get(eventdata.NewValue, 'String'), 'Averaged')
    set(w2.time_separate, 'Enable', 'off');
    if get(w2.time_separate, 'Value') == 1
        set(w2.time_all, 'Value', 1);
        set(w2.subtime_table, 'String', {});
    end
else
    set(w2.time_separate, 'Enable', 'on');
end

% Selection change function for time pannel
function TIME_SCF(~, eventdata)
global w2 stor_time
set(w2.subtime_table, 'Value', []);
if strcmp(get(eventdata.NewValue, 'String'), 'All')
    tmpstr = {};
elseif strcmp(get(eventdata.NewValue, 'String'), 'Years')
    tmpstr = cellstr(num2str(unique(stor_time(:,1)))); 
elseif strcmp(get(eventdata.NewValue, 'String'), 'Months')
    tmpstr = cellstr(num2str(unique(stor_time(:,2)))); 
elseif strcmp(get(eventdata.NewValue, 'String'), 'Profiles')
    tmpstr = cellstr(datestr(stor_time, 'yyyy/mm/dd HH'));
end
set(w2.subtime_table, 'String', tmpstr);    % Set string
set(w2.subtime_table, 'Value', 1);          % Set selected value

%% Averaging functions

% Prepare data for plotting
function PREP_DATA(hObject, ~)
global w2 stor_data trgt

% Identifies errors
% Case any othe time than All and no subset selected
if ~strcmp(get(get(w2.time, 'SelectedObject'), 'String'), 'All') && isempty(length(get(w2.subtime_table, 'Value')))
    errordlg('When plotting roses, please select only one time subset', ' ');
    return
% Case Roses and single profiles    
elseif strcmp(get(get(w2.type, 'SelectedObject'), 'String'), 'Roses') && strcmp(get(get(w2.time, 'SelectedObject'), 'String'), 'Profiles')
    errordlg('You can not plot roses for single profiles', ' ');
    return
% Case single profiles and multiple time subsets    
elseif strcmp(get(get(w2.time, 'SelectedObject'), 'String'), 'Profiles') && length(get(w2.subtime_table, 'Value')) > 1
    errordlg('Please select one single profile at the time', ' ');
    return
% Case separate and empty selection
elseif strcmp(get(get(w2.subtype, 'SelectedObject'), 'String'), 'Separate') && isempty(get(w2.subtime_table, 'Value'))
    errordlg('Please select one time subset', ' ');
    return
end

% Identifies target for plotting
if strcmp(get(hObject, 'String'), 'Plot')
    trgt = 0;   % GUI axis
else
    trgt = 1;   % New figure
end


switch get(get(w2.type, 'SelectedObject'), 'String')
    case 'Profiles'
        switch get(get(w2.time, 'SelectedObject'), 'String')
            case 'All'
                switch get(get(w2.subtype, 'SelectedObject'), 'String')
                    case 'Averaged'
                        average_whole(0);
                    case 'Separate'
                        errordlg('Quit messing around with the program!', ' ');
                        return;
                end
                
            case 'Years'                  
                switch get(get(w2.subtype, 'SelectedObject'), 'String')
                    case 'Averaged'
                        average_whole(1);
                    case 'Separate'
                        average_sep(1);
                end
                
            case 'Months'
                switch get(get(w2.subtype, 'SelectedObject'), 'String')
                    case 'Averaged'
                        average_whole(2);
                    case 'Separate'
                        average_sep(2);
                end
                
            case 'Profiles'
                switch get(get(w2.subtype, 'SelectedObject'), 'String')
                    case 'Averaged'
                        errordlg('Quit messing around with the program!', ' ');
                        return;
                    case 'Separate'
                        data = stor_data(:,:,get(w2.subtime_table, 'Value'));
                        plot_profile_single(data, trgt)
                end 
        end
    
    case 'Roses'
        switch get(get(w2.time, 'SelectedObject'), 'String')
            case 'All'
                average_rose(0);
            case 'Years'
                average_rose(1);
            case 'Months'
                average_rose(2);
            case 'Profiles'
                errordlg('Quit messing around with the program!', ' ');
                return;
        end 
end

% Check direction/provenance
function CHG_DIR(hObject, ~)
global stor_data

if strcmp(get(get(hObject, 'SelectedObject'), 'String'), 'Provenance')
    
    % Only way to index along the 1st and 3rd dimensions!
    [x,perm,nshifts] = shiftdata(stor_data(:,3,:),2);
    x = x + 180;
    x(x>360) = x(x>360)-360;
    stor_data(:,3,:) = unshiftdata(x,perm,nshifts);
    
elseif strcmp(get(get(hObject, 'SelectedObject'), 'String'), 'Direction')   
    % Only way to index along the 1st and 3rd dimensions!
    [x,perm,nshifts] = shiftdata(stor_data(:,3,:),2);
    x = x - 180;
    x(x<0) = x(x<0)+360;
    stor_data(:,3,:) = unshiftdata(x,perm,nshifts);
end


% Prepare data for averaged profiles
function dout = average_whole(typ)
global w2 stor_data stor_time trgt
% Typ 0 -> Whole
% Typ 1 -> Years
% Typ 2 -> Months

dout = zeros(size(stor_data,1), size(stor_data,2), 3);

if typ == 0
    tmp = stor_data;
else
    sel_val = get(w2.subtime_table, 'Value');
    sel_str = get(w2.subtime_table, 'String');
    subset  = str2double(sel_str(sel_val));
    if typ == 1       
        idx     = ismember(stor_time(:,typ),subset);
        tmp     = stor_data(:,:,idx);
    elseif typ == 2      
        idx     = ismember(stor_time(:,typ),subset);
        tmp     = stor_data(:,:,idx);
    end
end


% Check mean/median option
if strcmp(get(get(w2.opt1, 'SelectedObject'), 'String'), 'Median')
    dout(:,:,1) = median(tmp,3);
    dout(:,:,2) = dout(:,:,1) - get_prc(tmp, 25);
    dout(:,:,3) = get_prc(tmp, 75) - dout(:,:,1);
else
    dout(:,:,1) = mean(tmp,3);
    dout(:,:,2) = std(tmp, 0, 3);
    dout(:,:,3) = std(tmp, 0, 3);
end

guidata(w2.fig, dout);

plot_profile_all(dout, trgt)

% Prepare data for separate profiles
function dout = average_sep(typ)
global w2 stor_data stor_time trgt
% Typ 1 -> Years
% Typ 2 -> Months

% Make sure time is as datevec
if size(stor_time, 2) == 1
    stor_time = datevec(stor_time)
end

sel_val = get(w2.subtime_table, 'Value');
sel_str = get(w2.subtime_table, 'String');
subset  = str2double(sel_str(sel_val));

dout = zeros(size(stor_data,1), size(stor_data,2), length(subset));

for iS = 1:length(subset)
    tmp = stor_data(:,:,stor_time(:,typ)==subset(iS));
    if strcmp(get(get(w2.opt1, 'SelectedObject'), 'String'), 'Median')
        dout(:,:,iS) = median(tmp,3);
    else
        dout(:,:,iS) = mean(tmp,3);
    end
end

plot_profile_separate(dout, trgt)

% Prepare data for wind roses
function dout = average_rose(typ)
global w2 stor_data stor_time trgt
% Typ 0 -> Whole
% Typ 1 -> Years
% Typ 2 -> Months

alt     = get(w2.altitude_table, 'Value');

if typ == 0
   dout = stor_data(alt,:,:);
else
    sel_val = get(w2.subtime_table, 'Value');
    sel_str = get(w2.subtime_table, 'String');
    subset  = str2double(sel_str(sel_val));
    if typ == 1
        idx     = ismember(stor_time(:,typ),subset);
        dout    = stor_data(alt,:,idx);
    elseif typ == 2
        idx     = ismember(stor_time(:,typ),subset);
        dout    = stor_data(alt,:,idx);
    end
end

plot_roses(dout, trgt);

%% Plotting functions
% Plot single profiles
function plot_profile_single(data, trgt)
global w2 

% Prepare data
data = check_data(data);

XMIN=0; XMAX=360;
YMIN=0; YMAX=35;

% If previous axes exist, delete them

if trgt == 1
    fig = figure;
    prnt = fig;
    pos1 = [.1 .1 .35 .8]; pos2 = [.6 .1 .35 .8];
    clr = [0 0 0]; siz = 10;
else
    prnt = w2.wind1;
    pos1 = [.1 .53 .35 .42]; pos2 = [.575 .53 .35 .42];
    clr = [1 1 1]; siz = 8;
end

w2.s1 = subplot('position', pos1, 'units', 'normalized', 'Parent', prnt,  'XColor', clr, 'YColor', clr, 'FontSize', siz); 
plot(data(:,2), data(:,1)./1000, 'Color', 'k', 'LineWidth', 1);
title('Wind velocity','FontWeight','Bold', 'Color', clr, 'FontSize', siz);
xlabel('Velocity (m/s)', 'Color', clr, 'FontSize', siz);
ylabel('Height (km)', 'Color', clr, 'FontSize', siz);
axis([0 40 YMIN YMAX]);
set(w2.s1, 'XColor', clr, 'YColor', clr, 'FontSize', siz);

w2.s2 = subplot('position', pos2, 'units', 'normalized', 'Parent',prnt, 'XColor', clr, 'YColor', clr, 'FontSize', siz);
plot(data(:,3), data(:,1)./1000, 'Color', 'k', 'LineWidth', 1);
title('Wind direction','FontWeight','Bold', 'Color', clr, 'FontSize', siz);
xlabel('Direction (degrees)', 'Color', clr, 'FontSize', siz);
ylabel('Height (km)', 'Color', clr, 'FontSize', siz);
axis([XMIN XMAX YMIN YMAX])
set(w2.s2,'xtick',[0 90 180 270 360]);
set(w2.s2, 'XColor', clr, 'YColor', clr, 'FontSize', siz);

% Plot separate profiles
function plot_profile_separate(data, trgt)
global w2 

% Prepare data
data = check_data(data);

XMIN=0; XMAX=360;
YMIN=0; YMAX=45;

% If previous axes exist, delete them

if trgt == 1
    fig = figure;
    prnt = fig;
    pos1 = [.1 .1 .35 .8]; pos2 = [.6 .1 .35 .8];
    clr = [0 0 0]; siz = 10;
else
    prnt = w2.wind1;
    pos1 = [.1 .53 .35 .42]; pos2 = [.575 .53 .35 .42];
    clr = [1 1 1]; siz = 8;
end

cmap = linspecer(size(data,3));

w2.s1 = subplot('position', pos1, 'units', 'normalized', 'Parent', prnt, 'XColor', clr, 'YColor', clr, 'FontSize', siz); 
title('Wind velocity','FontWeight','Bold', 'Color', clr, 'FontSize', siz);
xlabel('Velocity (m/s)', 'Color', clr, 'FontSize', siz);
ylabel('Height (km)', 'Color', clr, 'FontSize', siz);
axis([0 40 YMIN YMAX]);
set(w2.s1, 'XColor', clr, 'YColor', clr, 'FontSize', siz);
hold on

w2.s2 = subplot('position', pos2, 'units', 'normalized', 'Parent',prnt, 'XColor', clr, 'YColor', clr, 'FontSize', siz);
title('Wind direction','FontWeight','Bold', 'Color', clr, 'FontSize', siz);
xlabel('Direction (degrees)', 'Color', clr, 'FontSize', siz);
ylabel('Height (km)', 'Color', clr, 'FontSize', siz);
axis([XMIN XMAX YMIN YMAX])
set(w2.s2,'xtick',[0 90 180 270 360]);
set(w2.s2, 'XColor', clr, 'YColor', clr, 'FontSize', siz);
hold on

axes(w2.s1)
for i = 1:size(data,3)
    plot(data(:,2,i), data(:,1,i)./1000, 'Color', cmap(i,:), 'LineWidth', 1);
end

axes(w2.s2)
for i = 1:size(data,3)  
    plot(data(:,3,i), data(:,1,i)./1000, 'Color', cmap(i,:), 'LineWidth', 1);
end

% Prepare legend
sel_val = get(w2.subtime_table, 'Value');
sel_str = get(w2.subtime_table, 'String');
legend(sel_str(sel_val));

% Plot averaged profiles
function plot_profile_all(data, trgt)
global w2 

% Prepare data
data = check_data(data);

XMIN=0; XMAX=360;
YMIN=0; YMAX=45;

if trgt == 1
    fig = figure;
    prnt = fig;
    pos1 = [.1 .1 .35 .8]; pos2 = [.6 .1 .35 .8];
    clr = [0 0 0]; siz = 10;
else
    prnt = w2.wind1;
    pos1 = [.1 .53 .35 .42]; pos2 = [.575 .53 .35 .42];
    clr = [1 1 1]; siz = 8;   
end

%w2.s1 = subplot(1,2,1, 'units', 'normalized', 'Parent', prnt, 'position', pos1, 'XColor', clr, 'YColor', clr, 'FontSize', siz); 
%errorbar_x(data(:,2,1), data(:,1,1)./1000, data(:,2,1)-data(:,2,2), data(:,2,3)-data(:,2,1));
w2.s1 = subplot('position', pos1, 'XColor', clr, 'YColor', clr, 'FontSize', siz, 'units', 'normalized', 'Parent', prnt);
errorbar_x(data(:,2,1), data(:,1,1)./1000, data(:,2,2), data(:,2,3));
title('Wind velocity','FontWeight','Bold', 'Color', clr, 'FontSize', siz);
xlabel('Velocity (m/s)', 'Color', clr, 'FontSize', siz);
ylabel('Height (km)', 'Color', clr, 'FontSize', siz);
axis([0 40 YMIN YMAX]);

%w2.s2 = subplot(1,2,2, 'units', 'normalized', 'Parent',prnt, 'position', pos2, 'XColor', clr, 'YColor', clr, 'FontSize', siz);
%errorbar_x(data(:,3,1), data(:,1,1)./1000, data(:,3,1)-data(:,3,2), data(:,3,3)-data(:,3,1));
w2.s2 = subplot('position', pos2, 'XColor', clr, 'YColor', clr, 'FontSize', siz, 'units', 'normalized', 'Parent', prnt);
errorbar_x(data(:,3,1), data(:,1,1)./1000, data(:,3,2), data(:,3,3));
title('Wind direction','FontWeight','Bold', 'Color', clr, 'FontSize', siz);
xlabel('Direction (degrees)', 'Color', clr, 'FontSize', siz);
ylabel('Height (km)', 'Color', clr, 'FontSize', siz);
axis([XMIN XMAX YMIN YMAX])

a1 = get(w2.s1, 'Children');
set(a1(1), 'Color', [0 0 0], 'LineWidth', 1); set(a1(2), 'Color', [.7 .7 .7]);
set(w2.s1, 'XColor', clr, 'YColor', clr, 'FontSize', siz);

a2 = get(w2.s2, 'Children');
set(a2(1), 'Color', [0 0 0], 'LineWidth', 1); set(a2(2), 'Color', [.7 .7 .7]);
set(w2.s2, 'XColor', clr, 'YColor', clr, 'FontSize', siz);

set(w2.s1, 'position', pos1)
set(w2.s2, 'position', pos2)
set(w2.s2,'xtick',[0 90 180 270 360]);


% Plot roses
function plot_roses(data, trgt)
global w2 

% Prepare data
data = check_data(data);

shaped_data = zeros(size(data,1)*size(data,3),2);
idx = 1;
for i = 1:size(data,1)
    shaped_data(idx:i*size(data,3),1) = reshape(data(i,2,:), size(data,3), 1);
    shaped_data(idx:i*size(data,3),2) = reshape(data(i,3,:), size(data,3), 1);
    idx = idx+size(data,3);
end

shaped_data(:,2) = shaped_data(:,2)+180;

if trgt == 1
    WindRose(shaped_data(:,2), shaped_data(:,1),'AngleNorth',180,'AngleEast',270,'FreqLabelAngle',60,'CenteredIn0',true,  'TitleString', '', 'cmap', 'parula', 'ndirections', 16, 'nfreq', 4, 'vwinds', [0,5,10,20,30,40]);
else
    w2.s1 = axes('units', 'normalized', 'Parent', w2.wind1, 'position', [.1 .53 .8 .42], 'XColor', [1 1 1], 'YColor', [1 1 1], 'FontSize', 8);  
    w2.w1 = WindRose(shaped_data(:,2), shaped_data(:,1),'AngleNorth',180,'AngleEast',270,'FreqLabelAngle',60,'CenteredIn0',true, 'axes', w2.s1, 'TitleString', '', 'figColor',[.25 .25 .25], 'textcolor', 'w', 'cmap', 'parula', 'ndirections', 16, 'nfreq', 4, 'vwinds', [0,5,10,20,30,40]);
end

function dout = check_data(data)
global trgt

% Delete existing axes
if trgt == 0
    delete(findall(gcf,'type','axes'));
end

dout = data;


%% Dependencies
% Get percentile on a matrix
function dout = get_prc(data, prc)
dout = zeros(size(data,1), size(data,2));
for iX = 1:size(data,2)
    for iY = 1:size(data,1)
        tmp          = reshape(data(iY, iX, :), size(data,3), 1);
        dout(iY, iX) = prctile(tmp, prc);
    end
end
% Calculate percentile
function yi = prctile(X,p)
x=X(:);
if length(x)~=length(X)
    error('please pass a vector only');
end
n   = length(x);
x   = sort(x);
Y   = 100*(.5 :1:n-.5)/n;
x   = [min(x); x; max(x)];
Y   = [0 Y 100];
yi  = interp1(Y,x,p);
% Error bar
function hh = errorbar_x(x, y, l,u,symbol)
%ERRORBAR Error bar plot.
%   ERRORBAR_X(X,Y,L,U) plots the graph of vector X vs. vector Y with 
%   error bars specified by the vectors L and U in horizontal direction.  
%   L and U contain the lower and upper error ranges for each point 
%   in X (lower = left side, upper = right side).  Each error bar is 
%   L(i) + U(i) long and is drawn a distance of U(i) from the right 
%   and L(i) from the left the points in (X,Y).  The vectors X,Y,L 
%   and U must all be the same length.  If X,Y,L and U are matrices 
%   then each column produces a separate line.
%
%   ERRORBAR_X(X,Y,E) or ERRORBAR(Y,E) plots X with error bars [X-E X+E].
%   ERRORBAR_X(...,'LineSpec') uses the color and linestyle specified by
%   the string 'LineSpec'.  See PLOT for possibilities.
%
%   H = ERRORBAR_X(...) returns a vector of line handles.
%
%   For example,
%      x = 1:10;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      errorbar_x(x,y,e)
%   draws symmetric error bars of unit standard deviation.

%   L. Shure 5-17-88, 10-1-91 B.A. Jones 4-5-93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.19 $  $Date: 2002/06/05 20:05:14 $

%   modified for plotting error bars in a logarithmic graph by:
%   Goetz Huesken
%   e-mail: goetz.huesken(at)gmx.de
%   Date: 10/23/2006


if min(size(x))==1,
  npt = length(x);
  x = x(:);
  y = y(:);
    if nargin > 2,
        if ~ischar(l),  
            l = l(:);
        end
        if nargin > 3
            if ~ischar(u)
                u = u(:);
            end
        end
    end
else
  [npt,~] = size(x);
end

if nargin == 3
    if ~ischar(l)  
        u = l;
        symbol = '-';
    else
        symbol = l;
        l = y;
        u = y;
        y = x;
        [~,n] = size(y);
        x(:) = (1:npt)'*ones(1,n);
    end
end

if nargin == 4
    if ischar(u),    
        symbol = u;
        u = l;
    else
        symbol = '-';
    end
end


if nargin == 2
    l = y;
    u = y;
    y = x;
    [~,n] = size(y);
    x(:) = (1:npt)'*ones(1,n);
    symbol = '-';
end

u = abs(u);
l = abs(l);
    
if ischar(x) || ischar(y) || ischar(u) || ischar(l)
    error('Arguments must be numeric.')
end

if ~isequal(size(x),size(y)) || ~isequal(size(x),size(l)) || ~isequal(size(x),size(u)),
  error('The sizes of X, Y, L and U must be the same.');
end

m = size(y,1);                      % modification for plotting error bars in x-direction
if m == 1                           %
  tee = abs(y)/40;                  % 
else                                %
  tee = (max(y(:))-min(y(:)))/40;   % 
end                                 %
                                    %
xl = x - l;                         %
xr = x + u;                         %
ytop = y + tee;                     %
ybot = y - tee;                     %
n = size(y,2); 

% Plot graph and bars
hold_state = ishold;
%cax = newplot;
%next = lower(get(cax,'NextPlot'));

% build up nan-separated vector for bars
xb = zeros(npt*9,n);    % modification for plotting error bars in in x-direction
xb(1:9:end,:) = xr;     %
xb(2:9:end,:) = xl;     %
xb(3:9:end,:) = NaN;    %
xb(4:9:end,:) = xr;     %
xb(5:9:end,:) = xr;     %
xb(6:9:end,:) = NaN;    %
xb(7:9:end,:) = xl;     %
xb(8:9:end,:) = xl;     %
xb(9:9:end,:) = NaN;    %

yb = zeros(npt*9,n);    % modification for plotting error bars in in x-direction
yb(1:9:end,:) = y;      %
yb(2:9:end,:) = y;      %
yb(3:9:end,:) = NaN;    %
yb(4:9:end,:) = ytop;   %
yb(5:9:end,:) = ybot;   %
yb(6:9:end,:) = NaN;    %
yb(7:9:end,:) = ytop;   %
yb(8:9:end,:) = ybot;   %
yb(9:9:end,:) = NaN;    %

[ls,col,mark,msg] = colstyle(symbol); if ~isempty(msg), error(msg); end
symbol = [ls mark col]; % Use marker only on data part
esymbol = ['-' col]; % Make sure bars are solid

h = plot(xb,yb,esymbol); hold on
h = [h;plot(x,y,symbol)]; 

if ~hold_state, hold off; end

if nargout>0, hh = h; end
