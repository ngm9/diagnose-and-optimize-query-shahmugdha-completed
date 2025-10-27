-- INSIGHTS NOW: Analytics / OLTP Blocking Production Schema (intentionally problematic)

-- USERS
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
  id serial PRIMARY KEY,
  email varchar(200) UNIQUE NOT NULL,
  full_name varchar(120),
  account_id int,
  created_at timestamp
);

-- ACCOUNTS
DROP TABLE IF EXISTS accounts CASCADE;
CREATE TABLE accounts (
  id serial PRIMARY KEY,
  name varchar(100),
  plan varchar(40),
  joined_at timestamp
);

-- EVENTS (very large, inefficiently indexed, no partitioning)
DROP TABLE IF EXISTS events CASCADE;
CREATE TABLE events (
  id bigserial PRIMARY KEY,
  user_id int,
  account_id int,
  event_type varchar(64),
  properties jsonb,
  created_at timestamp,
  dashboard_id int,
  value numeric
);

-- DASHBOARDS
DROP TABLE IF EXISTS dashboards CASCADE;
CREATE TABLE dashboards (
  id serial PRIMARY KEY,
  account_id int,
  title varchar(120),
  created_at timestamp
);

-- REPORTS (analytic summary & locking hot spot; no proper indexes, slow aggregations)
DROP TABLE IF EXISTS reports CASCADE;
CREATE TABLE reports (
  id serial PRIMARY KEY,
  dashboard_id int,
  report_date date,
  metrics jsonb,
  generated_at timestamp
);

-- Insert sample data
-- ACCOUNTS
INSERT INTO accounts (name, plan, joined_at)
SELECT 'Account ' || g, 
       CASE WHEN g % 3=0 THEN 'premium' WHEN g%2=0 THEN 'standard' ELSE 'basic' END,
       NOW() - (random()*730)::int * INTERVAL '1 day'
FROM generate_series(1,1200) g;
-- USERS
INSERT INTO users (email, full_name, account_id, created_at)
SELECT 'user' || g || '@mail.com', 'User ' || g, (random()*1199)::int+1, NOW() - (random()*800)::int * INTERVAL '1 day'
FROM generate_series(1,12000) g;
-- DASHBOARDS
INSERT INTO dashboards (account_id, title, created_at)
SELECT (random()*1199)::int+1, 'Dashboard '||g, NOW() - (random()*700)::int * INTERVAL '1 day'
FROM generate_series(1,1500) g;
-- EVENTS (very large table, intentional for lock/contention workload)
INSERT INTO events (user_id, account_id, event_type, properties, created_at, dashboard_id, value)
SELECT (random()*11999)::int+1, (random()*1199)::int+1, 
       CASE WHEN g % 4=0 THEN 'click' WHEN g%4=1 THEN 'view' WHEN g%4=2 THEN 'purchase' ELSE 'expand' END,
       jsonb_build_object('feature', CASE WHEN random()<0.5 THEN 'drilldown' ELSE 'overview' END),
       NOW() - (random()*365)::int * INTERVAL '1 day',
       (random()*1499)::int+1, (random()*1000)::numeric
FROM generate_series(1,850000) g;
-- REPORTS (no summary tables or mat views)
INSERT INTO reports (dashboard_id, report_date, metrics, generated_at)
SELECT (random()*1499)::int+1, NOW()-((g%60)*interval '1 day'),
       jsonb_build_object('views', (random()*5000)::int, 'clicks', (random()*2000)::int),
       NOW() - (random()*20)*INTERVAL '1 hour'
FROM generate_series(1,25000) g;
-- Note: No partitioning, few indexes, intentionally poor performance for large joins & analytics.

