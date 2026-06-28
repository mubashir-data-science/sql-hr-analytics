# 👥 HR Analytics using SQL

20+ HR analytics queries covering workforce composition, salary analysis, attrition prediction, performance insights, and gender pay gap analysis.

![SQL](https://img.shields.io/badge/SQL-Advanced-blue?style=flat-square&logo=postgresql)
![HR](https://img.shields.io/badge/HR-Analytics-purple?style=flat-square)
![Queries](https://img.shields.io/badge/Queries-20%2B-orange?style=flat-square)

---

## 📊 Analysis Coverage

| Section | Insights |
|---------|---------|
| Workforce Overview | Headcount, avg age, tenure, satisfaction |
| Salary Analysis | By department, gender pay gap, salary bands |
| Attrition Analysis | By dept, overtime, salary, tenure |
| Performance | Score distribution, high performers at risk |
| Advanced | Budget analysis, salary ranking, hiring trends |

---

## 🔍 Key Business Questions Answered

- Which department has highest attrition?
- Is there a gender pay gap? If so, where?
- Which high performers are at flight risk?
- Does overtime increase attrition?
- Does training improve performance?

---

## ⚙️ Run

```bash
pip install pandas openpyxl
python run_analysis.py
# → Outputs: hr_analytics_results.xlsx
```

Or open `hr_analytics.sql` in DB Browser / pgAdmin.

---

## 📂 Structure

```
2_sql_hr_analytics/
├── hr_analytics.sql         ← 20+ SQL queries
├── run_analysis.py          ← Python runner
├── employees.csv            ← 300 employee records
├── departments.csv          ← 7 departments
└── README.md
```

---

*Built by Muhammad Mubashir*
