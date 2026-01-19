# A Pragmatic, Parallel-Arm, Randomised Trial on the Effects of Two Repeated Sprint Training Protocols on Fitness Outcomes in Semi-Professional Male Soccer Players: Preliminary Report

**Authors:**
Palash Gupta<sup>1</sup>, Anthony P. Turner<sup>1</sup>, Shaun M. Phillips<sup>1</sup>, Matthew Weston<sup>1,2*</sup>

**Affiliations:**
1. Institute for Sport, Physical Education and Health Sciences, University of Edinburgh, Edinburgh, Scotland
2. Institute of Sport, Manchester Metropolitan University, Manchester, UK

*Corresponding author
E-mail: Matthew.Weston@ed.ac.uk

ORCID:
* PG: https://orcid.org/0009-0000-0172-4009
* AT: https://orcid.org/0000-0003-1202-6649
* SP: https://orcid.org/0000-0002-7947-3403
* MW: https://orcid.org/0000-0002-9531-3004 

## Project Description

This project contains the data and analysis scripts for a study investigating the effects of two different repeated-sprint training (RST) protocols on the physical performance of soccer players. The study compares a protocol with 10-second recoveries ("Group 1") to one with 20-second recoveries ("Group 2").

The repository includes:
1.  An **a priori power analysis** (`sesoi.Rmd`) to determine and justify the sample size required to detect the smallest effect size of interest (SESOI) for various fitness outcomes. Saves intermediate results for figure generation.
2.  An **analysis of training load** (`dRPE mixed model.Rmd`), using differential ratings of perceived exertion (dRPE) for legs and breathlessness across different training modes (RST, gym, soccer training), including statistical comparisons between groups. Saves intermediate results for figure generation.
3.  The **primary ANCOVA analysis** (`ancovas.Rmd`) comparing the pre-post changes in fitness test performance (sprint times, maximal velocity, countermovement jump, maximal aerobic speed) between the two training groups.
4.  **Centralised figure generation** (`figures.Rmd`) for all manuscript figures: power analysis sensitivity curves, dRPE session plots, RPE forest plot, and pre-post raincloud plots.

---

## Software and Platform

*   **Language:** R (version 4.0 or later recommended)
*   **Primary R Packages:**
    *   **Data Wrangling & Plotting:** `tidyverse`, `dplyr`, `patchwork`, `lemon`, `ggeasy`, `ggdist`, `visdat`, `here`, `svglite`
    *   **Statistical Analysis:** `Superpower` (for power analysis), `lme4`, `glmmTMB`, `estimatr`, `performance`, `easystats`, `sjPlot`, `broom.mixed`, `mixedup`, `emmeans`
*   **Recommended IDE:** RStudio, VSCode with R extensions, or Positron. The scripts use the `here` package for robust file path handling, so they work correctly regardless of where they are executed from within the project.

---

## Map of the Documentation & File Structure

The project is organized into the following directories and files:

```
├── README.md                              # This file
├── LICENSE.md                             # Data and code licenses
├── data_dictionary.md                     # Detailed description of all variables
├── data/
│   ├── ANCOVA Final.csv                   # Primary fitness test data (wide format)
│   ├── ANCOVA Final Long.csv              # Fitness test data for plotting (long format)
│   ├── rpe data.csv                       # Training load data (wide format)
│   ├── journal.pone.0299204.s001.csv      # Lee et al. (2024) supplementary data
│   ├── Sprinttest_Olympiatoppen.csv       # Haugen et al. (2019) sprint data
│   ├── sensitivity_analysis.rds           # Intermediate results from sesoi.Rmd (for Figure 2)
│   └── rpe_contrasts.rds                  # Intermediate results from dRPE mixed model.Rmd (for Figure 4)
├── scripts/
│   ├── sesoi.Rmd                          # SESOI calculation and power analysis
│   ├── figures.Rmd                        # Centralised manuscript figure generation
│   ├── dRPE mixed model.Rmd               # dRPE mixed model analysis
│   └── ancovas.Rmd                        # ANCOVA statistical analysis
└── figures/                               # Generated figure outputs (SVG format, PNG also supported)
    ├── figure 2.svg                       # Power analysis sensitivity curves
    ├── figure 3.svg                       # dRPE plot by session and group
    ├── figure 4.svg                       # Forest plot of between-group RPE differences
    └── figure 5.svg                       # Raincloud plots for pre-post data
```

---

## Instructions for Reproducing the Results

1.  **Clone or Download:** Clone this repository or download the zip file and extract it to a local directory.

2.  **Open the Project:** Open the project in your IDE (e.g., RStudio by opening the folder, or by opening the folder in VSCode/Positron). The scripts use the `here` package to automatically detect the project root.

3.  **Install Required Packages:** Run the following command in your R console to install all necessary packages:

    ```R
    install.packages(c(
      "Superpower", "easystats", "tidyverse", "dplyr", "readr", "lemon",
      "patchwork", "ggeasy", "lme4", "glmmTMB", "performance", "broom.mixed",
      "sjPlot", "estimatr", "visdat", "ggdist", "mixedup", "emmeans", "here", "svglite"
    ))
    
    # mixedup may need to be installed from GitHub:
    # remotes::install_github("m-clark/mixedup")
    ```

4.  **Run the R Markdown Scripts:** Execute the R Markdown files in the `/scripts` directory. You can render them using `rmarkdown::render()` or knit them directly in RStudio. A logical order is:

    *   `sesoi.Rmd`: SESOI calculation and power analysis. Saves intermediate results to `data/sensitivity_analysis.rds`.
    *   `dRPE mixed model.Rmd`: Mixed model analysis for training load (dRPE). Saves intermediate results to `data/rpe_contrasts.rds`.
    *   `figures.Rmd`: Generates all manuscript figures (2, 3, 4, 5). Requires `sesoi.Rmd` and `dRPE mixed model.Rmd` to be run first.
    *   `ancovas.Rmd`: ANCOVA models and diagnostics for all fitness outcomes.

    **Note:** Figures are saved as SVG by default. To generate PNG output instead, change the file extension in the `ggsave()` calls from `.svg` to `.png`.

---

## Relationships Between Files

*   **`sesoi.Rmd`**: A priori power analysis script that:
    *   Reads external validation data from `data/journal.pone.0299204.s001.csv` (Lee et al., 2024)
    *   Reads sprint data from `data/Sprinttest_Olympiatoppen.csv` (Haugen et al., 2019)
    *   Calculates SESOI values and performs sensitivity analyses
    *   Saves intermediate results to `data/sensitivity_analysis.rds` for figure generation

*   **`dRPE mixed model.Rmd`**: Training load analysis that:
    *   Reads `data/rpe data.csv`
    *   Fits an initial linear mixed model (lmer) for dRPE ratings with Group × Mode interaction
    *   Performs model diagnostics revealing heterogeneous variance across training modes
    *   Refits the model using glmmTMB with mode-specific variance structure (`dispformula = ~ Mode`)
    *   Conducts variance decomposition and calculates mode-specific standard deviations
    *   Performs pairwise contrasts with Bonferroni correction
    *   Saves intermediate results to `data/rpe_contrasts.rds` for figure generation

*   **`figures.Rmd`**: Centralised manuscript figure generation that:
    *   Loads `data/sensitivity_analysis.rds` for power analysis sensitivity curves (Figure 2)
    *   Reads `data/rpe data.csv` for the dRPE session plot (Figure 3)
    *   Loads `data/rpe_contrasts.rds` for the RPE forest plot (Figure 4)
    *   Reads `data/ANCOVA Final Long.csv` for raincloud plots (Figure 5)
    *   Generates all four manuscript figures: `figures/figure 2.svg`, `figure 3.svg`, `figure 4.svg`, `figure 5.svg`

*   **`ancovas.Rmd`**: ANCOVA statistical analysis that:
    *   Reads `data/ANCOVA Final.csv`
    *   Fits ANCOVA models for all six outcomes (10m, 20m, 40m sprint, VMax, CMJ, MAS)
    *   Includes assumption checks and outlier diagnostics
    *   Uses robust standard errors where assumptions are violated

---

## External Data Sources

The following external datasets are included in the `data/` folder:

*   **`journal.pone.0299204.s001.csv`**: Supplementary data from Lee et al. (2024). [DOI: 10.1371/journal.pone.0299204](https://doi.org/10.1371/journal.pone.0299204)
*   **`Sprinttest_Olympiatoppen.csv`**: Sprint test data from Haugen et al. (2019). [DOI: 10.18710/PJONBM](https://doi.org/10.18710/PJONBM)


