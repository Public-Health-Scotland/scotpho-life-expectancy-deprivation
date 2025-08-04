# Data queried directly from statistics.gov
# install the opendata scotland r package which communicates with the statistics.gov wesbite api
# install.packages("devtools")
# devtools::install_github("datasciencescotland/opendatascot")

library(opendatascot) # to extract from statistics.gov
library(readr)        # to write csv
library(dplyr)        # to get %>% operator
library(tidyr)      # pivot wider
library(readxl)     # to open ONS data
# datasets <- ods_all_datasets() # to see available datasets on statistics.gov.scot


# Setting file permissions to anyone to allow writing/overwriting of project files
Sys.umask("006")


# If you aren't analyst named in file path then consider UPDATING the filepath
shiny_folder <- "/PHI_conf/ScotPHO/1.Analysts_space/Vicky/scotpho-life-expectancy-scot/shiny_app/data/"

# UPDATE data file location each year if you want a record of what data was published historically
data_folder <- "/PHI_conf/ScotPHO/Website/Topics/Life expectancy/202507_update/"


# parameters used to filter the opendata
urban_rural <- c("all")
age_select <- "0-years"


###############################################.
# Life expectancy data
###############################################.

ods_structure("Life-Expectancy") # see structure and variables of this dataset

# date range for LE
date_range_le <- c("2001-2003", "2002-2004", "2003-2005", "2004-2006", "2005-2007",
                   "2006-2008", "2007-2009", "2008-2010", "2009-2011", "2010-2012",
                   "2011-2013", "2012-2014", "2013-2015", "2014-2016", "2015-2017", 
                   "2016-2018", "2017-2019", "2018-2020", "2019-2021", "2020-2022", "2021-2023") # add most recent year

# extract data
le = ods_dataset("Life-Expectancy", refPeriod = date_range_le, geography = "sc",
                 urbanRuralClassification = urban_rural, age= age_select) %>%
  setNames(tolower(names(.))) %>%
  rename("year" = refperiod) %>% 
  filter(age == age_select) %>% # age filter still keeps "90 years" which need to be removed
  mutate(measure = "Life expectancy",
         sex = case_when(sex == "male" ~ "Male",
                         sex == "female" ~ "Female")) |>
  select(c("year", "measure", "sex", "simdquintiles","measuretype", "value"))|>
  pivot_wider(names_from="measuretype" ,values_from="value") |>
  rename(value = count,
         lci = "95-lower-confidence-limit",
         uci = "95-upper-confidence-limit") |>
  arrange(simdquintiles,sex,year)

###############################################.
# Healthy Life expectancy data
###############################################.


ods_structure("healthy-life-expectancy") # see structure and variables of this dataset

# date range for HLE - revised methodology for HLE in July 2025 but SIMD breakdowns not available at first publication]
#
date_range_hle <- c("2015-2017", "2016-2018", "2017-2019", "2018-2020","2019-2021") # add most recent year

# extract data
hle = ods_dataset("healthy-life-expectancy", refPeriod = date_range_hle, geography = "sc",
                  urbanRuralClassification = urban_rural,age= age_select) %>%
  setNames(tolower(names(.))) %>%
  rename("year" = refperiod) %>%
  filter(age == age_select) %>%
  mutate(measure = "Healthy life expectancy",
         sex = case_when(sex == "male" ~ "Male",
                         sex == "female" ~ "Female")) %>%
  select(c("year", "measure", "measuretype", "sex","simdquintiles","value" )) |>
  pivot_wider(names_from="measuretype" ,values_from="value") |>
  rename(value = count,
         lci = "95-lower-confidence-limit",
         uci = "95-upper-confidence-limit") |>
  arrange(simdquintiles, sex, year)



# combine datasets
le_hle <- rbind(le, hle) %>% arrange(measure, sex, year, simdquintiles)|>
  rename(quintile=simdquintiles)


# round measure to 1 decimal place
final <- le_hle %>%
  mutate(value=round(value,2),
         lci=round(lci,2),
         uci=round(uci,2))

# Save data to shiny_app folder
saveRDS(final, file = paste0(shiny_folder,"le_hle_quintile.rds"))