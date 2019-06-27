library(ggplot2)
library(leaflet)
library(reshape2)
theme_set(theme_bw())

#function to create Flickr and Twitter Lealet
FlickrTwitter <- function(flickr_geojson,twitter_geojson){
  
  pal_flickr <- colorFactor(palette = 'viridis', domain = flickr_geojson$traveler_type)
  pal_twitter <- colorFactor(palette = rainbow(length(unique(twitter_geojson$hashtag))), 
                             domain = twitter_geojson$hashtag)
  
  north_arrow <- "<img src='http://pluspng.com/img-png/free-png-north-arrow-big-image-png-1659.png' style='width:30px;height:40px;'>"
  
  m <- leaflet(options = leafletOptions(zoomControl = F)) %>% 
    setView(lng = 4.895168, lat = 52.370216, zoom = 11) %>%
    addProviderTiles(providers$Esri.WorldGrayCanvas) %>%
    
    #flickr
    addCircleMarkers(group = "Flickr",data = flickr_geojson,radius = 4,stroke=F,fillOpacity = 0.7,color = ~pal_flickr(traveler_type),
                     popup = paste("<b>Photo title:</b>", flickr_geojson$photo_title, "<br>",
                                   "<b>Date taken:</b>", flickr_geojson$date_taken, "<br>",
                                   "<b>User origin:</b>", flickr_geojson$user_location))%>%
    #twitter
    addCircleMarkers(group = "Twitter",data = twitter_geojson,radius = 4,stroke=F,fillOpacity = 0.7,color = ~pal_twitter(hashtag),
                     popup = paste("<b>Neighbourhood:</b>", twitter_geojson$neighbourh, "<br>",
                                   "<b>Tweet date:</b>", twitter_geojson$created, "<br>",
                                   "<b>Text:</b>", twitter_geojson$text,
                                   "<b>Traveler type:</b>", twitter_geojson$Descriptio))%>%
    
    addLegend(group = "Flickr",data =flickr_geojson ,"topleft", pal = pal_flickr, values = ~traveler_type,title = "Traveler type")%>%
    addLegend(group = "Twitter",data =twitter_geojson ,"topleft", pal = pal_twitter, values = ~hashtag,title = "Twitter hashtag")%>%
    addMiniMap(position = "bottomright",toggleDisplay = T,minimized = T)%>%
    addControl(html = north_arrow , position = "topright")%>%
    addScaleBar(position = 'bottomleft',options = scaleBarOptions(imperial = F))%>%
    addLayersControl(overlayGroups = c("Flickr", "Twitter"),options = layersControlOptions(collapsed = FALSE))%>%
    hideGroup("Twitter")
  return(m)
}

flickr_geojson <- rgdal::readOGR(dsn='./data/GeotaggedFlickr_24june2019.geojson')
twitter_geojson <- rgdal::readOGR(dsn='./data/tweets_v2.geojson')

df_twitter <- data.frame(matrix(0, ncol = 6, nrow = length(unique(twitter_geojson$hashtag))))
colnames(df_twitter)[1] <- "hashtag"
colnames(df_twitter)[2] <- "count_tag_tourist"
colnames(df_twitter)[3] <- "count_tag_nontourist"
colnames(df_twitter)[4] <- "total_tag"
colnames(df_twitter)[5] <- "pct"
colnames(df_twitter)[6] <- "pct_non"
hashtags <- unique(twitter_geojson$hashtag)
for (row in 1:length(hashtags)){
  df_twitter$hashtag[row] <- as.character(hashtags[row])
  tag <- as.character(hashtags[row])
  total_tag <- length(twitter_geojson[ which(twitter_geojson$hashtag==tag),])
  tag_tourist <- length(twitter_geojson[ which(twitter_geojson$hashtag==tag & twitter_geojson$Descriptio=='tourist'), ])
  tag_nontourist <- length(twitter_geojson[ which(twitter_geojson$hashtag==tag & twitter_geojson$Descriptio=='non-tourist'), ])
  df_twitter$count_tag_nontourist[row] <- tag_nontourist
  df_twitter$count_tag_tourist[row] <- tag_tourist
  df_twitter$total_tag[row] <- total_tag
  df_twitter$pct[row] <- (tag_tourist/total_tag)*100
  
  tag_nontourist <- length(twitter_geojson[ which(twitter_geojson$hashtag==tag & twitter_geojson$Descriptio=='non-tourist'), ])
  df_twitter$pct_non[row] <- (tag_nontourist/total_tag)*100
  
}


  
# Draw plot
ggplot(df_twitter, aes(x=hashtag, y=pct)) + 
  geom_bar(stat="identity", width=.5, fill=rainbow(n=length(df_twitter$hashtag))) + 
  labs(title="Percentage of tourist per hashtag",
       caption="source: Twitter") + 
  theme(axis.text.x = element_text(angle=65, vjust=0.6))+
  xlab('Hashtag')+ylab('%')

df_twitter.long <- melt(df_twitter)
df_twitter.long <- df_twitter.long[ which(df_twitter.long$variable=='pct' | df_twitter.long$variable=='pct_non'), ]
df_twitter.long$variable <- as.character(df_twitter.long$variable)
df_twitter.long$variable[df_twitter.long$variable=='pct'] <- "tourist"
df_twitter.long$variable[df_twitter.long$variable=='pct_non'] <- "non-tourist"
ggplot(df_twitter.long,aes(hashtag,value,fill=variable))+
  geom_bar(stat="identity",position="dodge")+
  theme(axis.text.x = element_text(angle=65, vjust=0.6))+coord_flip()+
  xlab('Hashtag')+ylab('Percentage')+labs(fill = "Legend")


