-- Example 1: Analytics dashboard - top event types in a time window (OLAP, slow, may block upserts)
EXPLAIN ANALYZE
SELECT event_type, COUNT(*) as cnt, SUM(value) as total_value
FROM events
WHERE created_at > NOW() - interval '7 days'
GROUP BY event_type
ORDER BY cnt DESC;

-- Example 2: Event upsert (OLTP, can be blocked by long analytic query)
EXPLAIN ANALYZE
INSERT INTO events (user_id, account_id, event_type, properties, created_at, dashboard_id, value)
VALUES (123, 77, 'click', '{"feature": "overview"}', NOW(), 432, 789.23);

-- Example 3: Reporting - get total metrics by dashboard for last month (slow aggregation)
EXPLAIN ANALYZE
SELECT d.id AS dashboard_id, d.title, COUNT(e.id) as total_events, SUM(e.value) as event_value
FROM dashboards d
LEFT JOIN events e ON d.id = e.dashboard_id
WHERE e.created_at > date_trunc('month', NOW()) - interval '1 month'
GROUP BY d.id, d.title
ORDER BY total_events DESC LIMIT 20;

-- Example 4: OLTP Blocking Diagnostic
SELECT now(), pid, state, query,
       wait_event_type, wait_event, backend_type
FROM pg_stat_activity
WHERE state NOT IN ('idle')
ORDER BY now() DESC;

-- Example 5: Lock Inspection
SELECT locktype, mode, granted, pid, relation, page, tuple, virtualxid, transactionid
FROM pg_locks
WHERE NOT granted;
