-- Replace placeholders before running.
--
-- Example:
-- gcloud sql connect ${cloudsql_instance_name} \
--   --database=${app_database_name} \
--   --user=postgres \
--   --project=${project_id}
--
-- Then run:
-- \i database-grants.sql

\c ${app_database_name}

GRANT USAGE ON SCHEMA public TO "${app_database_iam_user}";
GRANT USAGE ON SCHEMA public TO "${worker_database_iam_user}";

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "${app_database_iam_user}";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "${worker_database_iam_user}";

GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO "${app_database_iam_user}";
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO "${worker_database_iam_user}";

GRANT CREATE ON SCHEMA public TO "${app_database_iam_user}";
GRANT CREATE ON SCHEMA public TO "${worker_database_iam_user}";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "${app_database_iam_user}", "${worker_database_iam_user}";

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO "${app_database_iam_user}", "${worker_database_iam_user}";

