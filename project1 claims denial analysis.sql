-- ============================================================
-- PROJECT 1: Healthcare Claims Denial Analysis
-- Author: Krishna Kandagatla
-- Domain: US Healthcare - Revenue Cycle Management
-- Tools: SQL (MySQL compatible)
-- Description: Analyze claim denials to identify revenue leakage
--              patterns, top denial reasons, and payer performance
-- ============================================================

-- ============================================================
-- STEP 1: CREATE DATABASE & TABLES
-- ============================================================

CREATE DATABASE IF NOT EXISTS healthcare_rcm;
USE healthcare_rcm;

-- Claims Master Table
CREATE TABLE claims (
    claim_id        VARCHAR(20) PRIMARY KEY,
    patient_id      VARCHAR(20),
    patient_name    VARCHAR(100),
    date_of_service DATE,
    submission_date DATE,
    payer_name      VARCHAR(100),
    provider_name   VARCHAR(100),
    cpt_code        VARCHAR(20),
    icd_code        VARCHAR(20),
    billed_amount   DECIMAL(10,2),
    paid_amount     DECIMAL(10,2),
    claim_status    VARCHAR(30),   -- 'Paid', 'Denied', 'Pending', 'Partial'
    denial_reason   VARCHAR(200),
    denial_code     VARCHAR(20),
    aging_days      INT,
    resubmitted     VARCHAR(5)     -- 'Yes' or 'No'
);

-- Insert Sample Data (100 realistic records)
INSERT INTO claims VALUES
('CLM001','PT001','John Smith','2024-01-05','2024-01-07','Aetna','Dr. Ravi Kumar','99213','Z00.00',250.00,200.00,'Paid',NULL,NULL,12,'No'),
('CLM002','PT002','Mary Johnson','2024-01-06','2024-01-08','BlueCross','Dr. Priya Nair','99214','J06.9',350.00,0.00,'Denied','Missing prior authorization','CO-15',45,'No'),
('CLM003','PT003','Robert Davis','2024-01-07','2024-01-09','United','Dr. Arjun Mehta','99215','M54.5',450.00,360.00,'Paid',NULL,NULL,18,'No'),
('CLM004','PT004','Linda Wilson','2024-01-08','2024-01-10','Cigna','Dr. Ravi Kumar','99213','I10',250.00,0.00,'Denied','Duplicate claim','CO-18',60,'No'),
('CLM005','PT005','James Brown','2024-01-09','2024-01-11','Aetna','Dr. Priya Nair','99214','E11.9',350.00,280.00,'Paid',NULL,NULL,22,'No'),
('CLM006','PT006','Patricia Taylor','2024-01-10','2024-01-12','Medicare','Dr. Arjun Mehta','99215','N18.3',450.00,0.00,'Denied','Service not covered','CO-97',90,'No'),
('CLM007','PT007','Michael Anderson','2024-01-11','2024-01-13','BlueCross','Dr. Ravi Kumar','99213','K21.0',250.00,225.00,'Paid',NULL,NULL,15,'No'),
('CLM008','PT008','Barbara Thomas','2024-01-12','2024-01-14','United','Dr. Priya Nair','99214','F32.1',350.00,0.00,'Denied','Missing prior authorization','CO-15',55,'Yes'),
('CLM009','PT009','William Jackson','2024-01-13','2024-01-15','Cigna','Dr. Arjun Mehta','99215','Z12.11',450.00,0.00,'Denied','Invalid diagnosis code','CO-4',40,'No'),
('CLM010','PT010','Elizabeth White','2024-01-14','2024-01-16','Aetna','Dr. Ravi Kumar','99213','I25.10',250.00,200.00,'Paid',NULL,NULL,20,'No'),
('CLM011','PT011','David Harris','2024-02-01','2024-02-03','Medicare','Dr. Priya Nair','99214','J18.9',350.00,0.00,'Denied','Missing prior authorization','CO-15',75,'No'),
('CLM012','PT012','Susan Martin','2024-02-02','2024-02-04','BlueCross','Dr. Arjun Mehta','99215','M79.3',450.00,405.00,'Paid',NULL,NULL,10,'No'),
('CLM013','PT013','Joseph Thompson','2024-02-03','2024-02-05','United','Dr. Ravi Kumar','99213','E78.5',250.00,0.00,'Denied','Duplicate claim','CO-18',65,'No'),
('CLM014','PT014','Margaret Garcia','2024-02-04','2024-02-06','Cigna','Dr. Priya Nair','99214','Z00.00',350.00,280.00,'Paid',NULL,NULL,25,'No'),
('CLM015','PT015','Charles Martinez','2024-02-05','2024-02-07','Aetna','Dr. Arjun Mehta','99215','I10',450.00,0.00,'Denied','Service not covered','CO-97',85,'No'),
('CLM016','PT016','Dorothy Robinson','2024-02-06','2024-02-08','Medicare','Dr. Ravi Kumar','99213','N18.3',250.00,200.00,'Paid',NULL,NULL,14,'No'),
('CLM017','PT017','Thomas Clark','2024-02-07','2024-02-09','BlueCross','Dr. Priya Nair','99214','K21.0',350.00,0.00,'Denied','Missing prior authorization','CO-15',95,'Yes'),
('CLM018','PT018','Helen Rodriguez','2024-02-08','2024-02-10','United','Dr. Arjun Mehta','99215','F32.1',450.00,360.00,'Paid',NULL,NULL,30,'No'),
('CLM019','PT019','Gary Lewis','2024-02-09','2024-02-11','Cigna','Dr. Ravi Kumar','99213','Z12.11',250.00,0.00,'Denied','Invalid diagnosis code','CO-4',50,'No'),
('CLM020','PT020','Betty Lee','2024-02-10','2024-02-12','Aetna','Dr. Priya Nair','99214','I25.10',350.00,280.00,'Paid',NULL,NULL,18,'No'),
('CLM021','PT021','Raymond Walker','2024-03-01','2024-03-03','Medicare','Dr. Arjun Mehta','99215','J06.9',450.00,0.00,'Denied','Missing prior authorization','CO-15',80,'No'),
('CLM022','PT022','Ruth Hall','2024-03-02','2024-03-04','BlueCross','Dr. Ravi Kumar','99213','M54.5',250.00,225.00,'Paid',NULL,NULL,12,'No'),
('CLM023','PT023','Frank Allen','2024-03-03','2024-03-05','United','Dr. Priya Nair','99214','E11.9',350.00,0.00,'Denied','Duplicate claim','CO-18',70,'Yes'),
('CLM024','PT024','Sharon Young','2024-03-04','2024-03-06','Cigna','Dr. Arjun Mehta','99215','N18.3',450.00,360.00,'Paid',NULL,NULL,22,'No'),
('CLM025','PT025','Jack Hernandez','2024-03-05','2024-03-07','Aetna','Dr. Ravi Kumar','99213','K21.0',250.00,0.00,'Denied','Service not covered','CO-97',100,'No'),
('CLM026','PT026','Gloria King','2024-03-06','2024-03-08','Medicare','Dr. Priya Nair','99214','F32.1',350.00,280.00,'Paid',NULL,NULL,16,'No'),
('CLM027','PT027','Dennis Wright','2024-03-07','2024-03-09','BlueCross','Dr. Arjun Mehta','99215','Z00.00',450.00,0.00,'Denied','Missing prior authorization','CO-15',88,'No'),
('CLM028','PT028','Carol Scott','2024-03-08','2024-03-10','United','Dr. Ravi Kumar','99213','I10',250.00,200.00,'Paid',NULL,NULL,28,'No'),
('CLM029','PT029','Jerry Green','2024-03-09','2024-03-11','Cigna','Dr. Priya Nair','99214','E78.5',350.00,0.00,'Denied','Invalid diagnosis code','CO-4',45,'No'),
('CLM030','PT030','Donna Baker','2024-03-10','2024-03-12','Aetna','Dr. Arjun Mehta','99215','I25.10',450.00,405.00,'Paid',NULL,NULL,20,'No'),
('CLM031','PT031','Walter Adams','2024-04-01','2024-04-03','Medicare','Dr. Ravi Kumar','99213','J18.9',250.00,0.00,'Denied','Missing prior authorization','CO-15',92,'Yes'),
('CLM032','PT032','Diane Nelson','2024-04-02','2024-04-04','BlueCross','Dr. Priya Nair','99214','M79.3',350.00,280.00,'Paid',NULL,NULL,15,'No'),
('CLM033','PT033','Harold Carter','2024-04-03','2024-04-05','United','Dr. Arjun Mehta','99215','Z12.11',450.00,0.00,'Denied','Duplicate claim','CO-18',60,'No'),
('CLM034','PT034','Frances Mitchell','2024-04-04','2024-04-06','Cigna','Dr. Ravi Kumar','99213','E11.9',250.00,200.00,'Paid',NULL,NULL,25,'No'),
('CLM035','PT035','Arthur Perez','2024-04-05','2024-04-07','Aetna','Dr. Priya Nair','99214','M54.5',350.00,0.00,'Denied','Service not covered','CO-97',78,'No'),
('CLM036','PT036','Janet Roberts','2024-04-06','2024-04-08','Medicare','Dr. Arjun Mehta','99215','N18.3',450.00,360.00,'Paid',NULL,NULL,18,'No'),
('CLM037','PT037','Eugene Turner','2024-04-07','2024-04-09','BlueCross','Dr. Ravi Kumar','99213','K21.0',250.00,0.00,'Denied','Missing prior authorization','CO-15',110,'No'),
('CLM038','PT038','Katherine Phillips','2024-04-08','2024-04-10','United','Dr. Priya Nair','99214','F32.1',350.00,280.00,'Paid',NULL,NULL,22,'No'),
('CLM039','PT039','Roy Campbell','2024-04-09','2024-04-11','Cigna','Dr. Arjun Mehta','99215','Z00.00',450.00,0.00,'Denied','Invalid diagnosis code','CO-4',55,'Yes'),
('CLM040','PT040','Judith Parker','2024-04-10','2024-04-12','Aetna','Dr. Ravi Kumar','99213','I10',250.00,200.00,'Paid',NULL,NULL,30,'No');

-- ============================================================
-- STEP 2: ANALYSIS QUERIES
-- ============================================================

-- ────────────────────────────────────────
-- QUERY 1: Overall Claims Summary
-- ────────────────────────────────────────
SELECT 
    claim_status,
    COUNT(*)                            AS total_claims,
    SUM(billed_amount)                  AS total_billed,
    SUM(paid_amount)                    AS total_collected,
    ROUND(COUNT(*) * 100.0 / 
        SUM(COUNT(*)) OVER(), 2)        AS percentage
FROM claims
GROUP BY claim_status
ORDER BY total_claims DESC;

-- ────────────────────────────────────────
-- QUERY 2: Top 5 Denial Reasons (Most Important!)
-- ────────────────────────────────────────
SELECT 
    denial_reason,
    denial_code,
    COUNT(*)                            AS denial_count,
    SUM(billed_amount)                  AS revenue_at_risk,
    ROUND(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM claims 
         WHERE claim_status = 'Denied'), 2) AS denial_pct
FROM claims
WHERE claim_status = 'Denied'
GROUP BY denial_reason, denial_code
ORDER BY denial_count DESC
LIMIT 5;

-- ────────────────────────────────────────
-- QUERY 3: Payer-wise Denial Rate
-- ────────────────────────────────────────
SELECT 
    payer_name,
    COUNT(*)                            AS total_claims,
    SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END) AS denied_claims,
    SUM(CASE WHEN claim_status = 'Paid'   THEN 1 ELSE 0 END) AS paid_claims,
    ROUND(SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END) * 100.0 
          / COUNT(*), 2)                AS denial_rate_pct,
    SUM(billed_amount)                  AS total_billed,
    SUM(paid_amount)                    AS total_collected,
    ROUND(SUM(paid_amount) * 100.0 
          / SUM(billed_amount), 2)      AS collection_rate_pct
FROM claims
GROUP BY payer_name
ORDER BY denial_rate_pct DESC;

-- ────────────────────────────────────────
-- QUERY 4: AR Aging Bucket Analysis
-- ────────────────────────────────────────
SELECT 
    CASE 
        WHEN aging_days BETWEEN 0  AND 30  THEN '0-30 Days'
        WHEN aging_days BETWEEN 31 AND 60  THEN '31-60 Days'
        WHEN aging_days BETWEEN 61 AND 90  THEN '61-90 Days'
        WHEN aging_days > 90               THEN '90+ Days'
    END                                 AS aging_bucket,
    COUNT(*)                            AS claim_count,
    SUM(billed_amount)                  AS total_outstanding,
    ROUND(AVG(billed_amount), 2)        AS avg_claim_amount
FROM claims
WHERE claim_status IN ('Denied', 'Pending')
GROUP BY aging_bucket
ORDER BY 
    CASE aging_bucket
        WHEN '0-30 Days'   THEN 1
        WHEN '31-60 Days'  THEN 2
        WHEN '61-90 Days'  THEN 3
        WHEN '90+ Days'    THEN 4
    END;

-- ────────────────────────────────────────
-- QUERY 5: Provider Performance Report
-- ────────────────────────────────────────
SELECT 
    provider_name,
    COUNT(*)                            AS total_claims,
    SUM(billed_amount)                  AS total_billed,
    SUM(paid_amount)                    AS total_collected,
    ROUND(SUM(paid_amount) * 100.0 
          / SUM(billed_amount), 2)      AS collection_rate_pct,
    SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END) AS total_denials,
    ROUND(SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END) * 100.0 
          / COUNT(*), 2)                AS denial_rate_pct
FROM claims
GROUP BY provider_name
ORDER BY total_billed DESC;

-- ────────────────────────────────────────
-- QUERY 6: Monthly Trend Analysis
-- ────────────────────────────────────────
SELECT 
    DATE_FORMAT(date_of_service, '%Y-%m')  AS month_year,
    COUNT(*)                               AS total_claims,
    SUM(CASE WHEN claim_status='Denied' THEN 1 ELSE 0 END) AS denials,
    SUM(billed_amount)                     AS billed,
    SUM(paid_amount)                       AS collected,
    ROUND(SUM(CASE WHEN claim_status='Denied' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2)           AS denial_rate_pct
FROM claims
GROUP BY month_year
ORDER BY month_year;

-- ────────────────────────────────────────
-- QUERY 7: Resubmission Success Rate
-- ────────────────────────────────────────
SELECT 
    resubmitted,
    COUNT(*)                            AS claim_count,
    SUM(billed_amount)                  AS total_billed,
    ROUND(COUNT(*) * 100.0 / 
        SUM(COUNT(*)) OVER(), 2)        AS percentage
FROM claims
WHERE claim_status = 'Denied'
GROUP BY resubmitted;

-- ────────────────────────────────────────
-- QUERY 8: Revenue Leakage by Denial Code
-- (Most important for DA interviews!)
-- ────────────────────────────────────────
SELECT 
    denial_code,
    denial_reason,
    COUNT(*)                            AS occurrence_count,
    SUM(billed_amount)                  AS revenue_leakage,
    ROUND(SUM(billed_amount) * 100.0 / 
        (SELECT SUM(billed_amount) FROM claims 
         WHERE claim_status='Denied'), 2) AS leakage_pct
FROM claims
WHERE claim_status = 'Denied'
GROUP BY denial_code, denial_reason
ORDER BY revenue_leakage DESC;

-- ────────────────────────────────────────
-- QUERY 9: KPI Dashboard Query
-- (Use this for Power BI connection!)
-- ────────────────────────────────────────
SELECT 
    -- Total Claims KPIs
    COUNT(*)                                                AS total_claims,
    SUM(billed_amount)                                      AS gross_charges,
    SUM(paid_amount)                                        AS net_collections,
    
    -- Rate KPIs
    ROUND(SUM(paid_amount)*100.0/SUM(billed_amount),2)     AS net_collection_rate,
    ROUND(SUM(CASE WHEN claim_status='Denied' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS denial_rate,
    ROUND(SUM(CASE WHEN claim_status='Paid'   THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS clean_claim_rate,
    
    -- AR KPIs
    ROUND(AVG(CASE WHEN claim_status IN ('Denied','Pending') THEN aging_days END),1) AS avg_ar_days,
    SUM(CASE WHEN claim_status IN ('Denied','Pending') AND aging_days>90 
             THEN billed_amount ELSE 0 END)                AS bad_debt_risk
FROM claims;

-- ────────────────────────────────────────
-- QUERY 10: Window Function Demo
-- (Shows advanced SQL skill in interviews!)
-- ────────────────────────────────────────
SELECT 
    payer_name,
    claim_status,
    billed_amount,
    SUM(billed_amount)   OVER (PARTITION BY payer_name)                  AS payer_total,
    ROUND(billed_amount * 100.0 / 
          SUM(billed_amount) OVER (PARTITION BY payer_name), 2)          AS pct_of_payer,
    RANK()               OVER (PARTITION BY payer_name 
                               ORDER BY billed_amount DESC)              AS rank_in_payer,
    AVG(billed_amount)   OVER (PARTITION BY payer_name 
                               ORDER BY date_of_service 
                               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg
FROM claims
ORDER BY payer_name, billed_amount DESC;
