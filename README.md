# Mapping

Example code and files for making US choropleths in Python and R.

- `shapefile_script.R` contains code for generating a modified shapefile from US Census Bureau files
- `R_mapping.R` contains example code for making a county-level choropleth in R using the modified shapefile

## Workflow

This got a bit complicated.

1. Download 2020 shapefiles from [US Census Bureau](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.2020.html). These are the files in the `cb_2020_us_county_5m` folder.
    - Specifically, I used their [Web Interface](https://www.census.gov/cgi-bin/geo/shapefiles/index.php) and downloaded the compressed folder from there (year = 2020 and layer type = counties)
2. Use the [mapshaper](https://mapshaper.org/) GUI to filter the shapefile data and convert to a GeoJSON file. I found this Mapbox blog [post](https://blog.mapbox.com/mapping-the-us-elections-guide-to-albers-usa-projection-in-studio-45be6bafbd7e) really helpful. I upload the core shapefiles (`.shp`, `.shx`, and `.dbf`) to mapshaper. Then in the console filter out all the areas except for 50 states + DC, which should leave you with the 3,143 US counties:

```
filter 'STATEFP != 60'
filter 'STATEFP != 66'
filter 'STATEFP != 69'
filter 'STATEFP != 72'
filter 'STATEFP != 78'
```

Now export as a GeoJSON file. The quirk here is that--per this [issue](https://github.com/developmentseed/dirty-reprojectors/issues/13#issuecomment-662715598)--you need to include the `-o gj2008` flag when exporting to avoid a really annoying bounding box appearing in the output file (I learned this the hard way). The outputted file is what's in the `mapshaper` folder. I'll then use a different tool for reprojection to Albers USA (sort of).

I've been doing something quite similar to this process in the R scripts here, and they seem to work just fine when plotting/doing everything within R. However, when I tried to convert those shapefiles to GeoJSON to use with Plotly, things quickly got messy. 

3. Then, as that blog post suggests, use [dirty reprojectors](https://github.com/developmentseed/dirty-reprojectors) for the reprojection to Albers USA trick. I downloaded the actual package, but I think there's a [web app](https://www.developmentseed.org/dirty-reprojectors-app/) out there that might work too.

4. This file can now be read with Python to make county-level choropleths with Plotly. My troubleshooting and the code I eventually settled on are in `python_mapping.ipynb`.
