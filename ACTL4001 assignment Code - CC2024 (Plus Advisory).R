library(dplyr)
library(StMoMo)
library(MortalityTables)
library(ggplot2)
library(zoo)
library(splines)
library(writexl)
library(survival)
library(survminer)
library(fanplot)
library(caret)

inforce_data <- read.csv("inforce_dataset.csv")
lumeria_mort <- read.csv("lumaria_mortality_table.csv")

#Check for duplicates
duplicates <- unique(inforce_data$Policy.number)

###Finding optimal span for loess###
#Data set with deaths only
death_inforce_data <- inforce_data %>%
  filter(Death.indicator==1)

#Finding age of death 
death_inforce_data <- death_inforce_data %>%
  mutate(age_policy = Year.of.Death - Issue.year,
         age_life = Issue.age+age_policy)
#Finding the number of deaths per age in each year
death_grouped_by_age_year <- death_inforce_data %>%
  group_by(Year.of.Death, age_life) %>%
  summarise(Deaths = n())
colnames(death_grouped_by_age_year)[1] <- "year"


# Range of active policies
analysis_years <- 2001:2023

#List to store the results for each year
active_policies_list <- list()

for (year in analysis_years) {
  
  # Determine if the policy is active
  inforce_data$active_policy <- (is.na(inforce_data$Year.of.Death) | inforce_data$Year.of.Death > year) &
    (is.na(inforce_data$Year.of.Lapse) | inforce_data$Year.of.Lapse > year)

  # Filter for active policies
  active_policies_year <- inforce_data %>% 
    filter(active_policy == "TRUE" & year >= Issue.year) %>%
    mutate(age_life = Issue.age + (year -Issue.year)) %>% #Calculate the age for each year
    group_by(age_life) %>%
    summarise(number_of_active_policies = n())
  
  active_policies_list[[as.character(year)]] <- active_policies_year
}

#Combining the lists into a dataframe
active_policies_df <- bind_rows(active_policies_list, .id = "year")
active_policies_df$year <- as.numeric(active_policies_df$year)

#Calculating the Mortality Rates
lifetable_df <- active_policies_df %>% 
  left_join(death_grouped_by_age_year, by = c("year","age_life")) %>%
  mutate(crude_mortality_rate = Deaths/number_of_active_policies,
         log_mortality_rate = log(Deaths/number_of_active_policies)) %>%
  filter(year>2002, age_life>29)

#Removing all the rows with no death
mortality_df <- na.omit(lifetable_df)
mortality_train <- mortality_df %>%
  filter(year< 2021)

mortality_valid <- mortality_df %>%
  filter(year> 2021)
calc.RSME <- function (pred,act){
  sqrt(mean(sum((pred - act)^2)))
}
results <- matrix(NA, 0 ,4) 
colnames(results) <- c("span", "degree", "train.rsme", "valid.rsme")
for(degree in seq(0,2,1)){
  for(span in seq(0.15,1,0.1)){
    mod <- loess(crude_mortality_rate ~ age_life, 
                 data= mortality_train,
                 span = span,
                 degree = degree,
                 normalize = TRUE,
                 control = loess.control(surface="direct"))
    train.rsme <- calc.RSME(mod$fitted, mortality_train$crude_mortality_rate)
    valid.rsme <- calc.RSME(predict(mod,newdata=mortality_valid) %>%
                              as.data.frame(), mortality_valid$crude_mortality_rate)
    results <- rbind(results, c(span,degree, train.rsme, valid.rsme))
    
  }
}
results <- as.data.frame(results)
best <- results[which.min(results$valid.rsme),]


###Men Mortality Model###
inforce_men <- inforce_data %>%
  filter(Sex =="M") %>%
    mutate(age_policy = Year.of.Death - Issue.year,
       age_life = Issue.age+age_policy)


death_inforce_data_men <- inforce_men %>%
  filter(Death.indicator==1) %>%
  mutate(age_policy = Year.of.Death - Issue.year,
         age_life = Issue.age+age_policy)

#Finding the number of deaths per age in each year
death_grouped_by_age_year_men <- death_inforce_data_men %>%
  group_by(Year.of.Death, age_life) %>%
  summarise(Deaths = n())
colnames(death_grouped_by_age_year_men)[1] <- "year"

# Range of active policies
analysis_years <- 2001:2023

#List to store the results for each year
active_policies_list <- list()

for (year in analysis_years) {
  
  # Determine if the policy is active
  inforce_men$active_policy <- (is.na(inforce_men$Year.of.Death) | inforce_men$Year.of.Death > year) &
    (is.na(inforce_men$Year.of.Lapse) | inforce_men$Year.of.Lapse > year)
  
  # Filter for active policies
  active_policies_year <- inforce_men %>% 
    filter(active_policy == "TRUE" & year >= Issue.year) %>%
    mutate(age_life = Issue.age + (year -Issue.year)) %>% #Calculate the age for each year
    group_by(age_life) %>%
    summarise(number_of_active_policies = n())
  
  active_policies_list[[as.character(year)]] <- active_policies_year
}

#Combining the lists into a dataframe
active_policies_df_men <- bind_rows(active_policies_list, .id = "year")
active_policies_df_men$year <- as.numeric(active_policies_df_men$year)

#Calculating the Mortality Rates
lifetable_df_men <- active_policies_df_men %>% 
  left_join(death_grouped_by_age_year_men, by = c("year","age_life")) %>%
  mutate(crude_mortality_rate = Deaths/number_of_active_policies,
         log_mortality_rate = log(Deaths/number_of_active_policies)) %>%
  filter(year>2002)

#Removing all the rows with no death
mortality_df_men <- na.omit(lifetable_df_men)

#Smoothing for men
smoothed_rates_list <- list()
Years <- sort(unique(mortality_df_men$year))
for (current_year in Years) {
  mortality_year_df_men <- mortality_df_men %>%
    filter(year== current_year) %>%
    group_by(age_life)
  smoothed_model <- loess(crude_mortality_rate ~ age_life, data = mortality_year_df_men, span = 0.45, degree = 2)
  smoothed_rates_year <- smoothed_model$fitted
  smoothed_rates_list[[as.character(current_year)]] <- data.frame(age_life=smoothed_model$x, year = current_year, smoothed_rate = as.vector(smoothed_rates_year))
}
smoothed_rates_df_men <- bind_rows(smoothed_rates_list)
smoothed_df_men <- active_policies_df_men %>% 
  left_join(smoothed_rates_df_men, by = c("year","age_life")) %>%
  mutate(smoothed_deaths = smoothed_rate*number_of_active_policies) %>%
  filter(year>2002)
smoothed_df_men[is.na(smoothed_df_men)] <- 0


#Mortality models for men
Dxt <- xtabs(smoothed_deaths ~ age_life + year, data = smoothed_df_men)
Ext <- xtabs(number_of_active_policies ~ age_life + year, data=smoothed_df_men )
Ages <- sort(unique(smoothed_df_men$age_life))
Years <- sort(unique(smoothed_df_men$year))
M6 <- m6(link = "log")
LC <- lc()
CBD <- cbd(link="log")
APC <- apc()
M7 <- m7(link="log")
RH <- rh(link="logit",cohortAgeFun = "1")
M6fit <- fit(M6, Dxt = Dxt, Ext = Ext, ages= Ages, years = Years)
LCfit <- fit(LC, Dxt = Dxt, Ext = Ext, ages= Ages, years = Years)
CBDfit <- fit(CBD, Dxt = Dxt, Ext = Ext, ages= Ages, years = Years)
APCfit <- fit(APC, Dxt = Dxt, Ext = Ext, ages= Ages, years = Years)
M7fit <- fit(M7, Dxt = Dxt, Ext = Ext, ages= Ages, years = Years)
plot(M6fit, parametricbx = FALSE)
LCres=residuals(LCfit)
CBDres=residuals(CBDfit)
APCres=residuals(APCfit)
M7res=residuals(M7fit)
M6res=residuals(M6fit)
#Plotting Residuals - Scatter
plot(LCres, type ="scatter")
plot(CBDres, type = "scatter")
plot(APCres, type="scatter")
plot(M7res, type = "scatter")
plot(M6res, type = "scatter")
#Plotting Residuals - Colourmap
plot(LCres, type ="colourmap", reslim = c(-3.5,3.5), main= "Lee Carter Residuals")
plot(CBDres, type = "colourmap",reslim = c(-3.5,3.5), main= "Cairns Blake Dowd Residuals")
plot(APCres, type="colourmap",reslim = c(-3.5,3.5), main= "Age Period Cohort Residuals")
plot(M6res, type = "colourmap",reslim = c(-3.5,3.5), main= "M6 Residuals")
#Calculating AIC 
AIC(LCfit)
AIC(CBDfit)
AIC(APCfit)
AIC(M7fit)
AIC(M6fit)
#Calculating BIC
BIC(LCfit)
BIC(CBDfit)
BIC(APCfit)
BIC(M7fit)
BIC(M6fit)

#Mortality projections for men
M6for_men = forecast(M6fit, h=100)
men_projected_mortality <- as.data.frame(M6for_men$rates)
write_xlsx(men_projected_mortality, "C:\\Users\\Con Zhang\\Desktop\\Finity Grad\\menfinal.xlsx")

###Female Mortality Model###
inforce_female <- inforce_data %>%
  filter(Sex =="F") %>%
  mutate(age_policy = Year.of.Death - Issue.year,
         age_life = Issue.age+age_policy)


death_inforce_data_female <- inforce_female %>%
  filter(Death.indicator==1) %>%
  mutate(age_policy = Year.of.Death - Issue.year,
         age_life = Issue.age+age_policy)

#Finding the number of deaths per age in each year
death_grouped_by_age_year_female <- death_inforce_data_female %>%
  group_by(Year.of.Death, age_life) %>%
  summarise(Deaths = n())
colnames(death_grouped_by_age_year_female)[1] <- "year"

# Range of active policies
analysis_years <- 2001:2023

#List to store the results for each year
active_policies_list <- list()

for (year in analysis_years) {
  
  # Determine if the policy is active
  inforce_female$active_policy <- (is.na(inforce_female$Year.of.Death) | inforce_female$Year.of.Death > year) &
    (is.na(inforce_female$Year.of.Lapse) | inforce_female$Year.of.Lapse > year)
  
  # Filter for active policies
  active_policies_year <- inforce_female %>% 
    filter(active_policy == "TRUE" & year >= Issue.year) %>%
    mutate(age_life = Issue.age + (year -Issue.year)) %>% #Calculate the age for each year
    group_by(age_life) %>%
    summarise(number_of_active_policies = n())
  
  active_policies_list[[as.character(year)]] <- active_policies_year
}

#Combining the lists into a dataframe
  active_policies_df_female <- bind_rows(active_policies_list, .id = "year")
active_policies_df_female$year <- as.numeric(active_policies_df_female$year)

#Calculating the Mortality Rates
lifetable_df_female <- active_policies_df_female %>% 
  left_join(death_grouped_by_age_year_female, by = c("year","age_life")) %>%
  mutate(crude_mortality_rate = Deaths/number_of_active_policies,
         log_mortality_rate = log(Deaths/number_of_active_policies)) %>%
  filter(year>2007, age_life>28)

#Removing all the rows with no death
mortality_df_female <- na.omit(lifetable_df_female)

#Smoothing
smoothed_rates_list <- list()
Years <- sort(unique(mortality_df_female$year))
for (current_year in Years) {
  mortality_year_df_female <- mortality_df_female %>%
    filter(year== current_year) %>%
    group_by(age_life)
  smoothed_model <- loess(crude_mortality_rate ~ age_life, data = mortality_year_df_female, span = 0.45, degree = 2)
  smoothed_rates_year <- smoothed_model$fitted
  smoothed_rates_list[[as.character(current_year)]] <- data.frame(age_life=smoothed_model$x, year = current_year, smoothed_rate = as.vector(smoothed_rates_year))
}
smoothed_rates_df_female <- bind_rows(smoothed_rates_list)
smoothed_df_female <- active_policies_df_female %>% 
  left_join(smoothed_rates_df_female, by = c("year","age_life")) %>%
  mutate(smoothed_deaths = smoothed_rate*number_of_active_policies) %>%
  filter(year>2007, age_life > 28)
smoothed_df_female[is.na(smoothed_df_female)] <-0

Dxt_f <- xtabs(smoothed_deaths ~ age_life + year, data = smoothed_df_female) 
Ext_f <- xtabs(number_of_active_policies ~ age_life + year, data=smoothed_df_female )
Ages_f <- sort(unique(smoothed_df_female$age_life))
Years_f <- sort(unique(smoothed_df_female$year))
M6fit_f <- fit(M6, Dxt = Dxt_f, Ext = Ext_f, ages= Ages_f, years = Years_f)
LCfit_f <- fit(LC, Dxt = Dxt_f, Ext = Ext_f, ages= Ages_f, years = Years_f)
CBDfit_f <- fit(CBD, Dxt = Dxt_f, Ext = Ext_f, ages= Ages_f, years = Years_f)
APCfit_f <- fit(APC, Dxt = Dxt_f, Ext = Ext_f, ages= Ages_f, years = Years_f)
LCres_f=residuals(LCfit_f)
CBDres_f=residuals(CBDfit_f)
APCres_f=residuals(APCfit_f)
M6res_f=residuals(M6fit_f)
#Plotting Residuals - Colourmap
plot(LCres_f, type ="colourmap", reslim = c(-3.5,3.5), main= "Lee Carter Residuals")
plot(CBDres_f, type = "colourmap",reslim = c(-3.5,3.5), main= "Cairns Blake Dowd Residuals")
plot(APCres_f, type="colourmap",reslim = c(-3.5,3.5), main= "Age Period Cohort Residuals")
plot(M6res_f, type = "colourmap",reslim = c(-3.5,3.5), main= "M6 Residuals")
#Calculating AIC 
AIC(LCfit_f)
AIC(CBDfit_f)
AIC(APCfit_f)
AIC(M6fit_f)
M6res_f=residuals(M6fit_f)
plot(M6res_f, type = "scatter")
plot(M6res_f, type = "colourmap")
AIC(M6fit_f)
plot(M6fit_f)
#Forecasting mortlaity projections for Females
M6for_f <- forecast(M6fit_f, h=15)
female_mortaltiy_projections <- as.data.frame(M6for_f$rates)
write_xlsx(female_mortaltiy_projections, "C:\\Users\\Con Zhang\\Desktop\\Finity Grad\\female_mortfinal2.xlsx")

###GLM Modelling for Risk loading for smokers###
inforce_men$Death.indicator[is.na(inforce_men$Death.indicator)] <- 0
inforce_men$Smoker.Status <- as.factor(inforce_men$Smoker.Status)
inforce_men$Smoker.Status <- as.numeric(inforce_men$Smoker.Status)
inforce_men_count <- inforce_men %>% 
  group_by(Issue.year, Smoker.Status) %>%
  summarise(deaths = sum(Death.indicator), population = n()) %>%
  mutate(rate = deaths/population)
inforce_men_count$standard_pop <- 100
inforce_men_count <- inforce_men_count %>%
  mutate(standard_deaths = round(rate*standard_pop))

inforce_female$Death.indicator[is.na(inforce_female$Death.indicator)] <- 0
inforce_female_count <- inforce_female %>% 
  group_by(Issue.year, Smoker.Status) %>%
  summarise(deaths = sum(Death.indicator), population = n()) %>%
  mutate(rate = deaths/population)
inforce_female_count$standard_pop <- 100
inforce_female_count <- inforce_female_count %>%
  mutate(standard_deaths = round(rate*standard_pop))

train_control <- trainControl(method = "repeatedcv", number = 5)
model_m <- train(standard_deaths ~ Smoker.Status, data = inforce_men_count,
               method ="glm",
               family = quasipoisson(link=log),
               trControl = train_control)
model_f <- train(standard_deaths ~ Smoker.Status, data = inforce_female_count,
               method ="glm",
               family = quasipoisson(link=log),
               trControl = train_control)
summary(model_m)
summary(model_f)
cor(inforce_men_count$rate,inforce_men_count$Smoker.Status)
mean(inforce_men_count$standard_deaths)
var(inforce_men_count$standard_deaths)



