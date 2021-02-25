## Import data ################################################################
library(readr)
library(readxl)

# police killings
PoliceKillingsUS <- read_csv("~/Desktop/Term 2/Hackathon/PoliceKillingsUS.csv")
PoliceKillingsUS$city_state <- paste(PoliceKillingsUS$city, PoliceKillingsUS$state)
#View(PoliceKillingsUS)
nrow(PoliceKillingsUS)

# city state mapping
city_county_data <- read.delim("~/Desktop/Term 2/Hackathon/city-to-county.txt", sep = ",")
city_county_data$city_state <- paste(city_county_data$city, city_county_data$state)
city_county_data$county_state <- paste(city_county_data$county, city_county_data$state)

# County data
County_demographic <- read_excel("~/Desktop/Term 2/Hackathon/Merged county data 3.xlsx")
County_demographic$county_state <- paste(County_demographic$`Area name`, County_demographic$`State abbreviation`)

# Nationwide scorecard
Scorecard <- read_csv("~/Desktop/Term 2/Hackathon/Nationwide Scorecard Database.csv")
unique(Scorecard$fips_state_code)
unique(Scorecard$fips_county_code)

# Merge state/county fips and ensure that fips are all of length 5  
Scorecard$fips_state_adj <- ifelse(nchar(Scorecard$fips_state_code) == 1, 
                              paste(0,Scorecard$fips_state_code, sep=""),
                              Scorecard$fips_state_code)

Scorecard$fips_county_adj <- ifelse(nchar(Scorecard$fips_county_code) == 1, 
                                   paste("00",Scorecard$fips_county_code, sep=""),
                                   ifelse(nchar(Scorecard$fips_county_code) == 2, 
                                          paste("0",Scorecard$fips_county_code, sep=""),
                                          Scorecard$fips_county_code))

Scorecard$fips_adj <- paste(Scorecard$fips_state_adj, Scorecard$fips_county_adj, sep = "")

Scorecard <- Scorecard[,c(264,1:263)]


## Merge data ################################################################

# Police killings with city state mapping
killings_county <- merge(PoliceKillingsUS, city_county_data, by="city_state", all.x = TRUE)
View(killings_county)

nrow(killings_county)
sum(is.na(killings_county$county_state))

# Police killings with county demographics
killings_county <- merge(killings_county, County_demographic, by="county_state", all.x = TRUE)
View(killings_county)

unique(killings_county$county_state[is.na(killings_county$`State-county FIPS code`)])
sum(is.na(killings_county$`State-county FIPS code`))

## Merge data with police info ###############################################

# Remove redundant state name columns
killings_county <- killings_county[,-c(17,20)]
nrow(killings_county)

# Merge based on fips
killings_county_police <- merge(killings_county, Scorecard[!duplicated(Scorecard$fips_adj),], by.x="State-county FIPS code", by.y= "fips_adj", all.x = TRUE)
nrow(killings_county_police)

write.csv(killings_county_police, "killings_with_county_dem_and_police_info.csv")
View(killings_county_police)
