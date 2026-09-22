/******************************************************************************
 PROGRAM      : 06_tlf_listing.sas
 PURPOSE      : E. TLF Generation - Listing 1 (patient-level data) and a
                PROC TRANSPOSE example producing a wide subject-by-visit
                HbA1c shell (baseline vs Week 24) commonly needed for
                statistical reporting / shell tables.
 SAS SKILLS   : PROC REPORT, PROC TRANSPOSE, PROC SORT, ODS
 INPUT        : clean.analysis_dataset
 OUTPUT       : Listing 1 - Patient-level Clinical Data
******************************************************************************/
%include "&projpath./sas_programs/00_setup.sas";

proc sort data = clean.analysis_dataset out = work.listing1;
     by treatment_group subject_id;
run;

ods rtf file = "&projpath./output/Listing1_Patient_Data.rtf" style = journal;
ods pdf  file = "&projpath./output/Listing1_Patient_Data.pdf";

proc report data = work.listing1 nowd headline split = "~";
     column subject_id sex age treatment_group hba1c_baseline hba1c_week24
            hba1c_chg adverse_reaction;
     define subject_id      / display "Subject~ID";
     define sex             / display "Sex";
     define age             / display "Age";
     define treatment_group / display "Treatment~Group";
     define hba1c_baseline  / display "Baseline~HbA1c" format = 5.2;
     define hba1c_week24    / display "Week 24~HbA1c"  format = 5.2;
     define hba1c_chg       / display "Change from~Baseline"  format = 5.2;
     define adverse_reaction/ display "Adverse~Reaction";
     title "Listing 1. Patient-level Clinical Data";
     title2 "All Randomized Subjects, Sorted by Treatment Group and Subject ID";
run;

ods rtf close;
ods pdf close;
title;

/* ---------------------------------------------------------------------
   PROC TRANSPOSE demonstration: reshape long (baseline/week24 rows)
   to a wide subject-by-visit shell, useful for spaghetti/profile plots
   and for building a "change from baseline" shell listing
   --------------------------------------------------------------------- */
data work.hba1c_long;
     set clean.analysis_dataset;
     length visit $10;
     visit = "Baseline"; avalc = hba1c_baseline; output;
     visit = "Week24";   avalc = hba1c_week24;   output;
     keep subject_id treatment_group visit avalc;
run;

proc sort data = work.hba1c_long;
     by subject_id visit;
run;

proc transpose data = work.hba1c_long out = work.hba1c_wide (drop = _name_) prefix = hba1c_;
     by subject_id treatment_group;
     id visit;
     var avalc;
run;

proc print data = work.hba1c_wide (obs = 10) noobs;
     title "PROC TRANSPOSE Output: Wide Subject-by-Visit HbA1c Shell (first 10 subjects)";
run;
title;
