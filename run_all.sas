/******************************************************************************
 PROGRAM      : run_all.sas
 PURPOSE      : Master driver - runs the full project pipeline end-to-end.
                Update the &projpath macro variable in 00_setup.sas first.
******************************************************************************/
%let projpath = /your/local/path/Type2Diabetes-Clinical-Trial-SAS;

%include "&projpath./sas_programs/01_import_data.sas";
%include "&projpath./sas_programs/02_data_cleaning.sas";
%include "&projpath./sas_programs/03_demographics.sas";
%include "&projpath./sas_programs/04_efficacy_analysis.sas";
%include "&projpath./sas_programs/05_safety_analysis.sas";
%include "&projpath./sas_programs/06_tlf_listing.sas";
%include "&projpath./sas_programs/07_figure.sas";
