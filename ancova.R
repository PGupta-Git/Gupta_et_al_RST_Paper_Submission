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
library(car)
library(ggtext)

conflicted::conflict_prefer("filter", "dplyr")

#### load data
pg <- openxlsx2::read_xlsx("ancova stacked.xlsm")

pg$Group <- pg$Group %>%
  dplyr::recode("10-sec" = "Group 1", "20-sec" = "Group 2")

# Ensure Group 1 is reference level
pg$Group <- factor(pg$Group, levels = c("Group 1", "Group 2"))

#### Function to format p-values ----
format_pvalue <- function(p) {
  if (p < 0.001) {
    return("***")
  } else if (p < 0.01) {
    return("**")
  } else if (p < 0.05) {
    return("*")
  } else {
    return("ns")
  }
}

#### Function to get group effect and p-value from ANCOVA (FINAL CORRECTED) ----
get_ancova_stats <- function(ancova_model, units = "") {
  # Get p-value
  anova_result <- car::Anova(ancova_model, type = "III")
  p_val <- anova_result["Group", "Pr(>F)"]

  # Get effect size using emmeans
  emm <- emmeans::emmeans(ancova_model, ~Group)

  # THIS IS THE GUARANTEED FIX: Explicitly call the function from emmeans
  contrast_result <- emmeans::contrast(
    emm,
    method = "pairwise"
  )

  contrast_summary <- summary(contrast_result)

  effect_size <- contrast_summary$estimate[1] # Guaranteed to be G2 - G1

  # Format the annotation
  effect_text <- paste0("ES: ", sprintf("%.3f", effect_size))
  p_text <- paste0(format_pvalue(p_val))

  return(list(
    effect_size = effect_size,
    p_value = p_val,
    annotation = paste0(effect_text, p_text),
    is_significant = p_val < 0.05
  ))
}

#### 10m ----
ten <- pg %>% filter(Test == "10 m")
ancova_ten <- aov(Change ~ Baseline + Group, data = ten)
pred <- predict(ancova_ten)
stats_10 <- get_ancova_stats(ancova_ten, "sec")

f.10 <- ggplot(data = cbind(ten, pred), aes(Baseline, Change, color = Group)) +
  geom_point(size = 4, shape = 21) +
  geom_line(aes(y = pred), linewidth = 2) +
  geom_vline(
    xintercept = mean(ten$Baseline),
    linewidth = 1,
    color = "wheat4",
    alpha = 0.8
  ) +
  scale_x_continuous(
    expand = expansion(add = 0.1),
    breaks = scales::breaks_pretty(n = 5)
  ) +
  labs(y = "10-m Change (sec)", x = "") +
  scale_colour_manual(values = c("#C84E00", "#012169"))
# annotate(
#   "text",
#   x = Inf,
#   y = Inf,
#   label = stats_10$annotation,
#   hjust = 1.1,
#   vjust = 1.2,
#   size = 8,
#   fontface = "bold",
#   color = ifelse(stats_10$is_significant, "black", "grey40")
# )

#### 20 m ----
twenty <- pg %>% filter(Test == "20 m")
ancova_twenty <- aov(Change ~ Baseline + Group, data = twenty)
pred <- predict(ancova_twenty)
stats_20 <- get_ancova_stats(ancova_twenty, "sec")

f.20 <- ggplot(
  data = cbind(twenty, pred),
  aes(Baseline, Change, color = Group)
) +
  geom_point(size = 4, shape = 21) +
  geom_line(aes(y = pred), linewidth = 2) +
  geom_vline(
    xintercept = mean(twenty$Baseline),
    linewidth = 1,
    color = "wheat4",
    alpha = 0.8
  ) +
  scale_x_continuous(
    expand = expansion(add = 0.1),
    breaks = scales::breaks_pretty(n = 5)
  ) +
  labs(y = "20-m Change (sec)", x = "") +
  scale_colour_manual(values = c("#C84E00", "#012169"))
# annotate(
#   "text",
#   x = Inf,
#   y = Inf,
#   label = stats_20$annotation,
#   hjust = 1.1,
#   vjust = 1.2,
#   size = 8,
#   fontface = "bold",
#   color = ifelse(stats_20$is_significant, "black", "grey40")
# )

#### 40 m ----
forty <- pg %>% filter(Test == "40 m")
ancova_forty <- aov(Change ~ Baseline + Group, data = forty)
pred <- predict(ancova_forty)
stats_40 <- get_ancova_stats(ancova_forty, "sec")

f.40 <- ggplot(
  data = cbind(forty, pred),
  aes(Baseline, Change, color = Group)
) +
  geom_point(size = 4, shape = 21) +
  geom_line(aes(y = pred), linewidth = 2) +
  geom_vline(
    xintercept = mean(forty$Baseline),
    linewidth = 1,
    color = "wheat4",
    alpha = 0.8
  ) +
  scale_x_continuous(
    expand = expansion(add = 0.1),
    breaks = scales::breaks_pretty(n = 5)
  ) +
  scale_y_continuous(
    breaks = scales::breaks_pretty(n = 6)
  ) +
  labs(y = "40-m Change (sec)", x = "") +
  scale_colour_manual(values = c("#C84E00", "#012169"))
# annotate(
#   "text",
#   x = Inf,
#   y = Inf,
#   label = stats_40$annotation,
#   hjust = 1.1,
#   vjust = 1.2,
#   size = 8,
#   fontface = "bold",
#   color = ifelse(stats_40$is_significant, "black", "grey40")
# )

#### Vmax ----
vmax <- pg %>% filter(Test == "Vmax")
ancova_vmax <- aov(Change ~ Baseline + Group, data = vmax)
pred <- predict(ancova_vmax)
stats_vmax <- get_ancova_stats(ancova_vmax, "m·s⁻¹")

f.vmax <- ggplot(
  data = cbind(vmax, pred),
  aes(Baseline, Change, color = Group)
) +
  geom_point(size = 4, shape = 21) +
  geom_line(aes(y = pred), linewidth = 2) +
  geom_vline(
    xintercept = mean(vmax$Baseline),
    linewidth = 1,
    color = "wheat4",
    alpha = 0.8
  ) +
  scale_x_continuous(
    expand = expansion(add = 0.1),
    breaks = scales::breaks_pretty(n = 7)
  ) +
  scale_y_continuous(
    breaks = scales::breaks_pretty(n = 5)
  ) +
  labs(y = "Max Velocity Change (m·s<sup>-1</sup>)", x = "Pre-Test Score") +
  scale_colour_manual(values = c("#C84E00", "#012169"))
# annotate(
#   "text",
#   x = Inf,
#   y = Inf,
#   label = stats_vmax$annotation,
#   hjust = 1.1,
#   vjust = 1.2,
#   size = 8,
#   fontface = "bold",
#   color = ifelse(stats_vmax$is_significant, "black", "grey40")
# )

#### CMJ ----
cmj <- pg %>% filter(Test == "CMJN")
ancova_cmj <- aov(Change ~ Baseline + Group, data = cmj)
pred <- predict(ancova_cmj)
stats_cmj <- get_ancova_stats(ancova_cmj, "cm")

f.cmj <- ggplot(data = cbind(cmj, pred), aes(Baseline, Change, color = Group)) +
  geom_point(size = 4, shape = 21) +
  geom_line(aes(y = pred), linewidth = 2) +
  geom_vline(
    xintercept = mean(cmj$Baseline),
    linewidth = 1,
    color = "wheat4",
    alpha = 0.8
  ) +
  scale_x_continuous(
    breaks = scales::breaks_pretty(n = 6)
  ) +
  scale_y_continuous(
    breaks = scales::breaks_pretty(n = 6)
  ) +
  labs(y = "CMJH No Arms Change (cm)", x = "Pre-Test Score") +
  scale_colour_manual(values = c("#C84E00", "#012169"))
# annotate(
#   "text",
#   x = Inf,
#   y = Inf,
#   label = stats_cmj$annotation,
#   hjust = 1.1,
#   vjust = 1.2,
#   size = 8,
#   fontface = "bold",
#   color = ifelse(stats_cmj$is_significant, "black", "grey40")
# )

#### MAS ----
mas <- pg %>% filter(Test == "MAS")
ancova_mas <- aov(Change ~ Baseline + Group, data = mas)
pred <- predict(ancova_mas)
stats_mas <- get_ancova_stats(ancova_mas, "m·s⁻¹")

f.mas <- ggplot(data = cbind(mas, pred), aes(Baseline, Change, color = Group)) +
  geom_point(size = 4, shape = 21) +
  geom_line(aes(y = pred), linewidth = 2) +
  geom_vline(
    xintercept = mean(mas$Baseline),
    linewidth = 1,
    color = "wheat4",
    alpha = 0.8
  ) +
  scale_x_continuous(
    expand = expansion(add = 0.1),
    breaks = scales::breaks_pretty(n = 7)
  ) +
  scale_y_continuous(
    breaks = scales::breaks_pretty(n = 4)
  ) +
  labs(y = "MAS Change (m·s<sup>-1</sup>)", x = "Pre-Test Score") +
  scale_colour_manual(values = c("#C84E00", "#012169"))
# annotate(
#   "text",
#   x = Inf,
#   y = Inf,
#   label = stats_mas$annotation,
#   hjust = 1.1,
#   vjust = 1.2,
#   size = 8,
#   fontface = "bold",
#   color = ifelse(stats_mas$is_significant, "black", "grey40")
# )

#### Create main plot ----
main_plot <- (f.10 | f.20 | f.40) /
  (f.vmax | f.cmj | f.mas) +
  plot_layout(guides = "collect") &
  coord_capped_cart(
    left = capped_vertical("both"),
    bottom = capped_horizontal("both")
  ) &
  theme_classic() +
    theme(
      legend.text = element_markdown(size = 20),
      legend.key.size = unit(2, "cm"),
      legend.position = "top",
      legend.title = element_markdown(size = 24),
      strip.background.x = element_rect(fill = 'cornsilk', colour = "black"),
      strip.text.x = element_markdown(colour = 'black'),
      strip.text = element_markdown(size = 26),
      axis.text.x = element_markdown(size = 22),
      axis.title.x = element_markdown(
        size = 26,
        margin = unit(c(10, 0, 10, 0), "pt")
      ),
      axis.text.y = element_markdown(size = 22),
      axis.title.y = element_markdown(
        size = 26,
        face = "bold",
        margin = unit(c(0, 10, 0, 10), "pt")
      )
    )

#### Display plot ----
print(main_plot)

### Save plot ----
ggsave(
  "Fig5_Ancova.svg",
  plot = main_plot,
  width = 52,
  height = 35,
  units = "cm",
  dpi = 320
)

#### Print comprehensive results summary ----
cat("ANCOVA Results Summary (Group 2 - Group 1):\n")
cat("==========================================\n")
cat(
  "10-m Change: Effect =",
  sprintf("%.3f", stats_10$effect_size),
  "sec,",
  "p =",
  sprintf("%.3f", stats_10$p_value),
  format_pvalue(stats_10$p_value),
  "\n"
)
cat(
  "20-m Change: Effect =",
  sprintf("%.3f", stats_20$effect_size),
  "sec,",
  "p =",
  sprintf("%.3f", stats_20$p_value),
  format_pvalue(stats_20$p_value),
  "\n"
)
cat(
  "40-m Change: Effect =",
  sprintf("%.3f", stats_40$effect_size),
  "sec,",
  "p =",
  sprintf("%.3f", stats_40$p_value),
  format_pvalue(stats_40$p_value),
  "\n"
)
cat(
  "Max Velocity Change: Effect =",
  sprintf("%.3f", stats_vmax$effect_size),
  "m·s⁻¹,",
  "p =",
  sprintf("%.3f", stats_vmax$p_value),
  format_pvalue(stats_vmax$p_value),
  "\n"
)
cat(
  "CMJH No Arms Change: Effect =",
  sprintf("%.3f", stats_cmj$effect_size),
  "cm,",
  "p =",
  sprintf("%.3f", stats_cmj$p_value),
  format_pvalue(stats_cmj$p_value),
  "\n"
)
cat(
  "MAS Change: Effect =",
  sprintf("%.3f", stats_mas$effect_size),
  "m·s⁻¹,",
  "p =",
  sprintf("%.3f", stats_mas$p_value),
  format_pvalue(stats_mas$p_value),
  "\n"
)
