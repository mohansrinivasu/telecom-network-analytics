# 📡 Telecom Network & Customer Experience Analytics
### End-to-End Data Analyst Project | Excel · SQL · Python · Tableau

---

## 📌 Project Overview

A telecom company was facing **increasing customer complaints, delayed payments, and unclear impact of network quality on customer retention**. Leadership needed data-driven insights to prioritize network investments and reduce churn.

As the Data Analyst on this project, I performed a complete end-to-end analysis — from raw data cleaning all the way to an executive-ready dashboard — answering three core business questions:

1. **Which cities require urgent network improvements?**
2. **Does poor network quality affect payments and churn?**
3. **Are 5G users experiencing fewer issues than 4G/3G users?**

---

## 📊 Dataset Description

The dataset contains **4 related tables** representing a real-world telecom business scenario:

| Table | Description | Key Columns |
|---|---|---|
| `customers` | Customer demographics & subscription info | customer_id, customer_type, age, city, signup_date |
| `network_usage` | Daily data and call usage per customer | data_used_gb, call_minutes, network_type |
| `network_issues` | Network complaints and resolution tracking | issue_type, resolution_time_hrs, resolved |
| `billing` | Monthly billing and payment behavior | bill_amount, payment_status |

**Cities covered:** Bangalore, Mumbai, Delhi, Chennai, Kolkata, Hyderabad

**Customer types:** Prepaid, Postpaid

**Network types:** 3G, 4G, 5G

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| Microsoft Excel | Data cleaning, standardization, pivot tables |
| SQL Server (T-SQL) | Relational database, joins, window functions, views |
| Python (Pandas, Matplotlib, Seaborn) | EDA, feature engineering, risk scoring |
| Tableau | Executive KPI dashboard, city-level performance |

---

## Phase 1 — Excel

**File:** `excel/Telecom_data_cleaned.xlsx`

**What was done:**

- Cleaned and standardized inconsistent city names and date formats
- Created `month` and `year` columns from date fields for time-series analysis
- Identified high-usage customers using `IF` logic based on data usage thresholds
- Built **pivot tables** for:
  - City-wise issue counts
  - Customer type distribution
  - Monthly billing trends

**Why this matters:** Raw data always has inconsistencies. This phase ensured all downstream SQL and Python analysis was built on reliable, clean inputs.

---

## Phase 2 — SQL

**File:** `sql/TelecomAnalytics.sql`

**Database:** `TelecomAnalyticsDB` (SQL Server)

**What was built:**

**Schema & Relationships**
- Created 4 relational tables with proper `PRIMARY KEY` and `FOREIGN KEY` constraints
- Loaded data via `BULK INSERT`

**Analysis Queries**

| Query | Business Purpose |
|---|---|
| Multi-table JOIN (all 4 tables) | Unified view of customer activity |
| Complaint Rate per Customer | `Total Complaints / Total Usage Records` |
| Monthly Complaint Trend | Aggregated complaints by month/year |
| Running Total Complaints | Cumulative trend using `SUM() OVER` |
| Month-over-Month City Complaints | `LAG()` window function for trend detection |
| City-wise Issues & Avg Resolution Time | Identifies cities needing urgent attention |
| Payment Delays vs. Complaints | Tests if poor network quality drives late payments |
| 5G vs. 4G/3G Issue Comparison | Validates 5G investment impact |

**View Created:**
```sql
CREATE VIEW VW_customer_complaint_analysis AS
-- Summarizes total complaints and avg resolution time per customer
```

**Why this matters:** SQL structured the data into business-ready aggregations that answered the leadership questions directly. Window functions provided trend insights that simple aggregations can't.

---

## Phase 3 — Python (Pandas)

**File:** `python/Telecom_Analytics.ipynb`

**Libraries:** `pandas`, `numpy`, `matplotlib`, `seaborn`

**What was built:**

**Data Validation**
- Shape, dtypes, null checks, duplicate detection
- Logical constraint validation (negative values, outliers, category consistency)
- Data quality report across all 4 tables

**Feature Engineering**

*Heavy Usage Flag (Lambda)*
```python
network_usage["heavy_usage_flag"] = network_usage.apply(
    lambda row: 1 if (row["data_used_gb"] > 10 or row["call_minutes"] > 200) else 0,
    axis=1
)
```

*Customer Risk Score Function*
```python
def calculate_risk_score(row):
    score = 0
    if row["total_complaints"] > 5:   score += 2
    if row["avg_resolution_time"] > 48: score += 2
    if row["payment_risk"] > 0:         score += 2
    if row["heavy_usage_flag"] == 1:    score += 1
    return score
```

Risk categories: `High Risk (≥5)` | `Medium Risk (3–4)` | `Low Risk (<3)`

**Exploratory Data Analysis (EDA)**
- Customer distribution by city and type
- Average customer age by city
- Total data used by network type (3G/4G/5G)
- Average call minutes by network type
- Heavy usage customer percentage
- Complaints by issue type
- Average resolution time by issue type
- Payment status distribution
- Revenue by city

**Visualizations:** 7 charts covering customer, usage, complaint, and billing dimensions

**Output:** `customer_risk_analysis.csv` — exported for Tableau use

**Why this matters:** Python enabled complex feature engineering (risk scoring) that SQL can't do easily. The risk score became the primary churn indicator used in the Tableau dashboard.

---

## Phase 4 — Tableau

**File:** `tableau/telecom_Analytics.twb`

**Dashboards built:**

| Dashboard | What It Shows |
|---|---|
| Revenue | Top-level metrics: revenue, payment delays, total bills |
| Customer Experience & Network Performance | Issues, Avg resolution times, and Total Customers|

**Why this matters:** Tableau translated all the technical analysis into a format that business stakeholders (non-technical) can understand and act on immediately.

---

## 💡 Business Insights & Answers

### 1. Which cities require urgent network improvement?
Cities with the highest complaint volume combined with the longest average resolution times were flagged as priority targets for infrastructure investment.

### 2. Does poor network quality affect payments and churn?
Yes. Customers with more than 5 complaints also showed a higher rate of delayed or unpaid bills, confirming a direct link between network experience and payment behavior — a strong churn predictor.

### 3. Are 5G users experiencing fewer issues?
The SQL and Python analysis compared issue counts across network types. Results showed whether the 5G investment was delivering a measurably better customer experience relative to 4G/3G users.

---

## ▶️ How to Run This Project

### Excel
Open `excel/Telecom_data_cleaned.xlsx` in Microsoft Excel 2016 or later.

### SQL
1. Open SQL Server Management Studio (SSMS)
2. Run `sql/TelecomAnalytics.sql`
3. Update the file paths in `BULK INSERT` statements to match your local machine before running
4. The script will create the database, tables, and all analysis queries

### Python
```bash
# Install dependencies
pip install pandas numpy matplotlib seaborn openpyxl

# Open notebook
jupyter notebook python/Telecom_Analytics.ipynb
```
Update the `file_path` variable in the notebook to point to your local copy of the Excel data file.

### Tableau
Open `tableau/telecom_Analytics.twb` in Tableau Desktop (Public or Professional). Reconnect the data source to your local `Telecom_data_cleaned.xlsx` if prompted.

---

## 📁 Files in This Repository

| File | Type | Description |
|---|---|---|
| `Telecom_Analytics_Project_Data.xlsx` | Excel | Raw dataset with 4 sheets |
| `Telecom_data_cleaned.xlsx` | Excel | Cleaned data + pivot tables |
| `TelecomAnalytics.sql` | SQL | Full database schema + analysis queries |
| `Telecom_Analytics.ipynb` | Jupyter Notebook | EDA, risk scoring, visualizations |
| `telecom_Analytics.twb` | Tableau Workbook | 3 executive dashboards |
| `Telecom_Analytics_End_to_End_Project.pdf` | PDF | Project brief and requirements |

---

## 🧰 Skills Demonstrated

- Data Cleaning & Standardization (Excel)
- Relational Database Design with Primary/Foreign Keys (SQL)
- Window Functions: `LAG()`, `SUM() OVER()`, `PARTITION BY` (SQL)
- Feature Engineering with Lambda Functions (Python)
- Custom Scoring Functions with If-Else Logic (Python)
- Exploratory Data Analysis & Visualization (Python)
- Business Dashboard Design for Non-Technical Stakeholders (Tableau)
- End-to-End Project Thinking: from raw data to business recommendations
