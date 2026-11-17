# Data Quality & Profiling Report

## 1. Pipeline Row Count Reconciliation (Denominators)
- **Raw Received Order Rows:** 12 rows (containing exact duplicates and update versions)[cite: 624]
- **Latest Business-Key Rows (`w8_orders_latest`):** 10 rows (resolved using `ROW_NUMBER()` ordered by `updated_at DESC, source_row_id DESC`)[cite: 624]
- **Valid Transaction Lines (`w8_valid_lines`):** 6 rows (after filtering out missing dates, non-positive quantities, negative prices, and invalid discounts)[cite: 624]
- **Completed Sales Lines (`w8_completed_lines`):** 5 rows (filtered by `status = 'Completed'`, excluding cancelled lines)[cite: 624]
- **Final Integrated Analytical Rows (`w8_sales_analytical`):** 5 rows[cite: 624]

## 2. Customer Integration & Match Coverage
- **Total Completed Lines:** 5[cite: 624]
- **Matched Customer Lines:** 4 lines (Regions: South = 2, North = 2)[cite: 624]
- **Unmatched Customer Lines:** 1 line (Customer ID `C99`, assigned region `'Unassigned'`, match flag = `FALSE`)[cite: 624]
- **Unmatched Revenue:** 80 (representing ~3.60% of total completed revenue)[cite: 624]

## 3. Regional Revenue Reconciliation
- **South:** 2,080 (2 lines)[cite: 624]
- **Unassigned:** 80 (1 line)[cite: 624]
- **North:** 60 (2 lines)[cite: 624]
- **Total Completed Revenue:** **2,220** (reconciled perfectly with the trusted line base)[cite: 624]