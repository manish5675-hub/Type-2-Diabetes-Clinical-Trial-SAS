/******************************************************************************
 PROGRAM      : 04_efficacy_analysis.sas
 PURPOSE      : C. Efficacy Analysis - Primary endpoint (change from baseline
                in HbA1c at Week 24) + TLF Table 2
 SAS SKILLS   : PROC TTEST, PROC GLM, PROC MEANS, ODS
 INPUT        : clean.analysis_dataset
 OUTPUT       : Table 2 - HbA1c Efficacy Analysis (RTF + PDF)
******************************************************************************/
%include "&projpath./sas_programs/00_setup.sas";

/* ---------------------------------------------------------------------
   1. Descriptive summary of baseline, Week 24, and change by arm
   --------------------------------------------------------------------- */
proc means data = clean.analysis_dataset n mean std stderr maxdec = 3;
     class treatment_group;
     var hba1c_baseline hba1c_week24 hba1c_chg;
     title "Descriptive Summary: HbA1c by Treatment Group";
run;
title;

/* ---------------------------------------------------------------------
   2. PRIMARY EFFICACY TEST: two-sample t-test on change from baseline
      Auralin (test) vs Novodra (control)
   --------------------------------------------------------------------- */
ods output ttests = work.ttest_results equality = work.ttest_equality
           statistics = work.ttest_stats;

proc ttest data = clean.analysis_dataset;
     class type;
     var hba1c_chg;
     title "Primary Endpoint: Two-Sample T-Test on Change from Baseline in HbA1c";
run;
title;

/* ---------------------------------------------------------------------
   3. PROC GLM - confirms the t-test result via a general linear model
      and allows covariate adjustment (baseline HbA1c, age) if desired
   --------------------------------------------------------------------- */
proc glm data = clean.analysis_dataset;
     class type;
     model hba1c_chg = type / solution;
     lsmeans type / pdiff cl;
     title "PROC GLM: Treatment Effect on Change from Baseline in HbA1c";
run;
quit;
title;

/* Adjusted model - controlling for baseline HbA1c and age */
proc glm data = clean.analysis_dataset;
     class type;
     model hba1c_chg = type hba1c_baseline age / solution;
     lsmeans type / pdiff cl;
     title "PROC GLM: Treatment Effect Adjusted for Baseline HbA1c and Age";
run;
quit;
title;

/* ---------------------------------------------------------------------
   Formatted TLF: Table 2 - HbA1c Efficacy Analysis
   --------------------------------------------------------------------- */
ods rtf file = "&projpath./output/Table2_Efficacy.rtf" style = journal;
ods pdf  file = "&projpath./output/Table2_Efficacy.pdf";

proc report data = work.ttest_stats nowd headline;
     title "Table 2. HbA1c Efficacy Analysis - Change from Baseline at Week 24";
     title2 "Primary Endpoint, Intent-to-Treat Population";
run;

ods rtf close;
ods pdf close;
title;
