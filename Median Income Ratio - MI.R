library(tidycensus)
library(data.table)
library(tidyverse)

#Download the Median housing income information from the census site. 
#Important columns:
#       GEOID: Census 5 digit ZCTA that corresponds to zip codes
#       estimate: Median household income in the past 12 months (in 2020 inflation-adjusted dollars)
MHI <- get_acs(geography = "zcta",
                     variables = "B19013_001",
                     year = 2019,
                     state = "MI"
)

#Read in & subset the 2010 ZCTA to Metropolitan and Micropolitan Statistical
#Areas Relationship File.
#Found at:
#https://www.census.gov/geographies/reference-files/2010/geo/relationship-files.html
zcta2metro <- fread("zcta_cbsa_rel_10.txt",
                    integer64 = 'character',
                    colClasses = rep("character"),
                    encoding = "UTF-8")

#Read in the CBSA metropolitan division delineation file from the census site
#Found at:
#https://www.census.gov/geographies/reference-files/time-series/demo/metro-micro/delineation-files.html
MImetros <- fread("MI Metros.csv",
                    integer64 = 'character',
                    colClasses = rep("character"),
                    encoding = "UTF-8")

#filter the zctas that we have data for 
miz2m <- zcta2metro[`ZCTA5` %in% MHI$GEOID]

MHI <- rename(MHI, "ZCTA5" = "GEOID")

setDT(MHI, miz2m)

miz2m <- miz2m %>%
  arrange(ZCTA5, desc(ZPOPPCT)) %>% 
  filter(!duplicated(ZCTA5))

MHI <- merge.data.table(MHI,
                        miz2m,
                        by = "ZCTA5",
                        all.x = TRUE)

#label each entry on whether it is a metro or state median
MHI[, `Metro or State` := fcase(
  `CBSA` %in% MImetros$`CBSA Code`,
  "metro",
  default = "state"
)]

# Assign Statewide median to all zips, then overwrite with metros, based on CBSA
MHI$GeoMedian = median(as.numeric(MHI$estimate), na.rm = TRUE)

MHI[`Metro or State` == "metro",
    `GeoMedian` := median(as.numeric(estimate), na.rm = TRUE),
    by = 'CBSA']

MHI[, `Median Income Ratio` := `estimate`/`GeoMedian`]

fwrite(MHI, file = "Median Housing Income by ZCTA5 - mi.csv")
