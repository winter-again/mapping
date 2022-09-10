# example of plotting in R
library(tidyverse)
library(ggthemes) # for clean map themes

# read in shapefile
county_sf <- sf::st_read('US_2020_county_sf.shp', quiet=T)

# generate some dummy data
# random value mapped to each county FIPS code
# "z" is the value we'll plot
dummy_data <- tibble(FIPS=county_sf$FIPS,
                     z=rnorm(length(county_sf$FIPS)))

# connect shapefile to data being mapped; join on the 'FIPS' column
map_data <- left_join(county_sf, dummy_data, by='FIPS')

# plot
# data is the map_data object we created above
# fill is the "z" column of values to plot in choropleth
# can change palette as you like (https://ggplot2.tidyverse.org/reference/scale_brewer.html#palettes)
plt <- ggplot() +
  geom_sf(data=map_data, mapping=aes(fill=z), color='black', size=0.01) +
  coord_sf() +
  scale_fill_distiller(palette='Blues', direction=1, name='Legend title') + # can put legend title here
  theme_map() + # from ggthemes
  theme(legend.position=c(0.95, 0.4),
        legend.background=element_blank(),
        plot.margin=margin(1,1.5,1,1, 'cm'))
plt