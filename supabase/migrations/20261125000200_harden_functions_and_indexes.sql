-- Revoke direct RPC access to trigger/maintenance functions.
-- The auth.users trigger continues to invoke handle_new_user automatically.
revoke all on function public.handle_new_user() from public, anon, authenticated;
revoke all on function public.rls_auto_enable() from public, anon, authenticated;

-- Cover foreign keys used by staff queries and record maintenance.
create index if not exists inquiries_assigned_to_idx on public.inquiries(assigned_to);
create index if not exists inquiries_service_id_idx on public.inquiries(service_id);
create index if not exists founder_profiles_reviewed_by_idx on public.founder_profiles(reviewed_by);