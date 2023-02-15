# Mapping

## Main files

- `county_popn_2021.csv`: example county population data I use to validate the maps
- `R_mapping.R`: example of US county choropleths using the shapefiles/GeoJSON I worked on
  - example plots are `R_mapping_plt.pdf` and `R_mapping_plt.png`
- `usmap_mapping.R`: example of US county choropleths using `usmap` package
  - example plots are `usmap_mapping_plt.pdf` and `usmap_mapping_plt.png`
- `python_mapping.ipynb`: example of US county choropleths using `Plotly` and the updated GeoJSON I worked on 
  - example plots are `Plotly_mapping_plt.pdf` and `Plotly_mapping_plot.png`
- `troubleshooting_Plotly.ipynb`: walkthrough of why Plotly's suggested GeoJSON file isn't up-to-date

## Motivation

I realized that the US county GeoJSON file used in Plotly's county choropleth examples is outdated; there are some county FIPS code and boundary changes that aren't included. While I had alternative code for making similar maps in R using updated county shapefiles, it'd be nice to get equivalent maps in Plotly, especially because of Plotly's interactivity. 

Note that I focus only on US county choropleths here (i.e., each county is shaded according to areal data). I haven't tested how these files work when trying to overlay point data on the base maps, but I think, with the projection trick used, you'd have to identically reproject those data to get it to properly show on the map.

## Process

I found that the `usmap` [package](https://github.com/pdil/usmap) appears to use updated shapefiles (and the package looks actively maintained). I include a code example using this package in `usmap_mapping.R`. However, I realized that the shapefile transformations the package uses to get the map into US Albers don't quite match what Plotly "expects." More specifically, when I used the modified shapefiles that I generated, Alaska and Hawaii weren't aligning with the Plotly basemap and lost hover functionality. These two states were also cut off somehow. After some experimenting with my own shapefiles and Plotly, my hunch is that I can provide my own shapefile to Plotly's choropleth functions, but to ensure everything works/shows properly, it has to perfectly match the US Albers projection that Plotly.js (and I'm guessing d3.js?) uses. I could just be missing something here with the reprojection or specification of the shapefiles, but I figured just generating files that play nicely with Plotly is the simplest way to go. 

Additionally, when looking [here](https://github.com/d3/d3-geo#geoAlbersUsa) at d3-geo's docs, composite projection steps are listed and the example map looks identical to Plotly (I think supporting my hunch). I'm guessing `usmap` (which coincidentally borrows heavily from this [blog post](https://rud.is/b/2014/11/16/moving-the-earth-well-alaska-hawaii-with-r/)) fails to apply quite the same transformations, which leads to the discrepancy that seems to break the Plotly map.

This got a bit complicated. My plan then (props to this Mapbox [blog post](https://blog.mapbox.com/mapping-the-us-elections-guide-to-albers-usa-projection-in-studio-45be6bafbd7e)) is to start from scratch with the up-to-date US Census Bureau county shapefiles and reproject/transform them to get something that works with Plotly + something that we can use in R too in case you either want more low-level control than what `usmap` offers or are really nitpicky like me about why the R map doesn't perfectly match the Plotly map.

Steps I took:

1. Download 2020 shapefiles from [US Census Bureau](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.2020.html). These are the files in the `cb_2020_us_county_5m` folder.
    - Specifically, I used their [Web Interface](https://www.census.gov/cgi-bin/geo/shapefiles/index.php) and downloaded the compressed folder from there (year = 2020 and layer type = counties)
    - A list of county/county equivalent changes can be found [here](https://www.census.gov/programs-surveys/geography/technical-documentation/county-changes.2020.html#list-tab-VFGBJX758RQ8HYEHJP)
    - Update (02/14/23): the Web Interface looks like it now makes you download a slightly different zip file (tl_2020_us_count.zip instead). If I go [here](https://www2.census.gov/geo/tiger/GENZ2020/shp/), I think I can find the proper files. Maybe they updated how the Web Interface acts.
    
2. Use [mapshaper](https://github.com/mbloch/mapshaper) to filter the shapefile data and convert to GeoJSON. There's a [GUI](https://mapshaper.org/) online you can use, but I installed the actual mapshaper npm package and wrote a script with the commands for future reference. The script is `mapshaper_script.js` and can be run with `node mapshaper_script.js` if you have NodeJS installed. As I found out later, there seems to be some odd behavior/compatibility issues because of GeoJSON conventions (gj2008 vs. rfc7946), so the script outputs 2 files to the `mapshaper_CLI` folder. `US_county_mapshaper_rfc7946.json` has default args and `US_county_mapshaper_gj2008.json` with the gj2008 flag as suggested in this [issue](https://github.com/developmentseed/dirty-reprojectors/issues/13#issuecomment-662715598) to handle for bounding boxes as discussed below. After some experimenting, it looks like you don't really need the RFC 7946 version because it just causes bounding box issues, but I kept it anyway just in case.

3. Then, as that blog post suggests, use [dirty reprojectors](https://github.com/developmentseed/dirty-reprojectors) for the reprojection to Albers USA trick. I downloaded the actual package but kept running into issues with the CLI output; it's likely I'm missing some argument in the formatting. For the sake of simplicity I instead opted for the [web app](https://www.developmentseed.org/dirty-reprojectors-app/) to modify both of the files in `mapshaper_CLI`. The 2 output files from the app are in the `dirty_reprojectors` folder. 
  - `US_county_albersUSA_gj2008.geojson` plays well with the code in `R_mapping.R`. The RFC 7946 version shows annoying bounding boxes. Perhaps there's a workaround, but I found it simple enough to just use the 2008 file.
  - `US_county_albersUSA_gj2008.geojson` also works with `px.choropleth()` from Plotly, but for some reason the polygons are [badly wound](https://github.com/plotly/plotly.py/issues/3248). I ended up installing the `geojson_rewind` package [here](https://anaconda.org/conda-forge/geojson-rewind) or [here](https://github.com/chris48s/geojson-rewind). Then you can use `rewind()` with `rfc7946=False` to fix things. I saved the rewound version of the file as `dirty_reprojectors/US_county_albersUSA_gj2008_rewound.geojson` so you can just read that in and start plotting. See `python_mapping.ipynb` for the details. 
  - Oddly enough the badly wound version works fine with the Mapbox variant of Plotly's choropleths. Perhaps the two methods are internally different?
