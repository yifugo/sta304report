#### Preamble ####
# Purpose: Prepare and clean the survey data downloaded from https://www.voterstudygroup.org/publication/nationscape data set
# Author: Yuting Ge，Ying Cao, Yifu Guo, Yuxin Du
# Data: 26 October 2020
# Contact: yuting.ge@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Need to have downloaded the data from X and save the folder that you're 
# interested in to inputs/data 
# - Don't forget to gitignore it!


#### Workspace setup ####
library(haven)
library(tidyverse)

# Read in the raw data (You might need to change this if you use a different dataset)
raw_data <- read_dta("inputs/ns20200625.dta")

# Add the labels
raw_data <- labelled::to_factor(raw_data)

#raw_data %>% head() %>% View()

# Just keep some variables

#### What else???? ####
# Maybe make some age-groups?
# Maybe check the values?
# Is vote a binary? If not, what are you going to do?

had_degree = c("Associate Degree",
               "College Degree (such as B.A., B.S.)",
               "Doctorate degree",
               "Masters degree")


reduced_data <- 
  raw_data %>% 
  select(#interest,
        # registration,
        # vote_2016,
        # vote_intention,
         vote_2020,
        # ideo5,
        # employment,
        # foreign_born,
         gender,
        # census_region,
        # hispanic,
         race_ethnicity,
        # household_income,
         education,
         state,
        # congress_district,
         age) %>%
  mutate(race_class = ifelse(race_ethnicity=="White", "White", "Other"),
        degree_class = ifelse(education %in% had_degree, "Yes","No"),
        vote_trump = 
          ifelse(vote_2020=="Donald Trump", 1, 0))


reduced_data$age_group = car::Recode(reduced_data$age,
                                    "1:20='1-20';
                                    21:40='21-40';
                                    41:60='41-60';
                                    61:80='60-80';
                                    81:200='80+' ")

# Saving the survey/sample data as a csv file in my
# working directory
write_csv(reduced_data, "outputs/survey_data.csv")

