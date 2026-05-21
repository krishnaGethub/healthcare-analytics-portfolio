-- PROJECT 5: Healthcare Job Market Intelligence
-- Author: Krishna Kandagatla
-- Domain: Healthcare + Analytics Job Market Research
-- Tools: SQL MySQL
-- Business Problem: Analyze healthcare analytics job market trends
--                   in India to identify top skills, salaries, and locations
-- Note: Based on research experience at Futran Solutions

USE healthcare_rcm;

CREATE TABLE IF NOT EXISTS job_postings (
    job_id            VARCHAR(20) PRIMARY KEY,
    posted_date       DATE,
    job_title         VARCHAR(100),
    company_name      VARCHAR(100),
    company_type      VARCHAR(50),
    location          VARCHAR(50),
    experience_min    INT,
    experience_max    INT,
    salary_min        DECIMAL(8,2),
    salary_max        DECIMAL(8,2),
    job_type          VARCHAR(30),
    domain            VARCHAR(50),
    sql_required      VARCHAR(5),
    python_required   VARCHAR(5),
    powerbi_required  VARCHAR(5),
    tableau_required  VARCHAR(5),
    excel_required    VARCHAR(5),
    healthcare_domain VARCHAR(5),
    views             INT,
    applications      INT
);

INSERT INTO job_postings VALUES
('JOB001','2024-01-05','Healthcare Data Analyst','Optum','MNC','Hyderabad',1,3,600000,900000,'Full-time','Healthcare Analytics','Yes','Yes','Yes','No','Yes','Yes',2450,380),
('JOB002','2024-01-06','Data Analyst','Omega Healthcare','Indian','Hyderabad',0,2,400000,650000,'Full-time','RCM Analytics','Yes','No','Yes','No','Yes','Yes',1820,290),
('JOB003','2024-01-07','Business Analyst','Cognizant','MNC','Bangalore',2,4,700000,1000000,'Full-time','Healthcare IT','Yes','Yes','No','Yes','Yes','No',3200,520),
('JOB004','2024-01-08','MIS Analyst','Apollo Hospitals','Indian','Hyderabad',1,3,500000,750000,'Full-time','Hospital Analytics','Yes','No','Yes','No','Yes','Yes',1650,240),
('JOB005','2024-01-09','RCM Analyst','Conduent','MNC','Hyderabad',1,3,550000,800000,'Full-time','RCM','Yes','No','Yes','No','Yes','Yes',1480,210),
('JOB006','2024-01-10','Data Analyst','CitiusTech','Indian','Bangalore',2,5,800000,1200000,'Full-time','HealthTech','Yes','Yes','Yes','No','Yes','Yes',2800,410),
('JOB007','2024-01-11','Healthcare Analyst','Infosys BPM','MNC','Bangalore',1,3,500000,750000,'Full-time','Healthcare BPO','Yes','No','No','No','Yes','Yes',1920,310),
('JOB008','2024-01-12','Data Analyst','Niva Bupa','Indian','Delhi',1,4,600000,900000,'Full-time','Insurance Analytics','Yes','Yes','Yes','No','Yes','No',1750,280),
('JOB009','2024-01-13','BI Analyst','Mu Sigma','Indian','Bangalore',2,4,700000,1000000,'Full-time','Analytics Consulting','Yes','Yes','Yes','Yes','Yes','No',2600,390),
('JOB010','2024-01-14','Clinical Data Analyst','Fortis Healthcare','Indian','Delhi',2,5,750000,1100000,'Full-time','Clinical Analytics','Yes','Yes','No','No','Yes','Yes',2100,320),
('JOB011','2024-02-01','Healthcare Data Analyst','Optum','MNC','Hyderabad',1,3,650000,950000,'Full-time','Healthcare Analytics','Yes','Yes','Yes','No','Yes','Yes',2680,420),
('JOB012','2024-02-03','Data Analyst','Omega Healthcare','Indian','Chennai',0,2,380000,600000,'Full-time','RCM Analytics','Yes','No','Yes','No','Yes','Yes',1620,260),
('JOB013','2024-02-05','Senior Data Analyst','Cognizant','MNC','Hyderabad',3,6,900000,1400000,'Full-time','Healthcare IT','Yes','Yes','Yes','Yes','Yes','No',3500,580),
('JOB014','2024-02-07','MIS Executive','Max Healthcare','Indian','Delhi',1,3,450000,700000,'Full-time','Hospital Analytics','Yes','No','Yes','No','Yes','Yes',1450,220),
('JOB015','2024-02-09','Revenue Analyst','Change Healthcare','MNC','Bangalore',2,4,700000,1050000,'Full-time','RCM','Yes','Yes','Yes','No','Yes','Yes',2200,360),
('JOB016','2024-02-11','Data Analyst','CitiusTech','Indian','Hyderabad',1,4,700000,1050000,'Full-time','HealthTech','Yes','Yes','Yes','No','Yes','Yes',2500,390),
('JOB017','2024-02-13','Healthcare BI Analyst','Wipro','MNC','Bangalore',2,5,800000,1200000,'Full-time','Healthcare IT','Yes','Yes','Yes','Yes','Yes','No',2900,450),
('JOB018','2024-02-15','Data Analyst','Star Health','Indian','Chennai',1,3,500000,750000,'Full-time','Insurance Analytics','Yes','No','Yes','No','Yes','No',1680,270),
('JOB019','2024-02-17','Analytics Executive','Manipal Hospitals','Indian','Bangalore',1,3,480000,720000,'Full-time','Hospital Analytics','Yes','No','Yes','No','Yes','Yes',1580,250),
('JOB020','2024-02-19','Data Analyst','Accenture','MNC','Hyderabad',2,4,750000,1100000,'Full-time','Healthcare Consulting','Yes','Yes','Yes','No','Yes','No',3100,490);

-- QUERY 1: Job Market Overview
SELECT
    COUNT(*)                                                             AS total_jobs,
    ROUND(AVG(salary_min/100000),1)                                      AS avg_min_salary_lpa,
    ROUND(AVG(salary_max/100000),1)                                      AS avg_max_salary_lpa,
    ROUND(AVG(experience_min),1)                                         AS avg_min_exp_yrs,
    SUM(applications)                                                    AS total_applications,
    ROUND(AVG(applications),0)                                           AS avg_applications_per_job
FROM job_postings;

-- QUERY 2: Top Skills Demand (Most Important for Job Seekers!)
SELECT 'SQL'      AS skill, SUM(CASE WHEN sql_required='Yes' THEN 1 ELSE 0 END) AS demand,
    ROUND(SUM(CASE WHEN sql_required='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),1) AS demand_pct FROM job_postings
UNION ALL
SELECT 'Excel'    , SUM(CASE WHEN excel_required='Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN excel_required='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),1) FROM job_postings
UNION ALL
SELECT 'Power BI' , SUM(CASE WHEN powerbi_required='Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN powerbi_required='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),1) FROM job_postings
UNION ALL
SELECT 'Python'   , SUM(CASE WHEN python_required='Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN python_required='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),1) FROM job_postings
UNION ALL
SELECT 'Tableau'  , SUM(CASE WHEN tableau_required='Yes' THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN tableau_required='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),1) FROM job_postings
ORDER BY demand DESC;

-- QUERY 3: Location-wise Job Market
SELECT
    location,
    COUNT(*)                                                             AS job_count,
    ROUND(AVG(salary_max/100000),1)                                      AS avg_max_salary_lpa,
    SUM(applications)                                                    AS total_applications,
    ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),1)                         AS market_share_pct
FROM job_postings
GROUP BY location
ORDER BY job_count DESC;

-- QUERY 4: Salary by Experience Band
SELECT
    CASE
        WHEN experience_min = 0  THEN 'Fresher (0 yrs)'
        WHEN experience_min <= 2 THEN 'Junior (1-2 yrs)'
        WHEN experience_min <= 4 THEN 'Mid (3-4 yrs)'
        ELSE 'Senior (5+ yrs)'
    END                                                                  AS experience_band,
    COUNT(*)                                                             AS jobs,
    ROUND(AVG(salary_min/100000),1)                                      AS avg_min_lpa,
    ROUND(AVG(salary_max/100000),1)                                      AS avg_max_lpa,
    ROUND(MIN(salary_min/100000),1)                                      AS lowest_lpa,
    ROUND(MAX(salary_max/100000),1)                                      AS highest_lpa
FROM job_postings
GROUP BY experience_band
ORDER BY avg_max_lpa;

-- QUERY 5: Healthcare Domain Premium
SELECT
    healthcare_domain,
    COUNT(*)                                                             AS jobs,
    ROUND(AVG(salary_max/100000),1)                                      AS avg_max_salary_lpa,
    ROUND(AVG(applications),0)                                           AS avg_competition
FROM job_postings
GROUP BY healthcare_domain
ORDER BY avg_max_salary_lpa DESC;

-- QUERY 6: Company Type Comparison
SELECT
    company_type,
    COUNT(*)                                                             AS openings,
    ROUND(AVG(salary_min/100000),1)                                      AS avg_min_lpa,
    ROUND(AVG(salary_max/100000),1)                                      AS avg_max_lpa,
    ROUND(AVG(experience_min),1)                                         AS avg_exp_required
FROM job_postings
GROUP BY company_type
ORDER BY avg_max_lpa DESC;

-- QUERY 7: Top Hiring Companies
SELECT
    company_name,
    company_type,
    location,
    COUNT(*)                                                             AS openings,
    ROUND(AVG(salary_max/100000),1)                                      AS avg_salary_lpa,
    SUM(applications)                                                    AS total_applicants
FROM job_postings
GROUP BY company_name, company_type, location
ORDER BY openings DESC, avg_salary_lpa DESC;

-- QUERY 8: Best Jobs for Career Transitioners (1-3 yr exp)
SELECT
    job_title,
    company_name,
    location,
    experience_min,
    experience_max,
    ROUND(salary_min/100000,1)                                           AS min_lpa,
    ROUND(salary_max/100000,1)                                           AS max_lpa,
    CASE WHEN healthcare_domain='Yes' THEN 'Yes' ELSE 'No' END           AS domain_match,
    CASE WHEN sql_required='Yes' AND powerbi_required='Yes' THEN 'Perfect Fit'
         WHEN sql_required='Yes' THEN 'Good Fit'
         ELSE 'Partial Fit'
    END                                                                  AS fit_for_krishna
FROM job_postings
WHERE experience_min <= 2 AND experience_max <= 4
ORDER BY salary_max DESC;
