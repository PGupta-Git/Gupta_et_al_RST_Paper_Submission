# Analysis of training data ----

rm(list = ls())

library(readxl)
library(dplyr)
library(tidyverse)
library(ggeasy)
library(MuMIn)
library(easystats)
library(performance)
library(lme4)
library(VCA)
library(sjPlot)
library(mixedup)
library(broom.mixed)
library(naniar)
library(lemon)

# setwd ----

# set theme
theme_set(theme_classic())

# Load data
rpe <- read_csv("rpe data.csv")

# Check for missing data
n_miss(rpe)
n_complete(rpe)

# Wrangling ----
# Pivot longer
rpe <- pivot_longer(
  data = rpe,
  cols = S1_Gym_L:S12_FT_B,
  names_sep = "_",
  names_to = c("Number", "Mode", "Measure"),
  values_to = "Ratings"
)

# Rename variables
rpe <- rpe |> rename("Session" = "Number")
rpe$Group <- rpe$Group |>
  dplyr::recode("10-sec" = "Group One", "20-sec" = "Group Two")
rpe$Mode <- rpe$Mode |>
  dplyr::recode(
    "RST" = "Repeated-Sprint Training",
    "FT" = "Soccer Training",
    "Gym" = "Gym-Based Training"
  )
rpe$Measure <- rpe$Measure |> dplyr::recode("L" = "dRPE-L", "B" = "dRPE-B")
rpe$Session <- rpe$Session |>
  dplyr::recode(
    "S1" = "1",
    "S2" = "2",
    "S3" = "3",
    "S4" = "4",
    "S5" = "5",
    "S6" = "6",
    "S7" = "7",
    "S8" = "8",
    "S9" = "9",
    "S10" = "10",
    "S11" = "11",
    "S12" = "12"
  )

# Convert rpe a dataframe
rpe <- as.data.frame(rpe)

# Convert predictors to factors
rpe$ID <- as.factor(rpe$ID)
rpe$Group <- as.factor(rpe$Group)
rpe$Mode <- as.factor(rpe$Mode)
rpe$Measure <- as.factor(rpe$Measure)

# Relevel factors
rpe$Mode <- factor(
  rpe$Mode,
  levels = c(
    "Repeated-Sprint Training",
    "Match",
    "Soccer Training",
    "Gym-Based Training"
  )
)
# Make session numeric
rpe$Session <- as.numeric(rpe$Session)

#### get descriptives ----
rpe |>
  group_by(Mode) |>
  summarise(
    mean = round(mean(Ratings, na.rm = TRUE), 3),
    sd = round(sd(Ratings, na.rm = TRUE), 3),
    min = round(min(Ratings, na.rm = TRUE), 2),
    max = round(max(Ratings, na.rm = TRUE), 2),
    n = n()
  )

#### plot ----
rpe |>
  ggplot(aes(x = Session, y = Ratings, col = Mode)) +
  geom_jitter(size = 2, height = 0.05, alpha = 0.25) +
  geom_smooth(aes(fill = Mode), method = 'lm', se = F, linewidth = 1.5) +
  scale_fill_manual(values = c("red", "blue", "orange", "orchid")) +
  scale_colour_manual(values = c("red", "blue", "orange", "orchid")) +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(from = 0, to = 100, by = 10)
  ) +
  scale_x_continuous(
    limits = c(1, 12),
    breaks = seq(from = 1, to = 12, by = 1)
  ) +
  labs(y = "Ratings (AU)", x = "Session Number") +
  theme_classic() +
  facet_wrap(~Group) +
  easy_all_text_color("black") +
  theme(
    legend.text = element_text(size = 14),
    legend.position = "top",
    legend.title = element_text(size = 14),
    legend.box.spacing = unit(0, "pt"),
    strip.background.x = element_rect(fill = 'cornsilk', colour = "black"),
    strip.text.x = element_text(colour = "black"),
    strip.text = element_text(size = 14),
    axis.line = element_line(linewidth = 0.5),
    axis.text.x = element_text(angle = 0, vjust = 0.5, hjust = 0.5, size = 14),
    axis.title.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    axis.title.y = element_text(size = 14)
  ) +
  coord_capped_cart(
    left = capped_vertical("both"),
    bottom = capped_horisontal("both")
  )

# Save
ggsave("figure 3.svg", width = 30, height = 20, units = "cm")

# Analysis ----
# Fixed effect only model
summary(lm.1 <- lm(Ratings ~ Group + Mode + Measure + Session, data = rpe))
# Fixed and random effects model
summary(
  lm.2 <- lme4::lmer(
    Ratings ~ Group + Mode + Measure + Session + (1 | ID) + (1 | Session),
    data = rpe
  )
)

# Assess model fit
MuMIn::model.sel(lm.1, lm.2)
icc(lm.2)
# model lm.1 fits marginally best and ICC of 0.016 suggested a mixed model is not needed here.
# further seen when % variance explained is calculated.
rpe$Session <- as.factor(rpe$Session)
model <- remlMM(
  Ratings ~ Group + Mode + Measure + (ID) + (Session),
  rpe,
  cov = TRUE
)
VCAinference(model, VarVC = TRUE)

# Check residuals/errors
fitted.lm.1 <- augment(lm.1)

# Look at relationship between fitted values and residuals ----
ggplot(fitted.lm.1, aes(x = .fitted, y = .resid)) +
  geom_point(aes(color = Group)) +
  geom_smooth(method = "lm") # generally OK and no clustering

# Histogram
ggplot(fitted.lm.1, aes(x = .resid)) +
  geom_histogram(binwidth = 2, color = "white") # again, fine

# Model plot ----
(rpe.fixed.effects <- plot_model(
  lm.1,
  type = "est",
  title = "",
  show.intercept = F,
  show.p = T,
  sort.est = T,
  colors = c("#012169"),
  ci.style = "whisker",
  value.offset = 0.3,
  jitter = 0.5,
  show.values = T,
  axis.title = "Fixed Effect Estimates (AU)",
  value.size = 5,
  digits = 1,
  dot.size = 2,
  prefix.labels = "none"
) +
  coord_capped_flip(bottom = 'both', left = 'both') +
  scale_y_continuous(
    limits = c(-10.0, 10.0),
    breaks = seq(from = -10.0, to = 10.0, by = 2)
  ) +
  easy_all_text_size(12) +
  easy_all_text_colour("black") +
  theme(
    axis.title.x = element_text(vjust = -0.5),
    panel.border = element_blank(),
    axis.line = element_line()
  ))

# Save
ggsave("figure 4.svg", width = 20, height = 10, units = "cm")
