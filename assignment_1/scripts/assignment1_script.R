library(tidyverse)
library(sf)
library(tmap)
library(rgdal)

crs_data = make_EPSG()
# use: # NAD83 / New York Long Island (ftUS), epsg: 2263

path_to_file = file.path("..", "data", "ny_trees2005.csv")
tree_2005 = path_to_file %>% read_csv()

# Replace boroname == 5 with staten island
tree_2005 = tree_2005 %>%
  mutate(boroname = replace(boroname, boroname == 5, "Staten Island"))

head(tree_2005)

# count the number of trees by nta_name
byBoro = tree_2005 %>%
  count(nta_name, boroname, spc_common, status, sort = TRUE)

head(byBoro, n = 10)

# plot count
byBoro %>% ggplot() +
  geom_bar(aes(x = boroname, fill = status), position = "dodge") +
  coord_flip()

# get location data
treeLocs = tree_2005 %>%
  select(OBJECTID, spc_common, nta, nta_name, boroname, latitude, longitude)  %>%
  filter(is.na(boroname) != TRUE)
 

# get tree coordinates
tree_coord = unique(treeLocs[,c("latitude", "longitude")]) %>%
  rename(Longitude = longitude, Latitude = latitude)

# see how many unique object ids there are. 
treeLocs$OBJECTID %>%
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
ny_P = ny %>% st_transform(crs = 2263)
st_crs(ny2)

# inspect
tm_shape(ny) +
  tm_fill() +
  tm_borders() 

ny_tree = left_join(ny2, tree_num, by = c("NTACode" = "nta")) %>%
  mutate(normalized = scale(num, center = FALSE))


plot(st_geometry(ny_tree), col = ny_tree$normalized)

m1 = ggplot(ny_tree) + 
  geom_sf(aes(fill = normalized))
m1

m2 = m1 + geom_polygon(color = "gray90", size = 0.05) + coord_equal()

m3 = m2 + scale_fill_brewer(palette = "Greens")
m3
m1

# read in street data.
road_file = file.path("..", "data", "Centerline.shp")
ny_roads = st_read(road_file)

# NAD83 / New York Long Island (ftUS)
ny_roads_P = ny_roads %>% st_transform(crs = 2263)
class(ny_roads_P)

length_roads = st_intersection(ny_roads_P, ny_P) %>%
  mutate(len = st_length(geometry)) %>%
  group_by(NTACode) %>%
  summarise(num_roads = n(),
            boro = first(NTAName),
            len_sum = as.numeric(sum(len)), # convert from class "units" to "numeric"
            miles = as.numeric(len_sum/5280))

tree_dens = length_roads %>%
  select(NTACode, boro, len_sum, miles) %>%
  left_join(tree_num, by = c("NTACode" = "nta")) %>%
  mutate(tree_norm = tree_num/miles,
         index = scale(tree_norm)) 

saveRDS(tree_dens, file = "tree_dens.rds")

write.csv(tree_dens, file = "tree_dens.csv")  

x=readRDS("tree_dens.rds")
