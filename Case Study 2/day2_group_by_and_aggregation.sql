/*
===============================================================================
Day 2: GROUP BY & Aggregation Functions
Description: SQL queries focusing on data aggregation, GROUP BY, HAVING, 
             conditional aggregations (CASE WHEN), and subqueries.
===============================================================================
*/

-- ============================================================================
-- 1. BASIC GROUP BY & COUNT
-- ============================================================================

-- Q1. Identify the top 3 preferred insurance providers among patients.
SELECT 
    insurance_provider,
    COUNT(*) AS total_patients
FROM hos
GROUP BY insurance_provider
ORDER BY total_patients DESC
LIMIT 3;


-- Q2. What are the most common medical conditions among patients aged 60 and above?
SELECT 
    medical_condition, 
    COUNT(*) AS patient_count
FROM hos
WHERE age >= 60
GROUP BY medical_condition
ORDER BY patient_count DESC;


-- Q3. Determine the count of universal blood donors (O-) and universal recipients (AB+) within the patient population.
SELECT
    blood_type,
    COUNT(*) AS patient_count
FROM hos
WHERE blood_type IN ('O-', 'AB+')
GROUP BY blood_type;


-- ============================================================================
-- 2. CONDITIONAL GROUPING & CASE STATEMENTS
-- ============================================================================

-- Q4. How many patients fall into different BMI categories (Underweight, Normal, Overweight, Obese)?
SELECT 
    CASE
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal Weight'
        WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
        ELSE 'Obese'
    END AS weight_category,
    COUNT(*) AS patient_count
FROM hos
GROUP BY weight_category
ORDER BY patient_count DESC;


-- ============================================================================
-- 3. CATEGORICAL AGGREGATION & MULTI-COLUMN GROUP BY
-- ============================================================================

-- Q5. Which ethnic group exhibits the highest susceptibility to cancer?
SELECT 
    ethnicity,
    COUNT(*) AS cancer_patient_count
FROM hos
WHERE LOWER(medical_condition) = 'cancer'
GROUP BY ethnicity
ORDER BY cancer_patient_count DESC
LIMIT 1;


-- Q6. Identify the most commonly prescribed medications for each medical condition.
SELECT 
    medical_condition, 
    medication,
    COUNT(*) AS prescription_count
FROM hos
GROUP BY medical_condition, medication
ORDER BY prescription_count DESC;


-- ============================================================================
-- 4. FILTERING AGGREGATED DATA WITH HAVING
-- ============================================================================

-- Q7. Identify doctors who have treated more than 10 distinct patients.
SELECT 
    doctor, 
    COUNT(DISTINCT name) AS unique_patient_count
FROM hos
GROUP BY doctor
HAVING COUNT(DISTINCT name) > 10
ORDER BY unique_patient_count DESC;


-- Q8. List medical conditions that have an average hospitalization period greater than 15 days 
--     and where the maximum billing amount exceeds $25,000.
SELECT 
    medical_condition,
    ROUND(AVG(days_hospitalised), 0) AS avg_hospitalization_days,
    ROUND(MAX(billing_amount), 0) AS max_billing_amount
FROM hos 
GROUP BY medical_condition
HAVING AVG(days_hospitalised) > 15 
   AND MAX(billing_amount) >= 25000;


-- ============================================================================
-- 5. ADVANCED AGGREGATIONS & SUBQUERIES
-- ============================================================================

-- Q9. Find hospitals where the average billing amount exceeds the overall average billing amount by at least 50%.
SELECT 
    hospital,
    ROUND(AVG(billing_amount), 2) AS avg_hospital_billing
FROM hos
GROUP BY hospital
HAVING AVG(billing_amount) > (SELECT AVG(billing_amount) * 1.5 FROM hos);


-- Q10. Calculate total billing for emergency and elective admissions per medical condition.
--      Show only conditions where emergency billing is less than elective billing.
SELECT 
    medical_condition,
    SUM(CASE WHEN admission_type = 'Emergency' THEN billing_amount ELSE 0 END) AS total_emergency_billing,
    SUM(CASE WHEN admission_type = 'Elective' THEN billing_amount ELSE 0 END) AS total_elective_billing
FROM hos
GROUP BY medical_condition 
HAVING SUM(CASE WHEN admission_type = 'Emergency' THEN billing_amount ELSE 0 END) <
       SUM(CASE WHEN admission_type = 'Elective' THEN billing_amount ELSE 0 END);


-- Q11. Find doctors who treated 3+ cancer patients with an average billing exceeding $25,000.
SELECT 
    doctor,
    COUNT(DISTINCT name) AS cancer_patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount
FROM hos
WHERE LOWER(medical_condition) = 'cancer'
GROUP BY doctor
HAVING COUNT(DISTINCT name) >= 3
   AND AVG(billing_amount) > 25000
ORDER BY avg_billing_amount DESC;
