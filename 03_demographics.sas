/******************************************************************************
 PROGRAM      : 03_demographics.sas
 PURPOSE      : B. Demographic Analysis + TLF Table 1
 SAS SKILLS   : PROC FREQ, PROC MEANS, PROC SUMMARY, PROC REPORT, ODS
 INPUT        : clean.analysis_dataset
 OUTPUT       : Table 1 - Demographic & Baseline Characteristics (RTF + PDF)
******************************************************************************/
%include "&projpath./sas_programs/00_setup.sas";

/* Categorical summaries by treatment group */
proc freq data = clean.analysis_dataset;
     tables treatment_group sex treatment_group*sex / nocol norow;
     title "Table 1a: Sex Distribution by Treatment Group";
run;
title;

/* Continuous baseline summaries by treatment group */
proc means data = clean.analysis_dataset n mean std median min max maxdec = 2;
     class treatment_group;
     var age weight_kg bmi hba1c_baseline;
     title "Table 1b: Baseline Continuous Characteristics by Treatment Group";
run;
title;

/* PROC SUMMARY equivalent, output to a dataset for the formatted TLF table */
proc summary data = clean.analysis_dataset nway;
     class treatment_group;
     var age weight_kg bmi hba1c_baseline;
     output out = work.demo_summary (drop = _type_ _freq_)
            n = n_age n_wt n_bmi n_hba1c
            mean = mean_age mean_wt mean_bmi mean_hba1c
            std  = std_age  std_wt  std_bmi  std_hba1c;
run;

/* ---------------------------------------------------------------------
   Formatted TLF: Table 1 - Demographic & Baseline Characteristics
   --------------------------------------------------------------------- */
ods rtf file = "&projpath./output/Table1_Demographics.rtf" style = journal;
ods pdf  file = "&projpath./output/Table1_Demographics.pdf";

proc report data = clean.analysis_dataset nowd headline;
     column treatment_group age weight_kg bmi hba1c_baseline;
     define treatment_group / group "Treatment Group";
     define age             / analysis mean format = 5.1 "Age, years\Mean";
     define weight_kg       / analysis mean format = 6.1 "Weight, kg\Mean";
     define bmi             / analysis mean format = 5.1 "BMI, kg/m2\Mean";
     define hba1c_baseline  / analysis mean format = 5.2 "Baseline HbA1c, %\Mean";
     title "Table 1. Demographic and Baseline Characteristics";
     title2 "Intent-to-Treat Population";
run;

ods rtf close;
ods pdf close;
title;
