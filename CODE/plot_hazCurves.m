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

Name:       plot_hazCurves.m
Purpose:    Plot hazard curves
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


function plot_hazCurves
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

d       = dir(['CURVES', filesep, '*.out']);
str     = {d.name};

if ~isempty(str)
    s       = listdlg('ListString',str,...
                    'PromptString','Select one or multiple files to plot:',...
                    'SelectionMode','multiple');
else
    warndlg('You have not computed hazard curves yet!');
end

if ~isempty(s)
    cmap = linspecer(length(s));
    
    figure; hold on
    for i = 1:length(s)
        file    = load(['CURVES', filesep, str{s(i)}]);

        % Plot
        leg{i}  = sprintf('%s', get_name(str{s(i)}));
        plot(file(:,1), file(:,2), 'Color', cmap(i,:));
    end
    
    xlabel('Mass accumulation (kg/m^2)');
    ylabel('Exceedance probability');
    set(gca, 'YScale', 'Log', 'XScale', 'Log', 'Box', 'on');
    xlim([0.001, 1000]);
    legend(leg,'Interpreter', 'none');
    hold off
end

function nm = get_name(str)
idx = strfind(str, '.out');
nm  = str(1:idx-1);