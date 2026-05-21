-- PROJECT 4: Healthcare Revenue Intelligence Dashboard
-- Author: Krishna Kandagatla
-- Domain: US Healthcare - Revenue Cycle Management
-- Tools: SQL MySQL + Power BI Ready
-- Business Problem: End-to-end revenue cycle performance tracking

USE healthcare_rcm;

CREATE TABLE IF NOT EXISTS revenue_data (
    record_id         VARCHAR(20) PRIMARY KEY,
    month_year        VARCHAR(10),
    department        VARCHAR(50),
    payer_name        VARCHAR(100),
    payer_type        VARCHAR(30),
    provider_name     VARCHAR(100),
    cpt_code          VARCHAR(20),
    total_claims      INT,
    billed_amount     DECIMAL(12,2),
    allowed_amount    DECIMAL(12,2),
    paid_amount       DECIMAL(12,2),
    denied_amount     DECIMAL(12,2),
    adjusted_amount   DECIMAL(12,2),
    denial_count      INT,
    avg_days_to_pay   INT
);

INSERT INTO revenue_data VALUES
('REV001','2024-01','Cardiology','Aetna','Commercial','Dr. Ravi Kumar','99213',120,180000,162000,145800,18000,16200,14,22),
('REV002','2024-01','Cardiology','Medicare','Medicare','Dr. Ravi Kumar','99214',85,127500,114750,103275,12750,11475,10,18),
('REV003','2024-01','Orthopedics','BlueCross','Commercial','Dr. Priya Nair','99215',95,142500,128250,115425,14250,12825,12,25),
('REV004','2024-01','Nephrology','United','Commercial','Dr. Arjun Mehta','99213',110,165000,148500,133650,16500,14850,15,20),
('REV005','2024-01','General Medicine','Cigna','Commercial','Dr. Ravi Kumar','99214',75,112500,101250,91125,11250,10125,8,28),
('REV006','2024-02','Cardiology','Aetna','Commercial','Dr. Ravi Kumar','99213',135,202500,182250,164025,20250,18225,18,21),
('REV007','2024-02','Cardiology','Medicare','Medicare','Dr. Ravi Kumar','99214',92,138000,124200,111780,13800,12420,11,17),
('REV008','2024-02','Orthopedics','BlueCross','Commercial','Dr. Priya Nair','99215',88,132000,118800,106920,13200,11880,10,24),
('REV009','2024-02','Nephrology','United','Commercial','Dr. Arjun Mehta','99213',125,187500,168750,151875,18750,16875,17,19),
('REV010','2024-02','General Medicine','Cigna','Commercial','Dr. Ravi Kumar','99214',82,123000,110700,99630,12300,11070,9,27),
('REV011','2024-03','Cardiology','Aetna','Commercial','Dr. Ravi Kumar','99213',148,222000,199800,179820,22200,19980,20,20),
('REV012','2024-03','Cardiology','Medicare','Medicare','Dr. Ravi Kumar','99214',98,147000,132300,119070,14700,13230,13,16),
('REV013','2024-03','Orthopedics','BlueCross','Commercial','Dr. Priya Nair','99215',102,153000,137700,123930,15300,13770,14,23),
('REV014','2024-03','Nephrology','United','Commercial','Dr. Arjun Mehta','99213',118,177000,159300,143370,17700,15930,16,21),
('REV015','2024-03','General Medicine','Cigna','Commercial','Dr. Ravi Kumar','99214',90,135000,121500,109350,13500,12150,10,26),
('REV016','2024-04','Cardiology','Aetna','Commercial','Dr. Ravi Kumar','99213',155,232500,209250,188325,23250,20925,21,19),
('REV017','2024-04','Cardiology','Medicare','Medicare','Dr. Ravi Kumar','99214',105,157500,141750,127575,15750,14175,14,15),
('REV018','2024-04','Orthopedics','BlueCross','Commercial','Dr. Priya Nair','99215',115,172500,155250,139725,17250,15525,15,22),
('REV019','2024-04','Nephrology','United','Commercial','Dr. Arjun Mehta','99213',130,195000,175500,157950,19500,17550,18,20),
('REV020','2024-04','General Medicine','Cigna','Commercial','Dr. Ravi Kumar','99214',95,142500,128250,115425,14250,12825,11,25);

-- QUERY 1: Executive Revenue Summary
SELECT
    SUM(total_claims)                                                    AS total_claims,
    SUM(billed_amount)                                                   AS gross_charges,
    SUM(paid_amount)                                                     AS net_collections,
    SUM(denied_amount)                                                   AS total_denials,
    ROUND(SUM(paid_amount)*100.0/SUM(billed_amount),2)                   AS net_collection_rate,
    ROUND(SUM(denied_amount)*100.0/SUM(billed_amount),2)                 AS denial_rate,
    ROUND(AVG(avg_days_to_pay),1)                                        AS avg_days_to_pay
FROM revenue_data;

-- QUERY 2: Department Revenue Performance
SELECT
    department,
    SUM(total_claims)                                                    AS claims,
    SUM(billed_amount)                                                   AS billed,
    SUM(paid_amount)                                                     AS collected,
    SUM(denied_amount)                                                   AS denied,
    ROUND(SUM(paid_amount)*100.0/SUM(billed_amount),2)                   AS collection_rate,
    ROUND(SUM(denied_amount)*100.0/SUM(billed_amount),2)                 AS denial_rate,
    RANK() OVER (ORDER BY SUM(paid_amount) DESC)                         AS revenue_rank
FROM revenue_data
GROUP BY department
ORDER BY collected DESC;

-- QUERY 3: Monthly Revenue Trend with Growth Rate
SELECT
    month_year,
    SUM(billed_amount)                                                   AS billed,
    SUM(paid_amount)                                                     AS collected,
    SUM(denied_amount)                                                   AS denied,
    ROUND(SUM(paid_amount)*100.0/SUM(billed_amount),2)                   AS collection_rate,
    LAG(SUM(paid_amount)) OVER (ORDER BY month_year)                     AS prev_month_collections,
    ROUND((SUM(paid_amount) - LAG(SUM(paid_amount)) OVER (ORDER BY month_year))
          *100.0 / LAG(SUM(paid_amount)) OVER (ORDER BY month_year),2)  AS mom_growth_pct
FROM revenue_data
GROUP BY month_year
ORDER BY month_year;

-- QUERY 4: Payer Mix Analysis (Critical for CFO!)
SELECT
    payer_type,
    payer_name,
    SUM(total_claims)                                                    AS claims,
    SUM(billed_amount)                                                   AS billed,
    SUM(paid_amount)                                                     AS collected,
    ROUND(SUM(paid_amount)*100.0/SUM(billed_amount),2)                   AS collection_rate,
    ROUND(AVG(avg_days_to_pay),1)                                        AS avg_days_to_pay,
    ROUND(SUM(paid_amount)*100.0/SUM(SUM(paid_amount)) OVER(),2)         AS pct_of_total_revenue
FROM revenue_data
GROUP BY payer_type, payer_name
ORDER BY collected DESC;

-- QUERY 5: Provider Revenue Scorecard
SELECT
    provider_name,
    COUNT(DISTINCT department)                                           AS departments,
    SUM(total_claims)                                                    AS total_claims,
    SUM(billed_amount)                                                   AS billed,
    SUM(paid_amount)                                                     AS collected,
    SUM(denial_count)                                                    AS denials,
    ROUND(SUM(paid_amount)*100.0/SUM(billed_amount),2)                   AS collection_rate,
    ROUND(SUM(denial_count)*100.0/SUM(total_claims),2)                   AS denial_rate
FROM revenue_data
GROUP BY provider_name
ORDER BY collected DESC;

-- QUERY 6: Revenue Leakage Analysis
SELECT
    department,
    payer_name,
    SUM(denied_amount)                                                   AS denied_revenue,
    SUM(adjusted_amount)                                                 AS adjusted_revenue,
    SUM(denied_amount) + SUM(adjusted_amount)                           AS total_leakage,
    ROUND((SUM(denied_amount)+SUM(adjusted_amount))*100.0/SUM(billed_amount),2) AS leakage_rate
FROM revenue_data
GROUP BY department, payer_name
ORDER BY total_leakage DESC
LIMIT 10;

-- QUERY 7: CTE - Rolling 3 Month Average Revenue
WITH monthly_rev AS (
    SELECT
        month_year,
        SUM(paid_amount) AS monthly_collections
    FROM revenue_data
    GROUP BY month_year
)
SELECT
    month_year,
    monthly_collections,
    ROUND(AVG(monthly_collections) OVER (
        ORDER BY month_year
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ),2)                                                                 AS rolling_3month_avg,
    ROUND(SUM(monthly_collections) OVER (ORDER BY month_year),2)        AS running_total_ytd
FROM monthly_rev
ORDER BY month_year;

-- QUERY 8: Power BI Dashboard Master Query
SELECT
    month_year,
    department,
    payer_name,
    payer_type,
    provider_name,
    SUM(total_claims)                                                    AS claims,
    SUM(billed_amount)                                                   AS billed,
    SUM(paid_amount)                                                     AS collected,
    SUM(denied_amount)                                                   AS denied,
    SUM(denial_count)                                                    AS denial_count,
    ROUND(SUM(paid_amount)*100.0/SUM(billed_amount),2)                   AS collection_rate,
    ROUND(SUM(denied_amount)*100.0/SUM(billed_amount),2)                 AS denial_rate,
    ROUND(AVG(avg_days_to_pay),1)                                        AS avg_days_to_pay
FROM revenue_data
GROUP BY month_year, department, payer_name, payer_type, provider_name
ORDER BY month_year, department;
