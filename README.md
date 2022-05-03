# MI-Median-Housing-Income-by-ZCTA
A visualization of the Median Housing Income by ZCTA in the state of Michigan

MHI - Median Housing Income
ZCTA - Zip Code Tabulation Area


## Data Wrangling
The median income estimates that are used here are from the US Census data site, pulled through the use of tidycensus.

## Score Assignment
A score was assigned as the ratio of each ZCTA's MHI to the median of the metropolitan area it is included in as defined by the US CBSA delineations. If the ZCTA was not considered to be in a metro, the comparison was made to the mean of the entire state.
