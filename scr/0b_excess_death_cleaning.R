# covid mobility
# may 2, 2020

# daily excess death

## preamble

# packages
library(tidyverse)
library(lubridate)
library(vtable)
library(fst)


# initialize graph theme
mytheme <- theme_minimal() +
  theme(panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        legend.position = 'bottom',
        legend.title = element_blank())


# # # #

# upload daily death
data <- read_csv('data/mortality_istat/Dataset-decessi-comunali-giornalieri-e-tracciato-record/2020_05_05_comuni_giornaliero.csv',
                 na = 'n.d.')

# lower
names(data) <- tolower(names(data))

# rename
data <- data %>%
  mutate(code_comune = cod_provcom,
         name_comune = nome_comune,
         name_provincia = nome_provincia,
         name_regione = nome_regione,
         age_group = cl_eta,
         month = str_extract(ge, "^\\d{2}"),
         day = str_extract(ge, "\\d{2}$"))

# recode 9999 to NA
#data <- data %>%
#  mutate_at(vars(starts_with('m_'), starts_with('f_'), starts_with('t_')),
#            function(x) {if_else(x == 9999, NA_real_, x)})

# month and day
data <- data %>%
  mutate_at(vars(day, month), as.numeric)

# total age group
data_d <- data %>%
  group_by(code_comune, ge) %>%
  summarise_at(vars(starts_with('m_'), starts_with('f_'), starts_with('t_')),
               'sum', na.rm = T)

# # # #

# upload names of municipality
names_data <- read_csv('results/cleaned/municipality_list.csv',
                       col_types = cols(.default = col_character()))


# # # # 

# reshape death data
data_d <- data_d %>%
  gather(key = 'key', value = 'death', m_15:t_20)

# separate key variable
data_d <- data_d %>%
  mutate(sex = str_extract(key, "^\\w{1}"),
         year = str_extract(key, "\\d{2}$"),
         year = as.numeric(year) + 2000,
         month = str_extract(ge, "^\\d{2}"),
         day = str_extract(ge, "\\d{2}$"),
         month = as.numeric(month),
         day = as.numeric(day),
         date = make_date(year = year, month = month, day = day))

# day of the year
data_d <- data_d %>%
  mutate(doy = yday(date),
         week = isoweek(date))

# recode sex variable
data_d <- data_d %>%
  mutate(sex = case_when(sex == 'm' ~ 'male',
                         sex == 'f' ~ 'female',
                         sex == 't' ~ 'total'))


# # # #

## merge in name of municipality
data_d <- data_d %>%
  left_join(names_data, by = 'code_comune')


# # # # 

## save dataset
write_fst(data_d, 'results/cleaned/excess_deaths/excess_deaths.fst')


