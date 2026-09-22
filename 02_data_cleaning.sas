/******************************************************************************
 PROGRAM      : 02_data_cleaning.sas
 PURPOSE      : A. Data Management (missing values, duplicates, cleaning)

 DATA QUALITY FINDINGS (identified during profiling in Python/SAS and
 documented here so the cleaning logic is transparent and reproducible):

   1. PATIENTS file contains 6 placeholder/test rows ("John Doe") and
      5 exact duplicate patient rows -> both must be removed.

   2. TREATMENTS file contains 2 exact duplicate rows -> removed.

   3. TREATMENTS file has an export artifact: hba1c_start / hba1c_end were
      duplicated onto BOTH an 'auralin' row and a 'novodra' row for every
      one of the 349 unique patients (i.e., every patient appears to be in
      both arms). This is NOT a real dual-enrollment - the true assigned
      arm is recoverable because only the arm actually administered has a
      real (non-missing) dosage_start / dosage_end value. We therefore
      keep, per patient, only the row where dosage_start ne 'No data'.

 SAS SKILLS   : DATA STEP, PROC SQL, PROC SORT, PROC FREQ (dup checks)
 INPUT        : work.patients_sorted, work.treatments_sorted
 OUTPUT       : clean.patients_clean, clean.treatments_clean,
                clean.analysis_dataset  (ADaM-style analysis-ready dataset)
******************************************************************************/
%include "&projpath./sas_programs/00_setup.sas";

/* ---------------------------------------------------------------------
   1. MISSING VALUE CHECK across both raw datasets
   --------------------------------------------------------------------- */
proc means data = work.patients_raw n nmiss;
     var weight height bmi;
     title "Missing Value Check: Patients numeric fields";
run;

proc sql;
     select "adverse_reaction" as variable, count(*) as n_missing
     from   work.treatments_raw
     where  adverse_reaction = "No data" or missing(adverse_reaction);
quit;
title;

/* ---------------------------------------------------------------------
   2. DUPLICATE CHECK: exact duplicate rows and duplicate identifiers
   --------------------------------------------------------------------- */
proc sql;
     title "Duplicate check: exact duplicate patient rows";
     select given_name, surname, count(*) as n_rows
     from   work.patients_raw
     group by given_name, surname
     having count(*) > 1;

     title "Duplicate check: exact duplicate treatment rows";
     select given_name, surname, type, count(*) as n_rows
     from   work.treatments_raw
     group by given_name, surname, type
     having count(*) > 1;
quit;
title;

/* ---------------------------------------------------------------------
   3. CLEAN PATIENTS: drop placeholders + exact duplicates, derive age
   --------------------------------------------------------------------- */
proc sort data = work.patients_raw out = work.patients_dedup nodupkey;
     by given_name surname;
run;

data clean.patients_clean;
     set work.patients_dedup;
     where not (given_name = "John" and surname = "Doe");   /* remove 6 test rows */

     length sex $10;
     sex = lowcase(strip(assigned_sex));

     /* birthdate is character in the raw export -> convert then derive age */
     bdate      = input(birthdate, mmddyy10.);
     format bdate date9.;
     age        = floor((intck('month', bdate, '01JAN2016'd) - 
                  (day('01JAN2016'd) < day(bdate))) / 12);

     weight_kg  = round(weight * 0.453592, 0.1);
     height_in  = height;
     bmi_c      = round(bmi, 0.1);

     keep given_name surname sex age weight_kg height_in bmi_c city state country;
     rename bmi_c = bmi;
run;

/* ---------------------------------------------------------------------
   4. CLEAN TREATMENTS: remove exact dups; resolve the true dosed arm;
      derive treatment_group label and the primary endpoint variable
   --------------------------------------------------------------------- */
proc sort data = work.treatments_raw out = work.treatments_dedup nodupkey;
     by given_name surname type hba1c_start hba1c_end dosage_start dosage_end
        adverse_reaction;
run;

data clean.treatments_clean;
     set work.treatments_dedup;
     by given_name surname;

     length dosage_start_n dosage_end_n 8;
     dosage_start_n = input(dosage_start, ?? best12.);   /* 'No data' -> missing */
     dosage_end_n   = input(dosage_end,   ?? best12.);

     if not missing(dosage_start_n);   /* keep only the row = TRUE administered arm */

     length treatment_group $20 adverse_reaction_c $40;
     if type = "auralin" then treatment_group = "Auralin (Test)";
     else if type = "novodra" then treatment_group = "Novodra (Control)";

     adverse_reaction_c = adverse_reaction;
     if adverse_reaction_c = "No data" then call missing(adverse_reaction_c);

     hba1c_baseline = hba1c_start;
     hba1c_week24   = hba1c_end;
     hba1c_chg      = round(hba1c_week24 - hba1c_baseline, 0.01);  /* negative = reduction */

     dosage_start = dosage_start_n;
     dosage_end   = dosage_end_n;

     keep given_name surname type treatment_group hba1c_baseline hba1c_week24
          hba1c_chg dosage_start dosage_end adverse_reaction_c;
     rename adverse_reaction_c = adverse_reaction;
run;

proc sort data = clean.treatments_clean;
     by type given_name surname;
run;

data clean.treatments_clean;
     set clean.treatments_clean;
     subject_id = catt("SUBJ-", put(_n_, z4.));
run;

/* ---------------------------------------------------------------------
   5. ANALYSIS DATASET: merge demographics onto the resolved trial roster
   --------------------------------------------------------------------- */
proc sql;
     create table clean.analysis_dataset as
     select t.subject_id, t.given_name, t.surname, p.sex, p.age,
            t.treatment_group, t.type, t.hba1c_baseline, t.hba1c_week24,
            t.hba1c_chg, t.dosage_start, t.dosage_end,
            p.weight_kg, p.height_in, p.bmi, t.adverse_reaction,
            case when not missing(t.adverse_reaction) then "Y" else "N" end
                 as ae_flag length = 1
     from   clean.treatments_clean as t
     left join clean.patients_clean as p
     on     t.given_name = p.given_name and t.surname = p.surname;
quit;

proc contents data = clean.analysis_dataset varnum;
     title "PROC CONTENTS: Final Analysis Dataset";
run;
title;
