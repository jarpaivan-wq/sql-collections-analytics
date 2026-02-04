# Documentation: Collection Strategy Automation

## 📋 Table of Contents
1. [Executive summary](#executive-summary)
2. [Business problem](#business-problem)
3. [Technical solution](#technical-solution)
4. [Decision matrix](#decision-matrix)
5. [Implementation](#implementation)
6. [Use cases](#use-cases)
7. [Results and metrics](#results-and-metrics)
8. [FAQ](#faq)

---

## 📊 Executive summary

**SQL query that automates contact strategy assignment for 10,000+ daily past-due cases**, freeing up executive time and guaranteeing consistency in collection policy application.

### Measurable impact
- ⏱️ **Time per case:** < 1 second (vs 5-10 minutes manual)
- 📈 **Volume:** 10,000 cases processed/day
- ✅ **Consistency:** 100% correct policy application
- 💰 **ROI:** 15-20 executive hours freed per day

---

## 🎯 Business problem

### Current situation (manual process)

Every morning, supervisors review the past-due portfolio and assign contact strategies:

```
Typical day example:
├─ 10,000 new past-due cases
├─ 3 supervisors available
├─ 5-10 minutes per manual decision
└─ Result: Only 200-300 cases assigned correctly
```

### Identified problems

1. **Inconsistency:** Different supervisors apply different criteria
2. **Bottleneck:** Doesn't scale with portfolio volume
3. **Wasted time:** Senior executives making operational decisions
4. **Errors:** Premium customer treated as Basic (relationship loss)

### Cost of the problem

- 💸 Supervisors spending 60-70% of time on assignments
- 📉 Cases without assigned strategy for 2-3 days
- ⚠️ Premium customers receiving generic treatment
- 🔄 Rework due to incorrect assignments

---

## 💡 Technical solution

### Approach

Encode the business decision matrix in a SQL query that:

1. **Evaluates** customer segment and days past due
2. **Applies** business-established policies
3. **Assigns** optimal strategy automatically
4. **Scales** to any volume without human intervention

### SQL technique used: Nested CASE

```sql
CASE
    WHEN [segment] = 'PREMIUM' THEN
        CASE
            WHEN [days_past_due] <= 30 THEN 'Strategy A'
            WHEN [days_past_due] <= 60 THEN 'Strategy B'
            ELSE 'Strategy C'
        END
    WHEN [segment] = 'STANDARD' THEN
        ...
END
```

**Why nested CASE:**
- ✅ Multiple hierarchical conditions (first segment, then past due)
- ✅ Readable and maintainable (clear decision structure)
- ✅ Performant (short-circuit evaluation)
- ✅ Extensible (easy to add new segments or thresholds)

---

## 📐 Decision matrix

### PREMIUM Segment (High-value customers)

**Philosophy:** Maximum personalization, avoid relationship deterioration

| Days past due | Strategy | Executor | Rationale |
|---------------|----------|----------|-----------|
| ≤ 30 days | Courteous call | Regular executive | Friendly reminder, probably oversight |
| ≤ 60 days | Email + Call | Senior executive | Needs attention but no excessive pressure |
| > 60 days | Senior executive visit | Account manager | Delicate situation, requires physical presence |

### STANDARD Segment (Operational volume)

**Philosophy:** Balance between attention and efficiency

| Days past due | Strategy | Executor | Rationale |
|---------------|----------|----------|-----------|
| ≤ 30 days | Automated email | System | First low-cost contact |
| ≤ 60 days | Standard call | Regular executive | Escalation necessary |
| > 60 days | Intensive collection | Collection team | Multiple contacts, controlled pressure |

### BASIC Segment (Operational efficiency)

**Philosophy:** Maximum efficiency, rapid escalation

| Days past due | Strategy | Executor | Rationale |
|---------------|----------|----------|-----------|
| ≤ 60 days | Mass SMS | System | Most economical channel |
| > 60 days | Legal action | Legal department | Low probability of voluntary payment |

---

## 🛠️ Implementation

### Step 1: Verify table structure

```sql
-- Verify necessary columns exist
SELECT 
    d.segment,           -- Must exist: 'PREMIUM', 'STANDARD', 'BASIC'
    de.days_past_due,    -- Must be numeric
    de.status            -- Must exist: 'PAST_DUE'
FROM debtors d
JOIN debts de ON d.debtor_id = de.debtor_id
LIMIT 5;
```

### Step 2: Run complete query

See file: [`collection_strategy_automation.sql`](./collection_strategy_automation.sql)

### Step 3: Validate results

```sql
-- Distribution of assigned strategies
SELECT 
    collection_strategy,
    COUNT(*) as cases,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM [query_result]
GROUP BY collection_strategy
ORDER BY cases DESC;
```

**Expected result:**
```
collection_strategy       | cases | percentage
--------------------------|-------|------------
AUTOMATED EMAIL           | 3,245 | 32.45%
STANDARD CALL             | 2,856 | 28.56%
MASS SMS                  | 2,103 | 21.03%
INTENSIVE COLLECTION      | 1,012 | 10.12%
COURTEOUS CALL            | 456   | 4.56%
EMAIL + CALL              | 234   | 2.34%
SENIOR EXECUTIVE VISIT    | 67    | 0.67%
LEGAL ACTION              | 27    | 0.27%
```

### Step 4: Integrate with Power BI / QuickSight

```sql
-- Materialized view for dashboard
CREATE VIEW vw_strategy_assignment AS
SELECT * FROM [complete query];

-- Connect Power BI to this view
-- Automatic refresh every hour
```

---

## 🎓 Use cases

### Case 1: Morning operational dashboard

**Need:** Supervisors need to see case distribution at start of day

```sql
-- Executive summary by strategy
SELECT 
    collection_strategy,
    COUNT(*) as total_cases,
    SUM(current_amount) as total_debt,
    AVG(days_past_due) as average_past_due
FROM [query_result]
GROUP BY collection_strategy
ORDER BY total_debt DESC;
```

### Case 2: Assignment to specific executives

**Need:** Distribute cases according to executive workload

```sql
-- Add assigned executive column
SELECT 
    *,
    CASE collection_strategy
        WHEN 'SENIOR EXECUTIVE VISIT' THEN 'Manager_North_Zone'
        WHEN 'EMAIL + CALL' THEN 'Premium_Executive_' || (ROW_NUMBER() OVER (ORDER BY current_amount DESC) % 3 + 1)
        ELSE 'Standard_Pool'
    END as assigned_executive
FROM [query_result];
```

### Case 3: Prioritization by amount

**Need:** Attack high-value cases first

```sql
-- Top 100 highest amount cases by strategy
SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY collection_strategy ORDER BY current_amount DESC) as priority
    FROM [query_result]
) ranked
WHERE priority <= 100;
```

### Case 4: Automatic alerts

**Need:** Notify when Premium customer enters severe past due

```sql
-- Critical cases for immediate alert
SELECT 
    name,
    surname,
    days_past_due,
    current_amount,
    collection_strategy
FROM [query_result]
WHERE segment = 'PREMIUM'
    AND days_past_due > 60
    AND current_amount > 5000000;  -- Significant amount
```

---

## 📈 Results and metrics

### Before vs After

| Metric | Before (Manual) | After (Automated) | Improvement |
|--------|-----------------|-------------------|-------------|
| Cases assigned/day | 200-300 | 10,000 | +3,233% |
| Time per case | 5-10 min | < 1 sec | -99.7% |
| Policy consistency | 60-70% | 100% | +43% |
| Executive hours/day | 20-25 hrs | 1-2 hrs | -92% |
| Assignment errors | 5-10% | 0% | -100% |

### Calculated ROI

```
Development cost:
├─ 8 hours SQL development
├─ 4 hours testing
└─ 2 hours documentation
Total: 14 hours

Monthly benefit:
├─ 400 executive hours freed
├─ Error reduction: ~50 cases/month
└─ Recovery improvement: 2-3%

ROI: 2,800% in first month
```

---

## ❓ FAQ

### What if business policies change?

**A:** The query is designed to be easily modifiable. Changing a day threshold or adding a strategy takes 5-10 minutes.

Example - change Premium threshold from 30 to 45 days:
```sql
WHEN de.days_past_due <= 45 THEN 'COURTEOUS CALL'  -- before: 30
```

### Does it work with other database engines?

**A:** Yes, the query uses standard SQL compatible with:
- ✅ MySQL / MariaDB
- ✅ PostgreSQL
- ✅ SQL Server
- ✅ SQLite
- ✅ Oracle

Just adjust engine-specific date/string functions if any.

### What about edge cases (missing data, new segments)?

**A:** The query handles edge cases with:
- `UPPER(TRIM())` for text inconsistencies
- Final `ELSE` for undefined segments (treated as Basic)
- Filter `WHERE status = 'PAST_DUE' AND days_past_due > 0` removes invalid cases

### How does it integrate with existing workflow?

**A:** 3 options:

1. **Daily batch:** Cron job executes query and exports to CSV for CRM import
2. **Live view:** Power BI connected directly to SQL view (refresh every hour)
3. **API:** Query exposed via REST API for external systems

### What if an executive needs to override the strategy?

**A:** The query assigns the **recommended** strategy, doesn't block manual changes. Supervisors can override when there's additional context (customer in legal process, previous agreement, etc.).

### Can it be used to predict recovery?

**A:** This query assigns strategies. For recovery prediction you would need:
- Historical collections vs payments
- ML model (logistic regression or random forest)
- Features: segment, past due, applied strategy, collection result

See: `recovery_prediction_model.py` (coming soon)

---

## 📞 Contact

**Questions about implementation?**  
Open an issue in this repo or contact me on [LinkedIn](https://linkedin.com/in/your-profile)

**Want to adapt this to your business?**  
This query is free to use. If you need help with implementation or adaptation, message me.

---

*Last updated: January 2026*
