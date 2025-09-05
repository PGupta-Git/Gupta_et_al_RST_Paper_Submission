# ANCOVA analyses for fitness outcomes ----

rm(list = ls())

library(readxl)
library(patchwork)
library(dplyr)
library(tidyverse)
library(lme4)
library(performance)
library(broom.mixed)
library(modelbased)
library(sjPlot)
library(lemon)
library(estimatr)
library(ggeasy)
library(ggrain)
library(ggdist)
library(ggtext)
library(visdat)

# setwd ----
# Please pull or clone the repo and set wd as your local directory if using RStudio. If using VSCode or Positron, then clone the project or download the zip file and open it as a folder from the file menu.

# set theme
theme_set(theme_classic())

# Load data
df <- read_csv("data/ANCOVA Final.csv")

# Create change scores
(df <- df |> mutate(Change = Post - Pre))

# Rename groups
df$Group <- df$Group |>
  dplyr::case_match("10-sec" ~ "Group 1", "20-sec" ~ "Group 2")

# Check for missing data
vis_miss(df)

# Descriptives ----
df |>
  group_by(Test, Group) |>
  summarise(
    mean = round(mean(Pre, na.rm = TRUE), 3),
    sd = round(sd(Change, na.rm = TRUE), 3),
    min = round(min(Change, na.rm = TRUE), 3),
    max = round(max(Change, na.rm = TRUE), 3),
    n = n()
  )

# Raincloud plots for pre and post test data ----
data <- read_csv("data/ANCOVA Final Long.csv")
data <- data |>
  mutate(across(c(Group, ID, Timeline, Test), as_factor))

data$Group <- data$Group |>
  dplyr::case_match("10-sec" ~ "Group 1", "20-sec" ~ "Group 2")
data$Group <- factor(data$Group, levels = c("Group 1", "Group 2"))

custom_labels <- c(
  "Time_10m" = "10 m Sprint Time (sec)",
  "Time_20m" = "20 m Sprint Time (sec)",
  "Time_40m" = "40 m Sprint Time (sec)",
  "Max_Velocity" = "VMax (m·s<sup>-1</sup>)",
  "MAS" = "MAS (m·s<sup>-1</sup>)",
  "CMJH" = "CMJ (cm)"
)

cbp <- c("#C84E00", "#012169")

data_positioned <- data |>
  mutate(
    x_points = case_when(
      Timeline == "Pre" & Group == "Group 1" ~ 0.7,
      Timeline == "Pre" & Group == "Group 2" ~ 0.7,
      Timeline == "Post" & Group == "Group 1" ~ 2.3,
      Timeline == "Post" & Group == "Group 2" ~ 2.3
    ),
    x_boxes = case_when(
      Timeline == "Pre" & Group == "Group 1" ~ 0.15,
      Timeline == "Pre" & Group == "Group 2" ~ 0.45,
      Timeline == "Post" & Group == "Group 1" ~ 2.55,
      Timeline == "Post" & Group == "Group 2" ~ 2.85
    ),
    x_violins = case_when(
      Timeline == "Pre" & Group == "Group 1" ~ 0,
      Timeline == "Pre" & Group == "Group 2" ~ 0,
      Timeline == "Post" & Group == "Group 1" ~ 3,
      Timeline == "Post" & Group == "Group 2" ~ 3
    )
  )

mean_data <- data |>
  group_by(Test, Group, Timeline) |>
  summarise(mean_value = mean(Value, na.rm = TRUE)) |>
  ungroup() %>%
  # Add the same x-coordinates used for the boxplots
  mutate(
    x_boxes = case_when(
      Timeline == "Pre" & Group == "Group 1" ~ 0.9,
      Timeline == "Pre" & Group == "Group 2" ~ 0.9,
      Timeline == "Post" & Group == "Group 1" ~ 2.1,
      Timeline == "Post" & Group == "Group 2" ~ 2.1
    )
  )

pre_post_plot_final <- data_positioned |>
  ggplot(aes(x = Timeline, y = Value)) +

  stat_slab(
    aes(
      x = x_violins,
      fill = Group,
      side = ifelse(Timeline == "Pre", "left", "right")
    ),
    alpha = 0.4,
    color = NA,
    scale = 0.8,
    normalize = "panels"
  ) +

  geom_line(
    aes(x = x_points, group = ID, color = Group),
    alpha = 0.2,
    linewidth = 0.8
  ) +

  geom_boxplot(
    aes(x = x_boxes, fill = Group, group = interaction(Timeline, Group)),
    alpha = 0.6,
    width = 0.3,
    outlier.shape = NA,
    color = "black",
    linewidth = 0.5
  ) +

  geom_line(
    data = mean_data,
    aes(x = x_boxes, y = mean_value, group = Group, color = Group),
    linewidth = 1.5,
    alpha = 0.6
  ) +

  geom_point(
    data = mean_data,
    aes(x = x_boxes, y = mean_value, fill = Group),
    shape = 22,
    alpha = 0.7,
    color = "black",
    size = 6,
    stroke = 0.8
  ) +

  geom_point(
    aes(x = x_points, color = Group, fill = Group),
    alpha = 0.5,
    size = 2.5,
    shape = 21,
    stroke = 0.3
  ) +

  facet_wrap(
    ~Test,
    scales = "free_y",
    labeller = labeller(Test = custom_labels),
    strip.position = "left"
  ) +

  theme_classic(base_size = 25) +
  coord_capped_cart(
    left = capped_vertical("both"),
    bottom = capped_horizontal("both")
  ) +

  labs(title = "", x = "", y = "") +

  scale_fill_manual(
    values = c(
      "Group 1" = "#C84E00",
      "Group 2" = "#012169"
    )
  ) +

  scale_colour_manual(
    values = c("Group 1" = "#C84E00", "Group 2" = "#012169")
  ) +

  scale_x_continuous(
    breaks = c(0, 3),
    labels = c("Pre", "Post")
  ) +

  theme(legend.key.size = unit(1, "cm")) +
  theme(strip.text = element_markdown(face = "plain")) +
  theme(legend.position = "top") +
  theme(
    strip.placement = "outside",
    strip.background = element_blank()
  )

pre_post_plot_final

ggsave("figure 4.svg", dpi = 300, width = 40, height = 25, units = "cm")

# 10m ancova ----
df.10 <- df |> filter(Test == "Time_10m") # separate dataframe for 10m
(lm.10m <- lm(Change ~ Pre + Group, data = df.10))

# get estimated marginal means & the contrast
(means.10m <- estimate_means(lm.10m, by = "Group"))
(difference.10m <- estimate_contrasts(lm.10m, contrast = "Group", length = 1))

# Check residuals/errors
plot(density(lm.10m$residuals))

# Look at relationship between fitted values and residuals
fitted.10 <- augment(lm.10m)
ggplot(fitted.10, aes(x = .fitted, y = .resid)) +
  geom_point(aes(color = Group)) +
  geom_smooth(method = "lm") # generally OK and no clustering

# Histogram
ggplot(fitted.10, aes(x = .resid)) +
  geom_histogram(binwidth = 0.05, color = "white") # nice

# Test checks
check_heteroscedasticity(lm.10m) # fine
check_normality(lm.10m) # fine

# Outlier check
(out.df10 <- check_outliers(df.10, method = "zscore_robust", ID = "ID"))
# fine to proceed with all data as change of -0.02 is plausible
(out.lm.10m <- check_outliers(lm.10m, method = "cook"))
# none impacting the model

# 10 m model plots ----
(ancova.10 <- plot_model(
  lm.10m,
  type = "est",
  title = "",
  show.intercept = F,
  vline.color = "grey50",
  show.p = T,
  sort.est = F,
  colors = c("#012169"),
  ci.style = "whisker",
  value.offset = 0.2,
  jitter = 0.5,
  show.values = T,
  axis.title = "10 m Sprint Effects (sec)",
  value.size = 7,
  digits = 2,
  dot.size = 2,
  prefix.labels = "none"
) +
  coord_capped_flip(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(-1.0, 1.0),
    breaks = seq(from = -1.0, to = 1.0, by = 0.4)
  ) +
  easy_all_text_size(20) +
  easy_all_text_colour("black") +
  theme(
    axis.title.x = element_text(vjust = -0.5),
    panel.border = element_blank(),
    axis.line = element_line()
  ))


# 20m ancova ----
df.20 <- df |> filter(Test == "Time_20m") # separate dataframe for 20m
(lm.20m <- lm(Change ~ Pre + Group, data = df.20))

# get estimated marginal means & the contrast
(means.20m <- estimate_means(lm.20m, by = "Group"))
(difference.20m <- estimate_contrasts(lm.20m, contrast = "Group"))

# Check residuals/errors
plot(density(lm.20m$residuals))

# Look at relationship between fitted values and residuals
fitted.20 <- augment(lm.20m)
ggplot(fitted.20, aes(x = .fitted, y = .resid)) +
  geom_point(aes(color = Group)) +
  geom_smooth(method = "lm") # bottom left?

# Histogram
ggplot(fitted.20, aes(x = .resid)) +
  geom_histogram(binwidth = 0.05, color = "white")

# Test checks
check_heteroscedasticity(lm.20m) # fine, just....
check_normality(lm.20m) # less so

# Outlier check
(out.df.20 <- check_outliers(df.20, method = "zscore_robust", ID = "ID"))
# fine to proceed with all data as -0.18 change is plausible
(out.lm.20m <- check_outliers(lm.20m, method = "cook"))
plot(out.lm.20m)
# 22 impacting the model but barely and data plausible

# rerun model with robust se estimates
(lm.20m_r <- lm_robust(Change ~ Pre + Group, data = df.20, se_type = "stata"))
tidy(lm.20m, conf.int = T)
tidy(lm.20m_r, conf.int = T) # use

# 20 m model plots ----
(ancova.20 <- plot_model(
  lm.20m_r,
  type = "est",
  title = "",
  show.intercept = F,
  vline.color = "grey50",
  show.p = T,
  sort.est = F,
  colors = c("#012169"),
  ci.style = "whisker",
  value.offset = 0.2,
  jitter = 0.5,
  show.values = T,
  axis.title = "20 m Sprint Effects (sec)",
  value.size = 7,
  digits = 2,
  dot.size = 2,
  prefix.labels = "none"
) +
  coord_capped_flip(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(-1.0, 1.0),
    breaks = seq(from = -1.0, to = 1.0, by = 0.4)
  ) +
  easy_all_text_size(20) +
  easy_all_text_colour("black") +
  theme(axis.title.x = element_text(vjust = -0.5)))


# 40m ancova ----
df.40 <- df |> filter(Test == "Time_40m") # separate dataframe for 40m
(lm.40m <- lm(Change ~ Pre + Group, data = df.40))

# get estimated marginal means & the contrast
(means.40m <- estimate_means(lm.40m, by = "Group"))
(difference.40m <- estimate_contrasts(lm.40m, contrast = "Group"))

# Check residuals/errors
plot(density(lm.40m$residuals))

# Look at relationship between fitted values and residuals
fitted.40 <- augment(lm.40m)
ggplot(fitted.40, aes(x = .fitted, y = .resid)) +
  geom_point(aes(color = Group)) +
  geom_smooth(method = "lm") # bottom left again

# Histogram
ggplot(fitted.40, aes(x = .resid)) +
  geom_histogram(binwidth = 0.05, color = "white")

# Test checks
check_heteroscedasticity(lm.40m) # not good
check_normality(lm.40m) # not good

# Outlier check
(out.df.40 <- check_outliers(df.40, method = "zscore_robust", ID = "ID"))
# values are plausible
(out.lm.40m <- check_outliers(lm.40m, method = "cook"))
plot(out.lm.40m)
# 22 again impacting the model but data plausible

# rerun model with robust se estimates
(lm.40m_r <- lm_robust(Change ~ Pre + Group, data = df.40, se_type = "stata"))
tidy(lm.40m, conf.int = T)
tidy(lm.40m_r, conf.int = T) # use these

# 40 m model plots ----
(ancova.40 <- plot_model(
  lm.40m_r,
  type = "est",
  title = "",
  show.intercept = F,
  vline.color = "grey50",
  show.p = T,
  sort.est = F,
  colors = c("#012169"),
  ci.style = "whisker",
  value.offset = 0.2,
  jitter = 0.5,
  show.values = T,
  axis.title = "40 m Sprint Effects (sec)",
  value.size = 7,
  digits = 2,
  dot.size = 2,
  prefix.labels = "none"
) +
  coord_capped_flip(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(-1.0, 1.0),
    breaks = seq(from = -1.0, to = 1.0, by = 0.4)
  ) +
  easy_all_text_size(20) +
  easy_all_text_colour("black") +
  theme(axis.title.x = element_text(vjust = -0.5)))


# Vmax ancova ----
df.vmax <- df |> filter(Test == "Max_Velocity") # separate dataframe for Vmax
(lm.vmax <- lm(Change ~ Pre + Group, data = df.vmax))

# get estimated marginal means & the contrast
(means.vmax <- estimate_means(lm.vmax, by = "Group"))
(difference.vmax <- estimate_contrasts(lm.vmax, contrast = "Group"))

# Check residuals/errors
plot(density(lm.vmax$residuals))

# Look at relationship between fitted values and residuals
fitted.vmax <- augment(lm.vmax)
ggplot(fitted.vmax, aes(x = .fitted, y = .resid)) +
  geom_point(aes(color = Group)) +
  geom_smooth(method = "lm") # fine (ish)

# Histogram
ggplot(fitted.vmax, aes(x = .resid)) +
  geom_histogram(binwidth = 0.05, color = "white") # fine (ish)

# Test checks
check_heteroscedasticity(lm.vmax) # not fine
check_normality(lm.vmax) # fine

# Outlier check
(out.df.vmax <- check_outliers(df.vmax, method = "zscore_robust", ID = "ID"))
# value is large but plausible given intervention and time.
(out.lm.vmax <- check_outliers(lm.vmax, method = "cook"))
# none detected

# rerun model with robust se estimates
(lm.vmax_r <- lm_robust(
  Change ~ Pre + Group,
  data = df.vmax,
  se_type = "stata"
))
tidy(lm.vmax, conf.int = T)
tidy(lm.vmax_r, conf.int = T) # use these

# Vmax plots ----
(ancova.max <- plot_model(
  lm.vmax_r,
  type = "est",
  title = "",
  show.intercept = F,
  vline.color = "grey50",
  show.p = T,
  sort.est = F,
  colors = c("#012169"),
  ci.style = "whisker",
  value.offset = 0.2,
  jitter = 0.5,
  show.values = T,
  value.size = 7,
  digits = 2,
  dot.size = 2,
  prefix.labels = "none"
) +
  coord_capped_flip(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(-1.0, 1.0),
    breaks = seq(from = -1.0, to = 1.0, by = 0.4)
  ) +
  easy_all_text_size(20) +
  easy_all_text_colour("black") +
  ylab(expression(VMax ~ Effects ~ (m.s^-1))) +
  theme(axis.title.x = element_text(vjust = -0.5)))


# CMJ ancova ----
df.cmj <- df |> filter(Test == "CMJH") # separate dataframe for CMJ
(lm.cmj <- lm(Change ~ Pre + Group, data = df.cmj))

# get estimated marginal means & the contrast
(means.cmj <- estimate_means(lm.cmj, by = "Group"))
(difference.cmj <- estimate_contrasts(lm.cmj, contrast = "Group"))

# Check residuals/errors
plot(density(lm.cmj$residuals))

# Look at relationship between fitted values and residuals
fitted.cmj <- augment(lm.cmj)
ggplot(fitted.cmj, aes(x = .fitted, y = .resid)) +
  geom_point(aes(color = Group)) +
  geom_smooth(method = "lm") # top right??

# Histogram
ggplot(fitted.cmj, aes(x = .resid)) +
  geom_histogram(binwidth = 0.5, color = "white") # ditto

# Test checks
check_heteroscedasticity(lm.cmj) # not fine
check_normality(lm.cmj) # not fine

# Outlier check
(out.df.cmj <- check_outliers(df.cmj, method = "zscore_robust", ID = "ID"))
# value is large but plausible given intervention and time.
(out.lm.cmj <- check_outliers(lm.vmax, method = "cook"))
# none detected

# rerun model with robust se estimates
(lm.cmj_r <- lm_robust(Change ~ Pre + Group, data = df.cmj, se_type = "stata"))
tidy(lm.cmj, conf.int = T)
tidy(lm.cmj_r, conf.int = T) # little impact here

# CMJ model plots ----
(ancova.cmj <- plot_model(
  lm.cmj_r,
  type = "est",
  title = "",
  show.intercept = F,
  vline.color = "grey50",
  show.p = T,
  sort.est = F,
  colors = c("#012169"),
  ci.style = "whisker",
  value.offset = 0.2,
  jitter = 0.5,
  show.values = T,
  axis.title = "CMJ Effects (cm)",
  value.size = 7,
  digits = 2,
  dot.size = 2,
  prefix.labels = "none"
) +
  coord_capped_flip(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(-3.4, 2.4),
    breaks = seq(from = -3.4, to = 2.4, by = 1)
  ) +
  easy_all_text_size(20) +
  easy_all_text_colour("black") +
  theme(axis.title.x = element_text(vjust = -0.5)))


# MAS ancova ----
df.mas <- df |> filter(Test == "MAS") # separate dataframe for MAS
(lm.mas <- lm(Change ~ Pre + Group, data = df.mas))

# get estimated marginal means & the contrast
(means.mas <- estimate_means(lm.cmj, by = "Group"))
(difference.mas <- estimate_contrasts(lm.mas, contrast = "Group"))

# Check residuals/errors
plot(density(lm.mas$residuals))

# Look at relationship between fitted values and residuals
fitted.mas <- augment(lm.mas)
ggplot(fitted.mas, aes(x = .fitted, y = .resid)) +
  geom_point(aes(color = Group)) +
  geom_smooth(method = "lm") # top right?

# Histogram
ggplot(fitted.mas, aes(x = .resid)) +
  geom_histogram(binwidth = 0.05, color = "white") # ditto

# Test checks
check_heteroscedasticity(lm.mas) # fine
check_normality(lm.mas) # fine

# Outlier check
(out.df.mas <- check_outliers(df.mas, method = "zscore_robust", ID = "ID"))
# value is large but plausible given intervention and time.
(out.lm.mas <- check_outliers(lm.mas, method = "cook"))
# none detected

# MAS model plots ----
(ancova.mas <- plot_model(
  lm.mas,
  type = "est",
  title = "",
  show.intercept = F,
  vline.color = "grey50",
  show.p = T,
  sort.est = F,
  colors = c("#012169"),
  ci.style = "whisker",
  value.offset = 0.2,
  jitter = 0.5,
  show.values = T,
  value.size = 7,
  digits = 2,
  dot.size = 2,
  prefix.labels = "none"
) +
  coord_capped_flip(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(-1.0, 1.0),
    breaks = seq(from = -1.0, to = 1.0, by = 0.4)
  ) +
  easy_all_text_size(20) +
  easy_all_text_colour("black") +
  ylab(expression(MAS ~ Effects ~ (m.s^-1))) +
  theme(axis.title.x = element_text(vjust = -0.5)))


# combine ancova plots ----
(ancova.10 | ancova.20 | ancova.40) / (ancova.max | ancova.cmj | ancova.mas)
# save
ggsave("figure 5.svg", dpi = 300, width = 45, height = 25, units = "cm")
