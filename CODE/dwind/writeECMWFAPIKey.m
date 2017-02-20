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

Name:       writeECMWFAPIKey.m
Purpose:    Writes the .ecmwfapirc file to user folder
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


function writeECMWFAPIKey
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

if ispc; 
    userdir= getenv('USERPROFILE'); 
else
    userdir= getenv('HOME');
end

if exist([userdir, filesep, '.ecmwfapirc'], 'file')
    choice = questdlg('It seems that an API key already exists. Overwrite?', ...
	'API key', ...
    'Yes','No','No');
    % Handle response
    switch choice
        case 'Yes'
            choice = 1;
        case 'No'
            choice = 0;
    end
else
    choice = 1;
end

if choice == 1
    apistr = inputdlg('Enter the content of the API key:', 'API key', [5,100]);
    apistr = apistr{1};

    fid = fopen([userdir, filesep, '.ecmwfapirc'], 'w');
    for i = 1:size(apistr,1)
        for j = 1:size(apistr,2)

            if j == size(apistr,2)
                fprintf(fid, '%s\n', apistr(i,j));
            else
                fprintf(fid, '%s', apistr(i,j));
            end
        end
    end
    fclose(fid);
end