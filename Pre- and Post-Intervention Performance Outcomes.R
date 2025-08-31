#| label:  Figure : Pre- and Post-Intervention Performance Outcomes
library(tidyverse)
library(lme4)
library(lmerTest)
library(merTools)
library(easystats)
library(broom)
library(ggeasy)
library(sandwich)
library(lmtest)
library(lemon)
library(clubSandwich)
library(emmeans)
library(sjPlot)
library(ggthemes)
library(ggpubr)
library(openxlsx2)
library(gt)
library(BlandAltmanLeh)
library(patchwork)
library(ggtext)
library(ggrain)

data <- read_csv("ANCOVA Final Long.csv")

data <- data %>%
  mutate(across(c(Group, ID, Timeline, Test), as_factor))

data$Group <- data$Group %>%
  dplyr::case_match("10-sec" ~ "Group 1", "20-sec" ~ "Group 2")

data$Group <- factor(data$Group, levels = c("Group 1", "Group 2"))

custom_labels <- c(
  "Time_10m" = "10-m Sprint Time (sec)",
  "Time_20m" = "20-m Sprint Time (sec)",
  "Time_40m" = "40-m Sprint Time (sec)",
  "Max_Velocity" = "Max Velocity (m·s<sup>-1</sup>)",
  "MAS" = "MAS (m·s<sup>-1</sup>)",
  "CMJH" = "CMJH No Arms (cm)"
)

# Updated plot with Jitters & stat_summary for mean and SD error bars

## set colour blind pallette
cbp <- c("#C84E00", "#012169")

pre_post_plot_final <- data %>%
  ggplot(aes(x = Timeline, y = Value, fill = Group, color = Group)) +
  geom_violin(
    position = position_dodge(width = 1),
    alpha = 0.15,
    color = NA
  ) +
  # Add mean point and SD error bars using stat_summary
  stat_summary(
    fun = mean,
    geom = "point",
    size = 4,
    position = position_dodge(width = 1)
  ) +
  stat_summary(
    fun.data = mean_sdl,
    fun.args = list(mult = 1),
    geom = "errorbar",
    width = 0.1,
    position = position_dodge(width = 1)
  ) +
  geom_rain(
    id.long.var = "ID",
    violin.args = list(alpha = 0, color = NA),
    boxplot.args = list(alpha = 0, color = NA),
    line.args = list(alpha = 0.2, linewidth = 0.5),
    point.args = list(shape = 21, size = 4, alpha = 1, fill = "white"),
    position = position_dodge(width = 1)
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
      "Group 1" = alpha("#C84E00", 0.2),
      "Group 2" = alpha("#012169", 0.2)
    )
  ) +
  scale_colour_manual(
    values = c("Group 1" = "#C84E00", "Group 2" = "#012169")
  ) +
  theme(legend.key.size = unit(1, "cm")) +
  theme(strip.text = element_markdown(face = "bold")) +
  theme(legend.position = "top") +
  theme(
    strip.placement = "outside",
    strip.background = element_blank()
  )


pre_post_plot_final

ggsave(
  "Fig4_Pre_Post_2.svg",
  plot = pre_post_plot_final,
  width = 50,
  height = 35,
  units = "cm",
  dpi = 320
)
