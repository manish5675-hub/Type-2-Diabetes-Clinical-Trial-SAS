# Type 2 Diabetes Clinical Trial Analysis Using SAS

## 📌 Project Overview

This project demonstrates the use of **SAS programming and statistical methods** to analyze a simulated Phase II randomized clinical trial for Type 2 Diabetes.

The analysis focuses on evaluating **treatment efficacy and safety**, with particular emphasis on changes in HbA1c from baseline and the assessment of adverse events.

The project follows a structured clinical-trial analysis workflow, from raw data preparation to statistical analysis and reporting.

---

## 🎯 Objectives

- Perform clinical trial data cleaning and validation using SAS.
- Summarize demographic and baseline characteristics.
- Evaluate treatment efficacy using HbA1c measurements.
- Analyze change from baseline in HbA1c.
- Compare treatment groups using appropriate statistical methods.
- Summarize adverse events and safety-related variables.
- Generate statistical tables, listings, and figures (TLFs).
- Apply reproducible SAS programming practices for clinical data analysis.

---

## 🧪 Study Overview

| Characteristic | Description |
|---|---|
| Study Type | Randomized Clinical Trial |
| Study Phase | Phase II |
| Therapeutic Area | Type 2 Diabetes |
| Study Duration | 24 Weeks |
| Treatment | Active Treatment vs. Control |
| Primary Efficacy Variable | HbA1c |
| Safety Assessment | Adverse Events & Clinical Parameters |

---

## 📊 Key Analyses

### 1. Data Management & Cleaning

- Imported raw clinical trial data into SAS.
- Checked dataset structure and variable attributes.
- Assessed missing values and duplicate records.
- Created derived analysis variables.
- Applied appropriate labels and formats.
- Performed basic data validation checks.

### 2. Demographic & Baseline Analysis

The following baseline characteristics are summarized by treatment group:

- Age
- Sex
- Weight
- BMI
- Baseline HbA1c
- Other available baseline characteristics

Descriptive statistics include:

- Mean
- Standard deviation
- Median
- Minimum and maximum
- Frequency and percentage

### 3. Efficacy Analysis

The primary efficacy analysis evaluates **change from baseline in HbA1c**.

The change from baseline is calculated as:

**Change from Baseline = Post-Baseline HbA1c − Baseline HbA1c**

Treatment groups are compared using appropriate statistical methods.

Reported measures include:

- Mean change
- Standard deviation
- Treatment-group difference
- 95% confidence interval
- P-value

### 4. Safety Analysis

Safety analysis includes:

- Adverse event frequency
- Adverse event percentage
- Treatment-emergent adverse events, where applicable
- Clinical and laboratory measurements available in the dataset
- Comparison of safety outcomes across treatment groups

### 5. Statistical Reporting

The analysis generates clinical-trial style:

- Tables
- Listings
- Figures (TLFs)

Example outputs include:

- Demographic and baseline characteristics table
- HbA1c efficacy summary
- Adverse event summary
- Patient-level listings
- Graphical comparison of treatment groups

---

## 🛠️ SAS Programming Techniques

The project uses the following SAS programming techniques and procedures:

```text
DATA Step
PROC IMPORT
PROC CONTENTS
PROC SORT
PROC SQL
PROC FREQ
PROC MEANS
PROC SUMMARY
PROC TTEST
PROC GLM
PROC REPORT
PROC TRANSPOSE
ODS
