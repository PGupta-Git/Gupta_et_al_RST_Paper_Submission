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

**Note:** The `rpe analysis.R` script transforms this wide-format data into a long format with the columns `ID`, `Group`, `Session`, `Mode`, `Measure`, and `Ratings` for analysis.

---

## Scripts Overview

The `/scripts` directory contains the following analysis scripts:

| Script Name | Purpose | Input Data | Output |
|-------------|---------|------------|--------|
| `sample size for sesoi.R` | A priori power analysis to determine optimal sample size | Literature parameters | `figure 2.svg` |
| `rpe analysis.R` | Training load analysis using dRPE | `rpe data.csv` | `figure 3.svg` |
| `ancova_statistical_analysis.R` | ANCOVA models and diagnostics for fitness outcomes | `ANCOVA Final.csv` | Model objects |
| `ancova_figures.R` | Figure generation for ANCOVA analysis | Sources `ancova_statistical_analysis.R`, reads `ANCOVA Final Long.csv` | `figure 4.svg`, `figure 5.svg` |

**Note:** To generate figures for the ANCOVA analysis, run `ancova_figures.R`, which automatically sources `ancova_statistical_analysis.R` first.
