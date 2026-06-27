# A pragmatic, parallel-arm, randomised trial on the effects of two repeated-sprint training protocols on fitness outcomes in semi-professional male soccer players: preliminary report

[![DOI](https://img.shields.io/badge/DOI-10.1080%2F24733938.2026.2684071-blue)](https://doi.org/10.1080/24733938.2026.2684071)

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

## Citation

If you use the data, analysis scripts, or findings from this study in your research, please cite the published article:

> Gupta, P., Turner, A. P., Phillips, S. M., & Weston, M. (2026). A pragmatic, parallel-arm, randomised trial on the effects of two repeated-sprint training protocols on fitness outcomes in semi-professional male soccer players: preliminary report. *Science and Medicine in Football*. https://doi.org/10.1080/24733938.2026.2684071

## Project Description

This project contains the data and analysis scripts for a study investigating the effects of two different repeated-sprint training (RST) protocols on the physical performance of soccer players. The study compares a protocol with 10-second recoveries ("Group 1") to one with 20-second recoveries ("Group 2").

The repository includes:
1.  A **sensitivity power analysis** (`sensitivity.Rmd`) to determine the range of effect sizes detectable with 80% power for the study's fixed sample size. Saves intermediate results for figure generation.
2.  An **analysis of training load** (`dRPE mixed model.Rmd`), using differential ratings of perceived exertion (dRPE) for legs and breathlessness across different training modes (RST, gym, soccer training), including statistical comparisons between groups. Saves intermediate results for figure generation.
3.  The **primary ANCOVA analysis** (`ancovas.Rmd`) comparing the pre-post changes in fitness test performance (sprint times, maximal velocity, countermovement jump, maximal aerobic speed) between the two training groups.
4.  **Centralised figure generation** (`figures.Rmd`) for all manuscript figures: power analysis sensitivity curves, dRPE session plots, RPE forest plot, and pre-post raincloud plots.

---

## Software and Platform

*   **Language:** R (use the R version recorded in `renv.lock`; `renv` does not install R itself)
*   **Package Environment:** `renv.lock` is the authoritative record of the R package versions and package sources used for this project.
*   **Primary R Packages:**
    *   **Rendering:** `rmarkdown`, `knitr`
    *   **Data Import, Wrangling & Plotting:** `readr`, `readxl`, `tidyverse`, `dplyr`, `patchwork`, `lemon`, `ggeasy`, `ggdist`, `ggtext`, `visdat`, `here`, `svglite`
    *   **Statistical Analysis:** `Superpower` (for power analysis), `lme4`, `glmmTMB`, `estimatr`, `performance`, `easystats`, `sjPlot`, `broom`, `broom.mixed`, `mixedup`, `emmeans`
*   **GitHub Package:** `mixedup` is installed from GitHub (`m-clark/mixedup`) through the lockfile during `renv::restore()`.
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
│   ├── sensitivity_analysis.rds           # Intermediate results from sensitivity.Rmd (for Figure 2)
│   └── rpe_contrasts.rds                  # Intermediate results from dRPE mixed model.Rmd (for Figure 4)
├── scripts/
│   ├── sensitivity.Rmd                    # Sensitivity power analysis
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

3.  **Restore Required Packages:** Run the following commands in your R console to install `renv` and restore the package environment recorded in `renv.lock`:

    ```r
    install.packages("renv", repos = "https://cloud.r-project.org")
    renv::restore()
    ```

    The lockfile records the package versions and sources used for this project, including the GitHub source for mixedup; it does not install R itself, Pandoc, or operating-system libraries.

4.  **Run the R Markdown Scripts:** Execute the R Markdown files in the `/scripts` directory. You can render them using `rmarkdown::render()` or knit them directly in RStudio. A logical order is:

    *   `sensitivity.Rmd`: Sensitivity power analysis. Saves intermediate results to `data/sensitivity_analysis.rds`.
    *   `dRPE mixed model.Rmd`: Mixed model analysis for training load (dRPE). Saves intermediate results to `data/rpe_contrasts.rds`.
    *   `figures.Rmd`: Generates all manuscript figures (2, 3, 4, 5). Requires `sensitivity.Rmd` and `dRPE mixed model.Rmd` to be run first.
    *   `ancovas.Rmd`: ANCOVA models and diagnostics for all fitness outcomes.

    **Note:** Figures are saved as SVG by default. To generate PNG output instead, change the file extension in the `ggsave()` calls from `.svg` to `.png`.

---

## Relationships Between Files

*   **`sensitivity.Rmd`**: Sensitivity power analysis script that:
    *   Uses meta-analytic data from Thurlow et al. (2024) for covariate-outcome relationships
    *   Uses normative data from Haugen et al. (2020) and Tønnessen et al. (2013) for population parameters
    *   Performs sensitivity analyses to determine detectable effect sizes at 80% power
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

