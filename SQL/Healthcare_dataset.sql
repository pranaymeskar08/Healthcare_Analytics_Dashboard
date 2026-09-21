-- ============================================================
-- Healthcare Dashboard Mini Project
-- SQL Analysis Questions
-- ============================================================
--
-- Instructions:
-- 1. Solve each question using SQL.
-- 2. Each question should produce ONE analytical result set.
-- 3. These result sets are intended to be exported as CSV files
--    and later imported into Power BI.
-- 4. Do not modify the raw healthcare table.
-- 5. Use your cleaned/staging table as the source.
--
-- Dataset columns:
-- Name
-- Age
-- Gender
-- Blood Type
-- Medical Condition
-- Date of Admission
-- Doctor
-- Hospital
-- Insurance Provider
-- Billing Amount
-- Room Number
-- Admission Type
-- Discharge Date
-- Medication
-- Test Results
--
-- ============================================================
-- SECTOR 1: EXECUTIVE OVERVIEW
-- ============================================================

-- Q1. Create a final executive healthcare summary report containing:
--
-- total_patients
-- total_admissions
-- total_hospitals
-- total_doctors
-- total_medical_conditions
-- total_insurance_providers
-- total_billing_amount
-- average_billing_amount
-- average_patient_age
-- earliest_admission_date
-- latest_admission_date
--
-- Expected CSV:
-- executive_healthcare_summary.csv
SELECT 
    COUNT(*) AS total_admissions,
    COUNT(DISTINCT hcd."Hospital") AS total_hospitals,
    COUNT(DISTINCT hcd."Doctor") AS total_doctors,
    COUNT(DISTINCT hcd."Medical Condition") AS total_medical_conditions,
    COUNT(DISTINCT hcd."Insurance Provider") AS total_insurance_providers,
    ROUND(SUM(hcd."Billing Amount")::numeric, 2) 
        AS total_billing_amount,
    ROUND(AVG(hcd."Billing Amount")::numeric, 2) 
        AS average_billing_amount,
    ROUND(AVG(hcd."Age")::numeric, 1) 
        AS average_patient_age,
    MIN(hcd."Date of Admission") 
        AS earliest_admission_date,
    MAX(hcd."Date of Admission") 
        AS latest_admission_date
FROM healthcare_cleaned_dataset hcd;


-- ============================================================
-- SECTOR 2: PATIENT DEMOGRAPHICS
-- ============================================================

-- Q2. Create a patient demographics analysis report containing:
--
-- age_group
-- gender
-- blood_type
-- patient_count
-- average_age
-- total_billing_amount
-- average_billing_amount
--
-- The result should allow Power BI to analyze patient
-- demographics by age group, gender, and blood type.
--
-- Expected CSV:
-- patient_demographics.csv
SELECT 
    CASE
        WHEN hcd."Age" < 18 THEN 'Children'
        WHEN hcd."Age" BETWEEN 18 AND 29 THEN 'Young Adults'
        WHEN hcd."Age" BETWEEN 30 AND 44 THEN 'Adults'
        WHEN hcd."Age" BETWEEN 45 AND 59 THEN 'Middle Age'
        WHEN hcd."Age" >= 60 THEN 'Seniors'
        ELSE 'Unknown'
    END AS age_group,
    hcd."Gender" AS gender,
    hcd."Blood Type" AS blood_type,
    COUNT(*) AS patient_count,
    ROUND(AVG(hcd."Age")::numeric, 1) AS average_age,
    ROUND(SUM(hcd."Billing Amount")::numeric, 2) 
        AS total_billing_amount,
    ROUND(AVG(hcd."Billing Amount")::numeric, 2) 
        AS average_billing_amount
FROM healthcare_cleaned_dataset hcd
GROUP BY
    CASE
        WHEN hcd."Age" < 18 THEN 'Children'
        WHEN hcd."Age" BETWEEN 18 AND 29 THEN 'Young Adults'
        WHEN hcd."Age" BETWEEN 30 AND 44 THEN 'Adults'
        WHEN hcd."Age" BETWEEN 45 AND 59 THEN 'Middle Age'
        WHEN hcd."Age" >= 60 THEN 'Seniors'
        ELSE 'Unknown'
    END,
    hcd."Gender",
    hcd."Blood Type";


-- ============================================================
-- SECTOR 3: MEDICAL CONDITION ANALYSIS
-- ============================================================

-- Q3. Create a medical condition performance report containing:
--
-- medical_condition
-- patient_count
-- average_patient_age
-- total_billing_amount
-- average_billing_amount
-- male_patient_count
-- female_patient_count
-- average_length_of_stay
--
-- Expected CSV:
-- medical_condition_analysis.csv
select 
	hcd."Medical Condition" ,
	count(*) as patient_count,
	ROUND(AVG(hcd."Age")::numeric, 1) AS average_patient_age,
	ROUND(sum(hcd."Billing Amount" )::NUMERIC,2) as total_billing_amount,
	ROUND(avg(hcd."Billing Amount" )::NUMERIC,2) as average_billing_amount,
	count(*) filter(where "Gender" = 'Male') as male_patients,
	count(*) filter(where "Gender" = 'Female') as female_patients,
	ROUND(AVG(hcd."Discharge Date"::date  - hcd."Date of Admission"::date)::numeric) AS average_length_of_stay
from healthcare_cleaned_dataset hcd 
group by hcd."Medical Condition";


-- ============================================================
-- SECTOR 4: HOSPITAL ANALYSIS
-- ============================================================

-- Q4. Create a hospital performance report containing:
--
-- hospital
-- patient_count
-- unique_doctor_count
-- medical_condition_count
-- total_billing_amount
-- average_billing_amount
-- average_patient_age
-- average_length_of_stay
-- first_admission_date
-- latest_admission_date
--
-- Expected CSV:
-- hospital_performance.csv
select 
	hcd."Hospital" ,
	count(*) as patient_count,
	count(distinct hcd."Doctor" ) as unique_doctor_count,
	count(distinct hcd."Medical Condition" ) as medical_condition_count,
	round(sum(hcd."Billing Amount" )::numeric,2) as total_billing_amount,
	round(avg(hcd."Billing Amount" )::numeric,2) as average_billing_amount,
	round(avg(hcd."Age" )::numeric,1) as average_patient_age,
	ROUND(AVG(hcd."Discharge Date"::date  - hcd."Date of Admission"::date)::numeric) AS average_length_of_stay,
	MIN(hcd."Date of Admission"::date ) as first_admission_date,
	MAX(hcd."Date of Admission"::date ) as last_admission_date
from healthcare_cleaned_dataset hcd
group by hcd."Hospital" ;


-- ============================================================
-- SECTOR 5: ADMISSION ANALYSIS
-- ============================================================

-- Q5. Create an admission analysis report containing:
--
-- admission_year
-- admission_month
-- admission_month_number
-- admission_type
-- patient_count
-- average_age
-- total_billing_amount
-- average_billing_amount
-- average_length_of_stay
--
-- Expected CSV:
-- admission_analysis.csv
select 
	to_char(hcd."Date of Admission"::date ,'YYYY') as admission_year,
	to_char(hcd."Date of Admission"::date, 'Mon') as admission_month,
	to_char(hcd."Date of Admission"::date, 'MM') as admission_month_number,
	hcd."Admission Type" ,
	count(*) as patient_count,
	round(avg(hcd."Age" )::numeric) as average_age,
	round(sum(hcd."Billing Amount" )::numeric,2) as total_billing_amount,
	round(avg(hcd."Billing Amount" )::numeric,2) as average_billing_amount,
	round(avg(hcd."Discharge Date"::date - hcd."Date of Admission"::date )::numeric) as average_length_of_stay
from healthcare_cleaned_dataset hcd 
group by to_char(hcd."Date of Admission"::date ,'YYYY'),
	to_char(hcd."Date of Admission"::date, 'Mon'),
	to_char(hcd."Date of Admission"::date, 'MM'),
	hcd."Admission Type" 
order by admission_year asc, admission_month_number ASC ;


-- ============================================================
-- SECTOR 6: DOCTOR ANALYSIS
-- ============================================================

-- Q6. Create a doctor performance report containing:
--
-- doctor
-- hospital
-- patient_count
-- medical_condition_count
-- total_billing_amount
-- average_billing_amount
-- average_patient_age
-- average_length_of_stay
-- first_admission_date
-- latest_admission_date
--
-- Expected CSV:
-- doctor_performance.csv
select 
	hcd."Doctor" as Doctor,
	hcd."Hospital" as Hospital,
	count(*) as patient_count,
	count(distinct hcd."Medical Condition" ) as medical_condition_count,
	round(sum(hcd."Billing Amount" )::numeric,2) as total_billing_amount,
	round(avg(hcd."Billing Amount" )::numeric,2) as average_billing_amount,
	round(avg(hcd."Age" )::numeric) as average_patient_age,
	round(avg(hcd."Discharge Date"::date - hcd."Date of Admission"::date )::numeric) as average_length_of_stay,
	min(hcd."Date of Admission" ::date) as first_admission_date,
	max(hcd."Date of Admission" ::date) as latest_admission_date
from healthcare_cleaned_dataset hcd 
group by hcd."Doctor" , hcd."Hospital" ;



-- ============================================================
-- SECTOR 7: INSURANCE ANALYSIS
-- ============================================================

-- Q7. Create an insurance provider analysis report containing:
--
-- insurance_provider
-- patient_count
-- hospital_count
-- total_billing_amount
-- average_billing_amount
-- average_patient_age
-- medical_condition_count
--
-- Expected CSV:
-- insurance_analysis.csv
select 
	hcd."Insurance Provider" as Insurance_provider ,
	count(*) as patient_count,
	count(distinct hcd."Hospital" ) as hospital_count,
	round(sum(hcd."Billing Amount" )::numeric,2) as total_billing_amount,
	round(avg(hcd."Billing Amount" )::numeric,2) as average_billing_amount,
	round(avg(hcd."Age" )::numeric) as average_patient_age,
	count(distinct hcd."Medical Condition" ) as medical_condition_count
from healthcare_cleaned_dataset hcd 
group by hcd."Insurance Provider" ;



-- ============================================================
-- SECTOR 8: ADMISSION TYPE ANALYSIS
-- ============================================================

-- Q8. Create an admission type performance report containing:
--
-- admission_type
-- patient_count
-- average_age
-- total_billing_amount
-- average_billing_amount
-- average_length_of_stay
-- medical_condition_count
--
-- Expected CSV:
-- admission_type_analysis.csv
select 
	hcd."Admission Type" as admission_type,
	count(*) as patient_count,
	round(avg(hcd."Age" )::numeric) as average_age,
	round(sum(hcd."Billing Amount" )::numeric,2) as total_billing_amount,
	round(avg(hcd."Billing Amount" )::numeric,2) as average_billing_amount,
	round(avg(hcd."Discharge Date"::date - hcd."Date of Admission"::date )::numeric) as average_length_of_stay,
	count(distinct hcd."Medical Condition" ) as medical_condition_count
from healthcare_cleaned_dataset hcd 
group by hcd."Admission Type" ;



-- ============================================================
-- SECTOR 9: MEDICATION & TEST RESULTS
-- ============================================================

-- Q9. Create a medication and test-results analysis report containing:
--
-- medication
-- test_results
-- patient_count
-- average_patient_age
-- total_billing_amount
-- average_billing_amount
-- average_length_of_stay
--
-- Expected CSV:
-- medication_test_analysis.csv
select 
	hcd."Medication" as medication,
	hcd."Test Results" as test_results,
	count(*) as patient_count,
	round(avg(hcd."Age" )::numeric) as average_patient_age,
	round(sum(hcd."Billing Amount" )::numeric,2) as total_billing_amount,
	round(avg(hcd."Billing Amount" )::numeric,2) as average_billing_amount,
	round(avg(hcd."Discharge Date"::date - hcd."Date of Admission"::date )::numeric) as average_length_of_stay
from healthcare_cleaned_dataset hcd 
group by hcd."Medication" , hcd."Test Results" 
ORDER BY 
    hcd."Medication" ASC,
    hcd."Test Results" ASC;


-- ============================================================
-- SECTOR 10: PATIENT ADMISSION DETAIL / DRILL-THROUGH
-- ============================================================

-- Q10. Create a detailed patient admission report containing:
--
-- patient_name
-- age
-- gender
-- blood_type
-- medical_condition
-- doctor
-- hospital
-- insurance_provider
-- admission_date
-- discharge_date
-- length_of_stay
-- admission_type
-- billing_amount
-- medication
-- test_results
--
-- Expected CSV:
-- patient_admission_detail.csv
select 
	hcd."Name" as patient_name,
	hcd."Age" as age,
	hcd."Gender" as gender,
	hcd."Blood Type" as blood_type,
	hcd."Medical Condition" as medical_condition,
	hcd."Doctor" as doctor,
	hcd."Hospital" as hospital,
	hcd."Insurance Provider" as insurance_provider,
	hcd."Date of Admission"  as admission_date,
	hcd."Discharge Date" as discharge_date,
	(hcd."Discharge Date"::date - hcd."Date of Admission"::date) as length_of_stay,
	hcd."Admission Type" as admission_type,
	hcd."Billing Amount" as billing_amount,
	hcd."Medication" as medication,
	hcd."Test Results" as test_results
from healthcare_cleaned_dataset hcd ;


-- ============================================================
-- SECTOR 11: HOSPITAL × MEDICAL CONDITION
-- ============================================================

-- Q11. Create a hospital and medical-condition analysis report containing:
--
-- hospital
-- medical_condition
-- patient_count
-- average_patient_age
-- total_billing_amount
-- average_billing_amount
-- average_length_of_stay
--
-- Expected CSV:
-- hospital_condition_analysis.csv
select 
	hcd."Hospital" ,
	hcd."Medical Condition" ,
	count(*) as patient_count,
	round(avg(hcd."Age" )::numeric) as average_patient_age,
	round(sum(hcd."Billing Amount" )::numeric,2) as total_billing_amount,
	round(avg(hcd."Billing Amount" )::numeric,2) as average_billing_amount,
	round(avg(hcd."Discharge Date"::date - hcd."Date of Admission"::date )::numeric) as average_length_of_stay
from healthcare_cleaned_dataset hcd 
group by hcd."Hospital" , hcd."Medical Condition" ;


-- ============================================================
-- SECTOR 12: DEMOGRAPHICS × MEDICAL CONDITION
-- ============================================================

-- Q12. Create a demographic and medical-condition analysis report containing:
--
-- age_group
-- gender
-- medical_condition
-- patient_count
-- average_billing_amount
-- total_billing_amount
-- average_length_of_stay
--
-- Expected CSV:
-- demographic_condition_analysis.csv
select 
	case 
        WHEN hcd."Age" < 18 THEN 'Children'
        WHEN hcd."Age" BETWEEN 18 AND 29 THEN 'Young Adults'
        WHEN hcd."Age" BETWEEN 30 AND 44 THEN 'Adults'
        WHEN hcd."Age" BETWEEN 45 AND 59 THEN 'Middle Age'
        WHEN hcd."Age" >= 60 THEN 'Seniors'
        ELSE 'Unknown'
	end as age_group,
	hcd."Gender" as gender,
	hcd."Medical Condition" as medical_condition ,
	count(*) as patient_count,
	round(avg(hcd."Billing Amount" )::numeric,2) as average_billing_amount,
	round(sum(hcd."Billing Amount" )::numeric,2) as total_billing_amount,
	round(avg(hcd."Discharge Date"::date - hcd."Date of Admission"::date )::numeric) as average_length_of_stay
from healthcare_cleaned_dataset hcd 
group by 
	case 
        WHEN hcd."Age" < 18 THEN 'Children'
        WHEN hcd."Age" BETWEEN 18 AND 29 THEN 'Young Adults'
        WHEN hcd."Age" BETWEEN 30 AND 44 THEN 'Adults'
        WHEN hcd."Age" BETWEEN 45 AND 59 THEN 'Middle Age'
        WHEN hcd."Age" >= 60 THEN 'Seniors'
        ELSE 'Unknown'
	end,hcd."Gender" , hcd."Medical Condition" 
order by
	age_group ASC,
    gender ASC,
    medical_condition ASC;


-- ============================================================
-- SECTOR 13: MONTHLY HEALTHCARE ACTIVITY
-- ============================================================

-- Q13. Create a monthly healthcare activity report containing:
--
-- year
-- month
-- month_number
-- admission_count
-- total_billing_amount
-- average_billing_amount
-- average_patient_age
-- average_length_of_stay
--
-- The result should be suitable for creating time-series
-- visualizations in Power BI.
--
-- Expected CSV:
-- monthly_healthcare_activity.csv
select 
	to_char(hcd."Date of Admission"::date ,'YYYY') as year,
	to_char(hcd."Date of Admission"::date , 'Mon') as month,
	to_char(hcd."Date of Admission"::date , 'MM') as month_number,
	count(*) as admission_count,
	round(sum(hcd."Billing Amount" )::numeric,2) as total_billing_amount,
	round(avg(hcd."Billing Amount" )::numeric,2) as average_billing_amount,
	round(avg(hcd."Age" )::numeric) as average_patient_age,
	round(avg(hcd."Discharge Date"::date - hcd."Date of Admission"::date )::numeric) as average_length_of_stay
from healthcare_cleaned_dataset hcd 
group by 
	to_char(hcd."Date of Admission"::date ,'YYYY') ,
	to_char(hcd."Date of Admission"::date , 'Mon') ,
	to_char(hcd."Date of Admission"::date , 'MM')
order by 
	"year" asc,
	month_number asc;





-- ============================================================
-- END OF QUESTION FILE
-- ============================================================
