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

Name:       aggregate.m
Purpose:    Aggregate a TGSD following the empirical method of Bonadonna et
            al. (2002)
Author:     Sebastien Biass
Created:    April 2015
Updates:    April 2016: Added the option to chose maximum aggregated
                        diameter
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

function totgs_agg = aggregate(GS, prc, max_diam)

totgs_agg   = GS;
idx_min     = find(GS(:,1) == max_diam); % Find corresponding diameter in the matrix
sum_ag      = 0;

for i = idx_min:size(GS,1)
    agg             = prc*GS(i,2);        % Amount removed due to aggregation
    totgs_agg(i,2)  = totgs_agg(i,2)-agg; % Remove amount
    sum_ag          = sum_ag + agg;       % Add the removed amount for given phi to total removed amount
end

idx         = find(GS(:,1) == -1);        % Max diameter in which aggregates will be redistributed
sum_ag      = sum_ag/length(idx:idx_min-1); % Split the total amount of aggregates into the number of classes in which they will be redistributed

totgs_agg(idx:idx_min-1, 2) = totgs_agg(idx:idx_min-1, 2) + sum_ag;  
totgs_agg   = totgs_agg(:,2);


   