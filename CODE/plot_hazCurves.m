%{
Name:       plot_hazCurves.m
Purpose:    Plot hazard curves
Author:     Sebastien Biass
Created:    April 2015
Updates:    April 2015
            Oct 2018:   Modified so can be called as function
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


function plot_hazCurves(varargin)
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end


if nargin == 0  % -> called from GUI
    % Load preference file
    load(['CODE', filesep, 'VAR', filesep, 'prefs'], 'prefs');

    d       = dir(['CURVES', filesep, '*.out']);
    str     = {d.name};
    vis     = 'on';
    if ~isempty(str)
        s       = listdlg('ListString',str,...
                        'PromptString','Select one or multiple files to plot:',...
                        'SelectionMode','multiple');
    else
        warndlg('You have not computed hazard curves yet!');
        return
    end

else % -> called from another function
    d       = dir(['CURVES', filesep, varargin{1}, '*']);
    str     = {d.name};
    s       = 1:length(str);
    vis     = 'off';
    prefs   = varargin{3};
end
    
if ~isempty(s)
    cmap = linspecer(length(s));
    
    f = figure('visible', vis); hold on
    maxtmp = 0;
    for i = 1:length(s)
        file    = load(['CURVES', filesep, str{s(i)}]);
        % Plot
        leg{i}  = sprintf('%s', get_name(str{s(i)}));
        plot(file(:,1), file(:,2), 'Color', cmap(i,:));
        
        if max(file(:,1))>maxtmp
            maxtmp = max(file(:,1));
        end
    end
    
    xlabel('Mass accumulation (kg/m^2)');
    ylabel('Exceedance probability (%)');
    set(gca, 'YScale', 'Log', 'XScale', 'Log', 'Box', 'on');
    xlim([10^(-prefs.files.nbDigits), 10^(ceil(log10(maxtmp)))]);
    ylim([.1 100]);
    legend(leg,'Interpreter', 'none', 'Location', 'southwest');
    hold off
    
    if nargin > 0
        print(f, varargin{2}, '-dpng');
        close(f);
    end
end

function nm = get_name(str)
idx = strfind(str, '.out');
nm  = str(1:idx-1);