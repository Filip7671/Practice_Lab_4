# Data Dictionary: `w8_sales_analytical`

| Column Name | Data Type | Description | Handling of Missing Values |
| :--- | :--- | :--- | :--- |
| `order_line_key` | STRING | Composite unique key (`order_id-line_no`) | None (Required) |
| `order_id` | STRING | Business order identifier | None (Required) |
| `line_no` | INT64 | Line number within the order | None (Required) |
| `customer_key` | STRING | Normalized customer identifier (Uppercase, trimmed) | Represented as NULL if blank |
| `order_date` | DATE | Calendar date of purchase | Quarantined if unparseable |
| `quantity` | INT64 | Number of units sold | Quarantined if non-positive |
| `unit_price` | NUMERIC | Unit price in standard currency | Quarantined if negative or malformed |
| `discount` | NUMERIC | Applied discount fraction (0 to 1) | Defaults to 0 if missing (per business rule) |
| `status` | STRING | Standardized transaction status (`Completed`, `Cancelled`, `Unknown`) | Mapped to `Unknown` if unrecognized |
| `revenue` | NUMERIC | Calculated line revenue (`quantity * unit_price * (1 - discount)`) | Computed for valid rows only |
| `region` | STRING | Customer geographic region | Defaults to `'Unassigned'` if customer is unmatched |
| `customer_matched` | BOOL | Flag indicating whether the customer key exists in the clean customer dimension (`TRUE`/`FALSE`) | Evaluated during LEFT JOIN |
| `source_row_id` | INT64 | Stable ingestion tracking identifier | None (Required) |
| `updated_at` | TIMESTAMP | Last modification timestamp from source system | None (Required) |