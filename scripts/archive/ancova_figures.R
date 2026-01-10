# =============================================================================
# ANCOVA Figures for Fitness Outcomes
# =============================================================================
# This script generates all figures from the ANCOVA analysis.
# It sources the statistical analysis script to load models and data.
#
# Contents:
#   1. Source statistical analysis script
#   2. Raincloud plots for pre/post data (Figure 4)
#   3. ANCOVA model coefficient plots (Figure 5)
#
# Outputs:
#   - figure 4.svg (Raincloud plots)
#   - figure 5.svg (Combined ANCOVA coefficient plots)
# =============================================================================

# =============================================================================
# 1. SOURCE STATISTICAL ANALYSIS AND LOAD FIGURE LIBRARIES
# =============================================================================

# Source the statistical analysis script (loads models and data)
source("scripts/ancova_statistical_analysis.R")

# Load additional libraries needed for figures
library(patchwork)
library(sjPlot)
library(lemon)
library(ggeasy)
library(ggrain)
library(ggdist)
library(ggtext)

# Set theme
theme_set(theme_classic())

# =============================================================================
# 2. RAINCLOUD PLOTS FOR PRE AND POST TEST DATA (FIGURE 4)
# =============================================================================

# Load long-format data for raincloud plots
data <- read_csv("data/ANCOVA Final Long.csv")
data <- data |>
  mutate(across(c(Group, ID, Timeline, Test), as_factor))

data$Group <- data$Group |>
  dplyr::case_match("10-sec" ~ "Group 1", "20-sec" ~ "Group 2")
data$Group <- factor(data$Group, levels = c("Group 1", "Group 2"))

# Custom labels for facets
# Note: Using Unicode superscript characters (⁻¹) for proper rendering in SVG output
custom_labels <- c(
  "Time_10m" = "10 m Sprint Time (sec)",
  "Time_20m" = "20 m Sprint Time (sec)",
  "Time_40m" = "40 m Sprint Time (sec)",
  "Max_Velocity" = "VMax (m·s⁻¹)",
  "MAS" = "MAS (m·s⁻¹)",
  "CMJH" = "CMJ (cm)"
)

# Color palette
cbp <- c("#C84E00", "#012169")

# Position data for plotting
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

# Calculate means for overlay
mean_data <- data |>
  group_by(Test, Group, Timeline) |>
  summarise(mean_value = mean(Value, na.rm = TRUE)) |>
  ungroup() %>%
  mutate(
    x_boxes = case_when(
      Timeline == "Pre" & Group == "Group 1" ~ 0.9,
      Timeline == "Pre" & Group == "Group 2" ~ 0.9,
      Timeline == "Post" & Group == "Group 1" ~ 2.1,
      Timeline == "Post" & Group == "Group 2" ~ 2.1
    )
  )

# Create raincloud plot
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

# Save Figure 4
ggsave("figure 4.svg", dpi = 300, width = 40, height = 25, units = "cm")

# =============================================================================
# 3. ANCOVA MODEL COEFFICIENT PLOTS (FIGURE 5)
# =============================================================================

# -----------------------------------------------------------------------------
# 10m Sprint Model Plot
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# 20m Sprint Model Plot (using robust SE model)
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# 40m Sprint Model Plot (using robust SE model)
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# VMax Model Plot (using robust SE model)
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# CMJ Model Plot (using robust SE model)
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# MAS Model Plot
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# Combine all ANCOVA plots into Figure 5
# -----------------------------------------------------------------------------
(ancova.10 | ancova.20 | ancova.40) / (ancova.max | ancova.cmj | ancova.mas)

# Save Figure 5
ggsave("figure 5.svg", dpi = 300, width = 45, height = 25, units = "cm")
