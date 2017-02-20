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

Name:       gvp.m
Purpose:    Access the GVP database, retreives the data and provides a GUI
            to plot the results and calculate probabilities of eruptions
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

function gvp
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

global gvp

scr = get(0,'ScreenSize');
w   = 650;
h   = 650;
gvp.fig = figure(...
    'position', [scr(3)/2-w/2 scr(4)/2-h/2 w h],...
    'Color', [.25 .25 .25],...
    'Resize', 'off',...
    'Tag', 'Configuration',...
    'Toolbar', 'none',...
    'Menubar', 'none',...
    'Name', 'Eruptive history from the GVP database',...
    'NumberTitle', 'off');

gvp.main = uipanel(...
    'units', 'normalized',...
    'position', [.03 .03 .94 .94],...
    'title', 'Eruptive history - GVP',...
    'BackgroundColor', [.25 .25 .25],...
    'ForegroundColor', [.9 .5 0],...
    'HighlightColor', [.9 .5 0],...
    'BorderType', 'line');

% TOP PANNEL
gvp.top = uipanel(...
    'parent', gvp.main,...
    'units', 'normalized',...
    'position', [.05 .88 .9 .1],...
    'BackgroundColor', [.25 .25 .25],...
    'ForegroundColor', [.5 .5 .5],...
    'HighlightColor', [.3 .3 .3],...
    'BorderType', 'line',...
    'Title', 'GVP database');

    gvp.top_code = uicontrol(...
        'parent', gvp.top,...
        'style', 'edit',...
        'unit', 'normalized',...
        'position', [.025 .1 .4 .8],...
        'HorizontalAlignment', 'left',...
        'ForegroundColor', [1 1 1],...
        'BackgroundColor', [.35 .35 .35],...
        'String', 'Volcano ID (e.g. 352050)');

    gvp.access = uicontrol(...
        'style', 'pushbutton',...
        'parent', gvp.top,...
        'units', 'normalized',...
        'position', [.45 .12 .25 .86],...
        'BackgroundColor', [.3 .3 .3],...
        'ForegroundColor', [.9 .5 .0],...
        'String', 'Access',...
        'Callback', @download_data);

    gvp.WS = uicontrol(...
        'style', 'pushbutton',...
        'parent', gvp.top,...
        'units', 'normalized',...
        'position', [.725 .12 .25 .86],...
        'BackgroundColor', [.3 .3 .3],...
        'ForegroundColor', [.9 .5 .0],...
        'String', 'Website',...
        'Callback', @ws);


% PLOT TYPE PANNEL
gvp.type = uibuttongroup(...
    'parent', gvp.main,...
    'units', 'normalized',...
    'position', [.05 .1 .2062 .23],...
    'BackgroundColor', [.25 .25 .25],...
    'ForegroundColor', [.5 .5 .5],...
    'HighlightColor', [.3 .3 .3],...
    'BorderType', 'line',...
    'Title', 'Plot type');

    gvp.type_hist = uicontrol(...
        'style', 'radiobutton',...
        'parent', gvp.type,...
        'units', 'normalized',...
        'position', [.1 .735 .78 .17],...
        'BackgroundColor', [.25 .25 .25],...
        'ForegroundColor', [1 1 1],...
        'String', 'Histogram');

    gvp.type_cum = uicontrol(...
        'style', 'radiobutton',...
        'parent', gvp.type,...
        'units', 'normalized',...
        'position', [.1 .54 .78 .17],...
        'BackgroundColor', [.25 .25 .25],...
        'ForegroundColor', [1 1 1],...
        'String', 'Cumulative');

% VEI PANNEL
gvp.VEI = uibuttongroup(...
    'parent', gvp.main,...
    'units', 'normalized',...
    'position', [.2812 .1 .2062 .23],...
    'BackgroundColor', [.25 .25 .25],...
    'ForegroundColor', [.5 .5 .5],...
    'HighlightColor', [.3 .3 .3],...
    'BorderType', 'line',...
    'Title', 'VEI');

    gvp.VEI_table = uicontrol(...
        'style', 'listbox',...
        'Parent', gvp.VEI,...
        'units', 'normalized',...
        'position', [.05 .05 .9 .9],...
        'BackgroundColor', [.3 .3 .3],...
        'ForegroundColor', [1 1 1],...
        'String', {},...
        'Max', 10);


% CONFIRMED PANNEL
gvp.conf = uibuttongroup(...
    'parent', gvp.main,...
    'units', 'normalized',...
    'position', [.5124 .1 .2062 .23],...
    'BackgroundColor', [.25 .25 .25],...
    'ForegroundColor', [.5 .5 .5],...
    'HighlightColor', [.3 .3 .3],...
    'BorderType', 'line',...
    'Title', 'Confirmed');

    gvp.conf_all = uicontrol(...
        'style', 'radiobutton',...
        'parent', gvp.conf,...
        'units', 'normalized',...
        'position', [.1 .735 .78 .17],...
        'BackgroundColor', [.25 .25 .25],...
        'ForegroundColor', [1 1 1],...
        'String', 'All');

    gvp.conf_1 = uicontrol(...
        'style', 'radiobutton',...
        'parent', gvp.conf,...
        'units', 'normalized',...
        'position', [.1 .54 .78 .17],...
        'BackgroundColor', [.25 .25 .25],...
        'ForegroundColor', [1 1 1],...
        'String', 'Confirmed');

    gvp.conf_0 = uicontrol(...
        'style', 'radiobutton',...
        'parent', gvp.conf,...
        'units', 'normalized',...
        'position', [.1 .345 .78 .17],...
        'BackgroundColor', [.25 .25 .25],...
        'ForegroundColor', [1 1 1],...
        'String', 'Unconfirmed');

% EVIDENCE PANNEL
gvp.evidence = uibuttongroup(...
    'parent', gvp.main,...
    'units', 'normalized',...
    'position', [.7436 .1 .2062 .23],...
    'BackgroundColor', [.25 .25 .25],...
    'ForegroundColor', [.5 .5 .5],...
    'HighlightColor', [.3 .3 .3],...
    'BorderType', 'line',...
    'Title', 'Evidence');

    gvp.evidence_all = uicontrol(...
        'style', 'radiobutton',...
        'parent', gvp.evidence,...
        'units', 'normalized',...
        'position', [.1 .735 .78 .17],...
        'BackgroundColor', [.25 .25 .25],...
        'ForegroundColor', [1 1 1],...
        'String', 'All');

    gvp.evidence_historical = uicontrol(...
        'style', 'radiobutton',...
        'parent', gvp.evidence,...
        'units', 'normalized',...
        'position', [.1 .54 .78 .17],...
        'BackgroundColor', [.25 .25 .25],...
        'ForegroundColor', [1 1 1],...
        'String', 'Historical');

    gvp.evidence_tephra = uicontrol(...
        'style', 'radiobutton',...
        'parent', gvp.evidence,...
        'units', 'normalized',...
        'position', [.1 .345 .78 .17],...
        'BackgroundColor', [.25 .25 .25],...
        'ForegroundColor', [1 1 1],...
        'String', 'Tephrochronology');

    gvp.evidence_radio = uicontrol(...
        'style', 'radiobutton',...
        'parent', gvp.evidence,...
        'units', 'normalized',...
        'position', [.1 .15 .78 .17],...
        'BackgroundColor', [.25 .25 .25],...
        'ForegroundColor', [1 1 1],...
        'String', 'Radiocarbon');
    
% Bottom
gvp.raw = uicontrol(...
        'parent', gvp.main,...
        'style', 'pushbutton',...
        'unit', 'normalized',...
        'position', [.05 .02 .16 .06],...
        'HorizontalAlignment', 'left',...
        'ForegroundColor', [.9 .5 .0],...
        'BackgroundColor', [.35 .35 .35],...
        'String', 'Export data',...
        'Callback', @PREP_DATA);
    
gvp.lim = uicontrol(...
        'parent', gvp.main,...
        'style', 'pushbutton',...
        'unit', 'normalized',...
        'position', [.232 .02 .16 .06],...
        'HorizontalAlignment', 'left',...
        'ForegroundColor', [.9 .5 .0],...
        'BackgroundColor', [.35 .35 .35],...
        'String', 'Time limit',...
        'Callback', @TIME_LIM);
    
gvp.prob = uicontrol(...
        'parent', gvp.main,...
        'style', 'pushbutton',...
        'unit', 'normalized',...
        'position', [.414 .02 .16 .06],...
        'HorizontalAlignment', 'left',...
        'ForegroundColor', [.9 .5 .0],...
        'BackgroundColor', [.35 .35 .35],...
        'String', 'Probability',...
        'Callback', @PREP_DATA);
    
gvp.zoom = uicontrol(...
        'parent', gvp.main,...
        'style', 'pushbutton',...
        'unit', 'normalized',...
        'position', [.596 .02 .16 .06],...
        'HorizontalAlignment', 'left',...
        'ForegroundColor', [.9 .5 .0],...
        'BackgroundColor', [.35 .35 .35],...
        'String', 'Export figure',...
        'Callback', @PREP_DATA);

gvp.plot = uicontrol(...
        'parent', gvp.main,...
        'style', 'pushbutton',...
        'unit', 'normalized',...
        'position', [.778 .02 .16 .06],...
        'HorizontalAlignment', 'left',...
        'ForegroundColor', [.9 .5 .0],...
        'BackgroundColor', [.35 .35 .35],...
        'String', 'Plot',...
        'Callback', @PREP_DATA);

function ws(~,~)
web http://www.volcano.si.edu/search_volcano.cfm -browser

function download_data(~, ~)
global gvp stor htmldata

volcano_code = get(gvp.top_code, 'String');

urlwrite(['http://www.volcano.si.edu/volcano.cfm?vn=', volcano_code], 'tmp.html');

tables.idTableBy.plaintextPreceedingTable = 'Summary of Holocene eruption dates and Volcanic Explosivity Indices (VEI)';
htmldata    = htmlTableToCell('tmp.html', tables);

delete('tmp.html');

count   = size(htmldata,1)-1;
stor    = zeros(count, 5);

for i = 1:count
    % Stor
        % 1:    Start year
        % 2:    Uncertainty
        % 3:    1 - Confirmed
        %       0 - Unconfirmed
        % 4:    VEI
        %       9 - Unspecified
        %       10 - Other
        % 5:    0 - Unspecified
        %       1 - Historical
        %       2 - Tephrochonology
        %       3 - Radiocarbon
        
    % Start date
    tmpS = htmldata{i+1,1};
    tmpD = str2double(regexp(tmpS, '\d+', 'Match'));
   
    if length(tmpD) > 1 && isempty(regexp(tmpS, '&plusmn;', 'once')) && isempty(regexp(tmpS, 'BCE', 'once'))
        stor(i,1) = tmpD(1);
    elseif length(tmpD) > 1 && isempty(regexp(tmpS, '&plusmn;', 'once')) && ~isempty(regexp(tmpS, 'BCE', 'once'))
        stor(i,1) = -tmpD(1);
    elseif length(tmpD) > 1 && ~isempty(regexp(tmpS, '&plusmn;', 'once'))  && isempty(regexp(tmpS, 'BCE', 'once')) && ~isempty(regexp(tmpS, 'years', 'once'))
        stor(i,1) = tmpD(1);
        stor(i,2) = tmpD(2);
    elseif length(tmpD) > 1 && ~isempty(regexp(tmpS, '&plusmn;', 'once'))  && ~isempty(regexp(tmpS, 'BCE', 'once')) && ~isempty(regexp(tmpS, 'years', 'once'))
        stor(i,1) = -tmpD(1);
        stor(i,2) = tmpD(2);
    elseif length(tmpD) > 1 && ~isempty(regexp(tmpS, '&plusmn;', 'once'))  && isempty(regexp(tmpS, 'BCE', 'once')) && isempty(regexp(tmpS, 'years', 'once'))
        stor(i,1) = tmpD(1);
        stor(i,2) = tmpD(2);
    elseif length(tmpD) > 1 && ~isempty(regexp(tmpS, '&plusmn;', 'once'))  && ~isempty(regexp(tmpS, 'BCE', 'once')) && isempty(regexp(tmpS, 'years', 'once'))
        stor(i,1) = -tmpD(1);
        stor(i,2) = tmpD(2);
    elseif length(tmpD) == 1 && isempty(regexp(tmpS, 'BCE', 'once'))
        stor(i,1) = tmpD(1);
    elseif length(tmpD) == 1 && ~isempty(regexp(tmpS, 'BCE', 'once'))
        stor(i,1) = -tmpD(1);
    end
    
    % Confirmed
    tmpS = htmldata{i+1,3};
    if ~isempty(regexp(tmpS, 'Confirmed', 'once'))
        stor(i,3) = 1;
    end
    
    % VEI
    tmpS = htmldata{i+1,4};
    tmpD = str2double(regexp(tmpS, '\d+', 'Match'));
    if isempty(tmpD)
        if strcmp(tmpS, 'P') && strcmp(tmpS, 'C') && strcmp(tmpS, 'I')
            stor(i,4) = 10;
        else
            stor(i,4) = 9;
        end
    else
        stor(i,4) = tmpD;
    end
    
    % Evidence
    tmpS = htmldata{i+1,5};
    if ~isempty(regexp(tmpS, 'Historical', 'once'))
        stor(i,5) = 1;
    elseif ~isempty(regexp(tmpS, 'Tephrochronology', 'once'))
        stor(i,5) = 2;
    elseif ~isempty(regexp(tmpS, 'Radiocarbon', 'once'))
        stor(i,5) = 3;
    else
        stor(i,5) = 0;
    end
    
end

% Prepare VEI string
vei     = sortrows(unique(stor(:,4)));
veiS    = cell(length(vei)+1,1);
veiS{1} = 'All';

for i = 2:size(veiS,1)
    if vei(i-1) == 9
        veiS{i} = 'Undefined';
    elseif vei(i-1) == 10
        veiS{i} = 'Other';
    else
        veiS{i} = num2str(vei(i-1));
    end
end

set(gvp.VEI_table, 'String', veiS);
PREP_DATA(gvp.plot)

function TIME_LIM(~, ~)
global time_lim

if ~isempty(time_lim)
    dft = time_lim;
else
    dft = {'min', 'now'};
end

answer = inputdlg({'Old time limit in years (enter min for no constraint):', 'Recent time limit in years (enter now for no constraint):'},...
    'Time constraint', 1, dft);
if ~isnan(str2double(answer{1})) && ~isnan(str2double(answer{2})) && str2double(answer{1})>str2double(answer{2})
    errordlg('The old time constraint should be further back in time than the recent one', ' ');
else
    time_lim = answer;
end

function PREP_DATA(hObject, ~)
global gvp stor trgt time_lim htmldata plt_src

% Sort by VEI
sel_val = get(gvp.VEI_table, 'Value');
sel_str = get(gvp.VEI_table, 'String');
idx = [];

if strcmp(sel_str{sel_val(1)}, 'All')
    data = stor;
    html = htmldata;
else
    for i = 1:length(sel_val)
        if isnan(str2double(sel_str{sel_val(i)})) && strcmp(sel_str{sel_val(i)}, 'Undefined')
            idx = [idx; find(stor(:,4) == 9)];
        elseif isnan(str2double(sel_str{sel_val(i)})) && strcmp(sel_str{sel_val(i)}, 'Other')
            idx = [idx; find(stor(:,4) == 10)];
        else
            idx = [idx; find(stor(:,4) == str2double(sel_str{sel_val(i)}))];
        end
    end
    data = stor(idx,:);
    html = htmldata(idx,:);
end

% Sort by Confirmed/unconfirmed
if strcmp(get(get(gvp.conf, 'SelectedObject'), 'String'), 'Confirmed')
    data = data(data(:,3) == 1, :);
    html = html(data(:,3) == 1, :);
elseif strcmp(get(get(gvp.conf, 'SelectedObject'), 'String'), 'Unconfirmed')
    data = data(data(:,3) == 0, :);
    html = html(data(:,3) == 0, :);
end

% Sort by Evidence
if strcmp(get(get(gvp.evidence, 'SelectedObject'), 'String'), 'Historical')
    data = data(data(:,5) == 1, :);
    html = html(data(:,5) == 1, :);
elseif strcmp(get(get(gvp.evidence, 'SelectedObject'), 'String'), 'Tephrochronology')
    data = data(data(:,5) == 2, :);
    html = html(data(:,5) == 2, :);
elseif strcmp(get(get(gvp.evidence, 'SelectedObject'), 'String'), 'Radiocarbon')
    data = data(data(:,5) == 3, :);
    html = html(data(:,5) == 3, :);
end

% Check if there is a time constrain
if ~isempty(time_lim)
    if ~isnan(str2double(time_lim{1}))
        lim_old = str2double(time_lim{1});
        data = data(data(:,1) >= lim_old,:);
        html = html(data(:,1) >= lim_old,:);
    end
    
    if ~isnan(str2double(time_lim{2}))
        lim_rec = str2double(time_lim{2});
        data = data(data(:,1) <= lim_rec, :);
        html = html(data(:,1) <= lim_rec, :);
    end
end

% Identifies target for plotting
if strcmp(get(hObject, 'String'), 'Plot') || strcmp(get(hObject, 'String'), 'Probability')
    trgt = 0;   % GUI axis
elseif strcmp(get(hObject, 'String'), 'Export figure')
    trgt = 1;   % New figure
end

% Error message if resulting selection
if isempty(data)
    errordlg('The resulting selection is empty', ' ');
    return
end

% Plot
if strcmp(get(hObject, 'String'), 'Plot')
    if strcmp(get(get(gvp.type, 'SelectedObject'), 'String'), 'Histogram')
        plot_hist(data);
    elseif strcmp(get(get(gvp.type, 'SelectedObject'), 'String'), 'Cumulative')
        plot_cum(data);
    elseif strcmp(get(get(gvp.type, 'SelectedObject'), 'String'), 'Interval')
        plot_int(data);
    end
elseif  strcmp(get(hObject, 'String'), 'Export figure')
    if plt_src == 1
        plot_probability(data);
    else
        if strcmp(get(get(gvp.type, 'SelectedObject'), 'String'), 'Histogram')
            plot_hist(data);
        elseif strcmp(get(get(gvp.type, 'SelectedObject'), 'String'), 'Cumulative')
            plot_cum(data);
        elseif strcmp(get(get(gvp.type, 'SelectedObject'), 'String'), 'Interval')
            plot_int(data);
        end
    end
elseif strcmp(get(hObject, 'String'), 'Export data')
    html = [htmldata(1,:); html];
    export_data(html);
elseif strcmp(get(hObject, 'String'), 'Probability')
    plot_probability(data);
end


% Plot histogram
function plot_hist(data)
global gvp trgt plt_src

plt_src = 0;

if trgt == 1
    fig     = figure;
    prnt    = fig;
    pos     = [.1,.1,.8,.8];
    clr     = [0 0 0]; siz = 10;
else
    delete(findall(gcf,'type','axes'));
    prnt    = gvp.main;
    pos     = [.075 .4 .85 .42];
    if ispc
        clr     = [1 1 1]; siz = 8; 
    else
        clr     = [1 1 1]; siz = 10; 
    end
end

axes('Parent', prnt, 'Position', pos); 
hist(data(:,4), -1:10);
set(gca,...
    'XColor', clr, 'YColor', clr,  'FontSize', siz,...
    'XLim', [-1 11], 'XTickLabel', {'', '0', '1', '2', '3', '4', '5', '6', '7', '8', 'U', 'O', ''});

set(get(gca,'child'),'FaceColor',[.6 .6 .6]);
title([num2str(length(data(:,4))), ' events'], 'Color', clr);
xlabel('VEI');
ylabel('Frequency');

% Plot Cumulative data
function plot_cum(data)
global gvp trgt plt_src

plt_src = 0;

if trgt == 1
    fig     = figure;
    prnt    = fig;
    pos     = [.1,.1,.8,.8];
    clr     = [0 0 0]; siz = 10;
else
    delete(findall(gcf,'type','axes'));
    prnt    = gvp.main;
    pos     = [.075 .4 .85 .42];
    if ispc
        clr     = [1 1 1]; siz = 8; 
    else
        clr     = [1 1 1]; siz = 10; 
    end 
end

sel_val = get(gvp.VEI_table, 'Value');
sel_str = get(gvp.VEI_table, 'String');


axes('Parent', prnt, 'Position', pos); 
hold on;

vei     = unique(data(:,4));
nb      = length(vei);
cmap    = linspecer(nb);

data    = sortrows(data,1);
y       = 1:size(data,1);

p1      = errorbar_x(data(:,1), y(:), data(:,2), data(:,2), '.k');
set(p1,'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'MarkerSize', 1);

pleg  = zeros(size(vei));
count = 1;
for i = 1:nb
    idx     = find(data(:,4)==vei(i));   
    p2      = scatter(data(idx,1),y(idx),40,data(idx,4), 'fill');
    set(p2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', cmap(i,:));
    pleg(i) = p2;   % Append handle for legend plotting
    count   = count+size(data(idx,1),1);
end

set(gca,...
    'XColor', clr, 'YColor', clr,  'FontSize', siz);

title([num2str(length(data(:,4))), ' events'], 'Color', clr);
ylabel('Cumulative number of eruptions');
xlabel('Time (years)');

% Prepare legend
leg = cell(length(sel_val),1);
if strcmp(sel_str{sel_val(1)}, 'All')
    leg = sel_str(2:end);
else
    for i = 1:length(sel_val)
        leg{i} = sel_str{sel_val(i)};
    end
end
legend(pleg, leg, 'Location', 'NorthWest');

% Export data
function export_data(html)
html = regexprep(html, '&nbsp;', '');
html = regexprep(html, '&plusmn;', '±');

[fl, pth]   = uiputfile('data_export.txt', 'Export data');
fid         = fopen(fullfile(pth, fl), 'wt');
form        = '%s\t%s\t%s\t%s\t%s\t%s\n';
for i = 1:size(html,1)
    fprintf(fid, form, html{i,:});
end
fclose(fid);

% Plot probability
function plot_probability(data)
global gvp trgt plt_src

plt_src = 1;

if trgt == 1
    fig     = figure;
    prnt    = fig;
    pos     = [.1,.1,.8,.8];
    clr     = [0 0 0]; siz = 10;
else
    delete(findall(gcf,'type','axes'));
    prnt    = gvp.main;
    pos     = [.075 .4 .85 .42];
    if ispc
        clr     = [1 1 1]; siz = 8; 
    else
        clr     = [1 1 1]; siz = 10; 
    end 
end

% Poisson distribution
%t   = 0:10:2000; t(1) = 1;
t = logspace(0,4,100);
p   = zeros(size(t));
lam = size(data,1)/(data(1,1)-data(end,1));
for i = 1:length(t)
    p(i) = 1-exp(-lam*t(i));
end

axes('Parent', prnt, 'Position', pos); 

plot(t,p,'-k.');
xlabel('Log_1_0 time (years)');
ylabel('Probability');
title('F(t) = P(T>=t)', 'color', clr);
set(gca, 'XColor', clr, 'YColor', clr,  'FontSize', siz, 'XScale', 'log',...
    'XGrid', 'on', 'YGrid', 'on');
datacursormode


% Error bar
function hh = errorbar_x(x, y, l,u,symbol)
if min(size(x))==1
  npt = length(x);
  x = x(:);
  y = y(:);
    if nargin > 2
        if ~ischar(l)  
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