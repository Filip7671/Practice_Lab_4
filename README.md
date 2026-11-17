# Week 8 Practice Lab: Data Preparation Pipeline

This repository contains the complete reproducible data preparation and integration pipeline for the retail sales reporting system, moving from raw messy sources to a clean analytical dataset in Google BigQuery.

## Repository Structure
- **`week8_pipeline.sql`** – End-to-end executable GoogleSQL script covering profiling, parsing, deduplication, validation, integration, and reconciliation.
- **`w8_sales_analytical.csv`** – Final export of the analysis-ready retail dataset (one row per valid, completed order line).
- **`quality_report.md`** – Summary of data quality findings, row counts, and rejection tracking before and after cleaning.
- **`data_dictionary.md`** – Definitions and data types for all fields in the analytical table.
- **`orchestration.md`** – Design specification for scheduling, dependency management, and incremental updates.

## Environment & Execution
- **Platform:** Google BigQuery (GoogleSQL dialect).
- **Execution:** Run the entire `week8_pipeline.sql` script in a single BigQuery query tab. All objects are handled using temporary tables to ensure a clean, reproducible, and self-contained execution.