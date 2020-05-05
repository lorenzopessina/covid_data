# covid AL
# may 5, 2020

# clean municipality names

## preamble

# packages
library(tidyverse)
library(readxl)

## upload and clean data

# 0. name and code of municipality
names_data <- read_excel("data/Elenco-codici-statistici-e-denominazioni-al-01_01_2020.xls")

# lower
names(names_data) <- tolower(names(names_data))

# rename
names_data <- names_data %>%
  mutate(code_comune = `codice comune formato alfanumerico`,
         name_comune = `denominazione in italiano`,
         name_regione = `denominazione regione`,
         code_provincia = `sigla automobilistica`)

# rename
names(names_data)[12] <- "name_provincia"

# select variables
names_data <- names_data %>%
  select(code_comune, code_provincia, name_comune, name_provincia, name_regione)

# save
write_csv(names_data, 'results/cleaned/municipality_list.csv')

