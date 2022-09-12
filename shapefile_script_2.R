library(sp)

# aea: Albers Equal Area projection
aea_crs <- sp::CRS(paste("+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0",
                     "+a=6370997 +b=6370997 +units=m +no_defs"))

county_sp <- sf::st_read('cb_2020_us_county_5m/cb_2020_us_county_5m.shp', quiet=T) %>%
  filter(!(STATEFP %in% c('66','69','72','78','60'))) %>% # ignore territories
  select(STUSPS, GEOID, geometry) %>%
  rename(FIPS=GEOID,
         state=STUSPS) %>%
  sf::st_transform(crs=aea_crs) %>%
  # sf::st_transform(crs=5070) %>%
  as('Spatial') # convert to Spatial obj

alaska <- county_sp[county_sp$state=='AK',] %>%
  maptools::elide(rotate=-50) %>%
  maptools::elide(scale=max(apply(bbox(alska), 1, diff)), / 2.3) %>%
  maptools::elide(shift=c(-2100000, -2500000))
sp::proj4string(alaska) <- aea_crs
