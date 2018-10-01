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

Name:       runProb_vulc.m
Purpose:    Creates ESPs for various probabilistic Vulcanian eruption scenarios
Author:     Sebastien Biass
Created:    April 2015
Updates:    April 2016: Added the option to chose maximum aggregated
                        diameter
            Nov 2016  : ESP generation doesn't use parallel anymore
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


function runProb_vulc
% Check that you are located in the correct folder!
if ~exist(fullfile(pwd, 'tephraProb.m'), 'file')
    errordlg(sprintf('You are located in the folder:\n%s\nIn Matlab, please navigate to the root of the TephraProb\nfolder, i.e. where tephraProb.m is located. and try again.', pwd), ' ')
    return
end

global data                                     % Global variable

% Retrieve data from storage
state = prepare_data(0);
if state == 0
    return
end

if isfield(data, 'testrun')&& isfield(data, 'min_ri')
    % Check run number
    run_path        = fullfile('RUNS', data.run_name);
    if exist(run_path, 'dir')
        run_nb      = num2str(get_run_nb(run_path));
        out_pth     = fullfile(run_path, run_nb);
        mkdir(out_pth);
    else
        run_nb      = 1;
        out_pth     = fullfile(run_path, num2str(run_nb));
        mkdir(out_pth);
    end
    data.run_nb     = run_nb;   % Save run number to main struct
    data.run_type   = 'V';      % Save run type to main struct

    
    % Save run matrix
    data = rmfield(data, 'testrun');
    save(fullfile(out_pth, [data.run_name, '_', num2str(run_nb), '.mat']), 'data');
    
	% Structure to save run detail
    stor_run = struct;
    home;
    % Check if seasonality option is enable and wind preprocessing
    wind_vec_all    = datenum(data.wind_start):1/data.wind_per_day:(datenum(data.wind_start)+data.nb_wind/data.wind_per_day)-1/data.wind_per_day;     % Wind vector for the entire population
    
    if data.seasonality == 1 && data.constrain_eruption_date == 1
        data.seasonality = 0;
        display(sprintf('You have enabled the seasonality and the constrain eruption date options, which does not really make sense!\nThe seasonality option was disabled'));
    end
    
    if (data.min_ri < data.min_dur) && data.constrain_wind_dir ==1
       data.constrain_wind_dir = 0; 
       display(sprintf('You chose to constrain the wind direction over a long-lasting Vulcanian cycle.\nThis is not possible, so the constrain wind direction option was disabled\n'));
    end

    if data.seasonality == 1                                                                            % If seasonality option enabled
        month_rainy = ['01-', data.wind_start_rainy];                                                   % Starting month of the rainy season
        month_dry   = ['01-', data.wind_start_dry];                                                     % Starting month of the dry season
        tmp         = datevec(wind_vec_all);
        seas_str    = {'all', 'rainy', 'dry'};
        % Gets the wind profiles for each subseason
        if month(month_rainy) > month(month_dry)
            tmp_dry             = month(month_dry):month(month_rainy)-1;
            range_month_dry     = datenum(tmp(tmp(:,2) >= tmp_dry(1) & tmp(:,2) < tmp_dry(end),:));
            range_month_rainy   = datenum(tmp(tmp(:,2) < tmp_dry(1) | tmp(:,2) >= tmp_dry(end),:));
        else
            tmp_rainy           = month(month_rainy):month(month_dry)-1;
            range_month_rainy   = datenum(tmp(tmp(:,2) >= tmp_rainy(1) & tmp(:,2) < tmp_rainy(end),:));
            range_month_dry     = datenum(tmp(tmp(:,2) < tmp_rainy(1) | tmp(:,2) >= tmp_rainy(end),:));
        end
        wind_vec_dry            = ((range_month_dry-datenum(data.wind_start))*data.wind_per_day)+1;     % Vector containing the indices of the wind profiles for the dry season
        wind_vec_rainy          = ((range_month_rainy-datenum(data.wind_start))*data.wind_per_day)+1;   % Vector containing the indices of the wind profiles for the rainy season
    
        % Check if the duration of the eruption is longer than the seasons
        if data.max_dur/data.wind_per_day > length(wind_vec_dry) || data.max_dur/data.wind_per_day > length(wind_vec_rainy)
            errordlg('The eruption lasts longer than the seasons. The seasonality function cannot be used in this case', ' ');
            rmdir(out_pth);
            return
        end 
    elseif data.seasonality == 0
        seas_str                = {'all'};
    end
    wind_vec_all                = ((wind_vec_all-datenum(data.wind_start))*data.wind_per_day)+1;        % Vector containing indices of the all wind profiles

    % _______________________________________________________________________
    %
    % Main code starts here
    % _______________________________________________________________________

    % General storage file fed to the run_T2 function
    fid_T2 = fopen(fullfile(out_pth, 'T2_stor.txt'), 'wt');
        
    for seas = 1:length(seas_str)
        fprintf('Run for season %s\n', seas_str{seas});

        fprintf('\t Creating storage matrices and output folders\n');
        % Storage for all occurrences of all runs
        mass_stor_tot       = zeros(data.nb_runs, 1);   % Mass storage matrix
        mass_stor_tot_all   = [];                       % Mass storage matrix for all sedata.parated mass of each sim j
        height_stor_tot     = [];                       % Height storage matrix
        dur_stor_tot        = zeros(data.nb_runs, 1);   % Duration storage matrix
        ri_stor_tot         = [];                       % Repose interval storage matrix
        date_stor_tot       = zeros(data.nb_runs, 6);   % Start day
        pulse_stor_tot      = zeros(data.nb_runs, 1);   % Number of pulses
        med_stor_tot        = zeros(data.nb_runs, 1);   % Median phi storage matrix
        std_stor_tot        = zeros(data.nb_runs, 1);   % Sigma phi storage matrix
        agg_stor_tot        = zeros(data.nb_runs, 1);   % Aggregation coefficient storage matrix

        % Initialize counters
        count_tot       = 0;        % Counter of the number of sampling attempts

        % Output folders
        mkdir(fullfile(out_pth, 'OUT', seas_str{seas}));
        mkdir(fullfile(out_pth, 'CONF', seas_str{seas}));
        mkdir(fullfile(out_pth, 'GS', seas_str{seas}));
        mkdir(fullfile(out_pth, 'LOG', seas_str{seas}));
        mkdir(fullfile(out_pth, 'FIG'));
        mkdir(fullfile(out_pth, 'KML'));
        mkdir(fullfile(out_pth, 'FIG/ESP', seas_str{seas}));
        mkdir(fullfile(out_pth, 'FIG/MAPS', seas_str{seas}));
        mkdir(fullfile(out_pth, 'SUM', seas_str{seas}));
        mkdir(fullfile(out_pth, 'CURVES', seas_str{seas}));

        if ~exist(fullfile(out_pth, 'PROB'), 'dir')
            mkdir(fullfile(out_pth, 'PROB'));
        end

        % Get the wind vector for the season considered
        if strcmp(seas_str{seas}, 'all')
            wind_vec_seas = wind_vec_all;
        elseif strcmp(seas_str{seas}, 'rainy')
            wind_vec_seas = wind_vec_rainy;
        elseif strcmp(seas_str{seas}, 'dry')
            wind_vec_seas = wind_vec_dry;
        end

        % Loop through runs
        wb = waitbar(0,sprintf('Creating ESP...\n Press Ctrl+C to interrupt'));
        fprintf('\t Going through the runs\n');
        for i = 1:data.nb_runs 
            % Output folders for each run i
            mkdir(fullfile(out_pth, 'OUT', seas_str{seas}, num2str(i)));
            if data.write_conf == 1
                mkdir(fullfile(out_pth, 'CONF', seas_str{seas}, num2str(i)));
            end
            if data.write_fig_sep == 1
                mkdir(fullfile(out_pth, 'FIG/ESP', seas_str{seas}, num2str(i)));
            end

            count_tot   = count_tot + 1;      % Update counter

            % Storage matrices for run i
            ri_tmp      = [];     % Storage matrix for repose intervals for run i
            wind_vec    = [];     % Storage matrix for wind profiles ids
            
            dur         = data.min_dur + (data.max_dur-data.min_dur)*rand(1);    % Sample a duration
            
            % Start by sampling repose interval and checks i) when the sum
            % of the repose intervals is greater than the duration and ii)
            % if all repose intervals sampled fall into the current season
            % when converted into dates
            check_seas  = 0;
            while check_seas == 0
                % Get wind profile of the start of the eruption
                if data.constrain_eruption_date == 0
                    date_start      = wind_vec_seas(randi(length(wind_vec_seas)));  % Get the wind index of the beginning of the eruption
                    if date_start == 0                                              % If wind file no 0 is sampled, corrected to 1
                        date_start  = 1;
                    end
                    % Check option for One Wind Scenario (OWS)
                elseif data.constrain_eruption_date == 1
                    date_start      = datenum(data.eruption_date)*data.wind_per_day - datenum(data.wind_start)*data.wind_per_day;
                end
                
                ri_tmp      = [ri_tmp; 0];          % Counter for repose interval
                nb_sim      = 0;                    % Counter of pulses for each run i<

                % Test to see if the sum of repose intervals is longer than the sampled duration
                while sum(ri_tmp) <= dur
                    
                    wind_vec    = [wind_vec;...
                    round(date_start + sum(ri_tmp)/(24/data.wind_per_day))]; % Gets the wind file for each pulse

                    % Sample repose interval
                    if data.ri_sample == 0
                        ri_tmp = [ri_tmp; data.min_ri+((data.max_ri)-(data.min_ri))*rand(1)];
                    else
                        ri_tmp = [ri_tmp; exp(log(data.min_ri)+(log(data.max_ri)-log(data.min_ri))*rand(1))];
                    end
                    
                    nb_sim = nb_sim + 1;                                                % Number of pulses for run i
                end

                % Make sure that all wind profiles contained in wind_vec
                % are part of the considered season
                if length(unique(intersect(wind_vec_seas, wind_vec))) == length(unique(wind_vec))
                    check_seas = 1;
                else
                    continue
                end
            end
           
            ht_tmp      = zeros(nb_sim,1);     % Storage matrix for heights for run i
            mass_tmp    = zeros(nb_sim,1);     % Storage matrix for mass for run i          

            % Test to see if the sum of repose intervals is longer than the sampled duration
            for j = 1:nb_sim
                % Sample plume height
                if data.ht_sample == 0
                    ht_tmp(j) = data.min_ht+((data.max_ht)-(data.min_ht))*rand(1);
                else
                    ht_tmp(j) = exp(log(data.min_ht)+(log(data.max_ht)-log(data.min_ht))*rand(1));
                end
                % Calculate mass from Bonadonna et al. (2002)
                mass_tmp(j)   = nthroot((ht_tmp(j)-data.vent_ht)./55, 0.25);            
            end

            %% TGSD
            gs_med  = (data.min_med_phi+(data.max_med_phi-data.min_med_phi).*rand(1));             % Random median phi (uniform distribution)
            gs_std  = (data.min_std_phi+(data.max_std_phi-data.min_std_phi).*rand(1));             % Random sigma phi (uniform distribution)
            gs_coef = (data.min_agg+(data.max_agg-data.min_agg).*rand(1));                         % Aggregation coef

            gs_pdf  = normpdf(data.max_phi:data.min_phi, gs_med, gs_std);                     	   % Creates Gaussian distribution
            gs      = [(data.max_phi:data.min_phi)', gs_pdf'];                                	   % Shapes GS

            gs_tmp  = aggregate(gs, gs_coef, data.max_diam);                                       % Aggregates distribution

            % Transforms the PDF into a CDF
            gs_cum  = gs_tmp;
            for k = 1: size(gs_tmp, 1)
                gs_cum(k) = sum(gs_tmp(1:k))/sum(gs_tmp);
            end

            % Writes the TGSD file
            if data.write_gs == 1
                dlmwrite(fullfile(out_pth, 'GS', seas_str{seas}, [num2str(i, '%04d'), '.gsd']), [gs(:,1), gs_cum], 'delimiter', '\t'); 
            end

            % Write log file for this run
            if data.write_log_sep == 1
                fid     = fopen(fullfile(out_pth, 'LOG', seas_str{seas}, [num2str(i, '%04i'), '.txt']), 'wt');
                fprintf(fid, 'Log file for run number %d\t%s\n%s\n____________________________________\n\n',...
                    i, data.run_name, datestr(now));
                fprintf(fid, 'Eruption date:\t%s \nEruption duration:\t%.1f days\nNumber of simulations:\t%i\nTotal mass:\t%d kg\n\nTGSD\nMedian:\t%.1f\nSigma:\t%.1f\nAggregation coefficient:\t%.1f\n\n\n',...
                    datestr(datenum(data.wind_start)+wind_vec(1)/4), dur, nb_sim, sum(mass_tmp), gs_med, gs_std, gs_coef);
                fprintf(fid, 'Sim\tDate\tRepose interval\tWind\tHeight\tMass\n');
                for k = 1:nb_sim
                    fprintf(fid, '%d\t%s\t%.1f\t%i\t%.0f\t%d\n',...
                        k, datestr(datenum(data.wind_start)+wind_vec(k)/4, 'YY/mm/dd/hh'), ri_tmp(k), wind_vec(k), ht_tmp(k), mass_tmp(k));
                end
                fclose(fid);
            end

            % Update global storage matrices
            height_stor_tot     = [height_stor_tot; ht_tmp];
            ri_stor_tot         = [ri_stor_tot; ri_tmp];
            mass_stor_tot(i)    = sum(mass_tmp);
            mass_stor_tot_all   = [mass_stor_tot_all; mass_tmp];
            dur_stor_tot(i)     = dur;
            date_stor_tot(i,:)  = datenum(data.wind_start)+wind_vec(1)/4;
            pulse_stor_tot(i)   = length(ri_tmp);
            med_stor_tot(i)     = gs_med;
            std_stor_tot(i)     = gs_std;
            agg_stor_tot(i)     = gs_coef;

            % Figures for all separate runs i
            if data.write_fig_sep == 1
                % Plume height
                h = figure('Visible', 'off'); hist(ht_tmp,15); colormap([.8 .8 .8]);  title('Plume height','FontWeight','bold'); xlabel('Height (m asl)'); ylabel('Frequency');
                saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, num2str(i), 'plume_height.pdf')); 
                saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, num2str(i), 'plume_height.fig')); close(h);
                % Mass
                h = figure('Visible', 'off'); hist(mass_tmp,15); colormap([.8 .8 .8]);  title('Mass','FontWeight','bold'); xlabel('Mass (kg)'); ylabel('Frequency');
                saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, num2str(i), 'mass.pdf')); 
                saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, num2str(i), 'mass.fig')); close(h);% Repose interval
                % Repose interval
				h = figure('Visible', 'off'); hist(ri_tmp,15); colormap([.8 .8 .8]);  title('Repose interval','FontWeight','bold'); xlabel('Repose interval (hours)'); ylabel('Frequency');
                saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, num2str(i), 'interval.pdf')); 
                saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, num2str(i), 'interval.fig')); close(h);
            end

            % Write configuration files
            if data.write_conf == 1
                for j = 1:nb_sim    
                    % Write CONF file for TEPHRA2
                    fid = fopen(fullfile(out_pth, 'CONF', seas_str{seas}, num2str(i), [num2str(j,'%04d'), '.conf']), 'wt');
                        fprintf(fid,...
                            'PLUME_HEIGHT\t%d\nERUPTION_MASS\t%d\nVENT_EASTING\t%d\nVENT_NORTHING\t%d\nVENT_ELEVATION\t%d\nEDDY_CONST\t%d\nDIFFUSION_COEFFICIENT\t%d\nFALL_TIME_THRESHOLD\t%d\nLITHIC_DENSITY\t%d\nPUMICE_DENSITY\t%d\nCOL_STEPS\t%d\nPART_STEPS\t%d\nPLUME_MODEL\t%d\nALPHA\t%d\nBETA\t%d\n',...
                            ht_tmp(j), mass_tmp(j),...
                            data.vent_easting, data.vent_northing, data.vent_ht,...
                            data.eddy_const, data.diff_coeff, data.ft_thresh,...
                            data.lithic_dens, data.pumice_dens,...
                            data.col_step, data.part_step, 2, data.alpha, data.beta);
                     fclose(fid);

                     % T2_Stor prints the entire command for T2
                     tmp_model= ['./', 'MODEL/tephra2-2012']; 
					 tmp_conf = fullfile(out_pth, 'CONF', seas_str{seas}, num2str(i), [num2str(j, '%04d'), '.conf']);
					 tmp_wind = fullfile(data.wind_pth, [num2str(wind_vec(j), '%05d'), '.gen']);
					 tmp_gs   = fullfile(out_pth, 'GS', seas_str{seas}, [num2str(i, '%04d'), '.gsd']);
					 tmp_out  = fullfile(out_pth, 'OUT', seas_str{seas}, num2str(i), [data.out_name, '_', num2str(j, '%04d'), '.out']);
                     fprintf(fid_T2, '%s %s %s %s %s > %s\n', tmp_model, tmp_conf, data.grid_pth, tmp_wind, tmp_gs, tmp_out);
                end
            end
            waitbar(i / data.nb_runs)
        end
        close(wb);

        % Save run files
%%%% CHECK THAT
           %save([out_pth, data.run_name, '_', num2str(run_nb), '.mat'], 'data', 'T2_stor');
        % Save run matrix
        data.stor = stor_run;
        save(fullfile(out_pth, [data.run_name, '_', num2str(run_nb), '.mat']), 'data');

        % Figures for the entire run
        if data.write_fig_all == 1
			fprintf('\t Write all figures\n');
            % Plume height
            h = figure('Visible', 'off'); hist(height_stor_tot,15); colormap([.8 .8 .8]);  title(sprintf('Plume height\n%d occurrences', length(height_stor_tot)),'FontWeight','bold'); xlabel('Height (m asl)'); ylabel('Frequency');
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'plume_height.pdf')); 
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'plume_height.fig')); close(h);
            % Mass (of each run)
            h = figure('Visible', 'off'); hist(mass_stor_tot,15); colormap([.8 .8 .8]);  title(sprintf('Total mass per run\n%d occurrences', length(mass_stor_tot)),'FontWeight','bold'); xlabel('Mass (kg)'); ylabel('Frequency');
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'mass_run.pdf')); 
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'mass_run.fig')); close(h);
            % Mass (of each simulation)
            h = figure('Visible', 'off'); hist(mass_stor_tot_all,15); colormap([.8 .8 .8]);  title(sprintf('Total mass per simulation\n%d occurrences', length(mass_stor_tot_all)),'FontWeight','bold'); xlabel('Mass (kg)'); ylabel('Frequency');
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'mass_sim.pdf')); 
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'mass_sim.fig')); close(h);
            % Start date
            h = figure('Visible', 'off'); hist(date_stor_tot, round(data.nb_wind/4/365)*12); colormap([.8 .8 .8]); datetick('x', 'mm/YY'); title(sprintf('Start date\n%d occurrences', length(date_stor_tot)),'FontWeight','bold'); xlabel('Date (per month)'); ylabel('Frequency');
			saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'date.pdf')); 
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'date.fig')); close(h);
			% Median phi
            h = figure('Visible', 'off'); hist(med_stor_tot,15); colormap([.8 .8 .8]);  title(sprintf('Median phi\n%d occurrences', length(med_stor_tot)),'FontWeight','bold'); xlabel('Median phi'); ylabel('Frequency');
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'median.pdf')); 
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'median.fig')); close(h);
            % Sigma phi
            h = figure('Visible', 'off'); hist(std_stor_tot,15); colormap([.8 .8 .8]);  title(sprintf('Sigma phi\n%d occurrences', length(std_stor_tot)),'FontWeight','bold'); xlabel('Sigma phi'); ylabel('Frequency');
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'sigma.pdf')); 
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'sigma.fig')); close(h);
            % Aggregation
            h = figure('Visible', 'off'); hist(agg_stor_tot,15); colormap([.8 .8 .8]);  title(sprintf('Aggregation coefficient\n%d occurrences', length(agg_stor_tot)),'FontWeight','bold'); xlabel('Aggregation coefficient'); ylabel('Frequency');
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'aggregation.pdf')); 
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'aggregation.fig')); close(h);
            % Duration
            h = figure('Visible', 'off'); hist(dur_stor_tot,15); colormap([.8 .8 .8]);  title(sprintf('Duration\n%d occurrences', length(dur_stor_tot)),'FontWeight','bold'); xlabel('Duration (days)'); ylabel('Frequency');
			saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'duration.pdf')); 
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'duration.fig')); close(h);
            % Repose interval
            h = figure('Visible', 'off'); hist(ri_stor_tot,15); colormap([.8 .8 .8]);  title(sprintf('Repose interval\n%d occurrences', length(ri_stor_tot)),'FontWeight','bold'); xlabel('Interval (hours)'); ylabel('Frequency');
			saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'interval.pdf')); 
            saveas(h, fullfile(out_pth, 'FIG/ESP', seas_str{seas}, 'interval.fig')); close(h);
        end

        % Write the log file for all runs
        if data.write_log_all == 1
			fprintf('\t Write log file\n');
            % Header
            fid = fopen(fullfile(out_pth, 'LOG', seas_str{seas}, '_LOG_ALL.txt'), 'wt');
            fprintf(fid, 'Log file for all runs \n%s\n____________________________________\n\n',...
                datestr(now));

            % Run parameters
            fprintf(fid, 'Run parameters\n\tRun name:\t%s\n\tOutput name:\t%s\n\tNumber of runs:\t%.0f\n\tWind population (years):\t%.0f\n\n',...
                data.run_name, data.out_name, data.nb_runs, round(data.nb_wind/4/365));

            % Volcano parameters
            fprintf(fid, 'Volcano parameters\n\tName:\t%s\n\tEasting:\t%i\n\tNorthing:\t%i\n\tElevation:\t%i\n\n',...
                data.volcano_name, data.vent_easting, data.vent_northing, data.vent_ht);

            % Eruption parameters
            if data.ht_sample == 1
                dist_ht = 'Logarithmic';
            else
                dist_ht = 'Uniform';
            end
            if data.ri_sample == 1
                dist_ri = 'Logarithmic';
            else
                dist_ri = 'Uniform';
            end
            fprintf(fid, 'Eruption parameters\n\tPlume height (m asl):\t%.0f\t%.0f\n\tPDF for plume height:\t%s\n\tRepose interval (hours):\t%.0f\t%.0f\n\tPDF for repose interval:\t%s\n\tDuration (days):\t%.0f\t%.0f\n\n',...
                data.min_ht, data.max_ht, dist_ht, data.min_ri, data.max_ri, dist_ri, data.min_dur, data.max_dur);

            % TGSD parameters
            fprintf(fid, 'Total grainsize distribution\n\tMinimum (phi):\t%.1f\n\tMaximum (phi):\t%.1f\n\tMedian (phi):\t%.1f\t%.1f\n\tSigma (phi):\t%.1f\t%.1f\n\tAggregation coefficient:\t%.1f\t%.1f\n\n',...
                data.min_phi, data.max_phi, data.min_med_phi, data.max_med_phi, data.min_std_phi, data.max_std_phi, data.min_agg, data.max_agg);

            % Model parameters
            fprintf(fid, 'Model parameters\n\tEddy constant:\t%.2f\n\tDiffusion coefficient:\t%.2f\n\tFall-time threshold:\t%.2f\n\tLithic density:\t%.2f\n\tPumice density:\t%.2f\n\tColumn step:\t%.2f\n\tParticles step:\t%.2f\n',...
                data.eddy_const, data.diff_coeff, data.ft_thresh, data.lithic_dens, data.pumice_dens, data.col_step, data.part_step);

            fprintf(fid, '\tPlume model:\t%s\n\tAlpha:\t%.2f\n\tBeta:\t%.2f\n\n',...
                'Beta', data.alpha, data.beta);

            % Runs
            fprintf(fid, 'Runs summary\nRun\tPulses\tMass (kg)\tDuration (h)\tMedian phi\tSigma phi\tAggregation coefficient\n');
            for k = 1:data.nb_runs
                fprintf(fid, '%d\t%i\t%.2e\t%.2f\t%.2f\t\t%.2f\t\t%.2f\n',...
                    k, pulse_stor_tot(k), mass_stor_tot(k), dur_stor_tot(k), med_stor_tot(k), std_stor_tot(k), agg_stor_tot(k));
            end
            fclose(fid);
        end
        fprintf('Min mass:\t%d\t\tMax mass:\t%d\n', min(mass_stor_tot), max(mass_stor_tot))
    end   
    
    % Close access to file
    fclose(fid_T2);
end



% Prepare data for the GUI
function state = prepare_data(mode)
% Mode: 0: New run
%       1: Load run
global t
load(fullfile('VAR','tephraProb_vulc.mat'));    % Load the description of each variable -> tab
if mode == 1                                    % If in load mode
    uiopen('*.mat');                            % Load previous run -> data
    if ~exist('data', 'var')
        return
    elseif isfield(data, 'long_lasting')
        errordlg('You are trying to load a wrong type of run (i.e. Plinian)', ' ');
        state = 0;
    else      
        state = 1;
        data  = check_project(tab, data);
        set(t.tab, 'Data', [data.var, data.ini, data.dsc]);
    end
    
elseif mode == 0  
    data_gui([tab.var, tab.ini, tab.dsc]);
    state = 1;
end

function load_data(~, ~, ~)
prepare_data(1);  

% Get run number
function run_nb = get_run_nb(run_path)
l       = dir(run_path);
dir_stor= zeros(length(l)-2,1);
if length(l) == 2
    run_nb = 1;
else
    for i = 3:length(l)
        dir_stor(i-2) = str2double(l(i).name);
    end
    run_nb = max(dir_stor)+1;
end


% GUI for displaying data
function data_gui(tab_data)
global t
% Define GUI
scr = get(0,'ScreenSize');
w   = 800;
h   = 800;

% Main figure
t.fig = figure(...
    'position', [scr(3)/2-w/2 scr(4)/2-h/2 w h],...
    'Color', [.25 .25 .25],...
    'Resize', 'off',...
    'Toolbar', 'none',...
    'Menubar', 'none',...
    'Name', 'TephraProb',...
    'NumberTitle', 'off');

        % Menu
        t.menu = uimenu(t.fig, 'Label', 'File');
            t.m11 = uimenu(t.menu, 'Label', 'Load', 'Accelerator', 'O');
        
        % Main panel
        t.main = uipanel(...
            'parent', t.fig,...
            'units', 'normalized',...
            'position', [.025 .025 .95 .95],...
            'title', '',...
            'BackgroundColor', [.25 .25 .25],...
            'ForegroundColor', [.9 .5 0],...
            'HighlightColor', [.9 .5 0],...
            'BorderType', 'line',...
            'Title', 'Input parameters');   
        
            % Main table
            t.tab = uitable(...
                'parent', t.main,...
                'units', 'normalized',...
                'position', [.03 .1 .94 .87],...
                'BackgroundColor', [.3 .3 .3; .25 .25 .25],...
                'ColumnName', {'Variable', 'Value', 'Description'},...
                'ColumnWidth', {100, 120, 470},...
                'ColumnFormat', {'char', 'char', 'char'},...
                'ColumnEditable', [false true false],...
                'RowStriping', 'on',...
                'Data', tab_data, ...
                'RowName', [],...
                'ForegroundColor', [1 1 1]);

           % Ok button    
           t.ok = uicontrol(...
                'parent', t.main,...
                'Style', 'pushbutton',...
                'units', 'normalized',...
                'position', [.85 .02 .12 .06],...
                'BackgroundColor', [.3 .3 .3],...
                'ForegroundColor', [.9 .5 .0],...
                'String', 'Ok');

% Callback for ok button
set(t.ok, 'callback', {@test_param, t})
set(t.m11, 'callback', {@load_data, t})
uiwait(t.fig);

% Test input parameters
function test_param(~, ~, t)
uiresume(t.fig);
global data                     % Define global variable
data = struct;                  % Create a new structure storing all data
tmp  = get(t.tab, 'Data');      % Retrieve data table

% Go through input parameters
for i = 1:size(tmp, 1)
    % If line is not empty (i.e. separator)
    if ~isempty(tmp{i,1}) && ~isempty(tmp{i,2}) && ~isempty(tmp{i,3})
        if isnan(str2double(tmp{i,2}))                                      % If cell is a string
            data.(tmp{i,1}) = tmp{i,2}; % = setfield(data, tmp{i,1}, tmp{i,2});
        else     
            % Else convert it to double
            data.(tmp{i,1}) = str2double(tmp{i,2});
            %data = setfield(data, tmp{i,1}, str2double(tmp{i,2}));
        end
    end
end

errchk  = 0;
warnstr = 'The following problems were identified:\n';
if ~exist(data.grid_pth, 'file')
    warnstr = strcat(warnstr, '- The path to the grid file does not exist\n'); errchk = 1;
elseif ~isdir(data.wind_pth)
    warnstr = strcat(warnstr, '- The path to the wind files does not exist\n'); errchk = 1;
elseif data.max_ht < data.min_ht
    warnstr = strcat(warnstr, '- The maximum plume height is lower than the minimum plume height\n'); errchk = 1;
elseif data.max_ri < data.min_ri
    warnstr = strcat(warnstr, '- The maximum repose interval is lower than the minimum mass\n'); errchk = 1;
elseif data.max_dur < data.min_dur
    warnstr = strcat(warnstr, '- The maximum duration is lower than the minimum duration\n'); errchk = 1;
elseif data.min_phi < data.max_phi
    warnstr = strcat(warnstr, '- The max_phi variable represents the coarsest material, i.e. the smallest number in phi units\n'); errchk = 1;
elseif data.max_med_phi < data.min_med_phi
    warnstr = strcat(warnstr, '- The maximum median phi is lower than the minimum median phi\n'); errchk = 1;
elseif data.max_std_phi < data.min_std_phi
    warnstr = strcat(warnstr, '- The maximum std phi is lower than the minimum std phi\n'); errchk = 1;
elseif data.max_agg < data.min_agg
    warnstr = strcat(warnstr, '- The maximum aggregation coefficient is lower than the minimum maggregation coefficient\n'); errchk = 1;
end

if errchk == 1
    wrn = warndlg(sprintf(warnstr), ' ');
    waitfor(wrn);
    close(t.fig);
    data_gui(tmp);
    
else
    data.testrun = 1;
    close(t.fig);
end
