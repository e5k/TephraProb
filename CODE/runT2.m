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

Name:       runT2.m
Purpose:    Compiles and runs the TEPHRA2 model
Author:     Sebastien Biass
Created:    April 2015
Updates:    August 2018
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

function runT2
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

% Retrieve path
pth     = pwd;
project = load_run;

% Retrieve run parameters
fl = dir([project.run_pth, '*.mat']);
load(fullfile(project.run_pth, fl(1).name), 'data');

if project.run_pth == -1
    return
elseif data.write_conf == 0     % length(dir([project.run_pth, 'CONF/all/'])) == 2
    warndlg('No configuration file exist for this project. Please re-run the sampling of ESPs specifying the write_conf = 1');
    return
elseif data.write_gs == 0     % length(dir([project.run_pth, 'GS/all/'])) == 2
    warndlg('No grainsize file exist for this project. Please re-run the sampling of ESPs specifying the write_gs_files = 1');
    return
end

clear data

mod_pth = [pwd, filesep, 'MODEL', filesep, 'forward_src', filesep];

% On PCs, add the Cygwin folder to the PATH environment
% Added 08-2018
% Noticed a problem with the definition of the cygwin path when not
% installed in c:\cygwin
if ispc
    % path1 = getenv('PATH');
    
    % % Retrieve architecture
    % if strcmp(computer('arch'), 'win64')
    %     pathC = 'C:\cygwin64\bin';
    % elseif strcmp(computer('arch'), 'win32')
    %     pathC = 'C:\cygwin\bin';
    % end
    
    % % Check if path exists
    % if ~exist(pathC, 'dir') == 7
    %     % Check if the path to cygwin has already been saved
    %     if exist('CODE/VAR/cygwin.mat', file)
    %         load('CODE/VAR/cygwin.mat', 'pathC');
            
    %     % If not, retrieve it
    %     else
    %         choice = questdlg('Did you already install CYGWIN?', ...
    %             'CYGWIN', ...
    %             'Yes','No','Yes');
    %         % Handle response
    %         switch choice
    %             case 'Yes'
    %                 sprintf('Select the cygwin\bin directory\n');
    %                 pathC = uigetdir('C:\', 'Select the cygwin\bin directory');
    %                 save('CODE/VAR/cygwin.mat', 'pathC');
    %             case 'No'
    %                 url('https://cygwin.com/install.html');
    %                 return
    %         end
    %     end
    % end
    
    % % Check if the cygwin path is already in the environment
    % if isempty(strfind(path1,pathC))
    %     setenv('PATH', [path1,';',pathC,';']);
    % end
    
    % if ~exist([pwd, filesep, 'MODEL', filesep, 'tephra2-2012.exe'], 'file')
    %     warning('You need to manually compile Tephra2 on Cygwin!')
    %     fprintf('\t1. Open the Cygwin terminal\n')
    %     fprintf('\t2. Navigate to TephraProb\\MODEL\\ and type: \n')
    %     fprintf('\t\t make clean\n')
    %     fprintf('\t3. Then, type:\n')
    %     fprintf('\t\t make\n')
    %     fprintf('\t4. Once finished, type:\n')
    %     fprintf('\t\t chmod 755 tephra2-2012.exe\n')
    %     fprintf('\t5. To test the compilation, type:\n')
    %     fprintf('\t\t ./tephra2-2012.exe\n')
    %     fprintf('\tYou should see:\n')
    %     fprintf('\t\t Missing comand line arguments,\n')
    %     fprintf('\t\t USAGE: <program name> <config file> <points file> <wind file> <file of grain sizes>')
    %     return
    % else
    %     cd(pth);
    %     runit(project.run_pth,project.par,project.cores,pathC);  % Runs model
    % end
    

    pathC = [];
    % Compiles the model and runs it
    disp('Compiling Tephra2...')
    cd(mod_pth);                            % Navigates to the makefile
    system('wsl make clean');
    [stat, cmd_out] = system('wsl make');       % Compiles TEPHRA2
    
    if stat == 0                            % If compilation ok
        disp('Compiling done!')
        cd(pth);
        runit(project.run_pth,project.par,project.cores,pathC);  % Runs model
    else
        cd(pth);
        errordlg('There was a problem compiling TEPHRA2...', ' ');
        display(cmd_out);
    end

% If UNIX
else
    pathC = [];
    % Compiles the model and runs it
    disp('Compiling Tephra2...')
    cd(mod_pth);                            % Navigates to the makefile
    system('make clean');
    [stat, cmd_out] = system('make');       % Compiles TEPHRA2
    
    if stat == 0                            % If compilation ok
        disp('Compiling done!')
        cd(pth);
        runit(project.run_pth,project.par,project.cores,pathC);  % Runs model
    else
        cd(pth);
        errordlg('There was a problem compiling TEPHRA2...', ' ');
        display(cmd_out);
    end
end
        



function runit(run_pth, par, cores, pathC)

% Read the T2_stor files, retrieve the commands and sets the number of
% lines
fid     = fopen([run_pth,'T2_stor.txt'], 'r');
count   = 1;
stor    = {};
tline   = fgets(fid);
stor{count} = check_line(tline, pathC);
while ischar(tline)
    count = count + 1;
    tline = fgets(fid);
    if ischar(tline)
        stor{count} = check_line(tline, pathC);
    end
end
fclose(fid);

% Check if inputs are good for the model
[stat,cmdout] = system(stor{1});
if stat ~= 0 && ~isempty(regexp(cmdout, 'Cannot open wind file','ONCE'))
    errordlg('Tephra2 cannot access the wind files. Check that the path specified in the runProb function is correct and try again.', ' ');
    return
elseif stat ~= 0 && ~isempty(regexp(cmdout, 'Cannot open points','ONCE'))
    errordlg('Tephra2 cannot access the calculation points file. Check that the path specified in the runProb function is correct and try again.', ' ');
    return
elseif stat ~= 0 && ~isempty(regexp(cmdout, 'Cannot open grain file','ONCE'))
    errordlg('Tephra2 cannot access the TGSD file. Check that the path specified in the runProb function is correct and try again.', ' ');
    return  
elseif stat ~= 0 && ~isempty(regexp(cmdout, 'Cannot open configuration file','ONCE'))
    errordlg('Tephra2 cannot access the configuration file. Check that the path specified in the runProb function is correct and try again.', ' ');
    return  
elseif stat ~= 0 && ~isempty(regexp(cmdout, 'Segmentation fault','ONCE'))
    errordlg('Tephra2 returned a segmentation fault, which most likely means that there is something corrupted in your input files. Make sure all parameters specified in the runProb function are correct and try again.', ' ');
    return  
end

% Loads the project file and test if the parallel option is selected
fl = dir(fullfile(run_pth, '*.mat'));
load(fullfile(run_pth, fl(1).name));

% Check one run and time it
if par == 0
    divider = 1;
elseif par == 1
    divider = cores;
end

tic;
system(stor{1});
T = toc*count;
home

if T/divider < 60
    timestr = [num2str(round(T)), ' secondes'];
elseif T/divider/60 < 60
    timestr = [num2str(round(T/60)), ' minutes'];    
elseif T/divider/3600 < 24
    timestr = [num2str(round(T/3600)), ' hours'];
elseif T/divider/3600 >= 24
    timestr = [num2str(round(T/3600/24)), ' days'];
end

choice = questdlg(['You are about to start running the model, which should take about ', timestr,'. It is possible to stop this process at any moment by pressing ctrl+c, Would you like to continue?'], ...
	'Runs', ...
	'Yes', 'No', 'Yes');
% Handle response
switch choice
    case 'No'
        return
    case 'Yes'
end

% If single core
if par == 0
    for i = 1:count-1
        display(['Run ', num2str(i), '/',num2str(count-1)])
        system(stor{i});
        home;
    end
% If multiple cores
else
    % check pool
    if verLessThan('matlab', '8.2')
        matlabpool(cores); %#ok<*DPOOL>
    else
        p = gcp('nocreate');
        if isempty(p)
            parpool(cores);
        end
    end
    
    % runs TEPHRA2
    parfor i = 1:count-1
        display(['Run ', num2str(i), '/',num2str(count-1)]);
        system(stor{i});
        home;
    end
    
    % Close pool
    if verLessThan('matlab', '8.2')
        matlabpool close;
    else
        delete(gcp);
    end
    
end
if exist('plume2.dat', 'file')
    delete('plume2.dat', 'node_');
end

disp('Modelling finished!');

function line_out = check_line(tline,pathC)

% Some housekeeping tasks if run on windows
if ispc
%     if strcmp(computer('arch'), 'win64')        % Cygwin 64 bits    
%         pathC = 'C:\cygwin64\bin\bash';
%     elseif strcmp(computer('arch'), 'win32')    % Cygwin 32 bits 
%         pathC = 'C:\cygwin\bin\bash';
%     end
    
    % Added 08-2018: Propagating the custom cygwin directory 
    pathC = fullfile(pathC, 'bash');

    pth_tmp = pwd;                              % Retrieve path
    pth_tmp(regexp(pth_tmp, '\')) = '/';        
    pth_tmp(regexp(pth_tmp, ':')) = [];

    % Split the command line and add the cygdrive path
    tline_split = strsplit(tline, ' ');
    for i = [2,3,4,5,7]
        tline_split{i} = regexprep(['/cygdrive/', pth_tmp, '/', tline_split{i}],'\s+','');
    end
    
    % Concatanates final command line for cygwin
    tline = [tline_split{2}, ' ', tline_split{3}, ' ', tline_split{4}, ' ', tline_split{5}, ' > ', tline_split{7}];
    [s,e] = regexp(tline, './MODEL/tephra2-2012');
    tline(s:e) = [];
    tline = strrep(tline, '\', '/');
    
    % line_out = [pathC, ' --login -c "/cygdrive/', pth_tmp, '/MODEL/./tephra2-2012.exe ', tline, '"'];
    line_out = ['wsl ', tline];
else
    line_out = tline;
end