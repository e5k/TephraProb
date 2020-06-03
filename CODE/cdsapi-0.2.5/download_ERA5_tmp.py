#!/usr/bin/env python
import cdsapi
import calendar
import os


#Time of dataset
year_start  = var_year_start
year_end    = var_year_end
month_start = var_month_start
month_end   = var_month_end
# Area
north       = var_north
south       = var_south
west        = var_west
east        = var_east
# Output folder, i.e. replace by your project name
out_path    = 'var_out'


count  = 1
for year in range(year_start, year_end+1):
    if len(range(year_start, year_end+1)) == 1:
        mt_start = month_start
        mt_end = month_end
    else:
        if year == year_start:
            mt_start = month_start
            mt_end = 12
        elif year == year_end:
            mt_start = 1
            mt_end = month_end
        else:
            mt_start = 1
            mt_end = 12
    for month in range(mt_start, mt_end+1):
        lastday1=calendar.monthrange(year,month)
        lastday=lastday1[1]
        dayList = range(lastday+1)
        dayList = dayList[1:]
        dayList = [str(i) for i in dayList]

        bdate="%s%02d01"%(year,month)
        edate="%s%02d%s"%(year,month,lastday)

        print("######### ERA-5  #########")
        print('Accessing wind data from ', bdate,' to ',edate,' (YYYYMMDD)')
        print("################################")


        c = cdsapi.Client()
        c.retrieve(
            'reanalysis-era5-pressure-levels', 
            {
                'variable'      : ['geopotential', 'u_component_of_wind', 'v_component_of_wind'],
                'pressure_level': ['1', '2', '3','5', '7', '10','20', '30', '50','70', '100', '125','150', '175', '200','225', '250', '300','350', '400', '450','500', '550', '600','650', '700', '750','775', '800', '825','850', '875', '900','925', '950', '975','1000'],
                'product_type'  : 'reanalysis',
                'year'          : '%s'%(year),
                'month'         : '%s'%(month),
                'day'           : dayList,       
                'area'          : [north, west, south, east], # North, West, South, East. Default: global
                'grid'          : [0.25, 0.25], # Latitude/longitude grid: east-west (longitude) and north-south resolution (latitude). Default: 0.25 x 0.25
                'time'          : ['00:00', '06:00', '12:00','18:00'],
                'format'        : 'netcdf' # Supported format: grib and netcdf. Default: grib
            }, 
            "%s%05d_%s_%04d.nc"%(out_path, count, calendar.month_abbr[month],year))

        count = count + 1