# =============================================================================
# ANCOVA Statistical Analysis for Fitness Outcomes
# =============================================================================
# This script contains all statistical modeling and diagnostics.
# Figure generation is handled separately in ancova_figures.R
#
# Contents:
#   1. Setup and data loading
#   2. Data preparation and descriptives
#   3. ANCOVA models for each outcome (10m, 20m, 40m, VMax, CMJ, MAS)
#   4. Model diagnostics and assumption checks
#   5. Robust standard error models where needed
#
# Note: This script is sourced by ancova_figures.R
# =============================================================================

rm(list = ls())

# Load required libraries ----
library(readxl)
library(dplyr)
library(tidyverse)
library(lme4)
library(performance)
library(broom.mixed)
library(modelbased)
library(estimatr)
library(visdat)

# setwd ----
# Please pull or clone the repo and set wd as your local directory if using
# RStudio. If using VSCode or Positron, then clone the project or download
# the zip file and open it as a folder from the file menu.

# =============================================================================
# 1. DATA LOADING AND PREPARATION
# =============================================================================

# Load data
df <- read_csv("data/ANCOVA Final.csv")

# Create change scores
(df <- df |> mutate(Change = Post - Pre))

# Rename groups
df$Group <- df$Group |>
  dplyr::case_match("10-sec" ~ "Group 1", "20-sec" ~ "Group 2")

# Check for missing data
vis_miss(df)

# =============================================================================
# 2. DESCRIPTIVES
# =============================================================================

df |>
  group_by(Test, Group) |>
  summarise(
    mean = round(mean(Pre, na.rm = TRUE), 3),
    sd = round(sd(Change, na.rm = TRUE), 3),
    min = round(min(Change, na.rm = TRUE), 3),
    max = round(max(Change, na.rm = TRUE), 3),
    n = n()
  )

# =============================================================================
# 3. ANCOVA MODELS
# =============================================================================

# -----------------------------------------------------------------------------
# 10m Sprint ANCOVA
# -----------------------------------------------------------------------------
df.10 <- df |> filter(Test == "Time_10m")
(lm.10m <- lm(Change ~ Pre + Group, data = df.10))

# Estimated marginal means & contrast
(means.10m <- estimate_means(lm.10m, by = "Group"))
(difference.10m <- estimate_contrasts(lm.10m, contrast = "Group", length = 1))

# Diagnostics
plot(density(lm.10m$residuals))
fitted.10 <- augment(lm.10m)

# Assumption checks
check_heteroscedasticity(lm.10m) # fine
check_normality(lm.10m) # fine

# Outlier check
(out.df10 <- check_outliers(df.10, method = "zscore_robust", ID = "ID"))
# fine to proceed with all data as change of -0.02 is plausible
(out.lm.10m <- check_outliers(lm.10m, method = "cook"))
# none impacting the model

# -----------------------------------------------------------------------------
# 20m Sprint ANCOVA
# -----------------------------------------------------------------------------
df.20 <- df |> filter(Test == "Time_20m")
(lm.20m <- lm(Change ~ Pre + Group, data = df.20))

# Estimated marginal means & contrast
(means.20m <- estimate_means(lm.20m, by = "Group"))
(difference.20m <- estimate_contrasts(lm.20m, contrast = "Group"))

# Diagnostics
plot(density(lm.20m$residuals))
fitted.20 <- augment(lm.20m)

# Assumption checks
check_heteroscedasticity(lm.20m) # fine, just....
check_normality(lm.20m) # less so

# Outlier check
(out.df.20 <- check_outliers(df.20, method = "zscore_robust", ID = "ID"))
# fine to proceed with all data as -0.18 change is plausible
(out.lm.20m <- check_outliers(lm.20m, method = "cook"))
plot(out.lm.20m)
# 22 impacting the model but barely and data plausible

# Rerun model with robust SE estimates (used for figures)
(lm.20m_r <- lm_robust(Change ~ Pre + Group, data = df.20, se_type = "stata"))
tidy(lm.20m, conf.int = T)
tidy(lm.20m_r, conf.int = T) # use

# -----------------------------------------------------------------------------
# 40m Sprint ANCOVA
# -----------------------------------------------------------------------------
df.40 <- df |> filter(Test == "Time_40m")
(lm.40m <- lm(Change ~ Pre + Group, data = df.40))

# Estimated marginal means & contrast
(means.40m <- estimate_means(lm.40m, by = "Group"))
(difference.40m <- estimate_contrasts(lm.40m, contrast = "Group"))

# Diagnostics
plot(density(lm.40m$residuals))
fitted.40 <- augment(lm.40m)

# Assumption checks
check_heteroscedasticity(lm.40m) # not good
check_normality(lm.40m) # not good

# Outlier check
(out.df.40 <- check_outliers(df.40, method = "zscore_robust", ID = "ID"))
# values are plausible
(out.lm.40m <- check_outliers(lm.40m, method = "cook"))
plot(out.lm.40m)
# 22 again impacting the model but data plausible

# Rerun model with robust SE estimates (used for figures)
(lm.40m_r <- lm_robust(Change ~ Pre + Group, data = df.40, se_type = "stata"))
tidy(lm.40m, conf.int = T)
tidy(lm.40m_r, conf.int = T) # use these

# -----------------------------------------------------------------------------
# VMax ANCOVA
# -----------------------------------------------------------------------------
df.vmax <- df |> filter(Test == "Max_Velocity")
(lm.vmax <- lm(Change ~ Pre + Group, data = df.vmax))

# Estimated marginal means & contrast
(means.vmax <- estimate_means(lm.vmax, by = "Group"))
(difference.vmax <- estimate_contrasts(lm.vmax, contrast = "Group"))

# Diagnostics
plot(density(lm.vmax$residuals))
fitted.vmax <- augment(lm.vmax)

# Assumption checks
check_heteroscedasticity(lm.vmax) # not fine
check_normality(lm.vmax) # fine

# Outlier check
(out.df.vmax <- check_outliers(df.vmax, method = "zscore_robust", ID = "ID"))
# value is large but plausible given intervention and time.
(out.lm.vmax <- check_outliers(lm.vmax, method = "cook"))
# none detected

# Rerun model with robust SE estimates (used for figures)
(lm.vmax_r <- lm_robust(
  Change ~ Pre + Group,
  data = df.vmax,
  se_type = "stata"
))
tidy(lm.vmax, conf.int = T)
tidy(lm.vmax_r, conf.int = T) # use these

# -----------------------------------------------------------------------------
# CMJ ANCOVA
# -----------------------------------------------------------------------------
df.cmj <- df |> filter(Test == "CMJH")
(lm.cmj <- lm(Change ~ Pre + Group, data = df.cmj))

# Estimated marginal means & contrast
(means.cmj <- estimate_means(lm.cmj, by = "Group"))
(difference.cmj <- estimate_contrasts(lm.cmj, contrast = "Group"))

# Diagnostics
plot(density(lm.cmj$residuals))
fitted.cmj <- augment(lm.cmj)

# Assumption checks
check_heteroscedasticity(lm.cmj) # not fine
check_normality(lm.cmj) # not fine

# Outlier check
(out.df.cmj <- check_outliers(df.cmj, method = "zscore_robust", ID = "ID"))
# value is large but plausible given intervention and time.
(out.lm.cmj <- check_outliers(lm.cmj, method = "cook"))
# none detected

# Rerun model with robust SE estimates (used for figures)
(lm.cmj_r <- lm_robust(Change ~ Pre + Group, data = df.cmj, se_type = "stata"))
tidy(lm.cmj, conf.int = T)
tidy(lm.cmj_r, conf.int = T) # little impact here

# -----------------------------------------------------------------------------
# MAS ANCOVA
# -----------------------------------------------------------------------------
df.mas <- df |> filter(Test == "MAS")
(lm.mas <- lm(Change ~ Pre + Group, data = df.mas))

# Estimated marginal means & contrast
# NOTE: Bug fix applied - previously incorrectly used lm.cmj instead of lm.mas
(means.mas <- estimate_means(lm.mas, by = "Group"))
(difference.mas <- estimate_contrasts(lm.mas, contrast = "Group"))

# Diagnostics
plot(density(lm.mas$residuals))
fitted.mas <- augment(lm.mas)

# Assumption checks
check_heteroscedasticity(lm.mas) # fine
check_normality(lm.mas) # fine

# Outlier check
(out.df.mas <- check_outliers(df.mas, method = "zscore_robust", ID = "ID"))
# value is large but plausible given intervention and time.
(out.lm.mas <- check_outliers(lm.mas, method = "cook"))
# none detected

# =============================================================================
# 4. SUMMARY OF MODELS AVAILABLE FOR FIGURES
# =============================================================================
# The following model objects are available for use in ancova_figures.R:
#
# Standard models:
#   - lm.10m (10m sprint)
#   - lm.20m (20m sprint)
#   - lm.40m (40m sprint)
#   - lm.vmax (VMax)
#   - lm.cmj (CMJ)
#   - lm.mas (MAS)
#
# Robust SE models (used for figures where assumptions violated):
#   - lm.20m_r (20m sprint - robust)
#   - lm.40m_r (40m sprint - robust)
#   - lm.vmax_r (VMax - robust)
#   - lm.cmj_r (CMJ - robust)
#
# Data objects:
#   - df (main data with change scores)
#   - df.10, df.20, df.40, df.vmax, df.cmj, df.mas (filtered datasets)
#   - fitted.10, fitted.20, fitted.40, fitted.vmax, fitted.cmj, fitted.mas
# =============================================================================
