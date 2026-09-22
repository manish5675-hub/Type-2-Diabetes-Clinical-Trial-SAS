/******************************************************************************
 PROGRAM      : 00_setup.sas
 PROJECT      : Type 2 Diabetes Clinical Trial Analysis (Auralin vs Novodra)
 PURPOSE      : Define global libraries, paths, and options used by every
                program in this project. %INCLUDE this file at the top of
                each program, or run it once per SAS session.
 AUTHOR       : <your name>
 DATE         : <date>
******************************************************************************/

/* ---- Update this single path to match your local project folder ---- */
%let projpath = /your/local/path/Type2Diabetes-Clinical-Trial-SAS;

libname raw   "&projpath./data/raw";     /* untouched source data          */
libname clean "&projpath./data/clean";   /* cleaned / derived analysis data */
libname out   "&projpath./output";       /* permanent output datasets      */

options nodate nonumber missing = '.' formchar="|----|+|---+=|-/\<>*"
        validvarname = v7;

ods html close;   /* run each program's own ODS destinations explicitly */
