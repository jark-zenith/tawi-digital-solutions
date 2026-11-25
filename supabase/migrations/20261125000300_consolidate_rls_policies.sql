-- Consolidate public/staff read policies and isolate staff-only writes.
drop policy if exists "Staff can manage profiles" on public.profiles;
drop policy if exists "Users can update own basic profile" on public.profiles;
create policy "Users and staff update profiles" on public.profiles for update to authenticated
using ((select auth.uid())=id or (select app_private.is_staff()))
with check (((select auth.uid())=id and role='member') or (select app_private.is_staff()));

drop policy if exists "Staff can manage services" on public.services;
drop policy if exists "Public can view published services" on public.services;
create policy "Public and staff read services" on public.services for select to anon,authenticated
using ((show_on_website and status in ('demo','pilot','live')) or (select app_private.is_staff()));
create policy "Staff insert services" on public.services for insert to authenticated with check ((select app_private.is_staff()));
create policy "Staff update services" on public.services for update to authenticated using ((select app_private.is_staff())) with check ((select app_private.is_staff()));
create policy "Staff delete services" on public.services for delete to authenticated using ((select app_private.is_staff()));

drop policy if exists "Staff can manage founder profiles" on public.founder_profiles;
drop policy if exists "Founders can read own founder profile" on public.founder_profiles;
drop policy if exists "Founders can create own founder profile" on public.founder_profiles;
drop policy if exists "Founders can update own pending profile" on public.founder_profiles;
create policy "Founders and staff read profiles" on public.founder_profiles for select to authenticated using(user_id=(select auth.uid()) or (select app_private.is_staff()));
create policy "Founders and staff create profiles" on public.founder_profiles for insert to authenticated with check((user_id=(select auth.uid()) and profile_status='pending') or (select app_private.is_staff()));
create policy "Founders and staff update profiles" on public.founder_profiles for update to authenticated using((user_id=(select auth.uid()) and profile_status='pending') or (select app_private.is_staff())) with check((user_id=(select auth.uid()) and profile_status='pending') or (select app_private.is_staff()));
create policy "Staff delete founder profiles" on public.founder_profiles for delete to authenticated using((select app_private.is_staff()));

drop policy if exists "Staff can manage public founder cards" on public.public_founders;
create policy "Staff insert public founder cards" on public.public_founders for insert to authenticated with check((select app_private.is_staff()));
create policy "Staff update public founder cards" on public.public_founders for update to authenticated using((select app_private.is_staff())) with check((select app_private.is_staff()));
create policy "Staff delete public founder cards" on public.public_founders for delete to authenticated using((select app_private.is_staff()));