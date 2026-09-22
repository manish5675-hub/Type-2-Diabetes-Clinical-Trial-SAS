/******************************************************************************
 PROGRAM      : 05_safety_analysis.sas
 PURPOSE      : D. Safety Analysis (AEs, TEAEs, vital signs) + TLF Table 3 & 4
 SAS SKILLS   : PROC FREQ, PROC MEANS, PROC REPORT, ODS
 INPUT        : clean.analysis_dataset
 OUTPUT       : Table 3 - Adverse Event Summary; Table 4 - Vital Sign Summary
******************************************************************************/
%include "&projpath./sas_programs/00_setup.sas";

/* ---------------------------------------------------------------------
   1. Overall AE incidence by treatment group
   --------------------------------------------------------------------- */
proc freq data = clean.analysis_dataset;
     tables treatment_group * ae_flag / nocol norow chisq;
     title "Table 3a: Overall Adverse Event Incidence by Treatment Group";
run;
title;

/* ---------------------------------------------------------------------
   2. AE incidence by preferred term (treatment-emergent AEs -
      all AEs collected in this trial were, by design, treatment-emergent)
   --------------------------------------------------------------------- */
proc freq data = clean.analysis_dataset;
     where not missing(adverse_reaction);
     tables adverse_reaction * treatment_group / norow nocol;
     title "Table 3b: Treatment-Emergent Adverse Events by Preferred Term";
run;
title;

ods rtf file = "&projpath./output/Table3_AE_Summary.rtf" style = journal;
ods pdf  file = "&projpath./output/Table3_AE_Summary.pdf";

proc report data = clean.analysis_dataset nowd headline;
     where not missing(adverse_reaction);
     column adverse_reaction treatment_group,(n);
     define adverse_reaction / group "Adverse Event (Preferred Term)";
     define treatment_group  / across "Treatment Group";
     define n / "n";
     title "Table 3. Adverse Event Summary by Preferred Term and Treatment Group";
run;

ods rtf close;
ods pdf close;
title;

/* ---------------------------------------------------------------------
   3. Vital signs / physical measures summary
   --------------------------------------------------------------------- */
proc means data = clean.analysis_dataset n mean std min max maxdec = 1;
     class treatment_group;
     var weight_kg height_in bmi dosage_start dosage_end;
     title "Table 4a: Vital Signs and Dosage Summary by Treatment Group";
run;
title;

ods rtf file = "&projpath./output/Table4_Vitals.rtf" style = journal;
ods pdf  file = "&projpath./output/Table4_Vitals.pdf";

proc report data = clean.analysis_dataset nowd headline;
     column treatment_group weight_kg height_in bmi dosage_start dosage_end;
     define treatment_group / group "Treatment Group";
     define weight_kg       / analysis mean format = 6.1 "Weight, kg\Mean";
     define height_in       / analysis mean format = 5.1 "Height, in\Mean";
     define bmi             / analysis mean format = 5.1 "BMI, kg/m2\Mean";
     define dosage_start    / analysis mean format = 5.1 "Dosage Start\Mean";
     define dosage_end      / analysis mean format = 5.1 "Dosage End\Mean";
     title "Table 4. Vital Sign and Dosage Summary by Treatment Group";
run;

ods rtf close;
ods pdf close;
title;
