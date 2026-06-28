-- ============================================================
-- 👥 HR Analytics using SQL
-- Author: Muhammad Mubashir
-- Description: 20+ HR analytics queries covering workforce,
--              attrition, salary, performance, and diversity
-- ============================================================

-- ── Setup Tables ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS employees (
    employee_id           INTEGER PRIMARY KEY,
    first_name            TEXT,
    last_name             TEXT,
    department            TEXT,
    job_title             TEXT,
    salary                INTEGER,
    hire_date             DATE,
    gender                TEXT,
    age                   INTEGER,
    city                  TEXT,
    performance_score     INTEGER,  -- 1-5
    attrition             INTEGER,  -- 0=Active, 1=Left
    overtime              INTEGER,  -- 0=No, 1=Yes
    training_hours        INTEGER,
    years_at_company      INTEGER,
    satisfaction_score    REAL      -- 1-5
);

CREATE TABLE IF NOT EXISTS departments (
    dept_id    INTEGER PRIMARY KEY,
    dept_name  TEXT,
    manager_id INTEGER,
    budget     INTEGER,
    location   TEXT
);


-- ============================================================
-- SECTION 1: WORKFORCE OVERVIEW
-- ============================================================

-- 1.1 Total Headcount & Basic Stats
SELECT
    COUNT(*)                                AS total_employees,
    COUNT(CASE WHEN attrition = 0 THEN 1 END) AS active_employees,
    COUNT(CASE WHEN attrition = 1 THEN 1 END) AS left_employees,
    ROUND(AVG(salary), 0)                   AS avg_salary,
    ROUND(AVG(age), 1)                      AS avg_age,
    ROUND(AVG(years_at_company), 1)         AS avg_tenure_years,
    ROUND(AVG(satisfaction_score), 2)       AS avg_satisfaction
FROM employees;


-- 1.2 Headcount by Department
SELECT
    department,
    COUNT(*)                                    AS total,
    COUNT(CASE WHEN attrition = 0 THEN 1 END)  AS active,
    COUNT(CASE WHEN attrition = 1 THEN 1 END)  AS left_company,
    ROUND(AVG(salary), 0)                       AS avg_salary,
    ROUND(AVG(performance_score), 2)            AS avg_performance
FROM employees
GROUP BY department
ORDER BY total DESC;


-- 1.3 Gender Distribution
SELECT
    gender,
    COUNT(*)                                            AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    ROUND(AVG(salary), 0)                               AS avg_salary,
    ROUND(AVG(performance_score), 2)                    AS avg_performance
FROM employees
GROUP BY gender;


-- 1.4 Age Group Distribution
SELECT
    CASE
        WHEN age < 30 THEN 'Under 30'
        WHEN age BETWEEN 30 AND 40 THEN '30-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        ELSE 'Above 50'
    END AS age_group,
    COUNT(*) AS count,
    ROUND(AVG(salary), 0) AS avg_salary,
    ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction
FROM employees
GROUP BY age_group
ORDER BY
    CASE age_group
        WHEN 'Under 30' THEN 1
        WHEN '30-40'    THEN 2
        WHEN '41-50'    THEN 3
        ELSE 4
    END;


-- ============================================================
-- SECTION 2: SALARY ANALYSIS
-- ============================================================

-- 2.1 Salary Statistics by Department
SELECT
    department,
    COUNT(*)                        AS employees,
    ROUND(MIN(salary), 0)           AS min_salary,
    ROUND(AVG(salary), 0)           AS avg_salary,
    ROUND(MAX(salary), 0)           AS max_salary,
    ROUND(MAX(salary) - MIN(salary), 0) AS salary_range
FROM employees
WHERE attrition = 0
GROUP BY department
ORDER BY avg_salary DESC;


-- 2.2 Salary by Gender per Department (Pay Gap Analysis)
SELECT
    department,
    ROUND(AVG(CASE WHEN gender='Male'   THEN salary END), 0) AS avg_male_salary,
    ROUND(AVG(CASE WHEN gender='Female' THEN salary END), 0) AS avg_female_salary,
    ROUND(
        (AVG(CASE WHEN gender='Male' THEN salary END) -
         AVG(CASE WHEN gender='Female' THEN salary END)) /
        NULLIF(AVG(CASE WHEN gender='Male' THEN salary END), 0) * 100, 2
    ) AS gender_pay_gap_pct
FROM employees
GROUP BY department
ORDER BY gender_pay_gap_pct DESC;


-- 2.3 Salary Bands
SELECT
    CASE
        WHEN salary < 60000  THEN 'Under 60K'
        WHEN salary < 100000 THEN '60K-100K'
        WHEN salary < 150000 THEN '100K-150K'
        WHEN salary < 200000 THEN '150K-200K'
        ELSE 'Above 200K'
    END AS salary_band,
    COUNT(*) AS employees,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM employees
WHERE attrition = 0
GROUP BY salary_band
ORDER BY MIN(salary);


-- 2.4 Top 10 Highest Paid Employees
SELECT
    employee_id,
    first_name || ' ' || last_name AS name,
    department,
    job_title,
    salary,
    performance_score,
    years_at_company
FROM employees
WHERE attrition = 0
ORDER BY salary DESC
LIMIT 10;


-- ============================================================
-- SECTION 3: ATTRITION ANALYSIS
-- ============================================================

-- 3.1 Overall Attrition Rate
SELECT
    COUNT(*) AS total_employees,
    SUM(attrition) AS left_count,
    ROUND(SUM(attrition) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees;


-- 3.2 Attrition by Department
SELECT
    department,
    COUNT(*)                    AS total,
    SUM(attrition)              AS left_count,
    ROUND(SUM(attrition) * 100.0 / COUNT(*), 2) AS attrition_rate_pct,
    ROUND(AVG(CASE WHEN attrition=1 THEN satisfaction_score END), 2) AS avg_sat_left,
    ROUND(AVG(CASE WHEN attrition=0 THEN satisfaction_score END), 2) AS avg_sat_stayed
FROM employees
GROUP BY department
ORDER BY attrition_rate_pct DESC;


-- 3.3 Attrition by Salary Band
SELECT
    CASE
        WHEN salary < 60000  THEN 'Under 60K'
        WHEN salary < 100000 THEN '60K-100K'
        WHEN salary < 150000 THEN '100K-150K'
        ELSE 'Above 150K'
    END AS salary_band,
    COUNT(*) AS total,
    SUM(attrition) AS left_count,
    ROUND(SUM(attrition) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY salary_band
ORDER BY MIN(salary);


-- 3.4 Attrition by Overtime
SELECT
    CASE overtime WHEN 1 THEN 'Yes' ELSE 'No' END AS overtime,
    COUNT(*)  AS total,
    SUM(attrition) AS left_count,
    ROUND(SUM(attrition) * 100.0 / COUNT(*), 2) AS attrition_rate_pct,
    ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction
FROM employees
GROUP BY overtime;


-- 3.5 Attrition by Years at Company
SELECT
    CASE
        WHEN years_at_company <= 1  THEN '0-1 years'
        WHEN years_at_company <= 3  THEN '2-3 years'
        WHEN years_at_company <= 5  THEN '4-5 years'
        WHEN years_at_company <= 10 THEN '6-10 years'
        ELSE '10+ years'
    END AS tenure_band,
    COUNT(*) AS total,
    SUM(attrition) AS left_count,
    ROUND(SUM(attrition) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY tenure_band
ORDER BY MIN(years_at_company);


-- ============================================================
-- SECTION 4: PERFORMANCE ANALYSIS
-- ============================================================

-- 4.1 Performance Score Distribution
SELECT
    performance_score,
    COUNT(*) AS employees,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    ROUND(AVG(salary), 0) AS avg_salary
FROM employees
WHERE attrition = 0
GROUP BY performance_score
ORDER BY performance_score;


-- 4.2 High Performers at Risk of Attrition
SELECT
    employee_id,
    first_name || ' ' || last_name AS name,
    department,
    salary,
    performance_score,
    satisfaction_score,
    years_at_company,
    overtime
FROM employees
WHERE performance_score >= 4
  AND satisfaction_score < 3.0
  AND attrition = 0
ORDER BY satisfaction_score ASC, performance_score DESC
LIMIT 15;


-- 4.3 Training Hours vs Performance
SELECT
    CASE
        WHEN training_hours < 20  THEN '0-20 hrs'
        WHEN training_hours < 50  THEN '20-50 hrs'
        WHEN training_hours < 80  THEN '50-80 hrs'
        ELSE '80+ hrs'
    END AS training_band,
    COUNT(*) AS employees,
    ROUND(AVG(performance_score), 2) AS avg_performance,
    ROUND(AVG(salary), 0) AS avg_salary,
    ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction
FROM employees
WHERE attrition = 0
GROUP BY training_band
ORDER BY MIN(training_hours);


-- ============================================================
-- SECTION 5: ADVANCED HR INSIGHTS
-- ============================================================

-- 5.1 Department Budget vs Headcount (using departments table)
SELECT
    d.dept_name,
    d.budget,
    COUNT(e.employee_id)              AS headcount,
    ROUND(d.budget * 1.0 / NULLIF(COUNT(e.employee_id), 0), 0) AS budget_per_employee,
    ROUND(SUM(e.salary), 0)           AS total_salary_cost,
    d.budget - SUM(e.salary)         AS remaining_budget
FROM departments d
LEFT JOIN employees e ON d.dept_name = e.department AND e.attrition = 0
GROUP BY d.dept_name, d.budget
ORDER BY budget DESC;


-- 5.2 Employee Ranking by Salary within Department
SELECT
    employee_id,
    first_name || ' ' || last_name AS name,
    department,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank,
    ROUND(salary - AVG(salary) OVER (PARTITION BY department), 0) AS vs_dept_avg
FROM employees
WHERE attrition = 0
ORDER BY department, salary_rank
LIMIT 20;


-- 5.3 New Hires per Year
SELECT
    substr(hire_date, 1, 4) AS year,
    COUNT(*) AS new_hires,
    ROUND(AVG(salary), 0) AS avg_starting_salary,
    SUM(attrition) AS have_left,
    ROUND(SUM(attrition) * 100.0 / COUNT(*), 2) AS retention_failure_pct
FROM employees
GROUP BY substr(hire_date, 1, 4)
ORDER BY year;
