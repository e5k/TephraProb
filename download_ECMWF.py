#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer
import calendar
import os
## Enter the required data below

# Time of dataset
<<<<<<< Updated upstream
year_start  = 2000
=======
year_start  = 2015
>>>>>>> Stashed changes
year_end    = 2015
month_start = 1
month_end   = 12
# Area
<<<<<<< Updated upstream
north       = 32.58
south       = 30.58
west        = 129.659
east        = 131.659
# Output folder, i.e. replace by your project name
out_path    = 'WIND/saku0015/'
=======
north       = 13
south       = 11
west        = 13
east        = 15
# Output folder, i.e. replace by your project name
out_path    = 'WIND/test/'
>>>>>>> Stashed changes


## Time of dataset
#year_start  = 2010
#year_end    = 2013
#month_start = 1
#month_end   = 12
## Area
#north       = -37
#south       = -40
#west        = -40
#east        = -38
## Output folder, i.e. replace by your project name
#out_path    = 'OUT/'


##################################################
#os.mkdir(out_path)
#os.mkdir(out_path+"nc_output_files")
#os.mkdir(out_path+"txt_output_files")
server = ECMWFDataServer()
count  = 1
for year in range(year_start, year_end+1):
<<<<<<< Updated upstream
    print('YEAR ',year)
=======
    print 'YEAR ',year
>>>>>>> Stashed changes
    for month in range(month_start, month_end+1):
        lastday1=calendar.monthrange(year,month)
        lastday=lastday1[1]
        bdate="%s%02d01"%(year,month)
        edate="%s%02d%s"%(year,month,lastday)

<<<<<<< Updated upstream
        print("######### ERA-interim  #########")
        print('Accessing wind data from ', bdate,' to ',edate,' (YYYYMMDD)')
        print("################################")
=======
        print "######### ERA-interim  #########"
        print 'Accessing wind data from ', bdate,' to ',edate,' (YYYYMMDD)'
        print "################################"
>>>>>>> Stashed changes
        
        server.retrieve({
            'dataset'   : "interim",
            'date'      : "%s/to/%s"%(bdate,edate),
            'time'      : "00/06/12/18",
            'step'      : "0",
            'stream'    : "oper",
            'levtype'   : "pl",
            'levelist'  : "all",
            'type'      : "an",
            'class'     : "ei",
            'grid'      : "0.25/0.25",
            'param'     : "129/131/132/156",
            'area'      : "%d/%d/%d/%d"%(north, west, south, east),
            'format'	: 'netcdf',
            'target'    : "%s%05d_%s_%04d.nc"%(out_path+"nc_output_files/", count, calendar.month_abbr[month],year)
        }) 
        
        count = count + 1