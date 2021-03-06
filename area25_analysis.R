# Area 25 Health Data
# July 9th 2018

# Install Packages and Import raw data ----------------------------------------

# Load Relevant packages
library("dplyr")
library("stringr")
library("tidyr")
library("ggplot2")
library("stringr")
library("lubridate")
library("gridExtra")
library("ggmap")
library("leaflet")
library("readr")


# Set working Directory
setwd("~/Desktop/summer_2018_projects")

# Import the SQL file data
concept <- read.delim("./sql_query/conceptnames.txt", header = FALSE)

# Clean data   --------------------------------------------------------------

# Rename variables
df1_concept  <-  concept %>% 
  rename(obs_id = V1,
         concept_id  = V2,
         person_id = V3,
         obs_datetime = V4,
         value_coded = V5,
         voided = V6,
         name = V7,
         gender = V8,
         birthdate = V9,
         birthdate_estimated = V10,
         address1 = V11,
         address2 = V12,
         city_village = V13,
         county_district =V14)

#  Modify data types
df1_concept <- df1_concept %>% 
  mutate(name = as.character(name),
         obs_datetime = ymd_hms(as.character(obs_datetime)),
         birthdate = ymd(as.character(birthdate)),
         address1 = as.character(address1),
         address2 = as.character(address2),
         city_village  = as.character(city_village),
         county_district = as.character(county_district),
         age = round((obs_datetime - as.POSIXct.Date(birthdate))/dyears(),0))

# Assign NAs
df1_concept$address1[df1_concept$address1  %in% c ("\\N", "")] <- NA
df1_concept$address2[df1_concept$address2  %in% c ("\\N", "")] <- NA
df1_concept$city_village[df1_concept$city_village  %in% c ("\\N", "")] <- NA
df1_concept$county_district[df1_concept$county_district  %in% c ("\\N", "")] <- NA

# Recode city village column
df1_concept$city_village[df1_concept$city_village %in% c ("Area25a","Area 25 a", "Area 25a", "25a" , "Area 25 A ",  
                                                         "Area 25a Houses", "Area 25a Location", " Area 25 A") ] <- "Area 25 A"
df1_concept$city_village[df1_concept$city_village %in% c ("Area25b", "Area 25 B ", "Area 25 b", "Area 25b", "25b", "Area25b near cindillela", "Area2b") ] <- "Area 25 B"
df1_concept$city_village[df1_concept$city_village %in% c ("Area25c","Area 25 c", "Area 25 C ",  "Area 25c", "Are25c", "Area5c", "Area2c","Area 2c", "Area 25c Housing", "Area 25c Location", "Area925c", "Area  25c", " Area 25 C", "25c") ] <- "Area 25 C"
df1_concept$city_village[df1_concept$city_village %in% c ("Area25","25", " 25", "25 ", "Area  25", "Area25 ", "Area 25 ") ] <- "Area 25"

df1_concept$city_village[df1_concept$city_village %in% c ("Collage", "Ttc","Lttc", "Ltcc", "Tt", "Lilongwe teachers college", "Ltc", "Lct", "College")] <- "LL TTC"

df1_concept$city_village[df1_concept$city_village %in% c ("Sec1","Sector 1", "25sector1")] <- "Sector 1"
df1_concept$city_village[df1_concept$city_village %in% c ("Sec2", "Sectar 2", "Secter 2" , "Sector2")] <- "Sector 2"
df1_concept$city_village[df1_concept$city_village %in% c ("Sec3",  "Secter 3" ,"Sector3", "Setor3" )] <- "Sector 3"
df1_concept$city_village[df1_concept$city_village %in% c ("Sec5","Secter 5", "Secter  5", "Sector5")] <- "Sector 5"
df1_concept$city_village[df1_concept$city_village %in% c ( "Sec 6",  "Sec6", "Secter 6" ,  "Sector6")] <- "Sector 6"
df1_concept$city_village[df1_concept$city_village %in% c ( "Area 25 A sec7", "Area 25 sec 7", "Area 25 sector 7", "Area25 sector 7",
                                                           "Area 25sec7", "Area 25sector 7", "Sector 7", "7", "Area 25  sec 7", "Secter7", "Se7","Sector7", "Secto 7","Secto 7" ,"Secter 7" ,  "Sec7", "Secor 7" ,"Sec 7","Sctor 7","Sectr7", "Setor 7","Sec78")] <- "Sector 7"
df1_concept$city_village[df1_concept$city_village %in% c ("Sector8", "Sectr8", "Secter8" , "Secter 8","Sec8")] <- "Sector 8"
df1_concept$city_village[df1_concept$city_village %in% c ("Sector9", "Sec9")] <- "Sector 9"


df1_concept$city_village[df1_concept$city_village %in% c ("25sungwi", "Nsunwi", "Nsungwi", "Sungwi Trading centre", "Sugwi", "Nsungwi")] <- "Sungwi"
df1_concept$city_village[df1_concept$city_village %in% c ("Mgomani", "Gomani", "Ngoman", "Ngomani ", "Ngomanii", "2ngomani", "Ngoomani", "Ngomn","Ngomaon",
                                                          "Ngomane", "Ngomam", "Ngoamani", "Ngmani", "Ng'oman","Ngommani","Ngomani---", "Ngomana", "Ngomain","Ngoani","Ngoaman","Ngman", "Ngomani village",
                                                          "Ngomamn","Mgoani", "Mgmani","Momani",  "Mgolman", "Mgolma", "Mgmani", "Ngomai","Ngoan", "Ngomni","Ngnman","Mgoman","Mgnomani","Ngomaoni", "Ngomami" , 
                                                          "Ngoma","Ngoami","Nogmani","Nomani", "Ngmna", "Ngamani","Amgona",  "Mgomni", "Mgomana", "Mgolani", "Mngomani",  "Mmgomani")] <- "Ngomani"

df1_concept$city_village[df1_concept$city_village %in% c ("Mgona village", "Mgomna","Mg'oma","Mgonna","Mgona c","Mgoma","Mgna",
                                                          "Mngona","Mgoa", "Mmgona" , "Mhona", "Mgonaa",  "Mgona b",  "Mgona a" , "Mgon",  "Ngona c",  "Ngona", "Ngon",  "Ng'oma","Mgoni","Mgona "  )] <- "Mgona"

df1_concept$city_village[df1_concept$city_village %in% c ("Mwmbakathu", "Mwmbakanthu","Mwambwakanthu","Mwambkathu","Mwambkanthu",
                                                          "Mwambathu","Mwambanthu", "Mwambalathu", "Mwambaknthv", "Mwambaknthu",
                                                          "Mwambakatu", "Mwambakathu", "Mwambakantu", "Mwambakanthv", "Mwambakanthuu",
                                                          "Mwambakanthu","Mwambakanhu",  "Mwambaka" ,"Mwamba","Mwambwakanthu","Mwamakathu", "Mwakathu", "Mwayakanthu","Mwayambakanthu","Mwabakanthu" 
                                                          )] <- "Mwambakathu"


df1_concept$city_village[df1_concept$city_village %in% c ("Kulyani", "Kuliyni", "Kuliyini",  "Kuliyanii", "Kuliyani  vge",
                                                          "Kuliyana",  "Kuliyan", "Kuliyam", "Kuliya", "Kulilani",  "Kuliani",
                                                          "Kulian",  "Kuleyan", "Kliyani", "Ktliani")] <- "Kuliyani"

df1_concept$city_village[df1_concept$city_village %in% c ("Khanyiji","Kanyinji", "Khanyinji","Khanyiji" ,"Khanyeji", "Khanxyinji", "Khanjinji",
                                                          "Khanjinje",  "Khaninyi", "Khaninji", "Khanenji","Khaminji","Khamenji",
                                                          "Khainji", "Kayinv", "Kayinji", "Kayimvi",  "Mkhanyinji", "Mkhaninji", "Mkaninji",  "Nkhaninji", 
                                                          "Nkhanyinji",  "Nkhaninj", "Nkaninji" , "Nkhanji"  )] <- "Khanyinji"

df1_concept$city_village[df1_concept$city_village %in% c ("Area 18 ", "Are18", "Aea18","18"  )] <- "Area 18"

df1_concept$city_village[df1_concept$city_village %in% c ( "Area 18 B Location" )] <- "Area 18 B"

df1_concept$city_village[df1_concept$city_village %in% c ( "23", " 23", "Area 23 Location"," Area 23", "Area 23 Trading Centre "
 )] <- "Area 23"

df1_concept$city_village[df1_concept$city_village %in% c ("49", " 49","49 ","Area49","Area 49", "Aea49", "Are49", "Area 49 Houses", "Area 49 Trading Centre", 
                                                          "Area 49 proper", "Areaa49", "49dobay", "Bagdad", "Bagidadi Houses", "Bakidadi", "Area49dubai", 
                                                          "Shire (A49)", "Dubai", "  49", " Area 49", "Area  49", "Gulliver (A49)") ] <- "Area 49"

df1_concept$city_village[df1_concept$city_village %in% c ("Area  50", "50", " 50","50 ","A50", "Area50", "Aa50", " Area 50", "Aea50", "Areaa50", "Areah50",
                                                          "Arrea50", "Area50b", "Area550" ,"500") ] <- "Area 50"

df1_concept$city_village[df1_concept$city_village %in% c ("51", " 51", "51 ", "Area51","Area 51")] <- "Area 51"

df1_concept$name[df1_concept$name %in% c ("Respiratory tract infections, recurrent (sinusitis, tonsilitus, otitis media, pharyngitis)")] <-"RTI, recurrent"

df1_concept$age[df1_concept$age < 0] <- NA

# Manipulate data ---------------------------------------------------------

# Remove voided obs
df2_concept <- df1_concept %>% 
  filter(voided == 0) %>% 
  
# Keep one obs for each concept_id; note loss of obs
  group_by(obs_id, value_coded) %>% 
  slice(1) %>% 
  ungroup()

# Create location .csv export file
coord_city_village<- df2_concept %>% 
  select(city_village) %>% 
  unique.data.frame() 
write.csv(coord_city_village, "./output/area_25/coord_city_village.csv")

coord_address1<- df2_concept %>% 
  select(address1) %>% 
  unique.data.frame()
write.csv(coord_address1, "./output/area_25/coord_address1.csv")
 
# Prelim Analysis ---------------------------------------------------------

df_sum <- df2_concept %>% 
  select(city_village,name) %>% 
  group_by(city_village) %>% 
  summarise(`Number of Cases` =n()) %>% 
  ungroup() %>% 
  arrange(desc(`Number of Cases`)) %>% 
  head(20)

# Export to csv
write.csv(df_sum, "./output/area_25/coord_city_village_2.csv")

# Plo1 1: Number of Cases by Location
ggplot(data = df_sum, aes(x = reorder(city_village,`Number of Cases`),  y = `Number of Cases`, fill = `Number of Cases`)) + 
  geom_col() +
  scale_fill_gradient(low = "green", high = "red") + 
  ggtitle("OPD Cases: Area 25 Health Center") +
  labs(caption  ="*Based on data from 12/21/2011 to 10/08/2013") +
  xlab("Patient Residence") +
  ylab("Number of Cases") 
  
# Top 10 Diagnosis
x_name_freq <- data.frame(table(df2_concept$name)) 

df_sum2<- df2_concept %>% 
  select(city_village,name) %>% 
# Select sample locations
  filter(city_village %in% c("Area 25 A", "Area 25 B", "Area 25 C", "Ngomani", "Mgona", "Area 50", "Area 49", 
                             "Chimoka", "Mchezi", "Area 25", "Chatata"),
# 10 most common diagnosis
         name %in% c("Acute respiratory infection", "Malaria", "Musculoskeletal pain","Respiratory Tract Infections, recurrent",
                     "Other skin condition", "Sepsis", "Diarrhoea diseases", "Abscess", 
                     "Dental caries", "Gastroenteritis")) %>% 
  group_by(city_village, name) %>% 
  summarise(`Number of Diagnosis` =n()) %>% 
  ungroup() %>% 
  mutate(`Percent of Total Cases` = round((`Number of Diagnosis`/sum(`Number of Diagnosis`)*100),2)) %>% 
  arrange(desc(`Number of Diagnosis`)) %>% 
  ungroup()

  # summary 3: Chimango's Suggestion
  df_sum_city_village<- df2_concept %>% 
    select(city_village) %>% 
    group_by(city_village) %>% 
    mutate(tot_patients =n()) %>% 
    unique.data.frame()
  
  df_sum_name <- df2_concept %>% 
    select(city_village, name) %>% 
    left_join(df_sum_city_village, by = "city_village") %>% 
    group_by(name, city_village) %>% 
    mutate(tot_diagnosis =n()) %>% 
    slice(1) %>% 
    ungroup() %>% 
    mutate(tot_diag_percent = round((tot_diagnosis/tot_patients)*100, 2)) %>% 
    filter(name == "STI") %>% 
    arrange(desc(tot_diagnosis)) %>% 
    head(100)
  
  
    filter(city_village %in% c("Area 25 A", "Area 25 B", "Area 25 C", "Ngomani", "Mgona", "Area 50", "Area 49", 
                               "Chimoka", "Mchezi", "Area 25", "Chatata"))

 

# Plot 2: Diagnosis  & Location
ggplot(df_sum2, aes(x=city_village, y=name, fill = `Percent of Total Cases`)) + geom_tile() +
  scale_fill_gradient(low = "yellow", high = "red") +
  ggtitle("Common Diagnosis: Area 25 Health Center") +
  xlab("Patient Residence") +
  ylab("Name of Diagnosis") 

# Plot 3: Number of Cases by Age
hist(x = df2_concept$age, col = "beige", xlab = "Age", main = "OPD Cases Area 25 Health Center: Age Distribution")
   
# Plot 4: Gender  & Name
 df_sum3<- df2_concept %>% 
   select(name, gender) %>% 
# 10 most common diagnosis
   filter(name %in% c("Acute respiratory infection", "Malaria", "Musculoskeletal pain","RTI, recurrent",
                         "Other skin condition", "Sepsis", "Diarrhoea diseases", "Abscess", 
                         "Dental caries", "Gastroenteritis")) %>% 
   group_by(name, gender) %>% 
   mutate(n = n()) %>% 
   ungroup() %>% 
   unique.data.frame()
 
 # Plot 4: 10 Top Diagnosis & Gender
 ggplot(df_sum3, aes(x= name, y= n, fill = n)) + geom_col()+
   scale_fill_gradient(low = "green", high = "red") + facet_wrap(~gender, nrow = 2) +
   ggtitle("Common Diagnosis by Gender: Area 25 Health Center") +
   xlab("Name of Diagnosis") +
   ylab("Number of Cases") 
 
 # Remove Some data frames
rm(df1_concept, df_sum, df_sum2, df_sum3, x_name_freq, coord_address1, coord_city_village, concept)
                                              

# Malaria Analysis --------------------------------------------------------
df_malaria <- df2_concept %>% 
  filter(name == "Malaria") %>% 
  mutate(age_group =ifelse(age<5, "Under 5s",
                           ifelse(age>=5 & age <= 14, "5-14", 
                                  ifelse(age >14 & age <= 49, "15-49",
                                         ifelse(age > 49 & age <= 69 , "50-69","70 +")))))
 
df_sum_malaria <- df_malaria %>% 
  select(city_village,name) %>% 
  group_by(city_village) %>% 
  summarise(`Number of Cases` =n()) %>% 
  ungroup() %>% 
  arrange(desc(`Number of Cases`)) %>% 
  head(20)

# Plot 5: Number of Cases by Location
ggplot(data = df_sum_malaria, aes(x = reorder(city_village,`Number of Cases`),  y = `Number of Cases`, fill = `Number of Cases`)) + 
  geom_col() +
  scale_fill_gradient(low = "green", high = "red") + 
  ggtitle("OPD Malaria Cases: Area 25 Health Center") +
  labs(caption  ="*Based on data from 12/21/2011 to 10/08/2013") +
  xlab("Patient Residence") +
  ylab("Number of Cases") 

# Plot 6: Age Distribution
hist( x = df_malaria$age, col = "beige", xlab = "Age", main = "OPD Malaria Cases at Area 25 Health Center: Age Distribution")

# Age group
df_sum_malaria_2 <- df_malaria %>% 
  group_by(gender, age_group) %>% 
  summarise(n = n()) %>% 
  spread(key = gender,  value = n) %>% 
  na.omit() %>% 
  arrange(desc(M))



# Mapping -----------------------------------------------------------------
# Import Lilongwe Shape file
tmp <- tempfile()
tmp <- "./shape_file/lilongwe_city_areas_2008_population.zip"
unzip(tmp, exdir = "./shape_file")


# 2008 Population Census data
ll <- readShapeSpatial("./shape_file/lilongwe_city_areas_2008_population")
ll_coord <- data.frame(ll) %>% 
  mutate(TA_NAME = as.character(TA_NAME),
         ll = "Lilongwe, Malawi") %>% 
  unite("location_ll", "TA_NAME", "ll", sep = ",") %>% 
  select(TACODE, location_ll, AreaName, Total, Density08 )

# Get coordinates & and  other location information fromm google maps API
ll_coord_2 <-  mutate_geocode(ll_coord, location=location_ll, output="more" )

# Batch 1 coordinates
ll_coord_na<- ll_coord_2 %>% 
  filter(is.na(lon)) %>% 
  select(TACODE, location_ll, AreaName, Total, Density08 ) %>% 
  mutate_geocode(location=location_ll, output="more" )

# Batch 2 coordinates 
ll_coord_na <- ll_coord_na %>% 
  select(TACODE:lat, political, locality, administrative_area_level_1, country)

# All coordinates
ll_coord <- ll_coord_2 %>%
  select(TACODE:lat, political, locality, administrative_area_level_1, country) %>% 
  filter(!is.na(lat)) %>% 
  rbind(ll_coord_na) %>% 
  rename(total_pop = Total,
         pop_density = Density08)

# Export coordinates
write.csv(ll_coord, "./shape_file/ll_coordinates.csv")

# remove files
rm(ll_coord, ll_coord_2, ll_coord_na)

# Re_import ll coordiantes file
ll_coord<- read_csv("./shape_file/ll_coordinates.csv") %>% 
  select(-X1)

# Customize Marker Colors
get_color <- function(ll_coord) {
  sapply(ll_coord$total_pop, function(total_pop) {
    if(total_pop <= 10000) {
      "green"
    } else if(total_pop <= 30000) {
      "orange"
    } else {
      "red"
    } })
}

# Customize icon colors
icons <- awesomeIcons(
  icon = 'ios-close',
  iconColor = 'black',
  library = 'ion',
  markerColor = get_color(ll_coord)
)

# Create bin formats
bins <- c(0, 10000, 30000, Inf)
pal <- colorBin(c("green", "orange", "red"), domain = ll_coord$total_pop, bins = bins)

# Plot Leaftet Map 
leaflet(data = ll_coord)%>% 
  setView(lat = -13.962612, lng =  33.774119 , zoom = 12) %>% 
  addTiles() %>% 
  addAwesomeMarkers(lat = ~lat, lng = ~lon, popup = ~ as.character(total_pop), label = ~political, icon = icons) %>% 
  addLegend(
    pal = pal,
    values = ~total_pop,
    opacity = 1,
    title = "Location Population",
    position = "bottomright")


# Health Centers
ll_health_centr <- data.frame(name = c("Area 18 Health Center, Lilongwe, Malawi", 
                                       "Area 25 Health Center, Lilongwe, Malawi", 
                                       "Kawale Health Center, Lilongwe, Malawi", 
                                       "Bwaila Hospital, Lilongwe, Malawi",
                                       "Kamuzu Central Hospital, Lilongwe, Malawi"),
                              hos_type =c("Area Health Center","Area Health Center", "Area Health Center", "District Hospital",
                                         "Regional Referral Hospital")) %>% 
 mutate(name = as.character(name)) %>% 
 mutate_geocode(location=name, output="more") 
  
  ll_health_centr <- ll_health_centr %>% 
  select(name:lat,political, administrative_area_level_1, country)

# Export ll health center coordinates
write.csv(ll_health_centr, "./shape_file/ll_health_centr.csv")

# Re_import ll health center
ll_health_centr <- read_csv("./shape_file/ll_health_centr.csv") %>% 
  select(-X1) %>% 
  mutate(name = str_sub(name, start = 1, -19))

leaflet(data = ll_health_centr) %>% 
  setView(lat = -13.97000, lng =  33.774119 , zoom = 12) %>%
  addTiles() %>% 
  addAwesomeMarkers(lat = ~lat, lng = ~lon, popup = ~hos_type, 
                    label = ~name, labelOptions = (labelOptions(noHide = T)))
