import pandas as pd, numpy as np
from scipy import stats

adam = pd.read_csv('/home/claude/project/data/clean/analysis_dataset.csv')
A = adam[adam.type=='auralin']
N = adam[adam.type=='novodra']

# ---------------- TABLE 1: Demographics ----------------
def cat_pct(df, col, val):
    sub = df[df[col].notna()]
    n = (sub[col]==val).sum()
    pct = 100*n/len(sub) if len(sub) else np.nan
    return f"{n} ({pct:.1f}%)"

rows = []
rows.append(["N", len(A), len(N)])
rows.append(["Age, years — Mean (SD)", f"{A.age.mean():.1f} ({A.age.std():.1f})", f"{N.age.mean():.1f} ({N.age.std():.1f})"])
rows.append(["Age, years — Median (Min, Max)", f"{A.age.median():.0f} ({A.age.min():.0f}, {A.age.max():.0f})",
             f"{N.age.median():.0f} ({N.age.min():.0f}, {N.age.max():.0f})"])
rows.append(["Sex — Female, n (%)", cat_pct(A,'sex','female'), cat_pct(N,'sex','female')])
rows.append(["Sex — Male, n (%)", cat_pct(A,'sex','male'), cat_pct(N,'sex','male')])
rows.append(["Weight, kg — Mean (SD)", f"{A.weight_kg.mean():.1f} ({A.weight_kg.std():.1f})", f"{N.weight_kg.mean():.1f} ({N.weight_kg.std():.1f})"])
rows.append(["BMI, kg/m^2 — Mean (SD)", f"{A.bmi.mean():.1f} ({A.bmi.std():.1f})", f"{N.bmi.mean():.1f} ({N.bmi.std():.1f})"])
rows.append(["Baseline HbA1c, % — Mean (SD)", f"{A.hba1c_baseline.mean():.2f} ({A.hba1c_baseline.std():.2f})",
             f"{N.hba1c_baseline.mean():.2f} ({N.hba1c_baseline.std():.2f})"])
t1 = pd.DataFrame(rows, columns=["Characteristic","Auralin (Test) N=174","Novodra (Control) N=175"])
t1.to_csv('/home/claude/project/output/table1_demographics.csv', index=False)
print(t1.to_string(index=False))

# ---------------- TABLE 2: Efficacy (primary endpoint) ----------------
t_stat, p_val = stats.ttest_ind(A.hba1c_chg, N.hba1c_chg, equal_var=True)
mean_diff = A.hba1c_chg.mean() - N.hba1c_chg.mean()
se_diff = np.sqrt(A.hba1c_chg.var(ddof=1)/len(A) + N.hba1c_chg.var(ddof=1)/len(N))
ci_low, ci_high = mean_diff - 1.96*se_diff, mean_diff + 1.96*se_diff

t2 = pd.DataFrame([
    ["Baseline HbA1c, %", f"{A.hba1c_baseline.mean():.2f} ({A.hba1c_baseline.std():.2f})", f"{N.hba1c_baseline.mean():.2f} ({N.hba1c_baseline.std():.2f})", "-", "-"],
    ["Week 24 HbA1c, %", f"{A.hba1c_week24.mean():.2f} ({A.hba1c_week24.std():.2f})", f"{N.hba1c_week24.mean():.2f} ({N.hba1c_week24.std():.2f})", "-", "-"],
    ["Change from Baseline, %", f"{A.hba1c_chg.mean():.2f} ({A.hba1c_chg.std():.2f})", f"{N.hba1c_chg.mean():.2f} ({N.hba1c_chg.std():.2f})",
     f"{mean_diff:.2f} (95% CI: {ci_low:.2f}, {ci_high:.2f})", f"{p_val:.4f}"],
], columns=["Parameter","Auralin (Test) N=174","Novodra (Control) N=175","Difference (Auralin-Novodra)","p-value"])
t2.to_csv('/home/claude/project/output/table2_efficacy.csv', index=False)
print("\n", t2.to_string(index=False))
print(f"\nt-stat={t_stat:.3f}, p={p_val:.4f}, mean_diff={mean_diff:.3f}, 95% CI=({ci_low:.3f},{ci_high:.3f})")

# ---------------- TABLE 3: Adverse Events ----------------
ae = adam[adam.adverse_reaction.notna()]
overall = pd.DataFrame([["Any adverse event, n (%)", cat_pct(adam[adam.type=='auralin'],'ae_flag','Y'),
                          cat_pct(adam[adam.type=='novodra'],'ae_flag','Y')]],
                        columns=["Adverse Event","Auralin (Test) N=174","Novodra (Control) N=175"])
by_term = adam.groupby(['adverse_reaction','type']).size().unstack(fill_value=0)
by_term_pct = pd.DataFrame({
    'Auralin (Test) N=174': by_term.get('auralin',0).apply(lambda n: f"{n} ({100*n/174:.1f}%)"),
    'Novodra (Control) N=175': by_term.get('novodra',0).apply(lambda n: f"{n} ({100*n/175:.1f}%)")
}).reset_index().rename(columns={'adverse_reaction':'Adverse Event'})
t3 = pd.concat([overall, by_term_pct], ignore_index=True)
t3.to_csv('/home/claude/project/output/table3_ae_summary.csv', index=False)
print("\n", t3.to_string(index=False))

# ---------------- TABLE 4: Vital Signs / Labs (baseline characteristics by arm) ----------------
t4 = pd.DataFrame([
    ["Weight, kg", f"{A.weight_kg.mean():.1f} ({A.weight_kg.std():.1f})", f"{N.weight_kg.mean():.1f} ({N.weight_kg.std():.1f})"],
    ["Height, in", f"{A.height_in.mean():.1f} ({A.height_in.std():.1f})", f"{N.height_in.mean():.1f} ({N.height_in.std():.1f})"],
    ["BMI, kg/m^2", f"{A.bmi.mean():.1f} ({A.bmi.std():.1f})", f"{N.bmi.mean():.1f} ({N.bmi.std():.1f})"],
    ["Dosage at Start, units", f"{A.dosage_start.mean():.1f} ({A.dosage_start.std():.1f})", f"{N.dosage_start.mean():.1f} ({N.dosage_start.std():.1f})"],
    ["Dosage at End, units", f"{A.dosage_end.mean():.1f} ({A.dosage_end.std():.1f})", f"{N.dosage_end.mean():.1f} ({N.dosage_end.std():.1f})"],
], columns=["Parameter","Auralin (Test) N=174","Novodra (Control) N=175"])
t4.to_csv('/home/claude/project/output/table4_vitals.csv', index=False)
print("\n", t4.to_string(index=False))

# ---------------- LISTING 1: Patient-level data (first 30 + full CSV) ----------------
listing = adam[['subject_id','sex','age','treatment_group','hba1c_baseline','hba1c_week24','hba1c_chg','adverse_reaction']].copy()
listing['adverse_reaction'] = listing['adverse_reaction'].fillna('None')
listing.to_csv('/home/claude/project/output/listing1_patient_data.csv', index=False)
print("\nListing1 rows:", len(listing))
