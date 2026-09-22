/******************************************************************************
 PROGRAM      : 07_figure.sas
 PURPOSE      : E. TLF Generation - Figure 1 (HbA1c Change by Treatment)
 SAS SKILLS   : PROC SGPLOT, ODS GRAPHICS
 INPUT        : clean.analysis_dataset
 OUTPUT       : Figure 1 - HbA1c Change by Treatment (PNG)
******************************************************************************/
%include "&projpath./sas_programs/00_setup.sas";

ods graphics on / reset width = 8in height = 5in imagename = "Figure1_HbA1c_Change"
                  outputfmt = png;
ods listing gpath = "&projpath./output" image_dpi = 150;

proc sgplot data = clean.analysis_dataset;
     vbox hba1c_chg / category = treatment_group fillattrs = (color = lightblue)
                      meanattrs = (symbol = diamondfilled color = red);
     yaxis label = "Change from Baseline in HbA1c (%)" grid;
     xaxis label = "Treatment Group";
     title "Figure 1. HbA1c Change from Baseline to Week 24 by Treatment Group";
run;

ods listing close;
title;
