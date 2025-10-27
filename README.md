# Task Overview

InsightsNow is a multi-tenant analytics SaaS product where customers upload large datasets for interactive dashboards and live reporting. Recently, support tickets have spiked due to performance degradations: users report delays in saving new events or updating dashboards, especially during periods of heavy analytics workloads (e.g., monthly report runs). Support staff noticed that analytical queries frequently block OLTP traffic in production, causing business outages and slowdowns for critical endpoints.

You join as a PostgreSQL database engineer to resolve blocking and optimize for mixed OLTP/OLAP workloads. The system uses large `events`, `users`, `accounts`, `dashboards`, and `reports` tables. Your main focus is to identify lock contention, tune queries and system parameters, implement materialized views where effective, and redesign high-contention schema regions for scalability and performance—while maintaining full data integrity and business logic.

# Database Access
- **Host**: <DROPLET_IP>
- **Port**: 5432
- **Database**: insightsnowdb
- **Username**: insightsuser
- **Password**: insightspass

You may use any PostgreSQL client (psql, DBeaver, pgAdmin, DataGrip) for connection, schema analysis, and performance diagnostics. System is preloaded with realistic event data and typical reporting/analytic workloads.

# Guidance
- Analyze lock contention using `pg_locks`, `pg_stat_activity`, and blocking_pids patterns.
- Investigate schema for large tables (events, reports) and identify hot spots or missing indexes.
- Write and optimize SQL queries for real-time event API operations and heavy analytical/reporting tasks.
- Consider range/list partitioning for event tables where appropriate.
- Implement and test materialized views for heavy reporting jobs with proper refresh strategies.
- Set per-query timeouts (statement_timeout/lock_timeout) at the DB level for long analytics jobs.
- Tune key parameters (shared_buffers, work_mem, max_parallel_workers_per_gather, etc.) within configuration comments—assume access via managed config.
- Enable pg_stat_statements/auto_explain and review key slow query data.

# Objectives
- Identify blocking relationships and sources of contention between OLTP/OLAP workloads using system views.
- Add or tune appropriate indexes, foreign keys, and constraints on high-volume tables.
- Optimize analytical queries and introduce materialized views or partitioning where needed.
- Implement query-level timeouts to prevent OLAP tasks from blocking crucial OLTP endpoints.
- Ensure new structure maintains transactional and data integrity for concurrent workloads.

# How to Verify
- Run supplied slow query samples and OLTP event upserts before and after your changes, comparing execution times and lock behavior.
- Use `pg_locks` and `pg_stat_activity` to show that OLTP operations no longer get blocked by long-running reporting queries.
- Reporting outputs with improved speed, reduced block/wait times, and accurate analytics.
- Document key schema, index, or config changes made and summarize OLTP vs OLAP performance improvements.
