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

Name:       process_wind.m
Purpose:    Convert NetCDF files into ascii wind profiles
Author:     Sebastien Biass
Created:    April 2015
Updates:    2015/10/05 Bug fix in wind direction
            2017/02/11 Re-wrote the processing with interpolation
            2017/09/17 Added the possibility to download ERA wind
            separately
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


function process_wind(varargin)
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

if nargin == 0
    [file,path]  = uigetfile('*.mat', 'Select the wind.mat file');              	 % Retrieve directory
    if file==0
        return
    end
    load(fullfile(path, file)); % Load wind project
else
    wind = varargin{1};
end

folder  = wind.folder;


in_path = fullfile(folder, 'nc');     % Set main path for nc files
out_path= fullfile(folder, 'ascii');    % Set main path for generated profiles

date_start  = datenum([str2double(wind.yr_s), str2double(wind.mt_s), 1, 0, 0, 0]);
date_end    = datenum([str2double(wind.yr_e), str2double(wind.mt_e), eomday(str2double(wind.yr_e), str2double(wind.mt_e)), 18, 0, 0]);
stor_time   = datevec(date_start:0.25:date_end);

% Case NOAA NCEP/NCAR
if ~isempty(regexp(wind.db, 'Reanalysis', 'ONCE'))
    if strcmp(wind.db, 'Reanalysis1')
        in_path = 'WIND/_Reanalysis1_Rawdata/';
    elseif strcmp(wind.db, 'Reanalysis2')
        in_path = 'WIND/_Reanalysis2_Rawdata/';
    end

    
    % Set storage matrices
    stor_data   = zeros(17, 3, length(stor_time));                          % Main storage matrix   
    tI          = 1;                                                        % Time index used to fill the storage matrix
    
    % Read nc files
    for iY = str2double(wind.yr_s):str2double(wind.yr_e)      % Loop through years
        fprintf('Reading year %4.0f\n', iY)
        % Retrieve the extent
        if iY == str2double(wind.yr_s)
            LAT     = ncread([in_path, 'hgt.', num2str(iY), '.nc'], 'lat'); 
            LON     = ncread([in_path, 'hgt.', num2str(iY), '.nc'], 'lon'); %LON(LON>180) = LON(LON>180)-360;
            latI(1) = find(LAT == wind.lat_min);
            latI(2) = find(LAT == wind.lat_max);
            latI = fliplr(latI);
            lonI(1) = find(LON == wind.lon_min);
            lonI(2) = find(LON == wind.lon_max);           
        end
        
        TIME = datevec(datenum([1800,1,1,0,0,0])+(ncread([in_path, 'hgt.', num2str(iY), '.nc'], 'time')./24));
        
        % Read NetCDF files
        fprintf('\tReading uwind\n')
        UWND = ncread([in_path, 'uwnd.', num2str(iY), '.nc'], 'uwnd');
        fprintf('\tReading vwind\n')
        VWND = ncread([in_path, 'vwnd.', num2str(iY), '.nc'], 'vwnd');      
        fprintf('\tReading geopotential height\n')
        HGT = ncread([in_path, 'hgt.', num2str(iY), '.nc'], 'hgt');
        
        % Find the intersection between time vector of the requested
        % dataset and the NC file
        [~,~,timeI] = intersect(datenum(stor_time),datenum(TIME));
        
        fprintf('\tInterpolating and writing ascii files, please wait...\n')
        for iT = 1:length(timeI)
            for iL = 1:17
                % Interpolate to vent coordinates
                u   = intVent(UWND, LON, LAT, latI, lonI, wind, iL, iT);
                v	= intVent(VWND, LON, LAT, latI, lonI, wind, iL, iT);
                z   = intVent(HGT, LON, LAT, latI, lonI, wind, iL, iT);
                                
                speed   = sqrt(u.^2+v.^2);                                  % Wind speed
                angle   = atan2d(u,v);                                      % Wind direction
                angle(angle<0) = 360+angle(angle<0);                        % Get rid of negative value
                
                stor_data(iL,:,tI) = [z, speed, angle];                     % Convert vectors to wind speed and direction and fill the storage matrix
            end
            dlmwrite(fullfile(out_path, [num2str(tI, '%05i'), '.gen']), stor_data(:,:,tI), 'delimiter', '\t', 'precision', 5);     % Write the wind file
            tI = tI+1;
        end                                      
    end
    disp('Done!')
    
    
% Case ECMWF ERA-Interim Offline    
elseif strcmp(wind.db, 'InterimOff') || strcmp(wind.db, 'ERA5Off') 
    in_path = wind.ncDir;
    fl          = dir(fullfile(in_path, '*.nc'));
    stor        = struct;
    
    fprintf('Reading .nc files\n');
    for i = 1:length(fl)
        
        stor(i).LAT       = ncread(fullfile(in_path, fl(i).name), 'latitude');
        stor(i).LON       = ncread(fullfile(in_path, fl(i).name), 'longitude');
        
        stor(i).LON(stor(i).LON<0) = 360-abs(stor(i).LON);
        % Find vent coordinates
       if i==1
           if length(stor(i).LAT) == 1 || length(stor(i).LON) == 1
               latI = stor(i).LAT;
               lonI = stor(i).LON;
           else
               latI(1) = find(stor(i).LAT == wind.lat_min);
               latI(2) = find(stor(i).LAT == wind.lat_max);
               latI = fliplr(latI);
               lonI(1) = find(stor(i).LON == wind.lon_min);
               lonI(2) = find(stor(i).LON == wind.lon_max);    
           end
        end
    
        stor(i).HGT       = ncread(fullfile(in_path, fl(i).name), 'z')/9.80665;
        stor(i).UWND      = ncread(fullfile(in_path, fl(i).name), 'u'); 
        stor(i).VWND      = ncread(fullfile(in_path, fl(i).name), 'v'); 
        stor(i).time      = double(ncread(fullfile(in_path, fl(i).name), 'time'))/24 + datenum(1900,1,1,0,0,0); 
    end
    
    % Do some tests to see if the timestamp is correct
    time    = cat(1,stor.time);
%     minTime = stor(1).time(1);
%     maxTime = stor(i).time(end);
    minTime = min(time);
    maxTime = max(time);
    
    % Check if the maximum time from downloaded data is equal to the
    % theoretical maximum time based on the time dimension
    tmp     = minTime:.25:minTime+.25*(numel(time)-1);
    if maxTime ~= tmp(end)
        error('There is a problem in the time index. Make sure you download wind data over continuous periods')
    end
    
    time = reshape(time, numel(time), 1);
    [stor_time, timeIdx] = sortrows(time);
    
    % Concatenate data
    HGT     = cat(4, stor.HGT);
    UWND    = cat(4, stor.UWND);
    VWND    = cat(4, stor.VWND);
    
    % Re-order data
    HGT     = HGT(:,:,:,timeIdx);
    UWND    = UWND(:,:,:,timeIdx);
    VWND    = VWND(:,:,:,timeIdx);

    % Set storage matrices
    stor_data   = zeros(length(37), 3, length(stor_time));           % Main storage matrix
    tI          = 1; % Time index used to fill the storage matrix
    
    fprintf('\tInterpolating and writing ascii files, please wait...\n')
    for iT = 1:size(UWND,4)     % Loop through time
        for iL = 1:size(UWND,3)   % Loop through levels
            % No interpolation
            if length(stor(i).LAT) == 1 || length(stor(i).LON) == 1
                u = UWND(1,1,iL,iT);
                v = VWND(1,1,iL,iT);
                z = HGT(1,1,iL,iT);
            else
            % Interpolate to vent coordinates
                u   = intVent(UWND, stor(i).LON, stor(i).LAT, latI, lonI, wind, iL, iT);
                v	= intVent(VWND, stor(i).LON, stor(i).LAT, latI, lonI, wind, iL, iT);
                z   = intVent(HGT, stor(i).LON, stor(i).LAT,  latI, lonI, wind, iL, iT);
            end
            
            speed   = sqrt(u.^2+v.^2);                                  % Wind speed
            angle   = atan2d(u,v);                                      % Wind direction
            angle(angle<0) = 360+angle(angle<0);                        % Get rid of negative value

            stor_data(iL,:,tI) = [z, speed, angle];                     % Convert vectors to wind speed and direction and fill the storage matrix
        end
        dlmwrite(fullfile(out_path, [num2str(tI, '%05i'), '.gen']), sortrows(stor_data(:,:,tI),1), 'delimiter', '\t', 'precision', 5);     % Write the wind file
        tI = tI+1;
    end  
    disp('Done!')
    
% Case ECMWF ERA-Interim Online
else   
    % Set storage matrices
    stor_data   = zeros(length(37), 3, length(stor_time));           % Main storage matrix
    
    tI      = 1; % Time index used to fill the storage matrix

    T = unique(stor_time(:,1:2), 'rows');
    
    for iF = 1:size(T,1)
        nc = [num2str(iF, '%05.0f'), '_', datestr([T(iF,:), 1, zeros(1,3)], 'mmm'), '_', num2str(T(iF,1)), '.nc'];
        
        % Read NetCDF files
        fprintf('Reading file %s\n', nc)
        HGT       = ncread(fullfile(in_path, nc), 'z')/9.80665;
        UWND      = ncread(fullfile(in_path, nc), 'u'); 
        VWND      = ncread(fullfile(in_path, nc), 'v'); 
        LAT       = ncread(fullfile(in_path, nc), 'latitude');
        LON       = ncread(fullfile(in_path, nc), 'longitude'); %LON(LON>180) = LON(LON>180)-360;
               
        fprintf('\tInterpolating and writing ascii files, please wait...\n')
        for iT = 1:size(UWND,4)     % Loop through time
            for iL = 1:size(UWND,3)   % Loop through levels
                
               
                % Interpolate to vent coordinates
                u   = intVent(UWND, LON, LAT, [1, length(LAT)], [1, length(LON)], wind, iL, iT);
                v	= intVent(VWND, LON, LAT, [1, length(LAT)], [1, length(LON)], wind, iL, iT);
                z   = intVent(HGT, LON, LAT, [1, length(LAT)], [1, length(LON)], wind, iL, iT);
                                
                speed   = sqrt(u.^2+v.^2);                                  % Wind speed
                angle   = atan2d(u,v);                                      % Wind direction
                angle(angle<0) = 360+angle(angle<0);                        % Get rid of negative value
                
                stor_data(iL,:,tI) = [z, speed, angle];                     % Convert vectors to wind speed and direction and fill the storage matrix
            end
            dlmwrite(fullfile(out_path, [num2str(tI, '%05i'), '.gen']), sortrows(stor_data(:,:,tI),1), 'delimiter', '\t', 'precision', 5);     % Write the wind file
            tI = tI+1;
        end     
    end
    disp('Done!')
end

save(fullfile(folder,'wind.mat'), 'wind', 'stor_data', 'stor_time');        % Save data for analyses


function val = intVent(VAR, LON, LAT, latI, lonI, wind, iL, iT)
% FYI: NetCDF file come in format [LON, LAT]. No need to transpose the
% matrix, the interpolation is done accordingly
val = interp2(repmat(LON(lonI(1):lonI(2))',length(latI(1):latI(2)),1), ...
    repmat(LAT(latI(1):latI(2)), 1, length(lonI(1):lonI(2))),...
    VAR(lonI(1):lonI(2),latI(1):latI(2), iL, iT), ...
    str2double(wind.lon), str2double(wind.lat),...
    wind.meth);
