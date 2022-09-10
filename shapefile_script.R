# script for reading in and manipulating US 2020 census county shapefile 

library(tidyverse)
library(sp)

# read shapefile from Census Bureau -- 2020 version
# downloaded all the files from here: https://www.census.gov/cgi-bin/geo/shapefiles/index.php
# used web interface to download (year = 2020, layer type = counties/equivalent)
county_sp <- sf::st_read('cb_2020_us_county_5m/cb_2020_us_county_5m.shp', quiet=T) %>%
  filter(!(STATEFP %in% c('66','69','72','78','60'))) %>% # ignore territories
  select(STUSPS, GEOID, geometry) %>%
  rename(FIPS=GEOID,
         state=STUSPS) %>%
  sf::st_transform(crs=2163) %>%
  as('Spatial') # convert to Spatial obj

# transform function to handle AK and HI -- stick them below continental US
# borrowed from urbnmapr package source code
transform_state <- function(object, rot, scale, shift) {
  object %>%
    maptools::elide(rotate=rot) %>%
    maptools::elide(scale=max(apply(bbox(object), 1, diff)) / scale) %>%
    maptools::elide(shift=shift)
}

# transform AK
alaska <- county_sp[county_sp$state=='AK',] %>%
  transform_state(-35, 2, c(-2600000, -2300000))
sp::proj4string(alaska) <- proj4string(county_sp)

# transform HI
hawaii <- county_sp[county_sp$state=='HI',] %>%
  transform_state(-35, 0.8, c(-1170000, -2363000))
sp::proj4string(hawaii) <- proj4string(county_sp)

# recombine with original shapefile
county_sf <- county_sp[!county_sp$state %in% c('AK','HI'),] %>%
  rbind(alaska, hawaii) %>%
  sf::st_as_sf()

# save sf object for later plotting
# 4 output files
sf::st_write(county_sf, 'US_2020_county_sf.shp')

# test mapping
ggplot() +
  geom_sf(data=county_sf, color='black', size=0.05)
