# TephraProb

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3590721.svg)](https://doi.org/10.5281/zenodo.3590721)

*TephraProb* is a toolbox of Matlab functions designed to produce scenario-based probabilistic hazard assessments for ground tephra accumulation using on the Tephra2 model. The toolbox includes series of GUIs that allow to:
- Retrieve and analyse wind conditions from the NOAA Reanalysis and the ECMWF ERA-Interim datasets; 
- Create calculation grids in UTM;
- Retrieve and analyse eruption datasets from the Global Volcanism Program database;
- Create distributions of eruption source parameters based on a wide range of probabilistic eruption scenarios;
- Run Tephra2 using the generated input scenarios;
- Compile exceedence probability maps, probabilistic isomass maps and hazard curves.

## Usage
In Matlab, navigate to the root of *TephraProb*, type
~~~
>> tephraProb
~~~
and press enter. 

## Documentation
Documentation can be found:
1. In the user manual attached with the code - which provides the most detailed decriptions of the functionalities of the code;
2. In the video tutorial available [here](https://www.youtube.com/channel/UCP8gCjSeMoPVwgzMwKUnW3w);
3. At [https://e5k.github.io](https://e5k.github.io), where updates and new functionalities are presented and described.

## Citation
*TephraProb* was published in *Journal of Applied Volcanology* available [here](https://www.researchgate.net/publication/306542890_TephraProb_a_Matlab_package_for_probabilistic_hazard_assessments_of_tephra_fallout?_sg=6C2i5QDp2yVVGwq6-1vysV6VPviMBwQUIultmIdieYx1rn5iIBf_idX6LFCaXxHcu-sVVOYm5Nwac8F0fpAe523tlDOATp8YTrPKxVZl.IhjyHIlIeyPY4N-EqNv8xDFe-JURfFYcvxG34tEZYWeJwcsRgzXdAcwAsCv8Np3itOrEFjcwVPR3-8vIvHiGWw) and [here](https://appliedvolc.biomedcentral.com/articles/10.1186/s13617-016-0050-5). Please cite as:
> Biass, S., Bonadonna, C., Connor, L., Connor, C., 2016. TephraProb: a Matlab package for probabilistic hazard assessments of tephra fallout. J. Appl. Volcanol. 5, 1–16. doi:10.1186/s13617-016-0050-5

> Biass, S., Bonadonna, C., Connor, L., Connor, C., 2016. TephraProb. [doi:10.5281/zenodo.3590721](https://doi.org/10.5281/zenodo.3590721)

## Acknowledgments

- **Zohar Bar-Yehuda** for the [plot_google_map](https://github.com/zoharby/plot_google_map) function.
- **Alex Voronov** for the [plot_openstreetmap](https://github.com/alexvoronov/plot_openstreetmap) function.
- **Wim Degruyter** for the [get_mer](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2012GL052566?casa_token=OBXKwSpV8vcAAAAA%3A4HJhAV0JgGCN2sLJehl8FMWA6PU8oxxLWwEQNBJbA31-M-iH6iz5ayjHwT-GrnWHEjIkOOUTFYYOKiWM) function.
- **Francois Beauducel** for the [ll2utm](https://ch.mathworks.com/matlabcentral/fileexchange/45699-ll2utm-and-utm2ll?s_tid=ta_fx_results) function.
- **M MA** for the [wind_rose](https://ch.mathworks.com/matlabcentral/fileexchange/17748-wind_rose?s_tid=ta_fx_results) function.
- **Scott Lee Davis** for the [Google Earth](https://ch.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox?s_tid=ta_fx_results) toolbox.

Apologies if I forgot anyone!

## License
TephraProb is released under a GPL3 license, which means that everybody should 
feel free to contribute, comment, suggest and modify the code for as long as any 
new update remains open-source. Don't hesitate to contact me by email should you 
have a suggestion or find a bug.

Hope this code will help!

