library(tidyverse)
library(sf)
library(tmap)
library(rgdal)

crs_data = make_EPSG()
# use: # NAD83 / New York Long Island (ftUS), epsg: 2263

path_to_file = file.path("..", "data", "2005_Street_Tree_Census.csv")
trees = path_to_file %>% read_csv()

# # Replace boroname == 5 with staten island
# trees = trees %>%
#   mutate(boroname = replace(boroname, boroname == 5, "Staten Island"))

head(trees)

# count the number of trees by nta_name
byBoro = trees %>%
  count(nta_name, borough, spc_common, status, sort = TRUE)

head(byBoro, n = 10)

# plot count
byBoro %>% ggplot() +
  geom_bar(aes(x = borough, fill = status), position = "dodge") +
  coord_flip()

# get location data
treeLocs = trees %>%
  select(tree_id, spc_common, nta, nta_name, borough, latitude, longitude)  %>%
  filter(is.na(borough) != TRUE)
 

# get tree coordinates
tree_coord = unique(treeLocs[,c("latitude", "longitude")]) %>%
  rename(Longitude = longitude, Latitude = latitude)
write_csv(tree_coord, "2015_tree_coords.csv")

# see how many unique object ids there are. 
treeLocs$tree_id %>%
  unique() %>%
  length()

# get amount of trees per NTA code
tree_num = treeLocs %>%
  group_by(nta) %>%
  summarise(tree_num = n())

head(tree_num)

# set points with WGS1984 coordinate system
coord_proj = tree_coord %>% 
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 2263) 

path_to_file2 = file.path("..", "data", "nynta_19d", "nynta.shp")

# read in shp file
ny = st_read(dsn = path_to_file2)

# project to NAD83 / New York Long Island (ftUS)
ny_P = ny %>% st_transform(crs = 4326) # 2263
st_crs(ny_P)

# inspect
tm_shape(ny) +
  tm_fill() +
  tm_borders() 

# join shp file with tree data by nta code
ny_tree = left_join(ny2, tree_num, by = c("NTACode" = "nta")) %>%
  mutate(normalized = scale(num, center = FALSE))

# try plotting
plot(st_geometry(ny_tree), col = ny_tree$normalized)

# try plotting
m1 = ggplot(ny_tree) + 
  geom_sf(aes(fill = normalized))

# read in street data.
road_file = file.path("..", "data", "Centerline.shp")
ny_roads = st_read(road_file)

# NAD83 / New York Long Island (ftUS)
ny_roads_P = ny_roads %>% st_transform(crs = 2263)
class(ny_roads_P)

# Get length of roads, sum length
length_roads = st_intersection(ny_roads_P, ny_P) %>%
  mutate(len = st_length(geometry)) %>%
  group_by(NTACode) %>%
  summarise(num_roads = n(),
            boro = first(NTAName),
            len_sum = as.numeric(sum(len)), # convert from class "units" to "numeric"
            miles = as.numeric(len_sum/5280))

# get tree densities, tree_num/miles per nta
tree_dens = length_roads %>%
  select(NTACode, boro, len_sum, miles) %>%
  left_join(tree_num, by = c("NTACode" = "nta")) %>%
  mutate(tree_norm = tree_num/miles,
         index = scale(tree_norm)) 

# save R object 
saveRDS(tree_dens, file = "tree_dens_2015.rds")

# read in RDS and remove geometries for faster processing
dens05 = readRDS("2005_tree_dens.rds")
st_geometry(dens05) = NULL
dens15 = readRDS("tree_dens_2015.rds")
st_geometry(dens15) = NULL

# join x and y
xy = left_join(x, y, by = "NTACode")

# roads and index comparison for 2005
roads_index05 = xy %>% ggplot(mapping = aes(x = miles.x, y = index.x)) +
  geom_point() +
  geom_smooth() +
  labs(title = "Comparing Indices",
       x = "Miles of Street in 2005 by NTA",
       y = "Index for 2005 by NTA")

# plot roads and index comparison
roads_index15 = xy %>% 
  filter(miles.x < 150, miles.y < 150) %>%
  ggplot(mapping = aes(x = miles.y, y = index.y)) +
  geom_point() +
  geom_smooth() +
  labs(title = "Comparing Indices",
       x = "Miles of Street in 2015 by NTA",
       y = "Index for 2015 by NTA")

# library(plotly)
ggplotly(roads_index15)

# from 2005 tree dataset, extract borough names and attach to nta code
borough = trees %>%
  group_by(nta) %>%
  summarise(
    boro_name = first(boroname)
  ) %>%
  mutate(boro_name = replace(boro_name, boro_name == 5, "Staten Island"))

# join boronames to tree_dens to plot
dens05 %>% 
  left_join(borough, by = c("NTACode" = "nta")) %>%
  filter(index > 1.5 && index < -1) %>%
  ggplot(mapping = aes(x = reorder(boro,index), y = index)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Tree Index Highs and Lows",
    x = "NTA Name",
    y = "Tree Index (tree #/road length)"
  )


# round index 
ny_2 = ny_P %>%
  left_join(dens05, by = "NTACode") %>%
  mutate(index_rnd = as.numeric(round(index, 3)))

# library(tmap)
# library(tmaptools)
# bg = read_osm(bb(ny_2))
# 
# tmap_mode("view")
# x = ny_2 %>% tm_shape(bbox = ny_2) +
#   tm_basemap("Esri.WorldTopoMap") +
#   tm_polygons(col = "index_rnd", title = "Tree Density, 2005", palette = "PRGn", alpha = 2/3)
# 
# 
# m = tmap_leaflet(x)
# 
# mapshot(m, file = paste0(getwd(), "/map.png"),
#         remove_controls = c("homeButton", "layersControl", "zoomControl"))
# 
# tmap_mode("plot")

# try getting background map. . . 
register_google(key = "[YOUR API KEY]", write = TRUE)
ny_lat_lon = c(lon = -73.935242, lat = 40.730610)
nyc_map = ggmap::get_map(ny_lat_lon, source = "stamen", maptype = "terrain")

# using ggplot, plot basemap w/ ggmap and then additional layers over it
ggmap(nyc_map, extent = "normal") +
  geom_sf(data = ny_2, aes(fill = index), color = "gray12", 
          alpha = 0.8, inherit.aes = FALSE) +
  scale_fill_gradient2(low = "darkorchid4", mid = "gray95", 
                       high = "darkgreen", na.value = "black", 
                       name = "Tree Index") +
  coord_sf(crs = st_crs(4326)) + # make sure you write crs = st_crs()
  theme_void() +
  theme(legend.position = c(0.85, 0.225), 
        legend.background = element_rect(fill = "white", colour = "black"),
        legend.margin = margin(10, 10, 10, 10)) +
  ggtitle("Tree Index for NYC, 2005") 

ggsave("map_1.png", width = 6, height = 6, units = "in", dpi = 300)

# Roads data:
# https://data.cityofnewyork.us/City-Government/NYC-Street-Centerline-CSCL-/exjm-f27b