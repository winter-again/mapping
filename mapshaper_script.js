var mapshaper = require("mapshaper");
const commandString = `
cb_2020_us_county_5m/cb_2020_us_county_5m.shp
-filter 'STATEFP != 60'
-filter 'STATEFP != 66'
-filter 'STATEFP != 69'
-filter 'STATEFP != 72'
-filter 'STATEFP != 78'
-o format=geojson mapshaper_CLI/US_county_mapshaper_rfc7946.json
`;
mapshaper.runCommands(commandString);

// using older GeoJSON convention to avoid bbox
const commandStringgj2008 = `
cb_2020_us_county_5m/cb_2020_us_county_5m.shp
-filter 'STATEFP != 60'
-filter 'STATEFP != 66'
-filter 'STATEFP != 69'
-filter 'STATEFP != 72'
-filter 'STATEFP != 78'
-o format=geojson gj2008 mapshaper_CLI/US_county_mapshaper_gj2008.json
`;
mapshaper.runCommands(commandStringgj2008);