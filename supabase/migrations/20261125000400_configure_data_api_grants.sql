-- The staff predicate returns false for anonymous users (auth.uid() is null).
-- It is in a non-exposed schema and does not disclose profile data.
grant usage on schema app_private to anon;
grant execute on function app_private.is_staff() to anon;

-- Service-role credentials remain backend-only; this grants DB privileges,
-- not access to the key from the browser.
grant all privileges on all tables in schema public to service_role;
grant usage, select on all sequences in schema public to service_role;
alter default privileges in schema public grant all on tables to service_role;
alter default privileges in schema public grant usage, select on sequences to service_role;