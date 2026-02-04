# SQL Collections Analytics

Automation of strategic decisions in debt collection using advanced SQL.

## 📊 About this project

12 years working in collections & debt recovery taught me that the best business decisions are those that can be automated consistently.

This repository contains production SQL queries that automate analysis and operational decisions in the debt collection and recovery domain.

## 🎯 Use cases

### 1. Collection Strategy Automation
Automatic assignment of contact strategy based on:
- Customer segment (Premium/Standard/Basic)
- Days past due (30/60/90/120+)
- Debt amount

**Impact:** 10,000 cases processed/day in < 1 second with 100% consistency.

See: [`collection_strategy_automation.sql`](./collection_strategy_automation.sql)

### 2. Rankings and Analysis with Window Functions
Calculation of rankings by region, temporal comparisons and Top-N analysis using ROW_NUMBER, RANK and PARTITION BY.

See: [`window_functions_rankings.sql`](./window_functions_rankings.sql) *(coming soon)*

### 3. CTEs and Defensive Programming
Queries that handle ETL duplicates, NULLs and imperfect production data using CTEs and pre-aggregations.

See: [`production_ctes.sql`](./production_ctes.sql) *(coming soon)*

## 🛠️ Tech stack

- **Database:** MySQL / PostgreSQL / SQLite
- **Tools:** DBeaver, AWS RDS, Power BI
- **Techniques:** Window Functions, CTEs, Nested CASE, Complex JOINs

## 📂 Repository structure

```
sql-collections-analytics/
├── README.md
├── collection_strategy_automation.sql    # Main query
├── collection_strategy_DOCUMENTATION.md  # Detailed explanation
└── sample_data/                          # Test data (coming soon)
```

## 🚀 How to use these queries

1. **Clone the repository** or download the .sql files
2. **Adapt the tables** to your database schema
3. **Review the documentation** for each query to understand the logic
4. **Test with sample data** before production

## 📈 Business context

These queries are not academic exercises. They are solutions to real problems that collection teams face:

- ✅ High volume processing (10K+ daily cases)
- ✅ Imperfect data (ETL duplicates, NULLs, multiple refreshes)
- ✅ BI tools integration (Power BI, QuickSight)
- ✅ Consistency in business policy application

## 👤 About me

**Iván Jarpa**  
BI Analyst | 12 years in Collections & Debt Recovery

Currently transitioning to Data Analyst with focus on AWS + SQL + Power BI.

📍 Chile | 🔗 [LinkedIn](https://linkedin.com/in/your-profile)

## 📝 License

These queries are free to use for educational and professional purposes. If you use them in your work, a mention would be appreciated 🙌

---

**Questions or suggestions?** Open an issue or contact me on LinkedIn.
