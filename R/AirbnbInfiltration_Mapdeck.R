
#load libraries
source('./source/EasyLoad.R')
packages <- c('mapdeck','rgdal','sf','geojsonsf','htmlwidgets')
EasyLoad(packages)

key = read.delim('./mapbox_token.txt',header=F)
key = toString(key[,1])
key
#key= 'pk.eyJ1Ijoic2VucGFpbWFwIiwiYSI6ImNqeGVodTE2bjBuNnkzeHM4Z2p3aW9vYTkifQ.lXLo4w0noWwxHIUWSYLhmg'

infiltration_geojson <-geojson_sf('./data/neighbourhoods_infiltration2018.geojson')
infiltration_geojson$dist2hot2018 <-as.numeric(infiltration_geojson$dist2hot2018)
infiltration_geojson$Airbnb_TouristIntensity <-as.numeric(infiltration_geojson$Airbnb_TouristIntensity)
infiltration_geojson$Airbnb_TouristIntensity <- infiltration_geojson$Airbnb_TouristIntensity *1000

ms = mapdeck_style("light")
m <- mapdeck(token = key,style = ms, pitch = 45, location = c(4.895168, 52.370216),zoom=10) %>%
add_polygon(data = infiltration_geojson,fill_colour = "dist2hot2018", na_colour = "#00ff000",elevation = 'Airbnb_TouristIntensity',legend=T,
    update_view = F,auto_highlight =T,highlight_colour = "#AAFFFFFF",
    tooltip = paste('Beds per inhabitant: ','Airbnb_TouristIntensity'),palette = "ylorrd",legend_options = list(title='Distance (m) 2018')
  )
saveWidget(m, file="./infiltration_mapdeck.html",selfcontained = F)

