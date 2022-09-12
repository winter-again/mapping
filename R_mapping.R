library(tidyverse)
library(vroom)
library(ggthemes) # for clean map themes
library(scales)

# example data -- 2021 population estimates for 3,143 counties
df <- vroom('county_popn_2021.csv') %>%
  select(STATE, STNAME, COUNTY, CTYNAME, POPESTIMATE2021) %>%
  mutate(fips=paste0(STATE, COUNTY)) %>% # create FIPS code col; note that it has to be named 'fips' to work with plot_usmap() below
  relocate(fips, .before=CTYNAME) %>%
  filter(COUNTY!='000') %>% # drop state rows
  filter(!(STATE %in% c('66','69','72','78','60'))) # drop territories

# read in geojson file
geo <- geojsonsf::geojson_sf('dirty_reprojectors/US_county_albersUSA_gj2008.geojson') %>%
  sf::st_as_sf() # note specific use of gj2008 file
map_data <- left_join(geo, df, by=c('GEOID'='fips')) # join df with geo data

plt <- ggplot() +
  geom_sf(data=map_data, mapping=aes(fill=POPESTIMATE2021), color='black', size=0.01) +
  coord_sf() +
  theme_map() +
  scale_fill_distiller(limits=c(10000, 200000), direction=1, name='2021 popn', oob=squish) + # can put legend title here; oob=squish makes it so that out of bound (oob) values get colored same as limit
  # modify legend location
  theme(legend.position=c(0.95, 0.4),
        legend.background=element_blank(),
        plot.margin=margin(1,1.5,1,1, 'cm'))
plt

# save
ggsave('R_mapping_plt.png', width=7, height=5, units='in', dpi=600) # png
ggsave('R_mapping_plt.pdf', width=7, height=5, units='in')