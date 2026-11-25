create extension if not exists pgcrypto;
create schema if not exists app_private;
revoke all on schema app_private from public, anon, authenticated;

create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 email text, display_name text,
 role text not null default 'member' check (role in ('member','founder','admin')),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.services (
 id uuid primary key default gen_random_uuid(), name text not null, slug text not null unique,
 summary text not null, description text,
 status text not null default 'idea' check (status in ('idea','demo','pilot','live','paused')),
 show_on_website boolean not null default false, sort_order integer not null default 0,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.inquiries (
 id uuid primary key default gen_random_uuid(), customer_name text,
 whatsapp text not null, email text, service_id uuid references public.services(id) on delete set null,
 service_name text not null, message text,
 status text not null default 'new' check (status in ('new','contacted','in_progress','closed')),
 assigned_to uuid references public.profiles(id) on delete set null, internal_notes text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.founder_profiles (
 id uuid primary key default gen_random_uuid(), user_id uuid not null unique references auth.users(id) on delete cascade,
 display_name text not null, title text, bio text, skills text[] not null default '{}',
 phone text, location text,
 profile_status text not null default 'pending' check (profile_status in ('pending','approved','rejected')),
 show_name boolean not null default false, show_title boolean not null default false,
 show_bio boolean not null default false, show_skills boolean not null default false,
 reviewed_by uuid references public.profiles(id) on delete set null, reviewed_at timestamptz,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.public_founders (
 id uuid primary key default gen_random_uuid(), display_name text not null,
 title text, bio text, skills text[] not null default '{}',
 sort_order integer not null default 0, created_at timestamptz not null default now()
);
create index if not exists inquiries_created_at_idx on public.inquiries(created_at desc);
create index if not exists inquiries_status_idx on public.inquiries(status);
create index if not exists services_public_idx on public.services(show_on_website,status,sort_order);

create or replace function app_private.is_staff()
returns boolean language sql stable security definer set search_path = ''
as $$ select exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.role in ('founder','admin')); $$;
revoke all on function app_private.is_staff() from public, anon;
grant usage on schema app_private to authenticated;
grant execute on function app_private.is_staff() to authenticated;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
 insert into public.profiles(id,email,display_name)
 values(new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name',split_part(coalesce(new.email,''),'@',1)))
 on conflict(id) do nothing;
 return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.services enable row level security;
alter table public.inquiries enable row level security;
alter table public.founder_profiles enable row level security;
alter table public.public_founders enable row level security;

create policy "Users read own profile or staff reads all" on public.profiles for select to authenticated using ((select auth.uid())=id or (select app_private.is_staff()));
create policy "Users update own basic profile" on public.profiles for update to authenticated using ((select auth.uid())=id) with check ((select auth.uid())=id and role='member');
create policy "Staff manage profiles" on public.profiles for all to authenticated using ((select app_private.is_staff())) with check ((select app_private.is_staff()));
create policy "Public read published services" on public.services for select to anon,authenticated using(show_on_website and status in ('demo','pilot','live'));
create policy "Staff manage services" on public.services for all to authenticated using((select app_private.is_staff())) with check((select app_private.is_staff()));
create policy "Public submit enquiry" on public.inquiries for insert to anon,authenticated with check(
 length(trim(whatsapp)) between 7 and 30 and length(trim(service_name)) between 2 and 120
 and (customer_name is null or length(customer_name)<=120) and (email is null or length(email)<=254)
 and (message is null or length(message)<=3000) and status='new' and assigned_to is null and internal_notes is null
);
create policy "Staff read enquiries" on public.inquiries for select to authenticated using((select app_private.is_staff()));
create policy "Staff update enquiries" on public.inquiries for update to authenticated using((select app_private.is_staff())) with check((select app_private.is_staff()));
create policy "Staff delete enquiries" on public.inquiries for delete to authenticated using((select app_private.is_staff()));
create policy "Founders read own profile" on public.founder_profiles for select to authenticated using(user_id=(select auth.uid()) or (select app_private.is_staff()));
create policy "Founders submit own profile" on public.founder_profiles for insert to authenticated with check(user_id=(select auth.uid()) and profile_status='pending');
create policy "Founders edit pending profile" on public.founder_profiles for update to authenticated using(user_id=(select auth.uid()) and profile_status='pending') with check(user_id=(select auth.uid()) and profile_status='pending');
create policy "Staff manage founder profiles" on public.founder_profiles for all to authenticated using((select app_private.is_staff())) with check((select app_private.is_staff()));
create policy "Public read approved cards" on public.public_founders for select to anon,authenticated using(true);
create policy "Staff manage public cards" on public.public_founders for all to authenticated using((select app_private.is_staff())) with check((select app_private.is_staff()));

grant select on public.services,public.public_founders to anon,authenticated;
grant insert on public.inquiries to anon,authenticated;
grant select,update on public.profiles to authenticated;
grant select,insert,update on public.founder_profiles to authenticated;
grant select,insert,update,delete on public.services,public.inquiries,public.public_founders to authenticated;

insert into public.services(name,slug,summary,description,status,show_on_website,sort_order) values
('QR digital menus','qr-digital-menus','Mobile-friendly menus customers can open by scanning a QR code.','A simple digital menu experience for restaurants and hospitality businesses.','demo',true,1),
('Website development','website-development','Professional websites and landing pages for businesses and individuals.','Responsive websites designed around clear business goals.','demo',true,2),
('AI-assisted business solutions','ai-assisted-solutions','Practical ways to use AI tools to improve selected workflows.','We help businesses explore and implement useful AI-assisted workflows.','idea',false,3),
('Digital business cards','digital-business-cards','Shareable digital profiles for professional and business details.','QR-enabled digital profiles that make it easier to share contact information.','idea',false,4),
('Promotional video and digital content','digital-content','Promotional videos and social content for businesses.','Short-form promotional content and digital assets.','idea',false,5)
on conflict(slug) do nothing;