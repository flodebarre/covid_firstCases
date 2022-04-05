# NOTES

# CCDC: Suspected cases were diagnosed clinically based on symptoms and exposures.

# Colors
colConfirmed <- "blue"#"#38527f"
colSuspected <- "#6a9e52"
colClinic <- "#ebae40"
cols <- c(colConfirmed, colSuspected, colClinic)
names(cols) <- c("Confirmed", "Suspected", "ClinicallyDiagnosed")
colMixSCl <- "brown"

datCCDC <- read.csv("CCDC_2020/data_CCDC.csv")
datWHO <- read.csv("WHO_2021/data_WHO.csv")

head(datCCDC)
names(datCCDC)
tmp <- datCCDC[, c("date_sympOnset", "nb_cases_Confirmed", "nb_cases_Suspected", "nb_cases_ClinicallyDiagnosed", "nb_cases_total")]
names(tmp)[-1] <- paste0("CCDC_", names(tmp)[-1])
names(tmp)

tmp2 <- datWHO[, c("date_sympOnset", "nb_cases_Confirmed", "nb_cases_ClinicallyDiagnosed", "nb_cases_total")]
names(tmp2)[-1] <- paste0("WHO_", names(tmp2)[-1])

dat <- merge(tmp, tmp2, all = TRUE, by = "date_sympOnset")
# 0 when there are NAs
dat[is.na(dat)] <- 0

head(dat)
dat$date_sympOnset <- as.Date(dat$date_sympOnset)

pchWHO <- 1
pchCCDC <- 0

par(las = 1)
yMax <- max(dat[, -1], na.rm = TRUE)
plot(dat$date_sympOnset, dat$CCDC_nb_cases_Confirmed, ylim = c(0, yMax), yaxs = "i", pch = pchCCDC, col = colConfirmed, lwd = 2)
for(i in 1:yMax) abline(h = i, col = gray(0.8))
points(dat$date_sympOnset, dat$WHO_nb_cases_Confirmed, pch = pchWHO, col = colConfirmed, cex = 1.4)

yMax <- max(c(cumsum(dat$CCDC_nb_cases_total), cumsum(dat$WHO_nb_cases_total)), na.rm = TRUE)
yMax <- 105
lwdCCDC <- 2

par(las = 1, mgp = c(2., 0.5, 0), tck = -0.015)
par(mar = c(2, 3, 2, 3))
dx <- 0.075
dxCCDC <- - dx
dxWHO <- + dx


plot(dat$date_sympOnset + dxCCDC, cumsum(dat$CCDC_nb_cases_Confirmed), ylim = c(0, yMax), col = colConfirmed, pch = pchCCDC, type = "s", lwd = lwdCCDC, lend = "butt", axes = FALSE, 
     xlab = "", ylab = "Cumulative nb of cases")
mtext("day in December 2019", line = 0.75, side = 1)
axis(2, lwd = 0, lwd.ticks = 1)
axis(4, lwd = 0, lwd.ticks = 1)
days <- seq(as.Date("2019-12-01"), as.Date("2019-12-31"), by = "day")
axis(1, at = days, labels = format(days, format = "%d"), pos = 0, lwd = 0, lwd.ticks = 1)

title(main = "Comparison of CCDC data (14 Feb 2020) and WHO data (2021)")
#for(i in 1:yMax) abline(h = i, col = gray(0.8), lwd = 0.7)
for(i in seq(0, yMax, by = 10)) abline(h = i, col = gray(0.8), lwd = 1)
for(i in seq(0, yMax, by = 5)) abline(h = i, col = gray(0.8), lwd = 0.5)

#iPos <- which(dat$CCDC_nb_cases_Confirmed > 0)
#points(dat$date_sympOnset[iPos], cumsum(dat$CCDC_nb_cases_Confirmed[iPos]), pch = pchCCDC, col = colConfirmed, cex = 1)

points(dat$date_sympOnset + dxWHO, cumsum(dat$WHO_nb_cases_ClinicallyDiagnosed), type = "s", col = colMixSCl)
sum(dat$WHO_nb_cases_ClinicallyDiagnosed)

#points(dat$date_sympOnset, cumsum(dat$CCDC_nb_cases_ClinicallyDiagnosed), type = "s", col = colClinic, lwd = lwdCCDC, lend = "butt")

points(dat$date_sympOnset, cumsum(dat$CCDC_nb_cases_ClinicallyDiagnosed) + cumsum(dat$CCDC_nb_cases_Suspected), type = "s", col = colMixSCl, lwd = 2, lend = "butt")


points(dat$date_sympOnset + dxWHO, cumsum(dat$WHO_nb_cases_Confirmed), pch = pchWHO, col = colConfirmed, cex = 1.4, type = "s")

points(dat$date_sympOnset + dxCCDC, cumsum(dat$CCDC_nb_cases_Confirmed), 
       col = colConfirmed, pch = pchCCDC, 
       type = "s", lwd = lwdCCDC, lend = "butt")

legend("topleft", box.lwd = 0, 
       col = c(colConfirmed, colConfirmed, colMixSCl, colMixSCl), 
       lwd = c(lwdCCDC, 1, lwdCCDC, 1), 
       legend = c("CCDC Confirmed cases", "WHO confirmed cases", 
                  "CCDC suspected and clinically diagnosed cases", "WHO clinically diagnosed cases (no suspected)"))


## Compare CCDC and WHO ####
datWHO20 <- read.csv("WHO_2020/data_WHO2020.csv")
head(datWHO20)
# 20 February 2020
# Source: https://www.who.int/docs/default-source/coronaviruse/who-china-joint-mission-on-covid-19-final-report.pdf&sa=D&source=editors&ust=1646512380902400&usg=AOvVaw162Ti0T0OFnk9omxQeEhlY
# Figure 2, Wuhan

datWHO20$date_sympOnset <- as.Date(datWHO20$dateOnset)

ii <- which(dat1wide$nb_cases_Confirmed > 0)
yMax <- 12.5
par(mar = c(3, 3, 3, 3))
plot(dat1wide$date_sympOnset[ii], dat1wide$nb_cases_Confirmed[ii], 
     ylim = c(0, yMax), yaxs = "i", 
     axes = FALSE, 
     col = "blue", lwd = 2, 
     type = "n", 
     xlab = "day of December 2019", ylab = "nb cases")
axis(2, lwd = 0, lwd.ticks = 1)
axis(4, lwd = 0, lwd.ticks = 1)
colLine <- gray(0.9)
for(i in 1:round(yMax)) abline(h = i, col = colLine)
for(i in days) abline(v = i, col = colLine)
colWHO2020 <- rgb(0.5, 0.7, 1)
colCCDC <- "blue"
points(dat1wide$date_sympOnset[ii], dat1wide$nb_cases_Confirmed[ii], col = colCCDC, lwd = 2)

points(datWHO20$date_sympOnset, datWHO20$nb_confirmed, col = colWHO2020, pch = 4, lwd = 2)
axis(1, at = days, labels = format(days, format = "%d"), pos = 0, lwd = 1, lwd.ticks = 1)

ii <- which(datWHO$nb_cases_Confirmed > 0)
colWHO21 <- "darkgreen"
points(as.Date(datWHO$date_sympOnset)[ii], datWHO$nb_cases_Confirmed[ii], pch = 3, col = colWHO21, lwd = 2)

legend("topleft", col = c(colCCDC, colWHO2020, colWHO21), pch = c(1, 4, 3), 
       legend = c("CCDC, 11 or 14 Feb 2020", "WHO report Fig2, 20 Feb 2020", "WHO report 2021"), box.lwd = 0)
title(main = "Confirmed cases")

sum(datWHO20$nb_confirmed, na.rm = TRUE)


