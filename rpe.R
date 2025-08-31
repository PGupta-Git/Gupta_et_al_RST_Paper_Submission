#### load libraries ----
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
library(lemon)
#### import data ----
rpe <- read_excel("rpe data.xlsx") ### Louis Johnston was removed
#### pivot longer ----
rpe <- pivot_longer(
  data = rpe,
  cols = S1_Gym_L:S12_FT_B,
  names_sep = "_",
  names_to = c("Number", "Mode", "Measure"),
  values_to = "Ratings"
)
#### rename variables ----
rpe <- rpe %>% rename("Session" = "Number")
rpe$Group <- rpe$Group %>%
  dplyr::recode("10-sec" = "Group One", "20-sec" = "Group Two")
rpe$Mode <- rpe$Mode %>%
  dplyr::recode(
    "RST" = "Repeated-Sprint Training",
    "FT" = "Soccer Training",
    "Gym" = "Gym-Based Training"
  )
rpe$Measure <- rpe$Measure %>% dplyr::recode("L" = "dRPE-L", "B" = "dRPE-B")
rpe$Session <- rpe$Session %>%
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
#### make rpe a dataframe
rpe <- as.data.frame(rpe)
#### convert predictors to factors
rpe$ID <- as.factor(rpe$ID)
rpe$Group <- as.factor(rpe$Group)
rpe$Mode <- as.factor(rpe$Mode)
rpe$Measure <- as.factor(rpe$Measure)
str(rpe)
#### relevel factors ----
rpe$Mode <- factor(
  rpe$Mode,
  levels = c(
    "Repeated-Sprint Training",
    "Match",
    "Soccer Training",
    "Gym-Based Training"
  )
)
#### make session numeric ----
rpe$Session <- as.numeric(rpe$Session)
#### get descriptives ----
rpe %>%
  group_by(Session) %>%
  summarise(
    mean = round(mean(Ratings, na.rm = TRUE), 3),
    sd = round(sd(Ratings, na.rm = TRUE), 3),
    min = round(min(Ratings, na.rm = TRUE), 2),
    max = round(max(Ratings, na.rm = TRUE), 2),
    n = n()
  )
#### plot ----
rpe %>%
  ggplot(aes(x = Session, y = Ratings, col = Mode)) +
  geom_jitter(size = 2, height = 0.05, alpha = 0.25) +
  geom_smooth(aes(fill = Mode), method = 'lm', se = F, linewidth = 1.5) +
  scale_fill_manual(values = c("red", "blue", "pink", "orchid")) +
  scale_colour_manual(values = c("red", "blue", "pink", "orchid")) +
  # scale_x_continuous(limits = c(1,12), breaks = c(1,4,8,12), guide = guide_axis(n.dodge=2)) +
  scale_y_continuous(
    limits = c(35, 85),
    breaks = seq(from = 35, to = 85, by = 5)
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
    axis.title.x = element_text(
      size = 14,
      margin = unit(c(10, 0, 10, 0), "pt")
    ),
    axis.text.y = element_text(size = 14),
    axis.title.y = element_text(size = 14, margin = unit(c(0, 10, 0, 10), "pt"))
  ) +
  coord_capped_cart(
    left = capped_vertical("both"),
    bottom = capped_horisontal("both")
  )
#### save ----
ggsave("Figure2dRPEv3.svg", width = 30, height = 20, units = "cm")

#### analysis ----
#### fixed effect only model ----
summary(lm.1 <- lm(Ratings ~ Group + Mode + Measure + Session, data = rpe))
#### fixed and random effects model ----
summary(
  lm.2 <- lme4::lmer(
    Ratings ~ Group + Mode + Measure + Session + (1 | ID) + (1 | Session),
    data = rpe
  )
)
#### assess model fit ----
MuMIn::model.sel(lm.1, lm.2)
performance::compare_performance(lm.1, lm.2, rank = F)
summarise_model(lm.2)
# model lm.1 fits marginally best and ICC of 0.015 suggested a mixed model is not needed here.
# further seen when % variance explained is calculated.
rpe$Session <- as.factor(rpe$Session)
model <- remlMM(
  Ratings ~ Group + Mode + Measure + (ID) + (Session),
  rpe,
  cov = TRUE
)
VCAinference(model, VarVC = TRUE)
#### check residuals/errors ----
fitted_data <- augment(lm.1)
#### Look at relationship between fitted values and residuals ----
ggplot(fitted_data, aes(x = .fitted, y = .resid)) +
  geom_point(aes(color = Group)) +
  geom_smooth(method = "lm")
# generally OK and no clustering
#### histogram ----
ggplot(fitted_data, aes(x = .resid)) +
  geom_histogram(binwidth = 2, color = "white")
# again, generally OK
#### model plot ----
plot_model(
  lm.1,
  type = c("est"),
  show.intercept = F,
  show.p = T,
  sort.est = F,
  ci.lvl = 0.90,
  colors = "bw",
  ci.style = "whisker",
  line.size = 0.5,
  value.offset = -0.3,
  show.values = T,
  width = .1,
  value.size = 6,
  digits = 2,
  dot.size = 3
) +
  theme_classic() +
  annotate(
    "rect",
    ymin = -8,
    ymax = 8,
    xmin = 0,
    xmax = 6.75,
    alpha = .1,
    fill = "deepskyblue"
  ) +
  annotate(
    geom = "text",
    y = -0,
    x = 6.5,
    label = "Region of practical equivalence",
    color = "black",
    size = 8,
    angle = 0
  ) +
  scale_y_continuous(
    limits = c(-12, 12),
    breaks = seq(from = -12, to = 12, by = 2)
  ) +
  labs(y = "Fixed Effect Estimates (AU)", x = "", title = "") +
  easy_all_text_color("black") +
  easy_all_text_size(18) +
  coord_capped_flip(
    left = capped_vertical("both"),
    bottom = capped_horisontal("both")
  ) +
  theme(
    axis.title.x = element_text(
      margin = unit(c(10, 0, 10, 0), "pt")
    )
  )

#### save ----
ggsave("Figure3rpefixedeffectsv2.svg", width = 30, height = 20, units = "cm")
