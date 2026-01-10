# Data Dictionary

This document provides a detailed description of the variables contained in the CSV files within the `/data` directory.

**Missing Data:** Across all files, missing values are represented by empty cells, which are interpreted as `NA` by R when using `read_csv`.

---

## File: `ANCOVA Final.csv`

This file contains the primary fitness test results for each participant in a wide format. Each row represents a unique combination of a participant and a specific test.

| Variable Name | Data Type   | Measurement Units | Description                                                                                                                                                            |
|---------------|-------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ID`          | Categorical | N/A               | A unique, anonymized identifier for each participant.                                                                                                                  |
| `Group`       | Categorical | N/A               | The assigned training group. Valid values: `10-sec` (Group 1), `20-sec` (Group 2).                                                                                     |
| `Test`        | Categorical | N/A               | The physical performance test conducted. Valid values: `Time_10m`, `Time_20m`, `Time_40m` (Sprint Times), `Max_Velocity` (Maximal Sprinting Speed), `CMJH` (Countermovement Jump Height), `MAS` (Maximal Aerobic Speed). |
| `Pre`         | Numeric     | Varies by `Test`  | The performance score on the test before the intervention period. See units below.                                                                                     |
| `Post`        | Numeric     | Varies by `Test`  | The performance score on the test after the intervention period. See units below.                                                                                      |

**Measurement Units for `Pre` and `Post` variables based on `Test`:**
*   `Time_10m`, `Time_20m`, `Time_40m`: Seconds (s)
*   `Max_Velocity`: Meters per second (m·s⁻¹)
*   `CMJH`: Centimeters (cm)
*   `MAS`: Meters per second (m·s⁻¹)

---

## File: `ANCOVA Final Long.csv`

This file contains the same data as `ANCOVA Final.csv` but is structured in a long format, primarily for use in plotting with `ggplot2`.

| Variable Name | Data Type   | Measurement Units | Description                                                                                                                                                            |
|---------------|-------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ID`          | Categorical | N/A               | A unique, anonymized identifier for each participant.                                                                                                                  |
| `Group`       | Categorical | N/A               | The assigned training group. Valid values: `10-sec`, `20-sec`.                                                                                                         |
| `Timeline`    | Categorical | N/A               | The time point of the measurement. Valid values: `Pre`, `Post`.                                                                                                        |
| `Test`        | Categorical | N/A               | The physical performance test conducted. See `ANCOVA Final.csv` for a list of valid values.                                                                            |
| `Value`       | Numeric     | Varies by `Test`  | The performance score for the given `Test` at the specified `Timeline`. See `ANCOVA Final.csv` for measurement units.                                                  |

---

## File: `rpe data.csv`

This file contains the training load data, collected as differential ratings of perceived exertion (dRPE). The data is in a very wide format, with each row representing one participant and columns representing dRPE ratings for specific sessions, training modes, and measures.

### Identifier Columns

| Variable Name | Data Type   | Measurement Units | Description                                                                    |
|---------------|-------------|-------------------|--------------------------------------------------------------------------------|
| `ID`          | Categorical | N/A               | A unique, anonymized identifier for each participant.                          |
| `Group`       | Categorical | N/A               | The assigned training group. Valid values: `10-sec`, `20-sec`.                 |

### Data Columns

The remaining columns follow a structured naming convention: `S<Session>_<Mode>_<Measure>`.

*   **`S<Session>`**: The session number.
    *   **Data Type:** Numeric (Integer)
    *   **Valid Range:** 1 to 12.
*   **`<Mode>`**: The type of training session.
    *   **Data Type:** Categorical
    *   **Valid Values:** `Gym` (Gym-Based Training), `RST` (Repeated-Sprint Training), `FT` (Soccer Training), `Match` (Competitive Match).
*   **`<Measure>`**: The type of dRPE rating.
    *   **Data Type:** Categorical
    *   **Valid Values:** `L` (Legs dRPE), `B` (Breathlessness dRPE).

**Example:** The column `S1_Gym_L` contains the dRPE rating for the legs from the first gym session.

The values within these columns represent the dRPE rating.
*   **Data Type:** Numeric (Integer)
*   **Measurement Units:** Arbitrary Units (AU)
*   **Valid Range:** 0-100 (based on the CR100 scale).

**Note:** The `dRPE mixed model.Rmd` script transforms this wide-format data into a long format with the columns `ID`, `Group`, `Session`, `Mode`, `Measure`, and `Ratings` for analysis.

---

## File: `journal.pone.0299204.s001.csv`

This file contains supplementary data from Lee et al. (2024) used to validate the SESOI calculation approach. It includes sprint performance data from an intervention study.

**Source:** Lee et al. (2024). [DOI: 10.1371/journal.pone.0299204](https://doi.org/10.1371/journal.pone.0299204)

| Variable Name | Data Type   | Measurement Units | Description                                                                    |
|---------------|-------------|-------------------|--------------------------------------------------------------------------------|
| `NO`          | Numeric     | N/A               | Participant number/identifier.                                                 |
| `Group`       | Categorical | N/A               | Intervention group assignment (1 = intervention, 2 = control).                 |
| `5sp_Pre`     | Numeric     | Seconds (s)       | 5m sprint time at pre-test.                                                    |
| `5sp_Post`    | Numeric     | Seconds (s)       | 5m sprint time at post-test.                                                   |
| `10sp_Pre`    | Numeric     | Seconds (s)       | 10m sprint time at pre-test.                                                   |
| `10sp_Post`   | Numeric     | Seconds (s)       | 10m sprint time at post-test.                                                  |
| `20sp_Pre`    | Numeric     | Seconds (s)       | 20m sprint time at pre-test.                                                   |
| `20sp_Post`   | Numeric     | Seconds (s)       | 20m sprint time at post-test.                                                  |
| `30sp_Pre`    | Numeric     | Seconds (s)       | 30m sprint time at pre-test.                                                   |
| `30sp_Post`   | Numeric     | Seconds (s)       | 30m sprint time at post-test.                                                  |

---

## File: `Sprinttest_Olympiatoppen.csv`

This file contains sprint test data from elite Norwegian athletes, used to assess linearity across sprint distances. Originally from Haugen et al. (2019).

**Source:** Haugen et al. (2019). [DOI: 10.18710/PJONBM](https://doi.org/10.18710/PJONBM)

| Variable Name   | Data Type   | Measurement Units | Description                                                                    |
|-----------------|-------------|-------------------|--------------------------------------------------------------------------------|
| `ID`            | Numeric     | N/A               | Unique identifier for each athlete.                                            |
| `Sport`         | Categorical | N/A               | The sport of the athlete.                                                      |
| `Sex`           | Categorical | N/A               | Sex of the athlete (M/F).                                                      |
| `10 m`          | Numeric     | Seconds (s)       | 10m sprint time.                                                               |
| `20 m`          | Numeric     | Seconds (s)       | 20m sprint time.                                                               |
| `30 m`          | Numeric     | Seconds (s)       | 30m sprint time.                                                               |
| `40 m`          | Numeric     | Seconds (s)       | 40m sprint time.                                                               |

**Note:** This dataset may contain additional columns not listed here. The variables above are the primary ones used in the analysis.

---

## Scripts Overview

The `/scripts` directory contains R Markdown analysis files that replace the legacy R scripts:

| Script Name | Purpose | Input Data | Output |
|-------------|---------|------------|--------|
| `sesoi.Rmd` | SESOI calculation and a priori power analysis | `journal.pone.0299204.s001.csv`, `Sprinttest_Olympiatoppen.csv` | `figures/figure 2.svg` |
| `dRPE mixed model.Rmd` | Training load analysis using mixed models for dRPE | `rpe data.csv` | Model diagnostics |
| `figures.Rmd` | dRPE and pre-post-test figure generation | `rpe data.csv`, `ANCOVA Final Long.csv` | `figures/figure 3.svg`, `figures/figure 4.svg` |
| `ancovas.Rmd` | ANCOVA models and diagnostics for fitness outcomes | `ANCOVA Final.csv` | Model results and diagnostics |

**Note:** All scripts use the `here` package for file path handling. Figures are output as SVG by default; change the file extension to `.png` in the `ggsave()` calls for PNG output. Legacy R scripts are preserved in `scripts/archive/` for reference.
