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
if ~exist([pwd, filesep, 'tephraProb.m'], 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

if nargin == 0
    folder  = uigetdir;                                 % Retrieve directory
    if folder==0
        return
    end
    folder  = [folder, filesep];                        % Cat folder
else
    folder  = varargin{1};
end



in_path = [folder, 'nc_output_files', filesep];     % Set main path for nc files
out_path= [folder, 'txt_output_files', filesep];    % Set main path for generated profiles

if exist([folder, 'vent'], 'file') == 2
    dataset = 2;    % ECMWF ERA-Interim
else
    dataset = 1;    % NOAA NCEP/NCAR Reanalysis 1
end


% Case NOAA NCEP/NCAR Reanalysis 1
if dataset == 1
    %files   = dir([folder,'nc_output_files', filesep, '*.nc']);
    

    lev     = [1000, 925, 850, 700, 600, 500, 400, 300, 250, 200, 150, 100, 70, 50, 30, 20, 10];
    var     = {'gheight', 'uwind', 'vwind'};    
    var2r   = {'hgt', 'uwnd', 'vwnd'};
    
    % Read nc files
    h       = waitbar(0,'Reading nc files...');
    for iV = 1:length(var)          % Loop through variables
        for iL = 1:length(lev)      % Loop through levels
            if iV == 1 && iL == 1   % Reads the first file to get the time index
                tmp         = ncread([in_path, 'gheight_1000mb.nc'],'time'); 
                stor_time   = datevec(datenum([1800,1,1,0,0,0])+(tmp./24));                 % Time vector
                stor_tmp    = zeros(length(stor_time), length(var), length(lev));           % Temporary storage matrix
                stor_data   = zeros(length(lev), length(var), length(stor_time));           % Main storage matrix
            end
            
            tmpvar  = ncread([in_path, var{iV}, '_', num2str(lev(iL)), 'mb.nc'], var2r{iV});   % Retrieve data from nc file
            tmpvar  = reshape(tmpvar, length(stor_time), 1);                                % Reshape data
            stor_tmp(:,iV,iL) = tmpvar;                                                     % Add to the storage matrix
        end 
        waitbar(iV/length(var),h);
    end
    delete(h);
    
    % Write profiles
    h      = waitbar(0,'Writing profiles...');
    for iT = 1:length(stor_time)
        z  = reshape(stor_tmp(iT, 1, :), 17, 1);    % Extract height
        u  = reshape(stor_tmp(iT, 2, :), 17, 1);    % Extract u wind
        v  = reshape(stor_tmp(iT, 3, :), 17, 1);    % Extract v wind
        
        speed   = sqrt(u.^2+v.^2);
        angle   = atan2d(u,v); 
        angle(angle<0) = 360+angle(angle<0);         % Get rid of negative values
        
        stor_data(:,:,iT) = [z, speed, angle];      % Convert vectors to wind speed and direction and fill the storage matrix
        dlmwrite([out_path, num2str(iT, '%05i'), '.gen'], [z, speed, angle], 'delimiter', '\t', 'precision', 5);     % Write the wind file
        waitbar(iT/length(stor_time),h);
    end
    delete(h);

% Case ECMWF ERA-Interim
elseif dataset == 2
    
    % Dialog box to input vent coordinates
    vent        = load([folder,'vent'], '-mat');
    vent        = vent.vent;
    %coor        = inputdlg({'Vent latitude:', 'Vent longitude:'}, 'Vent coordinates', 1);
    lat         = str2double(vent.lat);     % Retrieve vent latitude
    lon         = str2double(vent.lon);     % Retrieve vent longitude
    % Assures longitude is expressed as E
    if lon < 0
        lon = 360+lon;
    end
    
    fl          = dir([in_path, '*.nc']);   % List files
    
    % Operations to retrive the time
    dummy_s     = fl(1).name;
    dummy_e     = fl(size(fl, 1)).name;
    dummy_s2    = ['01-', dummy_s(7:9), '-', dummy_s(11:14), ' 00:00:00'];
    dummy_e2    = ['31-', dummy_e(7:9), '-', dummy_e(11:14), ' 18:00:00'];
    nb_files    = etime(datevec(dummy_e2), datevec(dummy_s2))/(3600*24)*4; % Get the number of final wind profiles

    stor_data   = zeros(37, 3, nb_files);   % Main storage matrix
    stor_time   = zeros(nb_files, 6);       % Time vector
    
    % Get indices of the closest grid cell to vent coordinates
    lon_tmp     = ncread([in_path, fl(1).name], 'longitude');
    lat_tmp     = ncread([in_path, fl(1).name], 'latitude');
    [~,lon_idx] = min(abs(lon_tmp-lon));
    [~,lat_idx] = min(abs(lat_tmp-lat));
    
    count_stor  = 1;                        % Counter for storage indexing

    % Read nc files
    h = waitbar(0,'Reading nc files...');
    for i = 1:length(fl)
        % Retrieve data from nc files
        z       = ncread([in_path, fl(i).name], 'z')/9.80665;     
        z       = squeeze(z(lon_idx,lat_idx,:,:));
        u       = ncread([in_path, fl(i).name], 'u');             
        u       = squeeze(u(lon_idx,lat_idx,:,:));
        v       = ncread([in_path, fl(i).name], 'v');             
        v       = squeeze(v(lon_idx,lat_idx,:,:));
        t       = ncread([in_path, fl(i).name], 'time');

        time    = size(z,2);
        level   = size(z,1);
        speed   = sqrt(u.^2+v.^2);
        angle   = atan2d(u,v); 

        angle(angle<0) = 360+angle(angle<0); % Get rid of negative values
        
        % Fills storage matrices
        stor_data(:,:,count_stor:count_stor+time-1) = [reshape(z, level,1,time), reshape(speed, level,1,time) reshape(angle, level,1,time)];
        stor_time(count_stor:count_stor+time-1, :)  = datevec(datenum([1900 1 1 0 0 0])+double(t)./24);

        count_stor     = count_stor+time;
        waitbar(i/length(fl),h);
    end
    delete(h);
    
    % Sorting files by time
    [~, idxT]   = sort(datenum(stor_time));
    stor_time   = stor_time(idxT,:);
    stor_data   = stor_data(:,:,idxT);
    
    % Write profiles
    h     = waitbar(0,'Writing profiles...');
    for i = 1:size(stor_data, 3)
        dlmwrite([out_path, num2str(i, '%05i'), '.gen'], flipud(stor_data(:,:,i)), 'delimiter', '\t', 'precision', 5);
        waitbar(i/size(stor_data,3),h);
    end
    delete(h);
    
end

save([folder, filesep, 'wind.mat'], 'stor_data', 'stor_time');  % Save data for analyses