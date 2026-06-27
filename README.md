# RST Soccer Training Analysis Repository

Repository for the published repeated-sprint training study in
semi-professional male soccer players.

DOI: <https://doi.org/10.1080/24733938.2026.2684071>

## Authors

- Palash Gupta (1)
- Anthony P. Turner (1)
- Shaun M. Phillips (1)
- Matthew Weston (1, 2; corresponding author)

Affiliations:

1. Institute for Sport, Physical Education and Health Sciences, University of
   Edinburgh, Edinburgh, Scotland.
2. Institute of Sport, Manchester Metropolitan University, Manchester, UK.

Corresponding author: <Matthew.Weston@ed.ac.uk>

ORCID:

- PG: <https://orcid.org/0009-0000-0172-4009>
- AT: <https://orcid.org/0000-0003-1202-6649>
- SP: <https://orcid.org/0000-0002-7947-3403>
- MW: <https://orcid.org/0000-0002-9531-3004>

## Citation

If you use the data, scripts, or findings from this study, cite:

> Gupta, P., Turner, A. P., Phillips, S. M., & Weston, M. (2026). A pragmatic,
> parallel-arm, randomised trial on the effects of two repeated-sprint training
> protocols on fitness outcomes in semi-professional male soccer players:
> preliminary report. *Science and Medicine in Football*.
> <https://doi.org/10.1080/24733938.2026.2684071>

## Project Description

This project contains data and analysis scripts for a study comparing two
repeated-sprint training protocols in soccer players:

- Group 1: 10-second recoveries.
- Group 2: 20-second recoveries.

The repository includes:

1. `scripts/sensitivity.Rmd`: sensitivity power analysis.
2. `scripts/dRPE mixed model.Rmd`: training-load mixed-model analysis.
3. `scripts/figures.Rmd`: centralised manuscript figure generation.
4. `scripts/ancovas.Rmd`: ANCOVA analysis for fitness outcomes.

## Software and Platform

- Language: R. Use the R version recorded in `renv.lock`.
- Package environment: `renv.lock` is authoritative for R package versions.
- Rendering packages: `rmarkdown` and `knitr`.
- Data and plotting packages include `readr`, `readxl`, `tidyverse`, `dplyr`,
  `patchwork`, `lemon`, `ggeasy`, `ggdist`, `ggtext`, `visdat`, `here`, and
  `svglite`.
- Statistical packages include `Superpower`, `lme4`, `glmmTMB`, `estimatr`,
  `performance`, `easystats`, `sjPlot`, `broom`, `broom.mixed`, `mixedup`,
  and `emmeans`.
- `mixedup` is restored from GitHub (`m-clark/mixedup`) through `renv.lock`.
- Recommended IDEs: RStudio, VSCode with R extensions, or Positron.

`renv` restores R packages. It does not install R itself, Pandoc, compilers,
or operating-system libraries.

## Map of the Documentation and File Structure

```text
README.md                 This file.
.Rprofile                 Activates the renv project environment.
.gitignore                Ignores local R and rendered HTML files.
renv.lock                 Reproducible R package lockfile.
renv-dependencies.R       Runtime dependency hints for renv.
renv/activate.R           renv bootstrap script.
renv/settings.json        renv project settings.
renv/.gitignore           Ignores local renv libraries and caches.
LICENSE.md                Data and code license information.
data_dictionary.md        Data and analysis output documentation.
data/                     Source data and intermediate RDS outputs.
scripts/                  R Markdown analysis files.
figures/                  Generated manuscript figures.
```

Important data files:

- `data/ANCOVA Final.csv`: primary fitness data in wide format.
- `data/ANCOVA Final Long.csv`: fitness data in long format for plotting.
- `data/rpe data.csv`: training-load data.
- `data/sensitivity_analysis.rds`: output from `sensitivity.Rmd`.
- `data/rpe_contrasts.rds`: output from `dRPE mixed model.Rmd`.

Generated figure files:

- `figures/figure 2.svg`: power analysis sensitivity curves.
- `figures/figure 3.svg`: dRPE session plot.
- `figures/figure 4.svg`: RPE forest plot.
- `figures/figure 5.svg`: pre-post raincloud plots.

## Instructions for Reproducing the Results

1. Clone this repository, or download and extract the zip archive.
2. Open the project folder in RStudio, VSCode, or Positron.
3. Restore the package environment:

   ```r
   install.packages("renv", repos = "https://cloud.r-project.org")
   renv::restore()
   ```

4. Render the R Markdown files in this order:

   1. `scripts/sensitivity.Rmd`
   2. `scripts/dRPE mixed model.Rmd`
   3. `scripts/figures.Rmd`
   4. `scripts/ancovas.Rmd`

The first two scripts create intermediate `.rds` files needed by
`figures.Rmd`. Figures are saved as SVG by default. To generate PNG files,
change the extensions in the `ggsave()` calls.

## Relationships Between Files

`sensitivity.Rmd`:

- Uses covariate-outcome relationships from Thurlow et al. (2024).
- Uses normative data from Haugen et al. (2020) and Tønnessen et al. (2013).
- Saves `data/sensitivity_analysis.rds` for Figure 2.

`dRPE mixed model.Rmd`:

- Reads `data/rpe data.csv`.
- Fits mixed models for dRPE ratings.
- Refits the final model with `glmmTMB` and mode-specific variance.
- Saves `data/rpe_contrasts.rds` for Figure 4.

`figures.Rmd`:

- Reads both intermediate `.rds` files.
- Reads the raw RPE and long-format ANCOVA data.
- Writes Figures 2 through 5 to `figures/`.

`ancovas.Rmd`:

- Reads `data/ANCOVA Final.csv`.
- Fits ANCOVA models for all six fitness outcomes.
- Includes assumption checks, outlier diagnostics, and robust standard errors.
