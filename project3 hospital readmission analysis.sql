-- PROJECT 3: Hospital Readmission Rate Analysis
-- Author: Krishna Kandagatla
-- Domain: US Healthcare - Clinical Analytics
-- Tools: SQL MySQL
-- Business Problem: Identify patients at high risk of 30-day readmission

CREATE DATABASE IF NOT EXISTS healthcare_rcm;
USE healthcare_rcm;

CREATE TABLE IF NOT EXISTS patients (
    patient_id        VARCHAR(20) PRIMARY KEY,
    patient_name      VARCHAR(100),
    age               INT,
    gender            VARCHAR(10),
    insurance_type    VARCHAR(50),
    chronic_conditions INT,
    smoking_status    VARCHAR(20),
    bmi_category      VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS admissions (
    admission_id      VARCHAR(20) PRIMARY KEY,
    patient_id        VARCHAR(20),
    admission_date    DATE,
    discharge_date    DATE,
    diagnosis_name    VARCHAR(100),
    department        VARCHAR(50),
    attending_doctor  VARCHAR(100),
    admission_type    VARCHAR(30),
    discharge_status  VARCHAR(30),
    los_days          INT,
    total_charges     DECIMAL(10,2),
    readmitted_30days VARCHAR(5)
);

INSERT INTO patients VALUES
('PT001','John Smith',72,'Male','Medicare',3,'Former','Obese'),
('PT002','Mary Johnson',65,'Female','Medicare',2,'Never','Normal'),
('PT003','Robert Davis',58,'Male','Commercial',1,'Current','Overweight'),
('PT004','Linda Wilson',81,'Female','Medicare',4,'Never','Obese'),
('PT005','James Brown',45,'Male','Commercial',0,'Never','Normal'),
('PT006','Patricia Taylor',69,'Female','Medicaid',3,'Former','Overweight'),
('PT007','Michael Anderson',76,'Male','Medicare',2,'Current','Obese'),
('PT008','Barbara Thomas',52,'Female','Commercial',1,'Never','Normal'),
('PT009','William Jackson',83,'Male','Medicare',5,'Former','Obese'),
('PT010','Elizabeth White',61,'Female','Commercial',2,'Never','Overweight');

INSERT INTO admissions VALUES
('ADM001','PT001','2024-01-05','2024-01-12','Heart Failure','Cardiology','Dr. Ravi Kumar','Emergency','Home',7,45000.00,'Yes'),
('ADM002','PT002','2024-01-08','2024-01-13','Pneumonia','Pulmonology','Dr. Priya Nair','Urgent','Home',5,32000.00,'No'),
('ADM003','PT003','2024-01-10','2024-01-14','Type 2 Diabetes','Endocrinology','Dr. Arjun Mehta','Elective','Home',4,28000.00,'No'),
('ADM004','PT004','2024-01-12','2024-01-22','Heart Failure','Cardiology','Dr. Ravi Kumar','Emergency','SNF',10,78000.00,'Yes'),
('ADM005','PT005','2024-01-15','2024-01-17','Appendicitis','Surgery','Dr. Priya Nair','Emergency','Home',2,22000.00,'No'),
('ADM006','PT006','2024-01-18','2024-01-25','Chronic Kidney Disease','Nephrology','Dr. Arjun Mehta','Urgent','Home',7,52000.00,'Yes'),
('ADM007','PT007','2024-01-20','2024-01-28','Heart Failure','Cardiology','Dr. Ravi Kumar','Emergency','SNF',8,65000.00,'Yes'),
('ADM008','PT008','2024-01-22','2024-01-24','Upper Respiratory','General Medicine','Dr. Priya Nair','Elective','Home',2,12000.00,'No'),
('ADM009','PT009','2024-01-25','2024-02-05','Heart Failure','Cardiology','Dr. Arjun Mehta','Emergency','SNF',11,92000.00,'Yes'),
('ADM010','PT010','2024-01-28','2024-02-01','Back Pain','Orthopedics','Dr. Ravi Kumar','Elective','Home',4,25000.00,'No'),
('ADM011','PT001','2024-02-01','2024-02-08','Heart Failure','Cardiology','Dr. Priya Nair','Emergency','Home',7,48000.00,'Yes'),
('ADM012','PT009','2024-03-01','2024-03-10','Heart Failure','Cardiology','Dr. Arjun Mehta','Emergency','SNF',9,76000.00,'Yes'),
('ADM013','PT004','2024-02-14','2024-02-24','Heart Failure','Cardiology','Dr. Ravi Kumar','Emergency','SNF',10,82000.00,'Yes'),
('ADM014','PT006','2024-03-15','2024-03-22','Chronic Kidney Disease','Nephrology','Dr. Ravi Kumar','Urgent','Home',7,54000.00,'No'),
('ADM015','PT007','2024-02-20','2024-03-02','Heart Failure','Cardiology','Dr. Arjun Mehta','Emergency','SNF',10,88000.00,'Yes');

-- QUERY 1: Overall Readmission Rate
SELECT
    COUNT(*)                                                             AS total_admissions,
    SUM(CASE WHEN readmitted_30days='Yes' THEN 1 ELSE 0 END)            AS readmissions,
    ROUND(SUM(CASE WHEN readmitted_30days='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS readmission_rate_pct,
    ROUND(AVG(los_days),1)                                               AS avg_length_of_stay,
    SUM(total_charges)                                                   AS total_revenue
FROM admissions;

-- QUERY 2: Readmission by Diagnosis
SELECT
    diagnosis_name,
    COUNT(*)                                                             AS total_cases,
    SUM(CASE WHEN readmitted_30days='Yes' THEN 1 ELSE 0 END)            AS readmitted,
    ROUND(SUM(CASE WHEN readmitted_30days='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS readmission_rate,
    ROUND(AVG(los_days),1)                                               AS avg_los,
    SUM(total_charges)                                                   AS total_charges
FROM admissions
GROUP BY diagnosis_name
ORDER BY readmission_rate DESC;

-- QUERY 3: Age Group Risk Analysis
SELECT
    CASE
        WHEN p.age < 45              THEN 'Under 45'
        WHEN p.age BETWEEN 45 AND 60 THEN '45-60'
        WHEN p.age BETWEEN 61 AND 75 THEN '61-75'
        ELSE 'Over 75'
    END                                                                  AS age_group,
    COUNT(a.admission_id)                                                AS admissions,
    SUM(CASE WHEN a.readmitted_30days='Yes' THEN 1 ELSE 0 END)          AS readmissions,
    ROUND(SUM(CASE WHEN a.readmitted_30days='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS readmission_rate
FROM admissions a
JOIN patients p ON a.patient_id = p.patient_id
GROUP BY age_group
ORDER BY readmission_rate DESC;

-- QUERY 4: Insurance Type Impact
SELECT
    p.insurance_type,
    COUNT(a.admission_id)                                                AS total_admissions,
    SUM(CASE WHEN a.readmitted_30days='Yes' THEN 1 ELSE 0 END)          AS readmissions,
    ROUND(SUM(CASE WHEN a.readmitted_30days='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS readmission_rate,
    ROUND(AVG(a.total_charges),0)                                        AS avg_charges
FROM admissions a
JOIN patients p ON a.patient_id = p.patient_id
GROUP BY p.insurance_type
ORDER BY readmission_rate DESC;

-- QUERY 5: Repeat Readmission Patients (Frequent Flyers)
SELECT
    p.patient_id,
    p.patient_name,
    p.age,
    p.insurance_type,
    p.chronic_conditions,
    COUNT(a.admission_id)                                                AS total_admissions,
    SUM(CASE WHEN a.readmitted_30days='Yes' THEN 1 ELSE 0 END)          AS readmission_count,
    SUM(a.total_charges)                                                 AS total_cost
FROM patients p
JOIN admissions a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.patient_name, p.age, p.insurance_type, p.chronic_conditions
HAVING COUNT(a.admission_id) > 1
ORDER BY readmission_count DESC;

-- QUERY 6: Patient Risk Score (Interview Favourite!)
SELECT
    a.admission_id,
    p.patient_name,
    p.age,
    p.chronic_conditions,
    a.los_days,
    a.admission_type,
    (
        CASE WHEN p.age > 75 THEN 3 WHEN p.age > 60 THEN 2 ELSE 1 END
        + p.chronic_conditions
        + CASE WHEN a.los_days > 7 THEN 2 ELSE 0 END
        + CASE WHEN a.admission_type = 'Emergency' THEN 2 ELSE 0 END
    )                                                                    AS risk_score,
    CASE
        WHEN (CASE WHEN p.age>75 THEN 3 WHEN p.age>60 THEN 2 ELSE 1 END
              + p.chronic_conditions
              + CASE WHEN a.los_days>7 THEN 2 ELSE 0 END
              + CASE WHEN a.admission_type='Emergency' THEN 2 ELSE 0 END) >= 7 THEN 'HIGH RISK'
        WHEN (CASE WHEN p.age>75 THEN 3 WHEN p.age>60 THEN 2 ELSE 1 END
              + p.chronic_conditions
              + CASE WHEN a.los_days>7 THEN 2 ELSE 0 END
              + CASE WHEN a.admission_type='Emergency' THEN 2 ELSE 0 END) >= 4 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END                                                                  AS risk_level,
    a.readmitted_30days                                                  AS actual_outcome
FROM admissions a
JOIN patients p ON a.patient_id = p.patient_id
ORDER BY risk_score DESC;

-- QUERY 7: Doctor Performance
SELECT
    attending_doctor,
    COUNT(*)                                                             AS total_patients,
    SUM(CASE WHEN readmitted_30days='Yes' THEN 1 ELSE 0 END)            AS readmissions,
    ROUND(SUM(CASE WHEN readmitted_30days='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS readmission_rate,
    ROUND(AVG(los_days),1)                                               AS avg_los
FROM admissions
GROUP BY attending_doctor
ORDER BY readmission_rate ASC;
