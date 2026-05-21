-- ============================================================
-- PROJECT 2: AR Aging Dashboard & Collections Analysis
-- Author: Krishna Kandagatla
-- Domain: US Healthcare - Accounts Receivable Management
-- Tools: SQL (MySQL compatible)
-- Description: Track outstanding AR, aging buckets, collector
--              performance, and payer-wise collection trends
-- ============================================================

USE healthcare_rcm;

-- ============================================================
-- STEP 1: CREATE AR TRACKING TABLE
-- ============================================================

CREATE TABLE ar_accounts (
    account_id       VARCHAR(20) PRIMARY KEY,
    patient_id       VARCHAR(20),
    patient_name     VARCHAR(100),
    date_of_service  DATE,
    bill_date        DATE,
    due_date         DATE,
    last_followup    DATE,
    payer_name       VARCHAR(100),
    payer_type       VARCHAR(50),   -- 'Commercial', 'Medicare', 'Medicaid', 'Self-Pay'
    provider_name    VARCHAR(100),
    collector_name   VARCHAR(100),
    billed_amount    DECIMAL(10,2),
    insurance_paid   DECIMAL(10,2),
    patient_paid     DECIMAL(10,2),
    adjustment       DECIMAL(10,2),
    balance_due      DECIMAL(10,2),
    account_status   VARCHAR(30),   -- 'Active', 'Resolved', 'Collections', 'Write-off'
    followup_count   INT,
    priority_flag    VARCHAR(10)    -- 'High', 'Medium', 'Low'
);

INSERT INTO ar_accounts VALUES
('AR001','PT001','John Smith','2024-01-05','2024-01-10','2024-02-10','2024-03-01','Aetna','Commercial','Dr. Ravi Kumar','Collector A',1200.00,960.00,100.00,50.00,90.00,'Active',3,'Low'),
('AR002','PT002','Mary Johnson','2024-01-08','2024-01-13','2024-02-13','2024-02-20','BlueCross','Commercial','Dr. Priya Nair','Collector B',2500.00,0.00,0.00,0.00,2500.00,'Active',1,'High'),
('AR003','PT003','Robert Davis','2024-01-12','2024-01-17','2024-02-17','2024-03-05','Medicare','Medicare','Dr. Arjun Mehta','Collector A',800.00,640.00,0.00,80.00,80.00,'Active',4,'Low'),
('AR004','PT004','Linda Wilson','2024-01-15','2024-01-20','2024-02-20','2024-02-28','Cigna','Commercial','Dr. Ravi Kumar','Collector C',3200.00,0.00,0.00,0.00,3200.00,'Active',2,'High'),
('AR005','PT005','James Brown','2024-01-20','2024-01-25','2024-02-25','2024-03-10','United','Commercial','Dr. Priya Nair','Collector B',1500.00,1200.00,150.00,75.00,75.00,'Active',5,'Low'),
('AR006','PT006','Patricia Taylor','2024-02-01','2024-02-06','2024-03-06','2024-03-15','Medicare','Medicare','Dr. Arjun Mehta','Collector A',950.00,0.00,0.00,0.00,950.00,'Active',1,'High'),
('AR007','PT007','Michael Anderson','2024-02-05','2024-02-10','2024-03-10','2024-03-20','BlueCross','Commercial','Dr. Ravi Kumar','Collector C',4500.00,3600.00,400.00,200.00,300.00,'Active',6,'Medium'),
('AR008','PT008','Barbara Thomas','2024-02-10','2024-02-15','2024-03-15','2024-03-25','Aetna','Commercial','Dr. Priya Nair','Collector B',750.00,0.00,0.00,0.00,750.00,'Active',2,'High'),
('AR009','PT009','William Jackson','2024-02-15','2024-02-20','2024-03-20','2024-04-01','Medicaid','Medicaid','Dr. Arjun Mehta','Collector A',600.00,480.00,0.00,60.00,60.00,'Active',3,'Low'),
('AR010','PT010','Elizabeth White','2024-02-20','2024-02-25','2024-03-25','2024-04-05','Cigna','Commercial','Dr. Ravi Kumar','Collector C',1800.00,0.00,0.00,0.00,1800.00,'Collections',0,'High'),
('AR011','PT011','David Harris','2024-03-01','2024-03-06','2024-04-06','2024-04-10','United','Commercial','Dr. Priya Nair','Collector B',2200.00,1760.00,200.00,110.00,130.00,'Active',4,'Low'),
('AR012','PT012','Susan Martin','2024-03-05','2024-03-10','2024-04-10','2024-04-15','Medicare','Medicare','Dr. Arjun Mehta','Collector A',1100.00,0.00,0.00,0.00,1100.00,'Active',1,'High'),
('AR013','PT013','Joseph Thompson','2024-03-10','2024-03-15','2024-04-15','2024-04-20','BlueCross','Commercial','Dr. Ravi Kumar','Collector C',3500.00,2800.00,300.00,175.00,225.00,'Active',5,'Medium'),
('AR014','PT014','Margaret Garcia','2024-03-15','2024-03-20','2024-04-20','2024-04-25','Aetna','Commercial','Dr. Priya Nair','Collector B',900.00,0.00,0.00,0.00,900.00,'Active',2,'High'),
('AR015','PT015','Charles Martinez','2024-03-20','2024-03-25','2024-04-25','2024-05-01','Medicaid','Medicaid','Dr. Arjun Mehta','Collector A',650.00,520.00,0.00,65.00,65.00,'Active',3,'Low'),
('AR016','PT016','Dorothy Robinson','2024-04-01','2024-04-06','2024-05-06','2024-05-10','Cigna','Commercial','Dr. Ravi Kumar','Collector C',2800.00,2240.00,250.00,140.00,170.00,'Active',4,'Low'),
('AR017','PT017','Thomas Clark','2024-04-05','2024-04-10','2024-05-10','2024-05-15','United','Commercial','Dr. Priya Nair','Collector B',1600.00,0.00,0.00,0.00,1600.00,'Active',1,'High'),
('AR018','PT018','Helen Rodriguez','2024-04-10','2024-04-15','2024-05-15','2024-05-20','Medicare','Medicare','Dr. Arjun Mehta','Collector A',850.00,680.00,0.00,85.00,85.00,'Active',3,'Low'),
('AR019','PT019','Gary Lewis','2024-04-15','2024-04-20','2024-05-20','2024-05-25','BlueCross','Commercial','Dr. Ravi Kumar','Collector C',5000.00,0.00,0.00,0.00,5000.00,'Collections',0,'High'),
('AR020','PT020','Betty Lee','2024-04-20','2024-04-25','2024-05-25','2024-05-28','Aetna','Commercial','Dr. Priya Nair','Collector B',1300.00,1040.00,130.00,65.00,65.00,'Resolved',6,'Low'),
('AR021','PT021','Raymond Walker','2024-01-03','2024-01-08','2024-02-08','2024-02-15','Cigna','Commercial','Dr. Arjun Mehta','Collector A',4200.00,0.00,0.00,0.00,4200.00,'Write-off',0,'High'),
('AR022','PT022','Ruth Hall','2024-01-18','2024-01-23','2024-02-23','2024-03-01','United','Commercial','Dr. Ravi Kumar','Collector C',780.00,624.00,78.00,39.00,39.00,'Resolved',5,'Low'),
('AR023','PT023','Frank Allen','2024-02-08','2024-02-13','2024-03-13','2024-03-20','Medicare','Medicare','Dr. Priya Nair','Collector B',1950.00,0.00,0.00,0.00,1950.00,'Active',2,'High'),
('AR024','PT024','Sharon Young','2024-02-18','2024-02-23','2024-03-23','2024-04-01','BlueCross','Commercial','Dr. Arjun Mehta','Collector A',670.00,536.00,0.00,67.00,67.00,'Active',4,'Low'),
('AR025','PT025','Jack Hernandez','2024-03-08','2024-03-13','2024-04-13','2024-04-18','Aetna','Commercial','Dr. Ravi Kumar','Collector C',3100.00,0.00,0.00,0.00,3100.00,'Active',1,'High');

-- ============================================================
-- STEP 2: CALCULATE AGING DAYS (Dynamic)
-- ============================================================

-- Add computed aging column view
CREATE OR REPLACE VIEW ar_with_aging AS
SELECT 
    *,
    DATEDIFF(CURDATE(), bill_date)      AS current_aging_days,
    CASE 
        WHEN DATEDIFF(CURDATE(), bill_date) BETWEEN 0  AND 30  THEN '0-30 Days'
        WHEN DATEDIFF(CURDATE(), bill_date) BETWEEN 31 AND 60  THEN '31-60 Days'
        WHEN DATEDIFF(CURDATE(), bill_date) BETWEEN 61 AND 90  THEN '61-90 Days'
        WHEN DATEDIFF(CURDATE(), bill_date) > 90               THEN '90+ Days'
    END                                 AS aging_bucket
FROM ar_accounts
WHERE account_status NOT IN ('Resolved', 'Write-off');

-- ============================================================
-- STEP 3: ANALYSIS QUERIES
-- ============================================================

-- ────────────────────────────────────────
-- QUERY 1: AR Aging Summary (Main KPI!)
-- ────────────────────────────────────────
SELECT 
    aging_bucket,
    COUNT(*)                            AS account_count,
    SUM(balance_due)                    AS total_outstanding,
    ROUND(AVG(balance_due), 2)          AS avg_balance,
    ROUND(SUM(balance_due) * 100.0 / 
        SUM(SUM(balance_due)) OVER(), 2) AS pct_of_total_ar
FROM ar_with_aging
GROUP BY aging_bucket
ORDER BY 
    CASE aging_bucket
        WHEN '0-30 Days'   THEN 1
        WHEN '31-60 Days'  THEN 2
        WHEN '61-90 Days'  THEN 3
        WHEN '90+ Days'    THEN 4
    END;

-- ────────────────────────────────────────
-- QUERY 2: Payer Type AR Breakdown
-- ────────────────────────────────────────
SELECT 
    payer_type,
    COUNT(*)                            AS accounts,
    SUM(billed_amount)                  AS total_billed,
    SUM(insurance_paid + patient_paid)  AS total_collected,
    SUM(balance_due)                    AS total_outstanding,
    ROUND(SUM(insurance_paid+patient_paid)*100.0/SUM(billed_amount), 2) AS collection_rate
FROM ar_accounts
GROUP BY payer_type
ORDER BY total_outstanding DESC;

-- ────────────────────────────────────────
-- QUERY 3: Collector Performance Scorecard
-- ────────────────────────────────────────
SELECT 
    collector_name,
    COUNT(*)                            AS total_accounts,
    SUM(CASE WHEN account_status='Resolved' THEN 1 ELSE 0 END) AS resolved,
    SUM(CASE WHEN account_status='Active'   THEN 1 ELSE 0 END) AS active,
    SUM(balance_due)                    AS outstanding_balance,
    SUM(insurance_paid+patient_paid)    AS amount_collected,
    ROUND(AVG(followup_count),1)        AS avg_followups,
    ROUND(SUM(CASE WHEN account_status='Resolved' THEN 1 ELSE 0 END)
          *100.0/COUNT(*), 2)           AS resolution_rate_pct
FROM ar_accounts
GROUP BY collector_name
ORDER BY amount_collected DESC;

-- ────────────────────────────────────────
-- QUERY 4: High Priority Accounts (Action List)
-- ────────────────────────────────────────
SELECT 
    account_id,
    patient_name,
    payer_name,
    collector_name,
    balance_due,
    DATEDIFF(CURDATE(), bill_date)      AS aging_days,
    last_followup,
    DATEDIFF(CURDATE(), last_followup)  AS days_since_followup,
    followup_count,
    account_status
FROM ar_accounts
WHERE priority_flag = 'High'
  AND account_status = 'Active'
ORDER BY balance_due DESC, aging_days DESC;

-- ────────────────────────────────────────
-- QUERY 5: Days in AR Calculation
-- (Key metric: target < 40 days)
-- ────────────────────────────────────────
SELECT 
    payer_name,
    ROUND(AVG(DATEDIFF(COALESCE(last_followup, CURDATE()), bill_date)), 1) AS avg_days_in_ar,
    COUNT(*)                            AS account_count,
    SUM(balance_due)                    AS total_ar,
    CASE 
        WHEN AVG(DATEDIFF(COALESCE(last_followup,CURDATE()), bill_date)) < 30  THEN '✅ Excellent'
        WHEN AVG(DATEDIFF(COALESCE(last_followup,CURDATE()), bill_date)) < 45  THEN '🟡 Good'
        WHEN AVG(DATEDIFF(COALESCE(last_followup,CURDATE()), bill_date)) < 60  THEN '🟠 Warning'
        ELSE '🔴 Critical'
    END                                 AS ar_health
FROM ar_accounts
WHERE account_status = 'Active'
GROUP BY payer_name
ORDER BY avg_days_in_ar DESC;

-- ────────────────────────────────────────
-- QUERY 6: Monthly Collections Trend
-- ────────────────────────────────────────
SELECT 
    DATE_FORMAT(date_of_service, '%Y-%m')  AS service_month,
    COUNT(*)                               AS total_accounts,
    SUM(billed_amount)                     AS gross_billed,
    SUM(insurance_paid + patient_paid)     AS total_collected,
    SUM(adjustment)                        AS total_adjustments,
    SUM(balance_due)                       AS net_outstanding,
    ROUND(SUM(insurance_paid+patient_paid)*100.0/SUM(billed_amount),2) AS collection_rate
FROM ar_accounts
GROUP BY service_month
ORDER BY service_month;

-- ────────────────────────────────────────
-- QUERY 7: Write-off & Bad Debt Analysis
-- ────────────────────────────────────────
SELECT 
    account_status,
    COUNT(*)                            AS count,
    SUM(balance_due)                    AS total_amount,
    ROUND(SUM(balance_due)*100.0/
        (SELECT SUM(balance_due) FROM ar_accounts), 2) AS pct_of_total
FROM ar_accounts
GROUP BY account_status
ORDER BY total_amount DESC;

-- ────────────────────────────────────────
-- QUERY 8: Accounts Needing Immediate Follow-up
-- ────────────────────────────────────────
SELECT 
    account_id,
    patient_name,
    payer_name,
    balance_due,
    DATEDIFF(CURDATE(), last_followup)  AS days_no_contact,
    followup_count,
    priority_flag,
    CASE 
        WHEN DATEDIFF(CURDATE(), last_followup) > 30 AND priority_flag='High' THEN '🔴 URGENT'
        WHEN DATEDIFF(CURDATE(), last_followup) > 20                          THEN '🟠 Follow Up'
        WHEN DATEDIFF(CURDATE(), last_followup) > 10                          THEN '🟡 Monitor'
        ELSE '✅ Recent'
    END                                 AS action_needed
FROM ar_accounts
WHERE account_status = 'Active'
ORDER BY days_no_contact DESC, balance_due DESC;

-- ────────────────────────────────────────
-- QUERY 9: Provider AR Performance
-- ────────────────────────────────────────
SELECT 
    provider_name,
    COUNT(*)                            AS patients,
    SUM(billed_amount)                  AS billed,
    SUM(insurance_paid+patient_paid)    AS collected,
    SUM(balance_due)                    AS outstanding,
    ROUND(SUM(insurance_paid+patient_paid)*100.0/SUM(billed_amount),2) AS net_collection_pct
FROM ar_accounts
GROUP BY provider_name
ORDER BY outstanding DESC;

-- ────────────────────────────────────────
-- QUERY 10: Complete AR Dashboard KPIs
-- (Power BI lo card visuals ki use cheyyi!)
-- ────────────────────────────────────────
SELECT
    COUNT(*)                                                     AS total_open_accounts,
    SUM(balance_due)                                             AS total_ar_outstanding,
    ROUND(AVG(DATEDIFF(CURDATE(), bill_date)), 1)                AS avg_days_in_ar,
    SUM(CASE WHEN priority_flag='High' THEN balance_due ELSE 0 END) AS high_priority_ar,
    SUM(CASE WHEN DATEDIFF(CURDATE(),bill_date)>90 THEN balance_due ELSE 0 END) AS ar_over_90_days,
    ROUND(SUM(CASE WHEN DATEDIFF(CURDATE(),bill_date)>90 THEN balance_due ELSE 0 END)
          *100.0/SUM(balance_due),2)                             AS pct_ar_over_90,
    SUM(insurance_paid+patient_paid)                             AS ytd_collections,
    ROUND(SUM(insurance_paid+patient_paid)*100.0/SUM(billed_amount),2) AS overall_collection_rate
FROM ar_accounts
WHERE account_status = 'Active';
