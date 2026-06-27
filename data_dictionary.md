# Data Dictionary

This document describes the variables in the CSV and RDS files in `/data`.

Missing values are represented by empty cells. The analysis scripts interpret
these cells as `NA` when importing data with `read_csv`.

## File: `ANCOVA Final.csv`

Primary fitness test results in wide format. Each row is one participant-test
combination.

Variables:

- `ID`
  - Type: categorical.
  - Units: not applicable.
  - Description: anonymized participant identifier.
- `Group`
  - Type: categorical.
  - Units: not applicable.
  - Valid values: `10-sec` for Group 1 and `20-sec` for Group 2.
- `Test`
  - Type: categorical.
  - Valid values: `Time_10m`, `Time_20m`, `Time_40m`, `Max_Velocity`,
    `CMJH`, and `MAS`.
- `Pre`
  - Type: numeric.
  - Units: vary by `Test`.
  - Description: pre-intervention performance score.
- `Post`
  - Type: numeric.
  - Units: vary by `Test`.
  - Description: post-intervention performance score.

Measurement units for `Pre` and `Post`:

- `Time_10m`, `Time_20m`, and `Time_40m`: seconds.
- `Max_Velocity`: metres per second.
- `CMJH`: centimetres.
- `MAS`: metres per second.

## File: `ANCOVA Final Long.csv`

The same fitness data as `ANCOVA Final.csv`, structured in long format for
plotting with `ggplot2`.

Variables:

- `ID`: anonymized participant identifier.
- `Group`: assigned training group; valid values are `10-sec` and `20-sec`.
- `Timeline`: measurement time point; valid values are `Pre` and `Post`.
- `Test`: physical performance test.
- `Value`: score for the given `Test` and `Timeline`.

Units for `Value` match the units listed for `ANCOVA Final.csv`.

## File: `rpe data.csv`

Training-load data collected as differential ratings of perceived exertion.
The file is in wide format: rows are participants and columns are session,
training-mode, and measure combinations.

Identifier columns:

- `ID`: anonymized participant identifier.
- `Group`: assigned training group; valid values are `10-sec` and `20-sec`.

Data columns follow this pattern:

```text
<Session>_<Mode>_<Measure>
```

Pattern fields:

- `<Session>`: integer session number from 1 to 12.
- `<Mode>`: `Gym`, `RST`, `FT`, or `Match`.
- `<Measure>`: `L` for legs or `B` for breathlessness.

Example: `S1_Gym_L` is the legs dRPE rating from the first gym session.

Values are integer arbitrary units on the CR100 scale, with a valid range of
0 to 100.

The `dRPE mixed model.Rmd` script reshapes this file into long format with
`ID`, `Group`, `Session`, `Mode`, `Measure`, and `Ratings` columns.

## File: `sensitivity_analysis.rds`

Intermediate results from `sensitivity.Rmd`, used by `figures.Rmd` to generate
Figure 2.

The object is a named list with these elements:

- `sen.10m`: sensitivity results for 10 m sprint.
- `sen.20m`: sensitivity results for 20 m sprint.
- `sen.40m`: sensitivity results for 40 m sprint.
- `sen.vmax`: sensitivity results for maximal velocity.
- `sen.cmj`: sensitivity results for countermovement jump height.
- `sen.mas`: sensitivity results for maximal aerobic speed.
- `critical.10`: critical effect size at 80% power for 10 m sprint.
- `critical.20`: critical effect size at 80% power for 20 m sprint.
- `critical.40`: critical effect size at 80% power for 40 m sprint.
- `critical.vmax`: critical effect size at 80% power for maximal velocity.
- `critical.cmj`: critical effect size at 80% power for jump height.
- `critical.mas`: critical effect size at 80% power for aerobic speed.

Each `sen.*` data frame contains a scenario column, two group columns, and a
`Power` column.

## File: `rpe_contrasts.rds`

Between-group contrast results from `dRPE mixed model.Rmd`, used by
`figures.Rmd` to generate Figure 4.

The contrasts are derived from a `glmmTMB` model that accounts for
heterogeneous variance across training modes.

Variables:

- `Mode`: training mode.
- `contrast`: pairwise contrast, expressed as Group One minus Group Two.
- `estimate`: estimated between-group RPE difference in arbitrary units.
- `SE`: standard error of the estimate.
- `df`: degrees of freedom.
- `lower.CL.bonf`: lower Bonferroni-adjusted confidence limit.
- `upper.CL.bonf`: upper Bonferroni-adjusted confidence limit.
- `p.value.bonf`: Bonferroni-adjusted p-value.

## Scripts Overview

The `/scripts` directory contains R Markdown analysis files.

- `sensitivity.Rmd`
  - Purpose: sensitivity power analysis.
  - Input: study design parameters.
  - Output: `data/sensitivity_analysis.rds`.
- `dRPE mixed model.Rmd`
  - Purpose: mixed-model analysis for dRPE ratings.
  - Input: `data/rpe data.csv`.
  - Output: `data/rpe_contrasts.rds` and model diagnostics.
- `figures.Rmd`
  - Purpose: manuscript figure generation.
  - Inputs: intermediate RDS files, RPE data, and long-format ANCOVA data.
  - Output: `figures/figure 2.svg` through `figures/figure 5.svg`.
- `ancovas.Rmd`
  - Purpose: ANCOVA models and diagnostics for fitness outcomes.
  - Input: `data/ANCOVA Final.csv`.
  - Output: model results and diagnostics.

All scripts use `here` for file path handling. Figures are output as SVG by
default. Change the extension in `ggsave()` calls to `.png` for PNG output.

## Reproducible Package Environment

Restore the R package environment with `renv::restore()` before rendering the
analysis files. The lockfile records package versions and sources, including
the GitHub source for `mixedup`.

`renv-dependencies.R` declares runtime package dependencies for `renv` only.
It is not an analysis script.

## Execution Order

Run the scripts in this order:

1. `sensitivity.Rmd`, which generates intermediate data for Figure 2.
2. `dRPE mixed model.Rmd`, which generates intermediate data for Figure 4.
3. `figures.Rmd`, which generates manuscript figures 2 through 5.
4. `ancovas.Rmd`, which runs the ANCOVA analysis.
