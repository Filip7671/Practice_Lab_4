# Orchestration & Workflow Specification

## 1. Schedule & Time Zone
- **Frequency:** Daily batch execution at **02:00 UTC**.
- **Logical Window:** Processes ingestion batches received during the preceding calendar day (half-open interval: `start_time >= 02:00 UTC` and `end_time < 02:00 UTC`).

## 2. Dependency Graph (DAG)
1. **Source Ingestion:** Wait for daily order manifests and customer dimension updates in Cloud Storage / Landing tables.
2. **Staging & Typing:** Parse raw text strings (`SAFE_CAST`) and normalize identifiers.
3. **Deduplication:** Apply `ROW_NUMBER()` partitioned by business keys to select authoritative latest versions.
4. **Validation & Quality Gate:** Filter out invalid records into a quarantine register; block publication if critical schema contracts fail.
5. **Integration & Publication:** Perform safe `LEFT JOIN` with customer dimensions, compute final metrics, and publish to `w8_sales_analytical`.

## 3. Error Handling & Retries
- **Transient Failures (e.g., service timeouts):** Configure a maximum of 2 automated retries with exponential backoff (1 minute, then 2 minutes).
- **Deterministic Failures (e.g., malformed source rows, missing required fields):** Do not retry automatically; route defective rows to a quarantine table and alert data engineering.
- **Idempotency:** Achieved via keyed staging applications and partition replacements, ensuring that retrying a successful run does not duplicate business records.