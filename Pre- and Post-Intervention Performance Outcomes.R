#| label: Figure : Pre- and Post-Intervention Performance Outcomes
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
library(ggdist)

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

## set colour blind palette
cbp <- c("#C84E00", "#012169")

# Create custom x positions for each element
# Pre: Violins (left) -> Boxes -> Points (right)
# Post: Points (left) -> Boxes -> Violins (right)
data_positioned <- data %>%
  mutate(
    # Define x positions for points and boxes (closer to center)
    x_points = case_when(
      Timeline == "Pre" & Group == "Group 1" ~ 0.7, # Pre: points on right side
      Timeline == "Pre" & Group == "Group 2" ~ 0.7,
      Timeline == "Post" & Group == "Group 1" ~ 2.3, # Post: points on left side
      Timeline == "Post" & Group == "Group 2" ~ 2.3
    ),
    x_boxes = case_when(
      Timeline == "Pre" & Group == "Group 1" ~ 0.15, # Pre: boxes between violins and points
      Timeline == "Pre" & Group == "Group 2" ~ 0.45,
      Timeline == "Post" & Group == "Group 1" ~ 2.55, # Post: boxes between points and violins
      Timeline == "Post" & Group == "Group 2" ~ 2.85
    ),
    # Violin positions stay at original timeline positions
    x_violins = case_when(
      Timeline == "Pre" & Group == "Group 1" ~ 0, # Pre: points on right side
      Timeline == "Pre" & Group == "Group 2" ~ 0,
      Timeline == "Post" & Group == "Group 1" ~ 3, # Post: points on left side
      Timeline == "Post" & Group == "Group 2" ~ 3
    )
  )

# True split-violin raincloud plot with custom positioning
pre_post_plot_final <- data_positioned %>%
  ggplot(aes(x = Timeline, y = Value)) +

  # Split violin plots using stat_slab - keep at original timeline positions
  stat_slab(
    aes(
      x = x_violins,
      fill = Group,
      side = ifelse(Timeline == "Pre", "left", "right")
    ),
    alpha = 0.5,
    color = NA,
    scale = 0.8,
    normalize = "panels"
  ) +

  # Connecting lines showing individual trajectories - connect the points
  geom_line(
    aes(x = x_points, group = ID, color = Group),
    alpha = 0.2,
    linewidth = 0.8
  ) +

  # Box plots positioned between violins and points
  geom_boxplot(
    aes(x = x_boxes, fill = Group, group = interaction(Timeline, Group)),
    alpha = 0.9,
    width = 0.3, # Narrower since they're positioned precisely
    outlier.shape = NA,
    color = "black",
    linewidth = 0.5
  ) +

  # Individual data points positioned closer to center
  geom_point(
    aes(x = x_points, color = Group, fill = Group),
    alpha = 0.8,
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
  theme(strip.text = element_markdown(face = "bold")) +
  theme(legend.position = "top") +
  theme(
    strip.placement = "outside",
    strip.background = element_blank()
  )

pre_post_plot_final


ggsave(
  "Fig4_Pre_Post.png",
  plot = pre_post_plot_final,
  width = 65,
  height = 40,
  units = "cm",
  dpi = 600
)
