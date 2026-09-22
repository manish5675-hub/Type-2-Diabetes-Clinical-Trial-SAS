# Analysis Report — Type 2 Diabetes Clinical Trial (Auralin vs. Novodra)

## 1. Background and Objective

This is a simulated Phase II randomized clinical trial comparing an investigational
insulin therapy, **Auralin (Test)**, against an active comparator, **Novodra
(Control)**, in adult patients with Type 2 Diabetes. The objective of this project
is to evaluate the **efficacy** (change from baseline in HbA1c at Week 24) and
**safety** (adverse events, vital signs) of Auralin relative to Novodra, and to
produce a standard set of clinical Tables, Listings, and Figures (TLFs).

## 2. Data Sources

| File | Rows (raw) | Description |
|---|---|---|
| `patients_raw.csv` | 502 | Demographics and contact information |
| `treatments_raw.csv` | 700 | Treatment assignment, dosage, baseline/Week 24 HbA1c, adverse reactions |

## 3. Data Management / Cleaning Log

A structured data-quality review was performed before analysis. Every issue found
and the corrective action taken is logged below so the cleaning is fully
reproducible (see `sas_programs/02_data_cleaning.sas` and `clean_and_analyze.py`).

| # | Issue Found | Evidence | Action Taken |
|---|---|---|---|
| 1 | 6 placeholder/test rows ("John Doe") in `patients_raw.csv` | Non-physiological duplicate contact records | Removed |
| 2 | 5 exact duplicate patient rows | Full-row duplicates | Removed (kept first) |
| 3 | 2 exact duplicate treatment rows | Full-row duplicates | Removed (kept first) |
| 4 | **Export artifact**: `hba1c_start`/`hba1c_end` were duplicated onto *both* an `auralin` row and a `novodra` row for **every one of the 349 unique patients**, making it look like every patient was enrolled in both arms | Profiling showed identical HbA1c pairs on both rows for the same name; but exactly **one** row per patient carries real `dosage_start`/`dosage_end` data (the other shows `"No data"`) | The row with a real, non-missing dosage value was kept as the patient's true, single treatment arm; the mirrored row was dropped |
| 5 | `dosage_start` / `dosage_end` stored as text with the literal string `"No data"` for missing | — | Converted to numeric with proper missing values |
| 6 | `adverse_reaction` stored as `"No data"` string | — | Converted to a true missing value; `ae_flag` (Y/N) derived |
| 7 | Weight recorded in pounds | — | Converted to kilograms (`weight_kg`) for clinical convention |
| 8 | 6 subjects in the resolved treatment roster have no matching demographic record in `patients_clean.csv` | Left join produced missing age/sex/weight/BMI | Retained in the efficacy population (HbA1c come from the treatments file only); flagged with missing demographics |

**Resolved analysis population:** 349 unique subjects — **174 Auralin**, **175 Novodra**.

## 4. Demographic Summary (Table 1)

| Characteristic | Auralin (Test) N=174 | Novodra (Control) N=175 |
|---|---|---|
| Age, years — Mean (SD) | 56.5 (23.6) | 57.6 (22.4) |
| Age, years — Median (Min, Max) | 57 (16, 94) | 58 (16, 93) |
| Sex — Female, n (%) | 94 (54.3%) | 82 (48.2%) |
| Sex — Male, n (%) | 79 (45.7%) | 88 (51.8%) |
| Weight, kg — Mean (SD) | 78.2 (15.4) | 78.1 (15.6) |
| BMI, kg/m² — Mean (SD) | 27.6 (5.3) | 27.0 (5.4) |
| Baseline HbA1c, % — Mean (SD) | 7.96 (0.57) | 7.95 (0.52) |

The two arms were well balanced at baseline on age, sex, weight, BMI, and
baseline HbA1c, supporting the validity of the between-group efficacy comparison.

## 5. Efficacy Analysis (Table 2) — Primary Endpoint

**Primary endpoint:** Change from Baseline in HbA1c at Week 24
(Week 24 HbA1c − Baseline HbA1c; a negative value indicates improvement).

| Parameter | Auralin (Test) | Novodra (Control) | Difference (Auralin − Novodra) | p-value |
|---|---|---|---|---|
| Baseline HbA1c, % | 7.96 (0.57) | 7.95 (0.52) | — | — |
| Week 24 HbA1c, % | 7.57 (0.57) | 7.55 (0.53) | — | — |
| **Change from Baseline, %** | **−0.39 (0.06)** | **−0.40 (0.06)** | **0.018 (95% CI: 0.006, 0.030)** | **0.0044** |

**Interpretation:** Both treatments produced a clinically meaningful reduction in
HbA1c from baseline to Week 24 (≈0.4 percentage points). The two-sample t-test
(`PROC TTEST`, confirmed with `PROC GLM`) found a small but statistically
significant difference between arms (mean difference = 0.018%, 95% CI 0.006 to
0.030, p = 0.0044): Novodra produced a marginally larger mean reduction than
Auralin. The absolute difference is small relative to the overall reduction seen
in both arms and its clinical significance would need to be judged against
pre-specified non-inferiority/superiority margins in a real protocol.

## 6. Safety Analysis (Table 3 & 4)

**Overall adverse event incidence:** 14/174 (8.0%) Auralin vs. 20/175 (11.4%) Novodra.

| Adverse Event (Preferred Term) | Auralin (Test) | Novodra (Control) |
|---|---|---|
| Hypoglycemia | 9 (5.2%) | 10 (5.7%) |
| Injection site discomfort | 0 (0.0%) | 6 (3.4%) |
| Headache | 1 (0.6%) | 2 (1.1%) |
| Throat irritation | 2 (1.1%) | 0 (0.0%) |
| Cough | 1 (0.6%) | 1 (0.6%) |
| Nausea | 1 (0.6%) | 1 (0.6%) |

Hypoglycemia was the most common adverse event in both arms, consistent with the
known safety profile of insulin therapies. Injection site discomfort was only
observed with Novodra.

**Vital signs / dosage summary (Table 4):** Mean weight, height, and BMI were
similar between arms at baseline. Mean ending dosage was higher for Auralin
(47.4 units) than Novodra (38.7 units), while starting dosage was comparable
(≈39 units in both arms) — consistent with an up-titration protocol.

## 7. TLF Deliverables

| Output | File |
|---|---|
| Table 1 — Demographic & Baseline Characteristics | `output/table1_demographics.csv`, `Table1_Demographics.rtf/pdf` |
| Table 2 — HbA1c Efficacy Analysis | `output/table2_efficacy.csv`, `Table2_Efficacy.rtf/pdf` |
| Table 3 — Adverse Event Summary | `output/table3_ae_summary.csv`, `Table3_AE_Summary.rtf/pdf` |
| Table 4 — Vital Sign Summary | `output/table4_vitals.csv`, `Table4_Vitals.rtf/pdf` |
| Listing 1 — Patient-level Clinical Data | `output/listing1_patient_data.csv`, `Listing1_Patient_Data.rtf/pdf` |
| Figure 1 — HbA1c Change by Treatment | `output/figure1_hba1c_change.png` |

*Note: the `.rtf`/`.pdf` TLF outputs are produced when `sas_programs/*.sas` is run
in a licensed SAS environment via `ODS RTF`/`ODS PDF`. This repository ships the
Python-reproduced `.csv`/`.png` equivalents of every table and figure so results
are viewable without a SAS license.*

## 8. Limitations

- This is a **simulated** dataset for portfolio/training purposes; it should not
  be interpreted as evidence about any real drug.
- The treatments file's duplication artifact (Section 3, issue 4) was resolved
  using the dosage field as the ground truth for arm assignment; this is a
  reasonable but assumption-based resolution given no unique subject identifier
  was available in the source files.
- Randomization/stratification variables and prior medical history were not
  available in the source data, so the efficacy comparison is unadjusted for
  covariates beyond the optional `PROC GLM` sensitivity model (age, baseline
  HbA1c).
