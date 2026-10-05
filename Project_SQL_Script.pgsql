CREATE DATABASE hospital_management_system;

-- 1. ICD-9 Dictionary
CREATE TABLE icd9_dictionary (
    icd9_code VARCHAR(10) PRIMARY KEY,
    official_title VARCHAR(150) NOT NULL,
    description TEXT,
    disease_category VARCHAR(100)
);

SELECT * FROM icd9_dictionary;

-- 2. Patients Core Info
CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    life_status VARCHAR(10) DEFAULT 'Alive' CHECK (life_status IN ('Alive', 'Deceased'))
);

SELECT * FROM patients;

-- 3. Admissions
CREATE TABLE admissions (
    admission_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES patients(patient_id) ON DELETE RESTRICT,
    admission_date_time TIMESTAMP NOT NULL,
    discharge_date_time TIMESTAMP,
    admission_type VARCHAR(20) CHECK (admission_type IN ('emergency', 'urgent', 'elective', 'outpatient', 'newborn')),
    reason_for_admission TEXT NOT NULL,
    CONSTRAINT chk_discharge_chronology CHECK (discharge_date_time IS NULL OR discharge_date_time >= admission_date_time)
);

SELECT * FROM admissions;

-- 4. Diagnoses Bridge
CREATE TABLE diagnoses (
    diagnosis_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES patients(patient_id),
    admission_id INT NOT NULL REFERENCES admissions(admission_id),
    icd9_code VARCHAR(10) NOT NULL REFERENCES icd9_dictionary(icd9_code),
    diagnosis_date_time TIMESTAMP NOT NULL,
    diagnosis_type VARCHAR(10) NOT NULL CHECK (diagnosis_type IN ('primary', 'secondary'))
);

SELECT * FROM diagnoses;

-- 1. Add a medical code to the dictionary
INSERT INTO icd9_dictionary (icd9_code, official_title, description, disease_category)
VALUES ('410.9', 'Acute myocardial infarction', 'Heart attack affecting unspecified site', 'Cardiac');

-- 2. Add a patient record
INSERT INTO patients (first_name, last_name, date_of_birth, gender, life_status)
VALUES ('John', 'Doe', '1985-05-12', 'Male', 'Alive');

-- 3. Add an admission record for John (patient_id will be 1)
INSERT INTO admissions (patient_id, admission_date_time, admission_type, reason_for_admission)
VALUES (1, '2026-10-01 08:00:00', 'emergency', 'Severe chest pain');

-- 4. Finally, link them together in the diagnoses table!
INSERT INTO diagnoses (patient_id, admission_id, icd9_code, diagnosis_date_time, diagnosis_type)
VALUES (1, 1, '410.9', '2026-10-01 09:30:00', 'primary');

SELECT * FROM diagnoses;
