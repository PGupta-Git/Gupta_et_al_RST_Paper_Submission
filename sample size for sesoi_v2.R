# Define the optimal sample size to detect a well-justified SESOI ----

rm(list = ls())

library(Superpower)
library(easystats)
library(tidyverse)
library(dplyr)
library(readxl)
library(lemon)
library(patchwork)
library(ggeasy)

# setwd ----
# Please pull or clone the repo and set wd as your local directory if using RStudio. If using VSCode or Positron, then clone the project or download the zip file and open it as a folder from the file menu.

# set plot theme
theme_set(theme_classic())

# Setting the target differences ----
# create dataframe of Datson et al. 2021 data
(sprint.datson <- data.frame(distance = c(5, 30), time = c(0.09, 0.21)))
# run a linear regression to get predict times for 10m, 20m, and 40m
summary(reg <- lm(time ~ distance, sprint.datson))
coeff <- coefficients(reg)
intercept <- coeff[1]
slope <- coeff[2]

# 10 m
(sesoi.10 <- (slope * 10) + intercept)
(sesoi.10 <- round(sesoi.10, 2))
# 20 m
(sesoi.20 <- (slope * 20) + intercept)
(sesoi.20 <- round(sesoi.20, 2))
# 40 m
(sesoi.40 <- (slope * 40) + intercept)
(sesoi.40 <- round(sesoi.40, 2))
# maximal sprinting speed (vmax)
# no data vmax (ms) so take proposal from Haugen & Buchheit (2016)
# 5% is the typical training induced change in mss
# countermovement jump
(sesoi.cmj <- 2.8)

# maximal aerobic speed
# extrapolation of the Datson data to a change in stage ~ 0.5kmh
# convert to m.s
(sesoi.mas <- (0.5 / 3.8))
(sesoi.mas <- round(sesoi.mas, 2))

# function to calculate pooled standard deviation for multiple samples in one vector
calculate_pooled_sd <- function(sds, ns) {
  # 'sds' is a vector of standard deviations
  # 'ns' is a vector of sample sizes

  if (length(sds) != length(ns) || length(sds) < 2) {
    stop(
      "You must provide vectors of SDs and sample sizes for at least two samples."
    )
  }

  # Calculate degrees of freedom for each sample
  dfs <- ns - 1

  # Calculate pooled variance
  pooled_variance <- sum((dfs * sds^2)) / sum(dfs)

  # Calculate pooled standard deviation
  pooled_sd <- sqrt(pooled_variance)

  return(pooled_sd)
}

# 10 m ----
# Get the covariate-outcome relationship from Thurlow et al. (2024)
(df.10 <- data.frame(
  pre.test = c(
    1.75,
    1.78,
    1.86,
    1.80,
    1.77,
    1.88,
    1.96,
    1.90,
    1.88,
    1.87,
    1.87,
    1.84,
    1.73,
    1.75,
    1.70,
    1.88,
    1.96,
    1.90,
    1.85,
    2.12
  ),
  pre.test.sd = c(
    0.11,
    0.11,
    0.13,
    0.08,
    0.06,
    0.1,
    0.05,
    0.07,
    0.07,
    0.10,
    0.09,
    0.09,
    0.07,
    0.05,
    0.05,
    0.21,
    0.12,
    0.14,
    0.14,
    0.06
  ),
  post.test = c(
    1.74,
    1.70,
    1.82,
    1.79,
    1.76,
    1.86,
    1.93,
    1.82,
    1.86,
    1.82,
    1.85,
    1.81,
    1.62,
    1.64,
    1.68,
    1.81,
    1.90,
    1.82,
    1.76,
    2.12
  ),
  post.test.sd = c(
    0.11,
    0.12,
    0.09,
    0.09,
    0.06,
    0.1,
    0.08,
    0.06,
    0.09,
    0.14,
    0.11,
    0.11,
    0.09,
    0.07,
    0.10,
    0.17,
    0.07,
    0.11,
    0.11,
    0.05
  ),
  study.n = c(
    18,
    18,
    10,
    10,
    13,
    8,
    7,
    12,
    21,
    9,
    13,
    14,
    8,
    7,
    9,
    16,
    15,
    10,
    10,
    8
  )
))

# Create change scores
(df.10 <- df.10 |> mutate(change = post.test - pre.test))

# get and store Thurlow et al. (2024) study descriptives
# 10 m weighted pre-test mean
(m.10 <- df.10$pre.test) # vector for means
(n.10 <- df.10$study.n) # vector for n
(wm.10 <- weighted.mean(m.10, n.10))
(wm.10 <- round(wm.10, 2))

# pooled SD
(sd.10 <- df.10$pre.test.sd) # vector for sds
(n.10 <- df.10$study.n) # vector for n
(pooledsd.10 <- calculate_pooled_sd(sd.10, n.10))
(pooledsd.10 <- round(pooledsd.10, 2))

# Calculate pre-post test correlation
cor.10 <- correlation(df.10, select = "pre.test", select2 = "change")
(r.10 <- cor.10$r) # save r value

# 10 m ancova power calculation
(res.10 <- power_oneway_ancova(
  mu = c(0, sesoi.10),
  n_cov = 1,
  sd = pooledsd.10,
  r2 = r.10^2,
  alpha_level = 0.05,
  beta_level = .2, # correction for 6 tests
  round_up = TRUE,
  type = "exact"
))

# dropout correction (20%)
(ss.10 <- (res.10$N / (1 - 0.20)))

# Sensitivity analyses
# Set common parameters for the 10 m ANCOVA
n_per_group <- 11
n_groups <- 2
n_covariates <- 1
sd_val <- pooledsd.10
r2_val <- r.10^2
alpha_level <- 0.05

# Define a set of 'mu' vectors to test
(mu_scenarios <- list(
  c(0.00, -0.01),
  c(0.00, -0.02),
  c(0.00, -0.03),
  c(0.00, -0.04),
  c(0.00, -0.05),
  c(0.00, -0.06),
  c(0.00, -0.07),
  c(0.00, -0.08),
  c(0.00, -0.09),
  c(0.00, -0.10),
  c(0.00, -0.11),
  c(0.00, -0.12),
  c(0.00, -0.13),
  c(0.00, -0.14),
  c(0.00, -0.15),
  c(0.00, -0.16),
  c(0.00, -0.17),
  c(0.00, -0.18),
  c(0.00, -0.19),
  c(0.00, -0.20)
))

# Create a data frame to store results
sensitivity.10m <- data.frame(
  scenario = character(),
  baseline = numeric(),
  target = numeric(),
  power = numeric(),
  stringsAsFactors = FALSE
)

# Run the analysis for each mu scenario
for (i in 1:length(mu_scenarios)) {
  current_mu <- mu_scenarios[[i]]

  result <- power_oneway_ancova(
    n = rep(n_per_group, n_groups), # Create a vector of sample sizes
    mu = current_mu,
    n_cov = n_covariates,
    sd = sd_val,
    r2 = r2_val,
    alpha_level = alpha_level,
    type = "exact"
  )

  # Add the results to the data frame
  sensitivity.10m[i, ] <- c(
    paste("Scenario", i),
    current_mu[1],
    current_mu[2],
    result$power
  )
}
sensitivity.10m

# Change chr to numeric
sensitivity.10m <- sensitivity.10m %>%
  mutate_at(c('target', 'power'), as.numeric)

# critical effect size is scenario 14, -0.14 s
(critical.10 <- sensitivity.10m[14, 3])
sesoi.10

# plot curve with data from critical.10 and sesoi.10
(ten <- sensitivity.10m |>
  ggplot(aes(target, power)) +
  geom_line() +
  annotate(
    "segment",
    x = -0.2,
    xend = -0.14,
    y = 80,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # 80% power
  annotate(
    "segment",
    x = -0.14,
    xend = -0.14,
    y = 0,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # critical es
  annotate(
    "segment",
    x = -0.11,
    xend = -0.11,
    y = 0,
    yend = 60.6,
    colour = "green",
    size = 1.5
  ) + # sesoi
  coord_capped_cart(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(from = 0, to = 100, by = 10)
  ) +
  scale_x_continuous(
    limits = c(-0.2, 0.0),
    breaks = seq(from = -0.2, to = 0, by = 0.05)
  ) +
  labs(x = "10 m Sprint Target Change (sec)", y = "Power")) +
  easy_all_text_colour("black") +
  theme(axis.title.x = element_text(vjust = -1))

# 20 m ----
# Get the covariate-outcome relationship from Thurlow et al. (2024)
(df.20 <- data.frame(
  pre.test = c(
    2.94,
    2.96,
    3.20,
    3.30,
    3.29,
    3.20,
    3.23,
    3.31,
    3.28,
    2.96,
    3.03,
    3.37,
    3.28,
    3.43
  ),
  pre.test.sd = c(
    0.11,
    0.12,
    0.10,
    0.09,
    0.08,
    0.25,
    0.14,
    0.15,
    0.15,
    0.1,
    0.07,
    0.27,
    0.25,
    0.11
  ),
  post.test = c(
    2.92,
    2.90,
    3.20,
    3.25,
    3.21,
    3.22,
    3.13,
    3.23,
    3.23,
    2.85,
    2.91,
    3.20,
    3.14,
    3.44
  ),
  post.test.sd = c(
    0.11,
    0.10,
    0.10,
    0.06,
    0.08,
    0.22,
    0.1,
    0.21,
    0.22,
    0.13,
    0.11,
    0.16,
    0.22,
    0.08
  ),
  study.n = c(18, 18, 12, 9, 10, 9, 30, 13, 14, 8, 7, 10, 10, 8)
))

# Create change scores
(df.20 <- df.20 |> mutate(change = post.test - pre.test))

# get and store Thurlow et al. (2024) study descriptives
# 20 m weighted pre-test mean
(m.20 <- df.20$pre.test) # vector for means
(n.20 <- df.20$study.n) # vector for n
(wm.20 <- weighted.mean(m.20, n.20))
(wm.20 <- round(wm.20, 2))

# pooled SD
(sd.20 <- df.20$pre.test.sd) # vector for sds
(n.20 <- df.20$study.n) # vector for n
(pooledsd.20 <- calculate_pooled_sd(sd.20, n.20))
(pooledsd.20 <- round(pooledsd.20, 2))

# Calculate pre-post test correlation
cor.20 <- correlation(df.20, select = "pre.test", select2 = "change")
(r.20 <- cor.20$r) # save r value

# 20 m ancova power calculation
(res.20 <- power_oneway_ancova(
  mu = c(0, sesoi.20),
  n_cov = 1,
  sd = pooledsd.20,
  r2 = r.20^2,
  alpha_level = 0.05,
  beta_level = .2,
  round_up = TRUE,
  type = "exact"
))

# dropout correction (20%)
(ss.20 <- (res.20$N / (1 - 0.20)))

# Sensitivity analyses
# Set common parameters for the 20 m ANCOVA
n_per_group <- 11
n_groups <- 2
n_covariates <- 1
sd_val <- pooledsd.20
r2_val <- r.20^2
alpha_level <- 0.05

# Define a set of 'mu' vectors to test
(mu_scenarios <- list(
  c(0.00, -0.05),
  c(0.00, -0.06),
  c(0.00, -0.07),
  c(0.00, -0.08),
  c(0.00, -0.09),
  c(0.00, -0.10),
  c(0.00, -0.11),
  c(0.00, -0.12),
  c(0.00, -0.13),
  c(0.00, -0.14),
  c(0.00, -0.15),
  c(0.00, -0.16),
  c(0.00, -0.17),
  c(0.00, -0.18),
  c(0.00, -0.19),
  c(0.00, -0.20),
  c(0.00, -0.21),
  c(0.00, -0.22),
  c(0.00, -0.23),
  c(0.00, -0.24),
  c(0.00, -0.26),
  c(0.00, -0.28),
  c(0.00, -0.30)
))

# Create a data frame to store results
sensitivity.20m <- data.frame(
  scenario = character(),
  baseline = numeric(),
  target = numeric(),
  power = numeric(),
  stringsAsFactors = FALSE
)

# Run the analysis for each mu scenario
for (i in 1:length(mu_scenarios)) {
  current_mu <- mu_scenarios[[i]]

  result <- power_oneway_ancova(
    n = rep(n_per_group, n_groups), # Create a vector of sample sizes
    mu = current_mu,
    n_cov = n_covariates,
    sd = sd_val,
    r2 = r2_val,
    alpha_level = alpha_level,
    type = "exact"
  )

  # Add the results to the data frame
  sensitivity.20m[i, ] <- c(
    paste("Scenario", i),
    current_mu[1],
    current_mu[2],
    result$power
  )
}
sensitivity.20m

# Change chr to numeric
sensitivity.20m <- sensitivity.20m %>%
  mutate_at(c('target', 'power'), as.numeric)

# critical effect size is scenario 16, -0.2 s
(critical.20 <- sensitivity.20m[16, 3])
# compare
sesoi.20

# plot curve with data from critical.20 and sesoi.20
(twenty <- sensitivity.20m |>
  ggplot(aes(target, power)) +
  geom_line() +
  annotate(
    "segment",
    x = -0.3,
    xend = -0.195,
    y = 80,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # 80% power
  annotate(
    "segment",
    x = -0.195,
    xend = -0.195,
    y = 0,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # critical es
  annotate(
    "segment",
    x = -0.16,
    xend = -0.16,
    y = 0,
    yend = 63.8,
    colour = "green",
    size = 1.5
  ) + # sesoi
  coord_capped_cart(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(from = 0, to = 100, by = 10)
  ) +
  scale_x_continuous(
    limits = c(-0.3, 0.0),
    breaks = seq(from = -0.3, to = 0, by = 0.05)
  ) +
  labs(x = "20 m Sprint Target Change (sec)", y = "Power")) +
  easy_all_text_colour("black") +
  theme(axis.title.x = element_text(vjust = -1))

# 40 m ----
# get and store 40 m data from Haugen (2020) doi: 10.1080/02640414.2020.1741955
(m1.40 <- 5.45) # forwards
(sd1.40 <- 0.18) # forwards
(n1.40 <- 90) # forwards
(m2.40 <- 5.53) # defenders
(sd2.40 <- 0.16) # defenders
(n2.40 <- 110) # defenders
(m3.40 <- 5.56) # midfielders
(sd3.40 <- 0.17) # midfielders
(n3.40 <- 102) # midfielders

# get and store weighted mean
(m.40 <- c(m1.40, m2.40, m3.40)) # vector for means
(sd.40 <- c(sd1.40, sd2.40, sd3.40)) # vector for sds
(n.40 <- c(n1.40, n2.40, n3.40)) # vector for n
(wm.40 <- weighted.mean(m.40, n.40))
(wm.40 <- round(wm.40, 2))

# pooled SD
(pooledsd.40 <- calculate_pooled_sd(sd.40, n.40))
(pooledsd.40 <- round(pooledsd.40, 2))

# No covariate-outcome relationship available from Thurlow et al. (2024)
# Therefore, use 20 m (r.20)

# 40 m ancova power calculation
(res.40 <- power_oneway_ancova(
  mu = c(0, sesoi.40),
  n_cov = 1,
  sd = pooledsd.40,
  r2 = r.20^2,
  alpha_level = .05,
  beta_level = .2,
  round_up = TRUE,
  type = "exact"
))

# dropout correction (20%)
(ss.40 <- (res.40$N / (1 - 0.20)))

# Sensitivity analyses
# Set common parameters for the 40 m ANCOVA
n_per_group <- 11
n_groups <- 2
n_covariates <- 1
sd_val <- pooledsd.40
r2_val <- r.20^2
alpha_level <- 0.05

# Define a set of 'mu' vectors to test
(mu_scenarios <- list(
  c(0.00, -0.05),
  c(0.00, -0.06),
  c(0.00, -0.07),
  c(0.00, -0.08),
  c(0.00, -0.09),
  c(0.00, -0.10),
  c(0.00, -0.11),
  c(0.00, -0.12),
  c(0.00, -0.13),
  c(0.00, -0.14),
  c(0.00, -0.15),
  c(0.00, -0.16),
  c(0.00, -0.17),
  c(0.00, -0.18),
  c(0.00, -0.19),
  c(0.00, -0.20),
  c(0.00, -0.21),
  c(0.00, -0.22),
  c(0.00, -0.23),
  c(0.00, -0.24),
  c(0.00, -0.26),
  c(0.00, -0.28),
  c(0.00, -0.30)
))

# Create a data frame to store results
sensitivity.40m <- data.frame(
  scenario = character(),
  baseline = numeric(),
  target = numeric(),
  power = numeric(),
  stringsAsFactors = FALSE
)

# Run the analysis for each mu scenario
for (i in 1:length(mu_scenarios)) {
  current_mu <- mu_scenarios[[i]]

  result <- power_oneway_ancova(
    n = rep(n_per_group, n_groups), # Create a vector of sample sizes
    mu = current_mu,
    n_cov = n_covariates,
    sd = sd_val,
    r2 = r2_val,
    alpha_level = alpha_level,
    type = "exact"
  )

  # Add the results to the data frame
  sensitivity.40m[i, ] <- c(
    paste("Scenario", i),
    current_mu[1],
    current_mu[2],
    result$power
  )
}
sensitivity.40m

# Change chr to numeric
(sensitivity.40m <- sensitivity.40m %>%
  mutate_at(c('target', 'power'), as.numeric))

# critical effect size is scenario 18, -0.22 s
(critical.40 <- sensitivity.40m[18, 3])
# compare
sesoi.40

# plot curve with data from critical.40 and sesoi.40
(forty <- sensitivity.40m |>
  ggplot(aes(target, power)) +
  geom_line() +
  annotate(
    "segment",
    x = -0.3,
    xend = -0.22,
    y = 80,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # 80% power
  annotate(
    "segment",
    x = -0.22,
    xend = -0.22,
    y = 0,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # critical es
  annotate(
    "segment",
    x = -0.26,
    xend = -0.26,
    y = 0,
    yend = 91.1,
    colour = "green",
    size = 1.5
  ) + # sesoi
  coord_capped_cart(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(from = 0, to = 100, by = 10)
  ) +
  scale_x_continuous(
    limits = c(-0.3, 0.0),
    breaks = seq(from = -0.3, to = 0, by = 0.05)
  ) +
  labs(x = "40 m Sprint Target Change (sec)", y = "Power")) +
  easy_all_text_colour("black") +
  theme(axis.title.x = element_text(vjust = -1))

# VMax ----
# get and store max sprinting speed data from Haugen (2020)
(m1.vmax <- 9.3) # forwards
(sd1.vmax <- 0.4) # forwards
(n1.vmax <- 90) # forwards
(m2.vmax <- 9.3) # defenders
(sd2.vmax <- 0.4) # defenders
(n2.vmax <- 110) # defenders
(m3.vmax <- 9.2) # midfielders
(sd3.vmax <- 0.4) # midfielders
(n3.vmax <- 102) # midfielders

# get and store weighted mean
(m.vmax <- c(m1.vmax, m2.vmax, m3.vmax)) # vector for means
(sd.vmax <- c(sd1.vmax, sd2.vmax, sd3.vmax)) # vector for sds
(n.vmax <- c(n1.vmax, n2.vmax, n3.vmax)) # vector for n
(wm.vmax <- weighted.mean(m.vmax, n.vmax))
(wm.vmax <- round(wm.vmax, 2))

# pooled SD
(pooledsd.vmax <- calculate_pooled_sd(sd.vmax, n.vmax))
(pooledsd.vmax <- round(pooledsd.vmax, 2))

# Calculate sesoi for maximal sprinting speed
(sesoi.vmax <- (wm.vmax * 1.05) - wm.vmax) # make sure it is multiplier
(sesoi.vmax <- round(sesoi.vmax, 2))

# No covariate-outcome relationship available from Thurlow et al. (2024)
# Therefore, use 20 m (r.20)

# mss ancova power calculation
(res.vmax <- power_oneway_ancova(
  mu = c(0, sesoi.vmax),
  n_cov = 1,
  sd = pooledsd.vmax,
  r2 = r.20^2,
  alpha_level = .05,
  beta_level = .2,
  round_up = TRUE,
  type = "exact"
))

# dropout correction (20%)
(ss.vmax <- (res.vmax$N / (1 - 0.20)))

# Sensitivity analyses
# Set common parameters for the max sprinting speed ANCOVA
n_per_group <- 11
n_groups <- 2
n_covariates <- 1
sd_val <- pooledsd.vmax
r2_val <- r.20^2
alpha_level <- 0.05

# Define a set of 'mu' vectors to test
(mu_scenarios <- list(
  c(0.00, 0.225),
  c(0.00, 0.25),
  c(0.00, 0.275),
  c(0.00, 0.30),
  c(0.00, 0.325),
  c(0.00, 0.35),
  c(0.00, 0.375),
  c(0.00, 0.40),
  c(0.00, 0.425),
  c(0.00, 0.45),
  c(0.00, 0.475),
  c(0.00, 0.50),
  c(0.00, 0.525),
  c(0.00, 0.55),
  c(0.00, 0.575),
  c(0.00, 0.60),
  c(0.00, 0.625),
  c(0.00, 0.65),
  c(0.00, 0.675),
  c(0.00, 0.70)
))

# Create a data frame to store results
sensitivity.vmax <- data.frame(
  scenario = character(),
  baseline = numeric(),
  target = numeric(),
  power = numeric(),
  stringsAsFactors = FALSE
)

# Run the analysis for each mu scenario
for (i in 1:length(mu_scenarios)) {
  current_mu <- mu_scenarios[[i]]

  result <- power_oneway_ancova(
    n = rep(n_per_group, n_groups), # Create a vector of sample sizes
    mu = current_mu,
    n_cov = n_covariates,
    sd = sd_val,
    r2 = r2_val,
    alpha_level = alpha_level,
    type = "exact"
  )

  # Add the results to the data frame
  sensitivity.vmax[i, ] <- c(
    paste("Scenario", i),
    current_mu[1],
    current_mu[2],
    result$power
  )
}
sensitivity.vmax

# Change chr to numeric
(sensitivity.vmax <- sensitivity.vmax %>%
  mutate_at(c('target', 'power'), as.numeric))

# critical effect size is scenario 13, 0.525 m.s
(critical.vmax <- sensitivity.vmax[13, 3])
# compare
sesoi.vmax

# plot curve with data from critical.max and sesoi.max
(vmax <- sensitivity.vmax |>
  ggplot(aes(target, power)) +
  geom_line() +
  annotate(
    "segment",
    x = 0.2,
    xend = 0.515,
    y = 80,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # 80% power
  annotate(
    "segment",
    x = 0.515,
    xend = 0.515,
    y = 0,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # critical es
  annotate(
    "segment",
    x = 0.46,
    xend = 0.46,
    y = 0,
    yend = 70,
    colour = "green",
    size = 1.5
  ) + # sesoi
  coord_capped_cart(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(from = 0, to = 100, by = 10)
  ) +
  scale_x_continuous(
    limits = c(0.2, 0.7),
    breaks = seq(from = 0.2, to = 0.7, by = 0.1)
  ) +
  labs(y = "Power", x = "VMax Target Change (m.s-1)") +
  easy_all_text_colour("black") +
  theme(axis.title.x = element_text(vjust = -1)))

# CMJ (cm) ----
# create dataframe with the pre and change values from Thurlow et al. (2024)
# using only the most common cmj method, i.e., Optojump n = 9 studies
(df.cmj <- data.frame(
  pre.test = c(35.76, 43.87, 47.1, 35.5, 39.96, 29.4, 41.9, 36.6, 34.7),
  pre.test.sd = c(5.26, 6.88, 4.4, 5.8, 5.11, 6.4, 3.8, 4.4, 10.0),
  post.test = c(37.38, 39.0, 49.3, 38.0, 40.86, 30.5, 42.53, 37.33, 35.5),
  post.test.sd = c(5.32, 7.76, 2.6, 7.0, 5.2, 6.8, 3.58, 5.38, 8.6),
  study.n = c(8, 8, 8, 7, 21, 12, 8, 7, 16)
))

# create change score
(df.cmj <- df.cmj |> mutate(change = post.test - pre.test))

# get and store weighted pre test mean
(m.cmj <- df.cmj$pre.test) # vector for means
(sd.cmj <- df.cmj$pre.test.sd) # vector for sds
(n.cmj <- df.cmj$study.n) # vector for n
(wm.cmj <- weighted.mean(m.cmj, n.cmj))
(wm.cmj <- round(wm.cmj, 2))

# get pooled pre test sd
(pooledsd.cmj <- calculate_pooled_sd(sd.cmj, n.cmj))
(pooledsd.cmj <- round(pooledsd.cmj, 1))

# calculate target change
(target.cmj <- wm.cmj + sesoi.cmj)

# calculate pre-post test correlation
cor.cmj <- correlation(df.cmj, select = "pre.test", select2 = "change")
(r.cmj <- cor.cmj$r) # save r value

# cmj ancova power calculation
(res.cmj <- power_oneway_ancova(
  mu = c(0, sesoi.cmj),
  n_cov = 1,
  sd = pooledsd.cmj,
  r2 = r.cmj^2,
  alpha_level = .05,
  beta_level = .2,
  round_up = TRUE,
  type = "exact"
))

# dropout correction
(ss.cmj <- (res.cmj$N / (1 - 0.20)))

# Sensitivity analyses
# Set common parameters for the CMJ ANCOVA
n_per_group <- 11
n_groups <- 2
n_covariates <- 1
sd_val <- pooledsd.cmj
r2_val <- r.cmj^2
alpha_level <- 0.05

# Define a set of 'mu' vectors to test
(mu_scenarios <- list(
  c(0.00, 0.50),
  c(0.00, 1.00),
  c(0.00, 1.50),
  c(0.00, 2.00),
  c(0.00, 2.50),
  c(0.00, 3.00),
  c(0.00, 3.50),
  c(0.00, 4.00),
  c(0.00, 4.50),
  c(0.00, 5.00),
  c(0.00, 5.50),
  c(0.00, 6.00),
  c(0.00, 6.50),
  c(0.00, 7.00),
  c(0.00, 7.50),
  c(0.00, 8.00),
  c(0.00, 8.50),
  c(0.00, 9.00),
  c(0.00, 9.50),
  c(0.00, 10.00)
))

# Create a data frame to store results
sensitivity.cmj <- data.frame(
  scenario = character(),
  baseline = numeric(),
  target = numeric(),
  power = numeric(),
  stringsAsFactors = FALSE
)

# Run the analysis for each mu scenario
for (i in 1:length(mu_scenarios)) {
  current_mu <- mu_scenarios[[i]]

  result <- power_oneway_ancova(
    n = rep(n_per_group, n_groups), # Create a vector of sample sizes
    mu = current_mu,
    n_cov = n_covariates,
    sd = sd_val,
    r2 = r2_val,
    alpha_level = alpha_level,
    type = "exact"
  )

  # Add the results to the data frame
  sensitivity.cmj[i, ] <- c(
    paste("Scenario", i),
    current_mu[1],
    current_mu[2],
    result$power
  )
}
sensitivity.cmj

# Change chr to numeric
(sensitivity.cmj <- sensitivity.cmj %>%
  mutate_at(c('target', 'power'), as.numeric))

# critical effect size is scenario 16, 8.0 cm
(critical.cmj <- sensitivity.cmj[16, 3])
# compare
sesoi.cmj

# plot curve with data from critical.cmj and sesoi.cmj
(cmj <- sensitivity.cmj |>
  ggplot(aes(target, power)) +
  geom_line() +
  annotate(
    "segment",
    x = 0,
    xend = 7.85,
    y = 80,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # 80% power
  annotate(
    "segment",
    x = 7.85,
    xend = 7.85,
    y = 0,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # critical es
  annotate(
    "segment",
    x = 2.8,
    xend = 2.8,
    y = 0,
    yend = 16.8,
    colour = "green",
    size = 1.5
  ) + # sesoi
  coord_capped_cart(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(from = 0, to = 100, by = 10)
  ) +
  scale_x_continuous(
    limits = c(0.0, 10.0),
    breaks = seq(from = 0.0, to = 10.0, by = 1.0)
  ) +
  labs(x = "CMJ Target Change (cm)", y = "Power")) +
  easy_all_text_colour("black") +
  theme(axis.title.x = element_text(vjust = -1))

# Maximal aerobic speed ----
# get and store max velocity data from Tønnessen et al. (2013)
(m1.mas <- 16.2) # forwards
(sd1.mas <- 1.0) # forwards
(n1.mas <- 167) # forwards
(m2.mas <- 16.3) # defenders
(sd2.mas <- 0.9) # defenders
(n2.mas <- 237) # defenders
(m3.mas <- 16.4) # midfielders
(sd3.mas <- 0.9) # midfielders
(n3.mas <- 253) # midfielders

# get and store weighted mean
(m.mas <- c(m1.mas, m2.mas, m3.mas)) # vector for means
(sd.mas <- c(sd1.mas, sd2.mas, sd3.mas)) # vector for sds
(n.mas <- c(n1.mas, n2.mas, n3.mas)) # vector for n
(wm.mas <- weighted.mean(m.mas, n.mas))
(wm.mas <- round(wm.mas, 2))
# convert to m.s
(wm.mas <- (wm.mas / 3.6))
(wm.mas <- round(wm.mas, 2))

# pooled SD
(pooledsd.mas <- calculate_pooled_sd(sd.mas, n.mas))
(pooledsd.mas <- round(pooledsd.mas, 2))
# convert to m.s
(pooledsd.mas <- (pooledsd.mas / 3.6)) # convert to m.s
(pooledsd.mas <- round(pooledsd.mas, 2))

# YYIR1 data from Thurlow et al. (2024)

# Get the covariate-outcome relationship from Thurlow et al. (2024)
(df.yoyo <- data.frame(
  pre.test = c(
    1105,
    1092,
    1642,
    1686,
    2472,
    2500,
    1917,
    1667,
    1792,
    2307,
    1832,
    1029,
    1515,
    1350,
    1455,
    1764,
    914,
    1830,
    1691,
    605
  ),
  pre.test.sd = c(
    314,
    238,
    365,
    359,
    223,
    246,
    440,
    441,
    209,
    252,
    310,
    273,
    275,
    450,
    188,
    334,
    330,
    274,
    600,
    233
  ),
  post.test = c(
    1435,
    1441,
    1822,
    1811,
    2604,
    2696,
    2455,
    1852,
    2065,
    2480,
    2216,
    1303,
    1612,
    1725,
    1677,
    1798,
    985,
    2270,
    2183,
    775
  ),
  post.test.sd = c(
    376,
    271,
    461,
    260,
    362,
    344,
    493,
    499,
    331,
    159,
    395,
    211,
    290,
    479,
    308,
    335,
    337,
    294,
    645,
    242
  ),
  study.n = c(
    18,
    18,
    18,
    18,
    10,
    10,
    13,
    8,
    8,
    9,
    5,
    7,
    13,
    9,
    12,
    10,
    10,
    8,
    7,
    8
  )
))

(df.yoyo <- df.yoyo |> mutate(change = post.test - pre.test))

# Calculate pre-post test correlation
plot(cor_test(df.yoyo, "pre.test", "change")) # view relationship
cor.yoyo <- correlation(df.yoyo, select = "pre.test", select2 = "change")
(r.yoyo <- cor.yoyo$r) # save r value

# mss ancova power calculation
(res.mas <- power_oneway_ancova(
  mu = c(0, sesoi.mas),
  n_cov = 1,
  sd = pooledsd.mas,
  r2 = r.yoyo^2,
  alpha_level = .05,
  beta_level = .2,
  round_up = TRUE,
  type = "exact"
))

# dropout correction (20%)
(ss.mas <- (res.mas$N / (1 - 0.20)))

# Sensitivity analyses
# Set common parameters for the MAS ANCOVA
n_per_group <- 11
n_groups <- 2
n_covariates <- 1
sd_val <- pooledsd.mas
r2_val <- r.yoyo^2
alpha_level <- 0.05

# Define a set of 'mu' vectors to test
(mu_scenarios <- list(
  c(0.00, 0.02),
  c(0.00, 0.04),
  c(0.00, 0.06),
  c(0.00, 0.08),
  c(0.00, 0.10),
  c(0.00, 0.12),
  c(0.00, 0.14),
  c(0.00, 0.16),
  c(0.00, 0.18),
  c(0.00, 0.20),
  c(0.00, 0.22),
  c(0.00, 0.24),
  c(0.00, 0.26),
  c(0.00, 0.28),
  c(0.00, 0.30),
  c(0.00, 0.32),
  c(0.00, 0.34),
  c(0.00, 0.36),
  c(0.00, 0.38),
  c(0.00, 0.40)
))

# Create a data frame to store results
sensitivity.mas <- data.frame(
  scenario = character(),
  baseline = numeric(),
  target = numeric(),
  power = numeric(),
  stringsAsFactors = FALSE
)

# Run the analysis for each mu scenario
for (i in 1:length(mu_scenarios)) {
  current_mu <- mu_scenarios[[i]]

  result <- power_oneway_ancova(
    n = rep(n_per_group, n_groups), # Create a vector of sample sizes
    mu = current_mu,
    n_cov = n_covariates,
    sd = sd_val,
    r2 = r2_val,
    alpha_level = alpha_level,
    type = "exact"
  )

  # Add the results to the data frame
  sensitivity.mas[i, ] <- c(
    paste("Scenario", i),
    current_mu[1],
    current_mu[2],
    result$power
  )
}
sensitivity.mas

# Change chr to numeric
(sensitivity.mas <- sensitivity.mas %>%
  mutate_at(c('target', 'power'), as.numeric))

# critical effect size is scenario 17, 0.34 m.s
(critical.mas <- sensitivity.mas[17, 3])
# compare
sesoi.mas

# plot curve with data from critical.mas and sesoi.mas
(mas <- sensitivity.mas |>
  ggplot(aes(target, power)) +
  geom_line() +
  annotate(
    "segment",
    x = 0,
    xend = 0.335,
    y = 80,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # 80% power
  annotate(
    "segment",
    x = 0.335,
    xend = 0.335,
    y = 0,
    yend = 80,
    colour = "red",
    size = 1.5
  ) + # critical es
  annotate(
    "segment",
    x = 0.13,
    xend = 0.13,
    y = 0,
    yend = 19,
    colour = "green",
    size = 1.5
  ) + # sesoi
  coord_capped_cart(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(from = 0, to = 100, by = 10)
  ) +
  scale_x_continuous(
    limits = c(0.0, 0.4),
    breaks = seq(from = 0.0, to = 0.4, by = 0.05)
  ) +
  labs(y = "Power", x = "MAS Target Change (m.s-1)") +
  easy_all_text_colour("black") +
  theme(axis.title.x = element_text(vjust = -2)))

ten + twenty + forty + vmax + cmj + mas
#### print
ggsave("figure 1.svg", width = 30, height = 15, units = "cm")
