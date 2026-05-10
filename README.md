# QuickPay Fintech Data Analysis

## Student Info
- **Student Name**: Greeshma
- **Assignment**: QuickPay Data Analyst Assessment (Masai)

## Repository Structure

```
├── 01_data/
│   └── processed/
│       ├── cleaned_transactions.csv       # Part 1 output
│       ├── merchant_risk_summary.csv      # Part 1 output
│       ├── missing_in_gateway.csv         # Part 3 output
│       ├── missing_in_ledger.csv          # Part 3 output
│       ├── amount_mismatches.csv          # Part 3 output
│       ├── status_mismatches.csv          # Part 3 output
│       ├── reconciliation_report.csv      # Part 3 output
│       ├── api_normalized.csv             # Part 4 output
│       ├── daily_summary.csv
│       ├── payment_method_breakdown.csv
│       ├── region_breakdown.csv
│       └── merchant_performance_summary.csv
├── 02_spreadsheet/
│   ├── spreadsheet_workbook.xlsx          # Part 1 working file
│   └── spreadsheet_answers.md
├── 03_sql/
│   ├── analysis_queries.sql               # Part 2 working file
│   └── sql_answers.md
├── 04_python/
│   ├── fintech_pipeline.ipynb             # Parts 3+4 working file
│   └── summary_metrics.json
└── README.md
```

## Tools Used
- Python 3, pandas, numpy, openpyxl, nbformat
- SQLite (for SQL query execution/validation)
- Excel / openpyxl (for spreadsheet workbook)

## How to Run

```bash
# Install dependencies
pip install pandas openpyxl nbformat

# Run full pipeline
python 04_python/pipeline.py

# Or open the notebook
jupyter notebook 04_python/fintech_pipeline.ipynb
```

## Key Findings

| Metric | Value |
|---|---|
| Total transactions | 30 |
| Captured GMV | $82,355.50 USD |
| Top merchant | Beta Stores ($33,431 captured) |
| High risk transactions | 8 |
| High value transactions | 7 |
| Reconciliation issues | 6 (2 missing in gateway, 1 missing in ledger, 2 amount mismatches, 1 status mismatch) |
| Amount at risk | $6,490.00 |
| Flagged user (fraud signal) | U008 — 4 failed/chargeback txns on 2026-03-05 |
