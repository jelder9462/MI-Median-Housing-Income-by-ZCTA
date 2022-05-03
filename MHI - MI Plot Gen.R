library(tidycensus)
library(tidyverse)
library(data.table)

library(sf)
library(wesanderson)


##Load in the distress scores that were calculated in "MI Economic Distress Modeling.R"
MHI <- fread("Median Housing Income by ZCTA5 - mi.csv")


##Download the Geography Geometry. Here we're using the census API, as that's where the
## Median household income data came from. This way, we will hopefully get a relatively
## representative shape vs the data
zipgeo <- get_acs(geography = "zcta", variables = c(TOTAL_Pop = "B06009_001",No_HS_Diploma = "B06009_002"),
                   state = "MI", year = 2019, geometry = TRUE, output = "wide")


#merge the geography and the MHI data
MHI$ZCTA5 <- as.character(MHI$ZCTA5)

MHI <- right_join(zipgeo, MHI, by = c("GEOID" = "ZCTA5"))


##Create and export the visualization

pal <- wes_palette("Zissou1", 25, type = "continuous") %>%
  rev()

png("MI - Median Housing Income.png",
    width = 720,
    height = 720,
    units = "px")
plot(select(MHI, c("Median Income Ratio", "geometry")),
     main = "Median Household Income as a Ratio of ZCTA to Metro mean or State Mean",
     breaks = "quantile",
     nbreaks = 25,
     pal = pal)
dev.off()