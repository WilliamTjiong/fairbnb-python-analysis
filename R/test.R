install.packages('mapdeck')
install.packages('sf')
install.packages('geojsonsf')
library(sf)

MAPBOX = 'pk.eyJ1Ijoic2VucGFpbWFwIiwiYSI6ImNqeGRzaG02dTAza3Uzb2w3aTA1Y2NkaTgifQ.tKJOjrcXcOlkRnpE05VdCw'

amsterdam <- geojson_sf('./data/amsterdam_neighbourhoods.geojson')
flickr <-geojson_sf('./data/GeotaggedFlickr_24june2019.geojson')
flickr$dummy_value <-  sample(10000:10000000, size = nrow(flickr), replace=T)

ms = mapdeck_style("light")
m <- mapdeck(token= MAPBOX, style = ms, pitch = 45, location = c(4.895168, 52.370216),zoom=10)%>%
  add_polygon(
    data = amsterdam
    , fill_colour = "2018"
    , elevation = "2018",
    legend=T,
    update_view = F,
    auto_highlight =T,
    highlight_colour = "#AAFFFFFF",
    fill_opacity=255,
    tooltip = '2018'
  )

saveWidget(m, file="./test.html",selfcontained = F)


