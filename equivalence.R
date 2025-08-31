# Load required libraries
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

# Resolve conflicts
conflicted::conflict_prefer_all(winner = "dplyr")
conflicted::conflict_prefer(name = "lmer", winner = "lme4")

# Load and prepare data
pg <- read_csv("ancova stacked.csv") %>%
  mutate(
    Group = case_match(
      Group,
      "10-sec" ~ "Group 1",
      "20-sec" ~ "Group 2"
    ),
    across(c(ID, Group, Test), as_factor)
  )

# Fit ANCOVA models for each test
ten.model <- lm(Change ~ Baseline + Group, data = filter(pg, Test == "10 m"))
twenty.model <- lm(Change ~ Baseline + Group, data = filter(pg, Test == "20 m"))
forty.model <- lm(Change ~ Baseline + Group, data = filter(pg, Test == "40 m"))
mas.model <- lm(Change ~ Baseline + Group, data = filter(pg, Test == "MAS"))
vmax.model <- lm(Change ~ Baseline + Group, data = filter(pg, Test == "Vmax"))
cmj.model <- lm(Change ~ Baseline + Group, data = filter(pg, Test == "CMJN"))

# ROPE bounds for each metric
get_rope_bounds <- function(test_name) {
  if (test_name == "10 m") {
    return(c(-0.114, 0.114))
  }
  if (test_name == "20 m") {
    return(c(-0.162, 0.162))
  }
  if (test_name == "40 m") {
    return(c(-0.258, 0.258))
  }
  if (test_name == "MAS") {
    return(c(-0.227, 0.227))
  }
  if (test_name == "Vmax") {
    return(c(-0.200, 0.200))
  }
  if (test_name == "CMJN") {
    return(c(-2.800, 2.800))
  }
  stop("Unknown test")
}

# Determine equivalence status based on CI vs. ROPE
determine_equivalence_status <- function(
  lower_ci,
  upper_ci,
  rope_lower,
  rope_upper
) {
  if (lower_ci > rope_upper || upper_ci < rope_lower) {
    "Rejected"
  } else if (lower_ci > rope_lower && upper_ci < rope_upper) {
    "Accepted"
  } else {
    "Undecided"
  }
}

# Within-group effects
get_within_group_effects <- function(data, test_name, rope_bounds) {
  data %>%
    filter(Test == test_name) %>%
    group_by(Group) %>%
    summarize(
      mean_change = mean(Change, na.rm = TRUE),
      se_change = sd(Change, na.rm = TRUE) / sqrt(n()),
      lower_ci = mean_change - qt(0.95, n() - 1) * se_change,
      upper_ci = mean_change + qt(0.95, n() - 1) * se_change,
      # Add t-test for within-group comparison against zero
      t_stat = mean_change / se_change,
      df = n() - 1,
      p_value = 2 * pt(abs(t_stat), df, lower.tail = FALSE),
      .groups = "drop"
    ) %>%
    mutate(
      effect_type = "Within Group",
      comparison = as.character(Group),
      equivalence_status = pmap_chr(
        list(lower_ci, upper_ci),
        ~ determine_equivalence_status(
          ..1,
          ..2,
          rope_bounds[1],
          rope_bounds[2]
        )
      ),
      # Format annotations
      annotation = paste0(
        round(mean_change, 3),
        case_when(
          p_value < 0.001 ~ "***", # character
          p_value < 0.01 ~ "**", # character
          p_value < 0.05 ~ "*", # character
          .default = "" # character
        )
      )
    )
}

# Between-group effects
get_between_group_effects <- function(model, test_name, rope_bounds) {
  emm <- emmeans(model, ~Group, level = 0.90)
  contrast_df <- contrast(emm, "pairwise") %>%
    summary(infer = TRUE) %>%
    as.data.frame()

  contrast_df %>%
    mutate(
      Test = test_name,
      effect_type = "Between Group",
      comparison = contrast,
      mean_change = estimate,
      lower_ci = lower.CL,
      upper_ci = upper.CL,
      p_value = p.value,
      equivalence_status = pmap_chr(
        list(lower_ci, upper_ci),
        ~ determine_equivalence_status(
          ..1,
          ..2,
          rope_bounds[1],
          rope_bounds[2]
        )
      ),
      # Format annotations
      annotation = paste0(
        round(mean_change, 3),
        case_when(
          p_value < 0.001 ~ "***", # character
          p_value < 0.01 ~ "**", # character
          p_value < 0.05 ~ "*", # character
          .default = "" # character
        )
      )
    ) %>%
    select(
      Test,
      effect_type,
      comparison,
      mean_change,
      lower_ci,
      upper_ci,
      equivalence_status,
      annotation
    )
}


# New color palette for groups
group_color_palette <- c(
  "Group 1" = "#D95F02",
  "Group 2" = "#012169",
  "Group 1 - Group 2" = "#1B9E77"
)

# Update the combined plot function
create_combined_plot <- function(test_name, model, rope_bounds) {
  within <- get_within_group_effects(pg, test_name, rope_bounds)
  between <- get_between_group_effects(model, test_name, rope_bounds)
  all_eff <- bind_rows(within, between)

  plot_title <- case_match(
    test_name,
    "10 m" ~ "A",
    "20 m" ~ "B",
    "40 m" ~ "C",
    "MAS" ~ "D",
    "Vmax" ~ "E",
    "CMJN" ~ "F",
    .default = test_name
  )

  x_min <- min(all_eff$lower_ci, rope_bounds[1])
  x_max <- max(all_eff$upper_ci, rope_bounds[2])
  x_pad <- (x_max - x_min) * 0.20
  x_limits <- c(x_min - x_pad, x_max + x_pad)

  # Calculate annotation positions
  all_eff <- all_eff %>%
    mutate(
      annotation_x = case_when(
        mean_change >= 0 ~ x_limits[2],
        TRUE ~ x_limits[1]
      )
    )

  ggplot(
    all_eff,
    aes(y = comparison, x = mean_change, xmin = lower_ci, xmax = upper_ci)
  ) +
    geom_rect(
      aes(
        xmin = rope_bounds[1],
        xmax = rope_bounds[2],
        ymin = -Inf,
        ymax = Inf
      ),
      fill = "deepskyblue",
      alpha = 0.15,
      color = alpha("deepskyblue", 0.15)
    ) +
    geom_pointrange(aes(color = comparison), size = 1) +
    geom_text(
      aes(
        x = mean_change,
        label = annotation,
        color = comparison
      ),
      vjust = 2,
      size = 6,
      fontface = "bold"
    ) +
    scale_x_continuous(
      limits = x_limits,
      expand = expansion(add = 0.1),
      breaks = scales::pretty_breaks(n = 6)
    ) +
    scale_color_manual(
      values = group_color_palette,
      name = "Group"
    ) +
    facet_grid(effect_type ~ ., scales = "free_y", space = "free_y") +
    theme_classic(base_size = 26) +
    labs(title = plot_title, x = NULL, y = NULL) +
    theme(
      panel.grid.minor = element_blank(),
      strip.text = element_blank(),
      plot.title = element_markdown(face = "bold")
    ) +
    coord_capped_cart(
      left = capped_vertical("both"),
      bottom = capped_horizontal("both")
    )
}

# Update the equivalence forest plot
create_equivalence_forest_plot <- function(models, test_names) {
  results <- map2_dfr(
    models,
    test_names,
    ~ {
      rope_bounds <- get_rope_bounds(.y)
      contrast_df <- contrast(
        emmeans(.x, ~Group, level = 0.90),
        "pairwise"
      ) %>%
        summary(infer = TRUE) %>%
        as.data.frame()
      eq_status <- determine_equivalence_status(
        contrast_df$lower.CL[1],
        contrast_df$upper.CL[1],
        rope_bounds[1],
        rope_bounds[2]
      )
      tibble(
        Test = .y,
        Estimate = contrast_df$estimate[1],
        Lower_CI = contrast_df$lower.CL[1],
        Upper_CI = contrast_df$upper.CL[1],
        ROPE_Lower = rope_bounds[1],
        ROPE_Upper = rope_bounds[2],
        Equivalence_Status = eq_status,
        comparison = contrast_df$contrast[1]
      )
    }
  )

  results <- results %>%
    mutate(
      Test = factor(Test, levels = test_names)
    )

  ggplot(results, aes(x = Estimate, y = Test)) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    geom_rect(
      aes(
        xmin = ROPE_Lower,
        xmax = ROPE_Upper,
        ymin = as.numeric(Test) - 0.4,
        ymax = as.numeric(Test) + 0.4
      ),
      fill = "deepskyblue",
      alpha = 0.15,
      color = alpha("deepskyblue", 0.15)
    ) +
    geom_errorbarh(
      aes(xmin = Lower_CI, xmax = Upper_CI),
      height = 0.2,
      size = 1,
      color = group_color_palette["Group 1 - Group 2"]
    ) +
    geom_point(size = 4, color = group_color_palette["Group 1 - Group 2"]) +
    theme_classic(base_size = 14) +
    labs(
      title = "Between-Group Differences",
      subtitle = "Mean difference with 90% CI (Group 1 – Group 2)",
      x = "Mean Difference",
      y = NULL
    ) +
    theme(
      panel.grid.minor = element_blank(),
      axis.text.y = element_text(face = "bold")
    )
}

# Update the shared legend function
create_legend_plot <- function() {
  dummy <- tibble(
    x = 1:3,
    y = 1,
    comparison = c("Group 1", "Group 2", "Group 1 - Group 2")
  )
  p <- ggplot(dummy, aes(x, y)) +
    geom_point(aes(color = comparison), size = 5) +
    scale_color_manual(values = group_color_palette, name = "Group") +
    theme_classic() +
    theme(
      legend.position = "bottom",
      legend.key.size = unit(1.5, "cm"),
      legend.text = element_text(size = 20),
      legend.title = element_text(face = "bold", size = 20)
    )
  get_legend(p)
}

# Assemble all plots
create_all_plots <- function() {
  models <- list(
    ten.model,
    twenty.model,
    forty.model,
    mas.model,
    vmax.model,
    cmj.model
  )
  test_names <- c("10 m", "20 m", "40 m", "MAS", "Vmax", "CMJN")

  combined_list <- map2(
    models,
    test_names,
    ~ {
      rb <- get_rope_bounds(.y)
      create_combined_plot(.y, .x, rb) +
        theme(legend.position = "none")
    }
  )

  shared_legend <- create_legend_plot()

  combined_grid <- (combined_list[[1]] +
    combined_list[[2]] +
    combined_list[[3]] +
    combined_list[[4]] +
    combined_list[[5]] +
    combined_list[[6]]) +
    plot_layout(
      ncol = 2,
      guides = "collect",
      axes = "collect",
      axis_titles = "collect"
    ) &
    theme(plot.margin = margin(20, 20, 20, 20))

  final_plot <- wrap_plots(
    shared_legend,
    combined_grid,
    ncol = 1,
    heights = c(2, 30)
  )

  list(
    combined_plots = combined_list,
    equivalence_forest = create_equivalence_forest_plot(models, test_names),
    final_plot = final_plot
  )
}

# Build a results table
create_results_table <- function() {
  models <- list(
    ten.model,
    twenty.model,
    forty.model,
    mas.model,
    vmax.model,
    cmj.model
  )
  test_names <- c("10 m", "20 m", "40 m", "MAS", "Vmax", "CMJN")

  results <- map2_dfr(
    models,
    test_names,
    ~ {
      rb <- get_rope_bounds(.y)
      within_df <- get_within_group_effects(pg, .y, rb)
      between_df <- get_between_group_effects(.x, .y, rb)
      bind_rows(within_df, between_df)
    }
  )

  results %>%
    mutate(
      CI = paste0("[", round(lower_ci, 3), ", ", round(upper_ci, 3), "]"),
      mean_change = round(mean_change, 3)
    ) %>%
    select(
      Test,
      effect_type,
      comparison,
      mean_change,
      CI,
      equivalence_status
    ) %>%
    rename(
      `Mean Change` = mean_change,
      `90% CI` = CI,
      `Equivalence Status` = equivalence_status
    )
}

# Run everything
run_analysis <- function() {
  plots <- create_all_plots()
  results_table <- create_results_table()
  list(plots = plots, results_table = results_table)
}

analysis_results <- run_analysis()

# Display plots and table
analysis_results$plots$final_plot

ggsave(
  "Fig6_Equivalence_ANCOVA.svg",
  plot = analysis_results$plots$final_plot,
  width = 40,
  height = 40,
  units = "cm",
  dpi = 320
)


analysis_results$plots$equivalence_forest

analysis_results$results_table %>%
  gt() %>%
  tab_header(title = "Equivalence Testing Results") %>%
  data_color(
    columns = `Equivalence Status`,
    fn = scales::col_factor(
      palette = c("#009E73", "#D55E00", "#F0E442"),
      domain = c("Accepted", "Rejected", "Undecided")
    )
  )
