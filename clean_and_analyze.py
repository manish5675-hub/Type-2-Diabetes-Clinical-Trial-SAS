import pandas as pd, numpy as np
from scipy import stats

pd.set_option('display.max_columns', None); pd.set_option('display.width', 200)

pts = pd.read_csv('/home/claude/project/data/raw/patients_raw.csv')
trt = pd.read_csv('/home/claude/project/data/raw/treatments_raw.csv')

# ================= 1. PATIENTS CLEANING =================
pts_clean = pts[~((pts.given_name=='John') & (pts.surname=='Doe'))].copy()           # remove 6 placeholder/test rows
pts_clean = pts_clean.drop_duplicates(subset=['given_name','surname'], keep='first')  # remove exact duplicate person rows
pts_clean['assigned_sex'] = pts_clean['assigned_sex'].str.lower().str.strip()
pts_clean['birthdate'] = pd.to_datetime(pts_clean['birthdate'], errors='coerce')
REF = pd.Timestamp('2016-01-01')                                                      # trial enrollment reference date
pts_clean['age'] = ((REF - pts_clean['birthdate']).dt.days // 365).astype('Int64')
pts_clean['weight_kg'] = round(pts_clean['weight'] * 0.453592, 1)
pts_clean['bmi'] = round(pts_clean['bmi'], 1)
pts_clean = pts_clean[['given_name','surname','assigned_sex','age','weight_kg','height','bmi','city','state','country']]
pts_clean.columns = ['given_name','surname','sex','age','weight_kg','height_in','bmi','city','state','country']

# ================= 2. TREATMENTS CLEANING =================
# Data-quality finding: on export, hba1c_start/hba1c_end were duplicated across BOTH an auralin
# row and a novodra row for every patient (a melt/export artifact). The TRUE treatment arm is
# recoverable because only the arm actually administered has real dosage_start/dosage_end values
# (the other arm's dosage = 'No data'). We resolve one authentic record per patient using this rule.
trt = trt.drop_duplicates(keep='first')                                               # drop 2 exact full-row duplicates
trt['dosage_start_num'] = pd.to_numeric(trt['dosage_start'].replace('No data', np.nan), errors='coerce')
trt['has_dose'] = trt['dosage_start_num'].notna()
trt_clean = trt[trt['has_dose']].copy().drop(columns=['dosage_start_num','has_dose'])  # keep only the true dosed arm -> 349 unique subjects

for c in ['dosage_start','dosage_end']:
    trt_clean[c] = pd.to_numeric(trt_clean[c].replace('No data', np.nan), errors='coerce')
trt_clean['adverse_reaction'] = trt_clean['adverse_reaction'].replace('No data', np.nan)
trt_clean['treatment_group'] = trt_clean['type'].map({'auralin':'Auralin (Test)','novodra':'Novodra (Control)'})
trt_clean.rename(columns={'hba1c_start':'hba1c_baseline','hba1c_end':'hba1c_week24'}, inplace=True)
trt_clean['hba1c_chg'] = round(trt_clean['hba1c_week24'] - trt_clean['hba1c_baseline'], 2)   # negative = reduction
trt_clean = trt_clean.sort_values(['type','given_name','surname']).reset_index(drop=True)
trt_clean.insert(0, 'subject_id', ['SUBJ-' + str(i+1).zfill(4) for i in range(len(trt_clean))])

# ================= 3. ANALYSIS DATASET (merge demographics onto the resolved trial roster) =================
adam = pd.merge(trt_clean, pts_clean, on=['given_name','surname'], how='left')
adam['ae_flag'] = np.where(adam['adverse_reaction'].notna(), 'Y', 'N')
adam = adam[['subject_id','given_name','surname','sex','age','treatment_group','type',
             'hba1c_baseline','hba1c_week24','hba1c_chg','dosage_start','dosage_end',
             'weight_kg','height_in','bmi','adverse_reaction','ae_flag']]

pts_clean.to_csv('/home/claude/project/data/clean/patients_clean.csv', index=False)
trt_clean.to_csv('/home/claude/project/data/clean/treatments_clean.csv', index=False)
adam.to_csv('/home/claude/project/data/clean/analysis_dataset.csv', index=False)

print("patients_clean:", pts_clean.shape)
print("treatments_clean (resolved roster):", trt_clean.shape, trt_clean.type.value_counts().to_dict())
print("analysis_dataset (ADaM-style, merged):", adam.shape)
print("missing demographics after merge:", adam['age'].isna().sum())
print(adam.head())
