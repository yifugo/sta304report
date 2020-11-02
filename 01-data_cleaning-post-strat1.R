#### Preamble ####
# Purpose: Prepare and clean the survey data downloaded from https://usa.ipums.org/usa/index.shtml
# Author: Yuting Ge，Ying Cao, Yifu Guo, Yuxin Du
# Data: 26 October 2020
# Contact: yuting.ge@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Need to have downloaded the ACS data and saved it to inputs/data
# - Don't forget to gitignore it!


#### Workspace setup ####
library(haven)
library(tidyverse)

rm(list = ls())

# Read in the raw data.
raw_data <- read_dta("inputs/usa_00001.dta.gz") #sample size= 1mi


# Add the labels
 raw_data <- labelled::to_factor(raw_data)
 

# Just keep some variables that may be of interest (change 
# this depending on your interests)
completed_degree = c("associate's degree, type not specified",
               "associate's degree, occupational program",
               "associate's degree, academic program",
               "bachelor's degree",
               "master's degree",
               "professional degree beyond a bachelor's degree",
               "doctoral degree")

reduced_data <- 
  raw_data %>% 
  select(#region, #correlated with state
         stateicp, 
         sex, 
         age, 
         race,
         #hispan,marst,bpl,citizen,
         educd) %>%
         #labforce,inctot)
  
  mutate(race_class = ifelse(race=="white", "White", "Other"),
         degree_class = ifelse(educd %in% completed_degree, "Yes","No"),
         age =ifelse(age=="less than 1 year old", 1, 
                     ifelse(age== "90 (90+ in 1980 and 1990)", 90, age) ))  

reduced_data$age <- as.integer(reduced_data$age)

# Map state id 
library(datasets)

crossref_states <- data.frame(state=state.abb,
                              stateicp=state.name %>% tolower())
reduced_data <- merge(reduced_data, crossref_states)

# Categorize ages
reduced_data$age_group = car::Recode(reduced_data$age,
                                    "1:20='1-20';
                                    21:40='21-40';
                                    41:60='41-60';
                                    61:80='60-80';
                                    81:150='80+' ")

#### What's next? ####

## Here I am only splitting cells by age, but you 
## can use other variables to split by changing
## count(age) to count(age, sex, ....)

group_data <- 
  reduced_data %>% 
  count(state,age_group, sex, race_class, degree_class) %>%
  group_by(state,age_group, sex, race_class, degree_class) 
  

# Saving the census data as a csv file in my
# working directory
write_csv(group_data, "outputs/census_data.csv")



         