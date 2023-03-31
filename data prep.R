library(readr)        # to write csv
library(dplyr)        # to get %>% operator


# UPDATE the analyst's folder - where data should be saved for shiny app to run
shiny_folder <- "/PHI_conf/ScotPHO/1.Analysts_space/Vicky/scotpho-life-expectancy-deprivation/shiny_app/data/"

# UPDATE data file location
data_folder <- "/PHI_conf/ScotPHO/Website/Topics/Life expectancy/202303_update/"


le_data <- read_csv("/PHI_conf/ScotPHO/Website/Topics/Life expectancy/LE trend data by SIMD Quintile.csv") %>%
setNames(tolower(names(.))) #variables to lower case


hle_data <- read_csv("/PHI_conf/ScotPHO/Website/Topics/Life expectancy/hle trend data by SIMD Quintile.csv") %>%
  setNames(tolower(names(.))) #variables to lower case


# combine datasets
le_hle <- rbind(le_data, hle_data) %>% arrange(measure, sex, year, quintile)


# round measure to 1 decimal place
final <- le_hle %>%
  mutate(value=round(value,2),
         lci=round(lci,2),
         uci=round(uci,2))

# Save data to shiny_app folder
saveRDS(final, file = paste0(shiny_folder,"le_hle_quintile.rds"))