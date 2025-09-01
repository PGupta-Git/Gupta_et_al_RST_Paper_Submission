# --- All your initial code remains the same ---
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

cbp <- c("#C84E00", "#012169")

data_positioned <- data %>%
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

mean_data <- data %>%
  group_by(Test, Group, Timeline) %>%
  summarise(mean_value = mean(Value, na.rm = TRUE)) %>%
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

pre_post_plot_final <- data_positioned %>%
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
  theme(strip.text = element_markdown(face = "bold")) +
  theme(legend.position = "top") +
  theme(
    strip.placement = "outside",
    strip.background = element_blank()
  )

pre_post_plot_final

ggsave(
  "Fig4_Pre_Post.svg",
  plot = pre_post_plot_final,
  width = 65,
  height = 40,
  units = "cm",
  dpi = 600
)
