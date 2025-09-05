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
1.  An **a priori power analysis** to determine and justify the sample size required to detect the smallest effect size of interest (SESOI) for various fitness outcomes.
2.  An **analysis of training load**, using differential ratings of perceived exertion (dRPE) for legs and breathlessness across different training modes (RST, gym, soccer training).
3.  The **primary ANCOVA analysis** comparing the pre-post changes in fitness test performance (sprint times, maximal velocity, countermovement jump, maximal aerobic speed) between the two training groups.

---

## Software and Platform

*   **Language:** R (version 4.0 or later recommended)
*   **Primary R Packages:**
    *   **Data Wrangling & Plotting:** `tidyverse`, `dplyr`, `patchwork`, `lemon`, `ggeasy`, `ggrain`, `ggdist`, `ggtext`, `visdat`
    *   **Statistical Analysis:** `Superpower` (for power analysis), `lme4`, `estimatr`, `performance`, `easystats`, `sjPlot`, `broom.mixed`, `modelbased`, `MuMIn`, `VCA`, `mixedup`
*   **Recommended IDE:** RStudio, VSCode with R extensions, or Positron. The scripts are designed to work well within an R project structure where the working directory is set to the project root.

---

## Map of the Documentation & File Structure

The project is organized into the following directories and files:

```
├── README.md                    # This file
├── LICENSE.md                   # Data and code licenses
├── data_dictionary.md           # Detailed description of all variables
├── data/
│   ├── ANCOVA Final.csv         # Primary fitness test data (wide format)
│   ├── ANCOVA Final Long.csv    # Fitness test data for plotting (long format)
│   └── rpe data.csv             # Training load data (wide format)
└── scripts/
    ├── sample size for sesoi.R  # A priori power analysis script
    ├── rpe analysis.R           # Training load (RPE) analysis script
    └── ancova analysis.R        # Main fitness outcomes ANCOVA script
```

---

## Instructions for Reproducing the Results

1.  **Clone or Download:** Clone this repository or download the zip file and extract it to a local directory.

2.  **Set Working Directory:** Open the project in your IDE (e.g., RStudio by opening the `.Rproj` file if available, or by opening the folder in VSCode/Positron). The scripts assume the working directory is the root of the project folder.

3.  **Install Required Packages:** Run the following command in your R console to install all necessary packages for all the scripts.

For example:

    ```R
    install.packages(c(
      "Superpower", "easystats", "tidyverse", "dplyr", "readxl", "lemon",
      "patchwork", "ggeasy", "lme4", "performance", "broom.mixed",
      "modelbased", "sjPlot", "estimatr", "naniar", "ggrain", "ggdist",
      "ggtext", "MuMIn", "VCA", "mixedup"
    ))
    ```

4.  **Run the Scripts:** Execute the R scripts located in the `/scripts` directory. A logical order is:
    *   `sample size for sesoi.R`: To understand the sample size justification. This script generates `figure 2.svg`.
    *   `rpe analysis.R`: To analyze the training load data. This script generates `figure 3.svg`.
    *   `ancova analysis.R`: To run the primary analysis on fitness outcomes. This script generates `figure 4.svg` and `figure 5.svg`.

---

## Relationships Between Files

*   **`sample size for sesoi.R`**: This is a standalone script for the *a priori* power analysis. It does not use any data from the `/data` folder but relies on parameters from published literature to inform its calculations.

*   **`rpe analysis.R`**: This script reads `data/rpe data.csv`, transforms it from wide to long format, and performs a linear model analysis on the training load data.

*   **`ancova analysis.R`**: This script is the core analysis of the study's outcomes.
    *   It reads `data/ANCOVA Final.csv` to perform the statistical ANCOVA models.
    *   It reads `data/ANCOVA Final Long.csv` to generate the raincloud plots for visualizing pre-post changes.
    *   `ANCOVA Final Long.csv` is a long-format representation of the data in `ANCOVA Final.csv`.
