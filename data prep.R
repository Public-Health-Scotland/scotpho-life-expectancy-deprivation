library(readr)        # to write csv
library(dplyr)        # to get %>% operator


# UPDATE the analyst's folder - where data should be saved for shiny app to run
shiny_folder <- "/PHI_conf/ScotPHO/1.Analysts_space/Vicky/scotpho-life-expectancy-deprivation/shiny_app/data/"

# UPDATE data file location
data_folder <- "/PHI_conf/ScotPHO/Website/Topics/Life expectancy/202303_update/"


le_data <- read_csv("/PHI_conf/ScotPHO/Website/Topics/Life expectancy/LE trend data by SIMD Quintile.csv") %>%
setNames(tolower(names(.))) %>% #variables to lower case



shes_data <- read_csv(paste0(source_network,"Self Assessed Health Data/SHeS/","2018/AH2018-005 - Figures for healthy life expectancy stats (2017).csv")) %>% 
  setNames(tolower(names(.))) %>% #variables to lower case
  rename(sah=genhelf, year=syear, sex_grp=sex) %>%
  subset(age<=14) %>%    # SHeS data only used for those up to age of 14
  create_agegroups_90()