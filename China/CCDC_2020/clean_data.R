if(!file.exists("clean_data.R")){
  setwd("China/CCDC_2020/")
}


# Load data
dat1 <- read.csv("CCDC_dataset1.csv")
dat2 <- read.csv("CCDC_dataset2.csv")

# Round onset dates and format them as dates
dat1$date_sympOnset <- round(dat1$Date_symptom.onset)
plot(dat1$date_sympOnset, dat1$Date_symptom.onset); abline(a = 0, b = 1) # Sanity check
dat1$date_sympOnset <- as.Date(paste0("2019-12-", dat1$date_sympOnset))

dat2$date_onset <- round(dat2$Date_onset)
plot(dat2$date_onset, dat2$Date_onset); abline(a = 0, b = 1) # Sanity check
dat2$date_onset <- as.Date(paste0("2019-12-", dat2$date_onset))

# Case data
## Confirmed cases
dat2$nb_cases <- round(dat2$Cases_confirmed)
# Sanity check
plot(dat2$nb_cases, dat2$Cases_confirmed); abline(a = 0, b = 1)
for(i in 1:max(dat2$Cases_confirmed)) abline(h = i, col = gray(0.6))
dat2$typeCase <- "Confirmed"

dat1$nb_cases_cumulated <- round(dat1$Cases_stacked)
# Sanity check
plot(dat1$nb_cases_cumulated, dat1$Cases_stacked, cex = 0.8, pch = 3, col = 2, lwd = 1.5)
abline(a = 0, b = 1)
for(i in 1:max(dat1$Cases_stacked)) abline(h = i, col = gray(0.6))
for(i in 1:max(dat1$Cases_stacked) - 0.5) abline(h = i, col = gray(0.6), lty = 3)

dat1$typeCase <- dat1$TypeCase
iC <- which(dat1$typeCase == "Confirmed")

# Sanity check
plot(dat1$date_sympOnset[iC], dat1$nb_cases_cumulated[iC])
points(dat2$date_onset, dat2$nb_cases, col = 2, pch = 3)
for(i in 1:max(dat1$Cases_stacked)) abline(h = i, col = gray(0.6))

# -> All confirmed cases of dat1 and dat2 match

## Other types of cases, to be "destacked"

# Turn the dataset into wide format and destack values
# Initialize wide with confirmed cases
dat1wide <- dat1[dat1$typeCase == "Confirmed", c("date_sympOnset", "nb_cases_cumulated")]
names(dat1wide)[2] <- "nb_cases_Confirmed"

# tmp with just suspected
tmp <- dat1[dat1$typeCase == "Suspected", c("date_sympOnset", "nb_cases_cumulated")]
names(tmp)[2] <- "nb_cases_cumulated_Suspected"

# Merge confirmed and suspected
dat1wide <- merge(dat1wide, tmp, all = TRUE, by = "date_sympOnset")
# Put 0 for new lines with no confirmed
dat1wide[is.na(dat1wide$nb_cases_Confirmed), "nb_cases_Confirmed"] <- 0

# Compute numbers of suspected by difference
dat1wide$nb_cases_Suspected <- dat1wide$nb_cases_cumulated_Suspected - dat1wide$nb_cases_Confirmed
# Turn NA into 0 for suspected cases with no cases on a given day
dat1wide[is.na(dat1wide$nb_cases_Suspected), "nb_cases_Suspected"] <- 0

# Compute cumulated number of C and S cases
dat1wide$nb_cases_cumulatedCS <- dat1wide$nb_cases_Confirmed + dat1wide$nb_cases_Suspected
# Sanity check
all(vapply(1:nrow(dat1wide), function(i) max(dat1wide[i, "nb_cases_Confirmed"], dat1wide[i, "nb_cases_cumulated_Suspected"], na.rm = TRUE), FUN.VALUE = 1) == dat1wide$nb_cases_cumulatedCS)

# tmo with just clinically diagnosed
tmp <- dat1[dat1$typeCase == "ClinicallyDiagnosed", c("date_sympOnset", "nb_cases_cumulated")]
names(tmp)[2] <- "nb_cases_cumulated_ClinicallyDiagnosed"

dat1wide <- merge(dat1wide, tmp, all = TRUE, by = "date_sympOnset")
# Turn NA into 0 for new lines
dat1wide[is.na(dat1wide$nb_cases_cumulatedCS), "nb_cases_cumulatedCS"] <- 0
dat1wide[is.na(dat1wide$nb_cases_Confirmed), "nb_cases_Confirmed"] <- 0
dat1wide[is.na(dat1wide$nb_cases_Suspected), "nb_cases_Suspected"] <- 0

# Compute number of CD by difference
dat1wide$nb_cases_ClinicallyDiagnosed <- dat1wide$nb_cases_cumulated_ClinicallyDiagnosed - dat1wide$nb_cases_cumulatedCS
# Turn NA into 0
dat1wide[is.na(dat1wide$nb_cases_ClinicallyDiagnosed), "nb_cases_ClinicallyDiagnosed"] <- 0

dat1wide$nb_cases_total <- dat1wide$nb_cases_Confirmed + dat1wide$nb_cases_Suspected + dat1wide$nb_cases_ClinicallyDiagnosed

# Sanity check
all(vapply(1:nrow(dat1wide), function(i) max(dat1wide[i, "nb_cases_Confirmed"], dat1wide[i, "nb_cases_cumulated_Suspected"], dat1wide[i, "nb_cases_cumulated_ClinicallyDiagnosed"], na.rm = TRUE), FUN.VALUE = 1) == dat1wide$nb_cases_total)

dat1wide

sum(dat1wide$nb_cases_total)
sum(dat1wide$nb_cases_Confirmed)
sum(dat1wide$nb_cases_Suspected)
sum(dat1wide$nb_cases_ClinicallyDiagnosed)

sum(dat2$nb_cases)

# Export output
write.csv(dat1wide, file = "data_CCDC.csv", row.names = FALSE)
