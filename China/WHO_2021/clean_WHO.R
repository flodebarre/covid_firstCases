# setwd("../WHO_2021/")

dat <- read.csv("WHOdataset.csv")
head(dat)

# Clean dates
dat$date_sympOnset <- round(dat$dateOnset)
plot(dat$date_sympOnset, dat$dateOnset); abline(a = 0, b = 1)
dat$date_sympOnset <- as.Date(paste0("2019-12-", dat$date_sympOnset))

# Clean cases
dat$nb_cases_cum <- round(dat$cumNb)

plot(dat$nb_cases_cum, dat$cumNb, pch = 3, col = 2, lwd = 1.5)
abline(a = 0, b = 1)
for(i in 1:25) abline(h = i)
for(i in 1:25 - 0.5) abline(h = i, lty = 3)

datwide <- dat[dat$type == "Confirmed", c("date_sympOnset", "nb_cases_cum")]
names(datwide)[2] <- "nb_cases_Confirmed"

tmp <- dat[dat$type == "ClinicallyDiagnosed", c("date_sympOnset", "nb_cases_cum")]
names(tmp)[2] <- "nb_cases_ClinicallyDiagnosed_cum"

# Merge the two subdataset
datwide <- merge(datwide, tmp, all = TRUE, by = "date_sympOnset")

# Set NA of confirmed to 0 (new lines)
datwide[is.na(datwide$nb_cases_Confirmed), "nb_cases_Confirmed"] <- 0

# Difference for diagnosed
datwide$nb_cases_ClinicallyDiagnosed <- datwide$nb_cases_ClinicallyDiagnosed_cum - datwide$nb_cases_Confirmed
# Set NA to 0
datwide$nb_cases_ClinicallyDiagnosed[is.na(datwide$nb_cases_ClinicallyDiagnosed)] <- 0

datwide$nb_cases_total <- datwide$nb_cases_Confirmed + datwide$nb_cases_ClinicallyDiagnosed

# Sanity check
all(vapply(1:nrow(datwide), function(i) max(datwide[i, "nb_cases_Confirmed"], datwide[i, "nb_cases_ClinicallyDiagnosed_cum"], na.rm = TRUE), FUN.VALUE = 1) == datwide$nb_cases_total)

plot(datwide$nb_cases_total)
sum(datwide$nb_cases_Confirmed)
sum(datwide$nb_cases_ClinicallyDiagnosed)

# Save output
write.csv(datwide, "data_WHO.csv")
