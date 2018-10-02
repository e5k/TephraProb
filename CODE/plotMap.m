%{
Name:       plotMap.m
Purpose:    Plot output maps from TephraProb
Author:     Sebastien Biass
Created:    April 2015
Updates:    Oct 2018
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


function plotMap(mapType)
% Type 0 = probability, 1 = isomass

% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

% Load preference file
load(['CODE', filesep, 'VAR', filesep, 'prefs'], 'prefs');

% Load project file
project = load_run;
if project.run_pth == -1
    return
end

% Check that simulations were done on a matrix
if project.grd_type == 1
    errordlg('Maps can only be produced if simulations were performed on a grid')
    return
end

% Check that dataProb.mat exists
if ~exist([project.run_pth, 'DATA/dataProb.mat'] , 'file')
    errordlg('No probability calculation found, please run post processing');
    return
end
load([project.run_pth, 'DATA/dataProb.mat'] , 'dataProb')

if ~isfield(dataProb, 'massT')
    errordlg('No probability calculation found, please run post processing');
    return
end

% Case 1: Probability map
if mapType == 0
    md      = 'prob';
    thresh  = dataProb.massT';
    unit    = ' kg/m2';
    ylab    = 'Probability of tephra accumulation';
    ctVal   = prefs.maps.prob_contour;
    minVal  = prefs.maps.min_prob;
    cmapV   = prefs.maps.prob_cmap;
    cmap    = prefs.cmap{cmapV};
% Case 2: Isomass maps
elseif mapType == 1
    md      = 'IM';
    thresh  = dataProb.probT'; 
    unit    = ' %';
    ylab    = 'Tephra accumulation (kg m^-^2)';
    ctVal   = prefs.maps.mass_contour;
    minVal  = prefs.maps.min_mass;
    cmapV   = prefs.maps.mass_cmap;
    cmap    = prefs.cmap{cmapV};
end

% Create the list of files
seas    = fieldnames(dataProb.(md));
threshT = cellstr(num2str(thresh));
threshT = cellfun(@(c)[' ' strtrim(c) unit],threshT,'uni',false);
[a, b]  = ndgrid(1:numel(seas),1:numel(threshT));
str     = strcat(seas(a(:)), threshT(b(:)));

s       = listdlg('PromptString','Select one or multiple files to plot:',...
                'SelectionMode','multiple',...
                'ListString',str);
% Check output
if isempty(s); return; end 

% Create storage for Google Earth
if prefs.maps.GE_export == 1
    GEfold = cell(numel(s),1);
    mkdir(fullfile(project.run_pth, 'KML/tmp'));
end

fprintf('_____________________________________________________________________________________________\n');
fprintf('To save all opened maps to the MAPS/ folder of your project, type:\n')
fprintf('\t  >> saveAllMaps(format)\n\twhere format can be ''png'', ''eps'' or ''pdf''.\n')
fprintf('_____________________________________________________________________________________________\n')

% Load grid
XX      = load(['GRID', filesep, project.grd_pth, filesep, project.grd_pth, '_lon.dat']);
YY      = load(['GRID', filesep, project.grd_pth, filesep, project.grd_pth, '_lat.dat']);
res     = (XX(1,2)-XX(1,1))/2;
[vent_lat, vent_lon] = utm2ll(project.vent.east, project.vent.north, project.vent.zone);

for i = 1:length(s)

    % Retrieve index of name file into matrix
    strParts = strsplit(str{s(i)});
    seasI    = strcmp(seas, strParts{1});
    threshI  = thresh == str2double(strParts{2});
    file     = dataProb.(md).(seas{seasI})(:,:,threshI);

    file(file<minVal) = nan; % Remove min masses for display
    
    % Prepare map title
    figData.pth  = project.run_pth;
    figData.name = project.run_name;
    figData.fl   = strrep(str{s(i)}, ' ' ,'_');
    figData.fl   = strrep(figData.fl, '/' ,'_');
    figData.md   = md;
    
    % Plot
    figure('Name',str{s(i)}, 'UserData', figData);    
    ax = axes;
    % If log isomass
    if mapType == 1 && prefs.maps.mass_log == 1
        hd = pcolor(XX-res,YY-res,log10(file)); shading flat; hold on;
    else
        hd = pcolor(XX-res,YY-res,file); shading flat; hold on;
    end
    
    % Colormap: makes sure than parula, HSV and jet are plotted in normal
    % way, else invert
    if cmapV <= 3
        colormap(cmap);
    else
        cmapT = flipud(eval(cmap));
        cmap  = cmapT;
        colormap(cmap);
    end
    
    [c,h]       = contour(XX,YY,file,ctVal, 'Color', 'k');
    if prefs.maps.plot_labels == 1
        clabel(c,h, ctVal, 'LabelSpacing', 1000, 'FontWeight', 'bold')
    end
    set(hd, 'FaceAlpha', 0.5)

    % Define scaling
    if mapType == 1 && prefs.maps.scale_pim == 1 && prefs.maps.mass_log == 0
       caxis([prefs.maps.mass_contour(1), prefs.maps.mass_contour(end)]); 
    elseif mapType == 1 && prefs.maps.scale_pim == 1 && prefs.maps.mass_log == 1
        caxis([log10(prefs.maps.mass_contour(1)), log10(prefs.maps.mass_contour(end))]); 
    elseif mapType == 1 && prefs.maps.scale_pim == 0 && prefs.maps.mass_log == 1
        caxis([log10(prefs.maps.min_mass), log10(max(max(file)))]); 
    elseif mapType == 0 && prefs.maps.scale_prob == 1
       caxis([prefs.maps.prob_contour(1), prefs.maps.prob_contour(end)]); 
    end
   
    
    % Tidies season labels
    if  mapType == 0; ttlLab = 'Probability map - ';
    else ttlLab = 'Probabilistic isomass map - ';
    end
    
    for iS = 1:length(project.seasons)
        if ~isempty(regexp(str{s(i)}, project.seasons{iS}, 'once'))
            ttl = [ttlLab, strrep(str{s(i)}, project.seasons{iS}, project.seasons_tag{iS})];
        end
    end

    title({project.run_name; ttl},'Interpreter', 'none');
    xlabel('Longitude');
    ylabel('Latitude');
    c = colorbar;
    ylabel(c, ylab, 'FontSize', ax.XLabel.FontSize);
    
    % Adjust color ramp
    % Make sure that the lowest tephra accumulation is labeled
    if mapType == 1 && prefs.maps.mass_log == 0 && c.Ticks(1) > prefs.maps.min_mass
        c.Limits(1)  = prefs.maps.min_mass;
        c.Ticks      = [prefs.maps.min_mass, c.Ticks];
    elseif mapType == 1 && prefs.maps.mass_log == 1
        c.Ticks      = log10(prefs.maps.mass_contour);
        c.TickLabels = cellfun(@strtrim, cellstr(num2str(prefs.maps.mass_contour')), 'UniformOutput', false);
    end
    
    
    %% Extra plotting
    % Plot basemap
    if prefs.maps.basemap == 2
        plot_google_map('maptype', 'terrain', 'MapScale', 1);
    end
    
    % Plot vent
    plot(vent_lon, vent_lat, '^k', 'LineWidth', 1, 'MarkerFaceColor', 'r', 'MarkerSize', 15);
    
    % Plot locations of hazard curves
    if prefs.maps.plot_pointC == 1 && isfield(dataProb, 'points')
        plot(dataProb.points.lon, dataProb.points.lat, '.k', 'MarkerSize', 6);
        if prefs.maps.plot_labC == 1
            text(dataProb.points.lon, dataProb.points.lat, dataProb.points.name, 'FontSize', 8)
        end
    end
    
    % Plot grid extent
    if prefs.maps.plot_extent == 1
        gX = [XX(1,1), XX(1,end), XX(end,end), XX(end,1), XX(1,1)];
        gY = [YY(1,1), YY(1,end), YY(end,end), YY(end,1), YY(1,1)];
        plot(gX, gY, '-r', 'linewidth',0.5);
    end
    set(gca, 'Layer', 'top');
    
    %% Prepare Google Earth content
    if prefs.maps.GE_export == 1
        % Re-interpolates data to have equally-spaced coordinates for Google Earth 
        obj = findobj(ax,'Type','Surface');
        obj = double(obj.CData);
        opc = 0.5;

        xNew = linspace(min(min(XX)), max(max(XX)), size(XX,2));
        yNew = linspace(min(min(YY)), max(max(YY)), size(XX,1));

        [XNew, YNew] = meshgrid(xNew, yNew);
        % Interpolation for surface
        F       = scatteredInterpolant(reshape(XX,numel(XX),1), reshape(YY,numel(XX),1), reshape(obj,numel(XX),1));
        ZNew    = F(XNew,YNew);
        % Interpolation for contour
        F2      = scatteredInterpolant(reshape(XX,numel(XX),1), reshape(YY,numel(XX),1), reshape(double(file),numel(XX),1));
        ZNew2   = F2(XNew,YNew);

        % Plot surface
        fl = [strParts{1},'_',strParts{2}, '.png'];
        data = ge_imagesc(XNew(1,:),YNew(:,1), flipud(ZNew),...
            'imgURL', fl,...
            'cLimLow',ax.CLim(1),...
            'cLimHigh',ax.CLim(2),...
            'altitude',zeros(size(XX)),...
            'altitudeMode','clampToGround',...
            'colorMap',cmap,...
            'alphaMatrix',ones(size(XX)).*opc,...
            'name', ylab,...
            'description', ylab);

        movefile(fl, fullfile(project.run_pth, 'KML', 'tmp', fl));

        % Clot contours
        try
            cntr = ge_contour(XNew, flipud(YNew), flipud(ZNew2),...
                'lineValues',ctVal,...
                'lineColor', '000000',...
                'lineWidth', 2,...
                'cLimLow',ax.CLim(1),...
                'cLimHigh',ax.CLim(2),...
                'altitudeMode','clampToGround',...
                'name', 'Contours');
            cntr = ge_folder('Contours',cntr);   
        catch
            warning('Problem defining contours for Google Earth')
            cntr = [];
        end
        ttlTmp = strsplit(ttl, ttlLab);
        GEfold{i} = ge_folder(ttlTmp{2},[data, cntr]);
    end
end


%% Write Google Earth File
if prefs.maps.GE_export == 1
    % Make colorbar
    cbar = ge_colorbar(max(XX(1,:)), min(YY(:,1)) ,ZNew,...
        'numClasses',length(c.Ticks)-1,...
        'labels', c.TickLabels,...
        'cLimLow',ax.CLim(1),...
        'cLimHigh',ax.CLim(2),...
        'cBarFormatStr','%+01.2f',...
        'colorMap',cmap,...
        'name', ylab);

    % Plot extent
    box = ge_plot(gX, gY, 'name', 'Domain');

    % Plot vent
    pt = ge_point(vent_lon, vent_lat, 100, ...
        'altitudeMode','clampToGround',...
        'iconURL', 'http://maps.google.com/mapfiles/kml/shapes/volcano.png',...
        'name', 'Vent',...
        'description', '');


    % Plot hazard curves
    if prefs.maps.plot_pointC == 1 && isfield(dataProb, 'points') && mapType == 0
        fprintf('- Preparing hazard curves, please wait...\n')
        crvs = cell(numel(dataProb.points.lon),1);
        for i = 1:numel(dataProb.points.lon)
            % Plot the hazard curve
            plot_hazCurves([dataProb.points.name{i}, '_', project.run_name],...
                fullfile(project.run_pth, 'KML/tmp', [project.run_name,'_curve_',dataProb.points.name{i}, '.png']),...
                prefs);

            crvs{i} = ge_point( dataProb.points.lon(i),  dataProb.points.lat(i), 100, ...
                'altitudeMode','clampToGround',...
                'iconURL', 'http://maps.google.com/mapfiles/kml/pal4/icon57.png',...
                'name', dataProb.points.name{i},...
                'description', ['<img src="', [project.run_name,'_curve_',dataProb.points.name{i}, '.png'] ,'">']);
        end
        crvs = ge_folder('Hazard curves', strcat(crvs{:}));
        fprintf('- Done!...\n')
    else
        crvs = [];
    end


    % Write everythin and cleanup
    toWrite = [GEfold; {cbar}; {box}; crvs; {pt}]; % Google Earth data to write
    targetFold = fullfile(project.run_pth, 'KML');
    targetName = [project.run_name, ' - ', ttlLab(1:end-3)];

    % Write to kml
    ge_output(fullfile(targetFold, 'tmp', [targetName, '.kml']),...
        [toWrite{:}],...
        'name', targetName);

    % Zip the file
    zip(fullfile(targetFold, targetName), fullfile(targetFold, 'tmp/*'));
    % Convert to kmz
    movefile(fullfile(targetFold, [targetName, '.zip']), fullfile(targetFold, [targetName, '.kmz']));
    % Remove temp folder
    rmdir(fullfile(targetFold, 'tmp'), 's')

    % Try to open the file
    if prefs.maps.GE_show == 1
        target = fullfile(targetFold, [targetName, '.kmz']);
        if ispc
                system(['start "kmltoolbox" "' target '"']);
        elseif ismac
                system(['open' ' "' target '"']);
        else
            disp(['The KML file has been saved, open it in Google Earth: ', fullfile(project.run_pth, 'KML', [project.run_name, ' - ', ttlLab(1:end-3), '.kml'])]);
        end
    end
end