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

Name:       tephraProb.m
Purpose:    Main tephraProb interface
Author:     Sebastien Biass
Created:    April 2015
Updates:    April 2016
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

function tephraProb

%vers = '1.5.4';     % Can open multiple figures, attempt to fix the cygwin problem;
vers = '1.6.1';     % Oct 2018 Added Google Earth export

% Check that you are located in the correct folder!
if ~exist([pwd, filesep, 'tephraProb.m'], 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd))
    return
end

% Add the main code to the Matlab path
addpath(genpath('CODE/'));

% Check if temporary run exists
if exist('tmp.mat', 'file')
    delete('tmp.mat')
end

% Check if folders exist
dirname = {'CURVES/', 'GRID/','WIND/', 'RUNS/'};
for i = 1:length(dirname)
    if ~exist(dirname{i}, 'dir')
        mkdir(dirname{i})
    end
end

% Define global GUI handle
global t

% Define GUI
scr = get(0,'ScreenSize');
w   = 500;
h   = 350;

% Main figure
t.fig = figure(...
    'position', [scr(3)/2-w/2 scr(4)/2-h/2 w h],...
    'Color', [.25 .25 .25],...
    'Resize', 'off',...
    'Toolbar', 'none',...
    'Menubar', 'none',...
    'Name', 'TephraProb',...
    'NumberTitle', 'off',...
    'DeleteFcn', @delete_figure);

        % Menu
        t.menu0 = uimenu(t.fig, 'Label', 'File');
            t.m01 = uimenu(t.menu0, 'Label', 'Load', 'Accelerator','O', 'callback', @load_project);
            t.m02 = uimenu(t.menu0, 'Label', 'Close current', 'Accelerator','W', 'callback', @close_project);
            t.m03 = uimenu(t.menu0, 'Label', 'Preferences', 'Accelerator', ';', 'Separator', 'on', 'callback', 'get_prefs');
            t.m04 = uimenu(t.menu0, 'Label', 'References', 'Separator', 'on');
                t.m041 = uimenu(t.m04, 'Label', 'TephraProb updates', 'callback', {@ref, 'https://e5k.github.io/pages/tephraprob'});
                t.m042 = uimenu(t.m04, 'Label', 'Reference paper', 'callback', {@ref, 'https://appliedvolc.springeropen.com/articles/10.1186/s13617-016-0050-5'});
        t.menu1 = uimenu(t.fig, 'Label', 'Input');
            t.m11 = uimenu(t.menu1, 'Label', 'Grid', 'Accelerator', 'G', 'callback', 'conf_grid');
            t.m12 = uimenu(t.menu1, 'Label', 'Points', 'Accelerator', 'P', 'callback', 'conf_points');
            
            t.m12 = uimenu(t.menu1, 'Label', 'Wind', 'Separator', 'on');
                t.m111 = uimenu(t.m12, 'Label', 'Set ECMWF API key', 'callback', 'writeECMWFAPIKey');
                t.m112 = uimenu(t.m12, 'Label', 'Install ECMWF libraries', 'callback', 'installECMWFAPI');
                t.m113 = uimenu(t.m12, 'Label', 'Download wind data', 'separator', 'on', 'callback', 'dwind');
                t.m115 = uimenu(t.m12, 'Label', 'Process wind data', 'callback', 'process_wind');
                t.m116 = uimenu(t.m12, 'Label', 'Analyze wind data', 'callback', 'analyze_wind');
            t.m13 = uimenu(t.menu1, 'Label', 'GVP', 'Separator', 'on', 'callback', 'gvp');
                
        t.menu2 = uimenu(t.fig, 'Label', 'Scenarios');
            t.m21 = uimenu(t.menu2, 'Label', 'sub-Plinian/Plinian', 'callback', 'runProb');
            t.m22 = uimenu(t.menu2, 'Label', 'Vulcanian', 'callback', 'runProb_vulc');
            t.m23 = uimenu(t.menu2, 'Label', 'Run TEPHRA2', 'callback', 'runT2', 'separator', 'on');
                            
        t.menu3 = uimenu(t.fig, 'Label', 'Post processing');
            t.m31 = uimenu(t.menu3, 'Label', 'Probability calculations', 'callback', {@probability_maker_,0});
            t.m32 = uimenu(t.menu3, 'Label', 'Hazard curves', 'callback', {@probability_maker_,1});
           % t.m33 = uimenu(t.menu3, 'Label', 'Probabilistic isomass maps', 'callback', 'prob2IM', 'Separator', 'on');
            t.m34 = uimenu(t.menu3, 'Label', 'File management', 'Separator', 'on');
                t.m341 = uimenu(t.m34, 'Label', 'Export ASCII files', 'callback', 'exportASCII');
                t.m342 = uimenu(t.m34, 'Label', 'Archive Tephra2 output files', 'callback', 'archiveFiles');
        t.menu4 = uimenu(t.fig, 'Label', 'Display');
            t.m45 = uimenu(t.menu4, 'Label', 'Display figure', 'callback', 'display_figure');
            t.m41 = uimenu(t.menu4, 'Label', 'Probability maps', 'Separator', 'on', 'callback', {@plotMap_,0});
            t.m42 = uimenu(t.menu4, 'Label', 'Isomass maps', 'callback', {@plotMap_,1});
            t.m43 = uimenu(t.menu4, 'Label', 'Hazard curves', 'Separator', 'on', 'callback', 'plot_hazCurves');
            %t.m44 = uimenu(t.menu4, 'Label', 'Export kml', 'Enable', 'off');
            

        % Main panel
        t.main = uipanel(...
            'parent', t.fig,...
            'units', 'normalized',...
            'position', [.025 .045 .95 .91],...
            'title', '',...
            'BackgroundColor', [.25 .25 .25],...
            'ForegroundColor', [.9 .5 0],...
            'HighlightColor', [.9 .5 0],...
            'BorderType', 'line');   

            t.title = uicontrol(...
                'parent', t.main,...
                'style', 'text',...
                'units', 'normalized',...
                'position', [.05 .75 .9 .24],...
                'HorizontalAlignment', 'center',...
                'BackgroundColor', [.25 .25 .25],...
                'ForegroundColor', [.9 .5 0],...
                'String', 'TephraProb',...
                'FontWeight', 'Bold',...
                'FontSize', 45,...
                'FontName', 'Arial Black');
            
            
            t.proj = uicontrol(...
                'parent', t.main,...
                'style', 'text',...
                'units', 'normalized',...
                'position', [.025 .025 .8 .05],...
                'HorizontalAlignment', 'left',...
                'BackgroundColor', [.25 .25 .25],...
                'ForegroundColor', [.9 .5 0],...
                'String', ' ');
            
            t.ver = uicontrol(...
                'parent', t.main,...
                'style', 'text',...
                'units', 'normalized',...
                'position', [.9 .01 .1 .05],...
                'HorizontalAlignment', 'center',...
                'BackgroundColor', [.25 .25 .25],...
                'ForegroundColor', [.9 .5 0],...
                'String', ['v. ', vers]);
            
            t.ax = axes(...
                'parent', t.main,...
                'units', 'pixel',...
                'position', [165 65 150 149]);
            logo = imread('logo.png');
            imagesc(logo);
            set(t.ax, 'XTick', [], 'YTick', [], 'box', 'on', 'XColor', [.25 .25 .25], 'YColor',[.25 .25 .25]);  

%             t.affil1 = uicontrol(...
%                 'parent', t.main,...
%                 'style', 'text',...
%                 'units', 'normalized',...
%                 'position', [.025 .05 .45 .175],...
%                 'HorizontalAlignment', 'right',...
%                 'BackgroundColor', [.25 .25 .25],...
%                 'ForegroundColor', [.9 .5 0],...
%                 'String', sprintf('Seb Biass & Costanza Bonadonna Department of Earth Sciences University of Geneva, Switzerland'),...
%                 'FontWeight', 'Bold',...
%                 'FontSize', 10,...
%                 'FontName', 'Arial');
% 
%             t.affil2 = uicontrol(...
%                 'parent', t.main,...
%                 'style', 'text',...
%                 'units', 'normalized',...
%                 'position', [.525 .05 .45 .175],...
%                 'HorizontalAlignment', 'Left',...
%                 'BackgroundColor', [.25 .25 .25],...
%                 'ForegroundColor', [.9 .5 0],...
%                 'String', sprintf('Laura Connor & Chuck Connor\nSchool of Geosciences\nUniversity of South Florida, USA'),...
%                 'FontWeight', 'Bold',...
%                 'FontSize', 10,...
%                 'FontName', 'Arial');
            
% Adapt display accross plateforms
set_display
        
function delete_figure(~,~)
if exist('tmp.mat', 'file')
    clear tmp
    delete('tmp.mat');
end

function plotMap_(~,~,type)
    plotMap(type);
    
function probability_maker_(~,~,type)
    probability_maker(type);
    
    
function load_project(~,~)
global t
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

if exist('tmp.mat', 'file')
    delete('tmp.mat')
    set(t.proj, 'String', ' ');
end

tmp = load_run;
if tmp.run_pth ~= -1   
    prts = strsplit(fileparts(tmp.run_pth),filesep);
    proj = [prts{end-1}, filesep, prts{end}];
    set(t.proj, 'String', proj);
    save('tmp.mat', 'tmp');
end

function close_project(~,~)
global t
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

if exist('tmp.mat', 'file')
    delete('tmp.mat')
    set(t.proj, 'String', ' ');
end

function ref(~,~,url)
 web(url, '-browser')
