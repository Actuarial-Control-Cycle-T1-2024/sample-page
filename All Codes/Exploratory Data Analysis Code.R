library("tidyverse")
library("data.table")
library("ggplot2")
library("gridExtra")
library("ggcorrplot")

IFPol<-read.csv("C:/Users/angel/OneDrive/Desktop/University/Year 4/Trimester 1/ACTL4001/2024-srcsc-superlife-inforce-dataset.csv", header = TRUE)
Death_Cause_Mapping<-read.csv("C:/Users/angel/OneDrive/Desktop/University/Year 4/Trimester 1/ACTL4001/Cause of Death Mapping.csv")

##Data Issues ----------------------------------------------------------------------------------------
claims_data <- setDT(x = claims_data,keep.rownames = TRUE)

#Death Information ----------------------------------------------------------------------------------------
claims_data <- claims_data[is.na(Death.indicator), c("Year.of.Death","Cause.of.Death") := list(NA,NA)]
claims_death_blank = claims_data[Cause.of.Death==""] 
claims_data <- claims_data[!claims_data$Policy.number %in% claims_death_blank$Policy.number,] #removed 836 rows of data 
claims_data <- claims_data[is.na(Death.indicator),Death.indicator:=0]

#Lapse Information ----------------------------------------------------------------------------------------
claims_data <- claims_data[Lapse.Indicator=="Y", Lapse.Indicator:="1"]
claims_data <- claims_data[is.na(Lapse.Indicator), Year.of.Lapse := NA]
claims_data <- claims_data[is.na(Lapse.Indicator),Lapse.Indicator:=0]

#Data Cleaning  ----------------------------------------------------------------------------------------
IFPol_Death <- IFPol %>%
  mutate( 
    Death.indicator = ifelse(is.na(Death.indicator), 0, 1),
    Year.of.Death = ifelse(Death.indicator==0, NA, Year.of.Death),
    Cause.of.Death = ifelse(Death.indicator==0, NA, Cause.of.Death),
    Lapse.Indicator = ifelse(Lapse.Indicator=="Y",1,ifelse(is.na(Lapse.Indicator),0,1)),
    Year.of.Lapse = ifelse(Lapse.Indicator == 0, NA, Year.of.Lapse)
  ) %>%
  filter(Cause.of.Death != "")%>%
  merge(Death_Cause_Mapping,by="Cause.of.Death")


##Exploratory Data Analysis -------------------------------------------------------------------
IFPol_Death_Summary<-IFPol_Death %>%
  group_by(Cause.of.Death)%>%
  summarise(Count=n())%>%
  mutate(Percentage=round(Count/sum(Count)*100,1))%>%
  merge(Death_Cause_Mapping,by="Cause.of.Death")

ggplot(IFPol_Death_Summary, aes(x = fct_reorder(Cause.of.Death, -Percentage),y=Percentage,fill=Cause.of.Death.Description)) +
  geom_bar(stat = "identity")+
  geom_text(aes(label = paste0(Percentage, "%")), 
            position = position_stack(vjust = 0.5), color = "white", size = 3) +
  labs(title="Prevalence of Different Causes of Death",
       x="Cause of Death",
       y="Percentage of Total Deaths (%)")


# Underwriting Class ----------------------------------------------------------------------------------------
# TOTAL
risk_words <- c("very low risk","low risk","moderate risk","high risk")
risk_order <- factor(risk_words, levels = risk_words)

# Count occurrences of each word in the specified column
risk_counts <- sapply(risk_words, function(Risk) sum(grepl(Risk, claims_data$Underwriting.Class, ignore.case = TRUE)))

# Create data frame for plotting
plot_data <- data.frame(Risk = risk_order, count = risk_counts)

# Total Pop Graph
ggplot(plot_data, aes(x = Risk, y = count, fill = Risk)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = count), vjust = -0.5, size = 3) +
  scale_y_continuous(breaks = seq(0, max(risk_counts), by = 100000), labels = scales::comma_format()) +
  theme_minimal() +
  labs(title = "Underwriting Class Policy Data",
       x = "Underwriting Classes",
       y = "Number of Policyholders")

# Risks in Dead Policyholders
claims_death <- claims_data[complete.cases(claims_data$Cause.of.Death), ]
deaths_verylow <- sum(claims_death$Underwriting.Class == "very low risk")
deaths_low <- sum(claims_death$Underwriting.Class == "low risk")
deaths_mod <- sum(claims_death$Underwriting.Class == "moderate risk")
deaths_high <- sum(claims_death$Underwriting.Class == "high risk")

# SEX BY PRODUCT ----------------------------------------------------------------------------------------
ggplot(claims_data, aes(x = Policy.type, fill = Sex)) +
  geom_bar(position = "dodge", stat = "count") +
  scale_fill_manual(values = c("M" = "#ADD8E6", "F" = "#FFC0CB")) +
  scale_y_continuous(breaks = seq(0, 500000, by = 25000), labels = scales::comma_format()) +
  theme_minimal() +
  labs(title = "Female and Male Policyholders by Policy Type", x = "Policy Type", y = "Number of Policyholders")

# SMOKER STATUS TOTAL -------------------------------------------------------------------------------------
filtered_data_smoker <- IFPol %>%
  filter(Smoker.Status %in% c('S', 'NS')) %>%
  filter(!is.na(Cause.of.Death)) %>% #filter out cause of death = NA variables
  group_by(Smoker.Status, Cause.of.Death) %>%
  summarize(Count = n())
print(filtered_data_smoker)

#total count of smokers vs nonsmokers
total_count_smokerstatus <- filtered_data_smoker %>%
  group_by(Smoker.Status) %>%
  summarise(Total_Count = sum(Count))
total_count_smokerstatus

#gender of smokers/nonsmokers
total_sex_smokerstatus <- IFPol %>%
  group_by(Smoker.Status, Sex) %>%
  summarise(count = n())
total_sex_smokerstatus

#graph of smokers cause of death
smoker.death <- ggplot(filtered_data_smoker, aes(x = Cause.of.Death, y = Count, fill = Smoker.Status)) +
  geom_bar(stat = "identity", colour="black", position = position_dodge()) +
  geom_text(aes(label= Count), vjust=-0.5, position=position_dodge(0.9), size=3.5, colour="black") +
  theme_gray() +
  labs(x = "Causes of Death",
       y = "Number of Deaths",
       title = "Cause of Deaths for Smokers (S) vs Non-Smokers (NS)")
smoker.death + scale_fill_brewer(palette="Paired")


# UNDERWRITING CLASS SMOKERS ------------------------------------------------
smoker.underwritingclass <- IFPol %>%
  filter(Smoker.Status %in% c('S')) %>%
  mutate(Underwriting.Class = factor(Underwriting.Class, levels = c("very low risk", "low risk", "moderate risk", "high risk"))) %>% #rearrange classes in increasing order
  group_by(Underwriting.Class) %>%
  summarize(Count = n())
print(smoker.underwritingclass)

nonsmoker.underwritingclass <- IFPol %>%
  filter(Smoker.Status %in% c('NS')) %>%
  mutate(Underwriting.Class = factor(Underwriting.Class, levels = c("very low risk", "low risk", "moderate risk", "high risk"))) %>% #rearrange classes in increasing order
  group_by(Underwriting.Class) %>%
  summarize(Count = n())
print(nonsmoker.underwritingclass)

combined.smokers <- IFPol %>% #combine smokers and nonsmokers
  filter(Smoker.Status %in% c('S', 'NS')) %>%
  mutate(Underwriting.Class = factor(Underwriting.Class, levels = c("very low risk", "low risk", "moderate risk", "high risk"))) %>% #rearrange classes in increasing order
  group_by(Smoker.Status, Underwriting.Class) %>%
  summarize(Count = n(), .groups = 'drop')
print(combined.smokers)


underwriting.class.smoker <- ggplot(combined.smokers, aes(x = Underwriting.Class, y = Count, fill = Smoker.Status)) +
  geom_bar(stat = "identity", colour="black", position = position_dodge()) +
  geom_text(aes(label= Count), vjust=-0.5, position=position_dodge(0.9), size=3.5, colour="black") +
  theme_gray() +
  labs(title = "Underwriting Class by Smoking Status",
       y = "Number of Policyholders",
       x = "Underwriting Class Group",
       fill = "Smoking Status")
underwriting.class.smoker + scale_fill_brewer(palette="Paired")
