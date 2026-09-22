/******************************************************************************
 PROGRAM      : 01_import_data.sas
 PURPOSE      : A. Data Management (Import + structure checks)
                - PROC IMPORT raw CSV files
                - PROC CONTENTS to check structure / variable types
                - PROC SORT to prepare data for downstream joins
 SAS SKILLS   : PROC IMPORT, PROC CONTENTS, PROC SORT
 INPUT        : raw.patients_raw.csv, raw.treatments_raw.csv
 OUTPUT       : work.patients_raw, work.treatments_raw (sorted)
******************************************************************************/
%include "&projpath./sas_programs/00_setup.sas";

/* ---------------------------------------------------------------------
   1. Import the two raw source files exported from the trial database
   --------------------------------------------------------------------- */
proc import datafile = "&projpath./data/raw/patients_raw.csv"
            out       = work.patients_raw
            dbms      = csv
            replace;
     guessingrows = max;
run;

proc import datafile = "&projpath./data/raw/treatments_raw.csv"
            out       = work.treatments_raw
            dbms      = csv
            replace;
     guessingrows = max;
run;

/* ---------------------------------------------------------------------
   2. Check structure / variable types / attributes for both datasets
   --------------------------------------------------------------------- */
proc contents data = work.patients_raw varnum; 
     title "PROC CONTENTS: Patients (raw)";
run;

proc contents data = work.treatments_raw varnum;
     title "PROC CONTENTS: Treatments (raw)";
run;
title;

/* ---------------------------------------------------------------------
   3. Sort both datasets by patient name (the join key available in
      this source system) ahead of the cleaning / merge step
   --------------------------------------------------------------------- */
proc sort data = work.patients_raw out = work.patients_sorted;
     by given_name surname;
run;

proc sort data = work.treatments_raw out = work.treatments_sorted;
     by given_name surname type;
run;

/* Persist a copy for downstream programs */
data clean.patients_sorted;    set work.patients_sorted;    run;
data clean.treatments_sorted;  set work.treatments_sorted;  run;
