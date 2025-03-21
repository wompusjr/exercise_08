library(tidyverse)
library(skimr)
#step one
d <- read_csv("https://raw.githubusercontent.com/difiore/ada-datasets/main/Street_et_al_2017.csv", col_names = TRUE)
skim(d)
##Social Learning - mean (2.3) sd (16.5) min(0) QT1 (0) Median (0) QT3 (0) max(214)
##Research_effort - mean (38.8) sd (16.5) min(1) QT1 (6) Median (16) QT3 (37.8) max(755)
##ECV - mean (68.5) sd (82.8) min(1.63) QT1 (11.8) Median (58.6) QT3 (86.2) max(491)
##Group_size - mean (13.3) sd (15.2) min(1) QT1 (3.12) Median (7.5) QT3 (18.2) max(91.2)
##Gestation - mean (165) sd (38) min(60) QT1 (138) Median (166) QT3 (183) max(275)
##Weaning- mean (311) sd (253) min(40) QT1 (122) Median (234) QT3 (389) max(1261)
##Longevity - mean (332) sd (166) min(103) QT1 (216) Median (301) QT3 (393) max(1470)
##Sex_maturity - mean (1480) sd (999) min(283) QT1 (702) Median (1427) QT3 (1894) max(5583)
##Body_mass - mean (6795) sd (14230) min(31.2) QT1 (739) Median (3554) QT3 (7465) max(130000)
##Maternal_investment - mean (479) sd (292) min(100) QT1 (256) Median (401) QT3 (592) max(1492)
##Repro_lifespan - mean (9065) sd (4602) min(2512) QT1 (6126) Median (8326) QT3 (10717) max(39130)
#step two
par(mfrow = c(2, 2))
plot (d$ECV~d$Group_size)
plot (d$ECV~d$Longevity)
plot (d$ECV~d$Weaning)
plot (d$ECV~d$Repro_lifespan)
par(mfrow = c(2, 2))
#step three
d2 <- na.omit(d)
cov <- cov(d2$ECV, d2$Group_size)
(beta1 <- cor(d2$ECV, d2$Group_size) * (sd(d2$ECV)/sd(d2$Group_size))) #beta 1 2.874
(beta0 <- mean(d2$ECV) - beta1 * mean(d2$Group_size)) #beta 0 32.495

#step four
m1 <- lm(formula = ECV~Group_size, data = d2)
m1 #same results

#step five
cat <- d |>
  filter(Taxonomic_group == "Catarrhini") |>
  na.omit(d)
plat <- d |>
  filter(Taxonomic_group == "Platyrrhini") |>
  na.omit(d)
streps <- d |>
  filter(Taxonomic_group == "Strepsirhini") |>
  na.omit(d)
##catarrhines
par(mfrow = c(2, 2))
plot (cat$ECV~cat$Group_size)
plot (cat$ECV~cat$Longevity)
plot (cat$ECV~cat$Weaning)
plot (cat$ECV~cat$Repro_lifespan)
par(mfrow = c(2,2))

covcat <- cov(cat$ECV, cat$Group_size)
(beta1cat <- cor(cat$ECV, cat$Group_size) * (sd(cat$ECV)/sd(cat$Group_size))) #beta 1 1.399
(beta0cat <- mean(cat$ECV) - beta1cat * mean(cat$Group_size)) #beta 0 105.411
(mcat <- lm(formula = ECV~Group_size, data = cat)) #double checking results
##platyrrhines 
par(mfrow = c(2, 2))
plot (plat$ECV~plat$Group_size)
plot (plat$ECV~plat$Longevity)
plot (plat$ECV~plat$Weaning)
plot (plat$ECV~plat$Repro_lifespan)
par(mfrow = c(2,2))

covplat <- cov(plat$ECV, plat$Group_size)
(beta1plat <- cor(plat$ECV, plat$Group_size) * (sd(plat$ECV)/sd(plat$Group_size))) #beta 1 2.05
(beta0plat <- mean(plat$ECV) - beta1plat * mean(plat$Group_size)) #beta 0 14.837
(mplat <- lm(formula = ECV~Group_size, data = plat)) #double checking results - intercept is different but only due to rounding
##strepsirhines
par(mfrow = c(2, 2))
plot (streps$ECV~streps$Group_size)
plot (streps$ECV~streps$Longevity)
plot (streps$ECV~streps$Weaning)
plot (streps$ECV~streps$Repro_lifespan)
par(mfrow = c(2,2))

covstreps <- cov(streps$ECV, streps$Group_size)
(beta1streps <- cor(streps$ECV, streps$Group_size) * (sd(streps$ECV)/sd(streps$Group_size))) #beta 1 1.186
(beta0streps <- mean(streps$ECV) - beta1streps * mean(streps$Group_size)) #beta 0 9.359
(mstreps <- lm(formula = ECV~Group_size, data = streps)) #double checking results
##comparing each group's coefficients
summary.aov(mcat) #pvalue of 0.178
summary.aov(mplat) #pvalue of 0.000752
summary.aov(mstreps) #pvalue of 0.051
###looks like the relationship between ECV and Group size is strongest in platyrrhines and weakest in catarrhines
#step six
SSX <- sum((m1$model$Group_size - mean(m1$model$Group_size))^2) 
SSE <- sum(m1$residuals^2)
SSR <- sum((m1$fitted.values - mean(m1$model$ECV))^2)
df_error <- nrow(d2) - 1 - 1
MSE <- SSE/df_error
MSR <- SSR/1
fratio <- MSR/MSE
SEbeta1 <- sqrt(MSE/SSX) #0.573
(crit <- qf(p = 0.95, df1 = 1, df2 = 74)) #3.97023
(pvalue <- pf(q = fratio, df1 = 1, df2 = 74, lower.tail = FALSE)) #p-value 3.55e-06
summary(m1)
#step seven
library(broom)
library(mosaic)
(obs_slope <- broom::tidy(m1) |>
  filter(term == "Group_size") |>
  pull(estimate))
nperm <- 1000
perm <- do(nperm) * {
  d_new <- d2
  d_new$Group_size <- sample(d_new$Group_size)
  m <- lm(data = d_new, ECV ~ Group_size)
  broom::tidy(m) |>
    filter(term == "Group_size") |>
    pull(estimate)
}
perm
##calculating p-value
ggplot(data = perm) +
  geom_histogram(aes(x = result))+
  geom_vline(xintercept = obs_slope, color = "pink")
(p <- sum(perm$result > abs(obs_slope) | perm$result < -1*abs(obs_slope))/nperm) #basically 0! means highly significant ECV trends increases as group size increases.
#step eight
library(infer)
boot.slope <- d2 |>
  specify(ECV ~ Group_size) |>
  generate(reps = 1000, type = "bootstrap") |>
  calculate(stat = "slope")
p_upper <- 1 - (0.05/2)
p_lower <- 0.05/2
critical_value <- qt(p_upper, df = 74)
(boot.slope.summary <- boot.slope |>
  summarize(estimate = mean(stat), std.error = sd(stat), lower = estimate - std.error *
              critical_value, upper = estimate + std.error * critical_value, boot.lower = quantile(stat,
                                                                                                   p_lower), boot.upper = quantile(stat, p_upper)))
(CI.percentile <- get_ci(boot.slope, level = 1 - 0.05, type = "percentile"))##lower ci = 1.22 and upper ci = 3.94
(CI.theory <- get_ci(boot.slope, level = 1 - 0.05, type = "se", point_estimate = pull(boot.slope.summary, estimate))) ##lower ci = 1.48 and upper ci = 4.11
#boot-strapping seems to suggest a slope within confidence intervals
