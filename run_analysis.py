"""
👥 HR Analytics — SQL Runner
Author: Muhammad Mubashir

Loads HR data into SQLite and runs all analytics queries.
Saves results to Excel with one sheet per query.
"""

import sqlite3
import pandas as pd

conn = sqlite3.connect(':memory:')

employees   = pd.read_csv('employees.csv')
departments = pd.read_csv('departments.csv')
employees.to_sql('employees',   conn, if_exists='replace', index=False)
departments.to_sql('departments', conn, if_exists='replace', index=False)

print("✅ HR Database loaded!")
print(f"   Employees   : {len(employees)}")
print(f"   Departments : {len(departments)}")
print(f"   Attrition % : {employees['attrition'].mean()*100:.1f}%\n")

queries = {
    "01_workforce_overview": """
        SELECT COUNT(*) AS total_employees,
               COUNT(CASE WHEN attrition=0 THEN 1 END) AS active,
               COUNT(CASE WHEN attrition=1 THEN 1 END) AS left_company,
               ROUND(AVG(salary),0)             AS avg_salary,
               ROUND(AVG(age),1)                AS avg_age,
               ROUND(AVG(years_at_company),1)   AS avg_tenure,
               ROUND(AVG(satisfaction_score),2) AS avg_satisfaction
        FROM employees
    """,
    "02_headcount_by_dept": """
        SELECT department,
               COUNT(*) AS total,
               COUNT(CASE WHEN attrition=0 THEN 1 END) AS active,
               ROUND(AVG(salary),0)          AS avg_salary,
               ROUND(AVG(performance_score),2) AS avg_performance
        FROM employees GROUP BY department ORDER BY total DESC
    """,
    "03_gender_distribution": """
        SELECT gender, COUNT(*) AS count,
               ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM employees),2) AS pct,
               ROUND(AVG(salary),0) AS avg_salary
        FROM employees GROUP BY gender
    """,
    "04_salary_by_dept": """
        SELECT department,
               ROUND(MIN(salary),0) AS min_salary,
               ROUND(AVG(salary),0) AS avg_salary,
               ROUND(MAX(salary),0) AS max_salary
        FROM employees WHERE attrition=0
        GROUP BY department ORDER BY avg_salary DESC
    """,
    "05_gender_pay_gap": """
        SELECT department,
               ROUND(AVG(CASE WHEN gender='Male'   THEN salary END),0) AS male_avg,
               ROUND(AVG(CASE WHEN gender='Female' THEN salary END),0) AS female_avg,
               ROUND((AVG(CASE WHEN gender='Male' THEN salary END) -
                      AVG(CASE WHEN gender='Female' THEN salary END)) /
                     AVG(CASE WHEN gender='Male' THEN salary END)*100,2) AS pay_gap_pct
        FROM employees GROUP BY department ORDER BY pay_gap_pct DESC
    """,
    "06_attrition_by_dept": """
        SELECT department,
               COUNT(*) AS total,
               SUM(attrition) AS left_count,
               ROUND(SUM(attrition)*100.0/COUNT(*),2) AS attrition_rate_pct,
               ROUND(AVG(CASE WHEN attrition=1 THEN satisfaction_score END),2) AS avg_sat_left,
               ROUND(AVG(CASE WHEN attrition=0 THEN satisfaction_score END),2) AS avg_sat_stayed
        FROM employees GROUP BY department ORDER BY attrition_rate_pct DESC
    """,
    "07_attrition_overtime": """
        SELECT CASE overtime WHEN 1 THEN 'Yes' ELSE 'No' END AS overtime,
               COUNT(*) AS total, SUM(attrition) AS left_count,
               ROUND(SUM(attrition)*100.0/COUNT(*),2) AS attrition_rate_pct,
               ROUND(AVG(satisfaction_score),2) AS avg_satisfaction
        FROM employees GROUP BY overtime
    """,
    "08_high_performers_at_risk": """
        SELECT employee_id,
               first_name||' '||last_name AS name,
               department, salary, performance_score, satisfaction_score
        FROM employees
        WHERE performance_score>=4 AND satisfaction_score<3.0 AND attrition=0
        ORDER BY satisfaction_score ASC LIMIT 15
    """,
    "09_training_vs_performance": """
        SELECT CASE WHEN training_hours<20  THEN '0-20 hrs'
                    WHEN training_hours<50  THEN '20-50 hrs'
                    WHEN training_hours<80  THEN '50-80 hrs'
                    ELSE '80+ hrs' END AS training_band,
               COUNT(*) AS employees,
               ROUND(AVG(performance_score),2) AS avg_performance,
               ROUND(AVG(salary),0)            AS avg_salary
        FROM employees WHERE attrition=0
        GROUP BY training_band ORDER BY MIN(training_hours)
    """,
    "10_new_hires_per_year": """
        SELECT substr(hire_date,1,4) AS year,
               COUNT(*) AS new_hires,
               ROUND(AVG(salary),0) AS avg_starting_salary,
               SUM(attrition) AS have_left,
               ROUND(SUM(attrition)*100.0/COUNT(*),2) AS attrition_pct
        FROM employees GROUP BY substr(hire_date,1,4) ORDER BY year
    """
}

print("="*60)
print("  RUNNING HR ANALYTICS QUERIES")
print("="*60)

results = {}
for name, query in queries.items():
    df_r = pd.read_sql_query(query, conn)
    results[name] = df_r
    print(f"\n📊 {name.replace('_',' ').title()}")
    print("-"*50)
    print(df_r.to_string(index=False))

print("\n\n💾 Saving to Excel...")
with pd.ExcelWriter('hr_analytics_results.xlsx', engine='openpyxl') as writer:
    for name, df_r in results.items():
        df_r.to_excel(writer, sheet_name=name[:31], index=False)
print("✅ Saved: hr_analytics_results.xlsx")

# Key insights
print("\n🔍 Key HR Insights:")
print("="*50)
total    = len(employees)
left     = employees['attrition'].sum()
at_risk  = len(employees[(employees['performance_score']>=4) & (employees['satisfaction_score']<3) & (employees['attrition']==0)])
top_dept = employees.groupby('department')['attrition'].mean().idxmax()
print(f"  Total Employees     : {total}")
print(f"  Attrition Rate      : {left/total*100:.1f}%")
print(f"  High Performers at Risk : {at_risk}")
print(f"  Highest Attrition Dept  : {top_dept}")
print(f"  Avg Satisfaction    : {employees['satisfaction_score'].mean():.2f}/5")
print("="*50)
conn.close()
print("\n✅ HR Analytics Complete!")
