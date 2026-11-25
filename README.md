# Tawi Digital Solutions

React + Vite public website and private team workspace.

## Local setup
1. Use Node.js 22 or newer.
2. Copy `.env.example` to `.env.local`.
3. Set `VITE_SUPABASE_URL` and the project's **publishable** key.
4. Run `npm install`, then `npm run dev`. Build with `npm run build`.

## Supabase
Connected project: **Project Teravex** (`zvozkqdthvyrnesmbwjo`), URL `https://zvozkqdthvyrnesmbwjo.supabase.co`.

Schema migration: `supabase/migrations/20261125000100_initial_tawi_schema.sql`.

Tables: profiles, services, inquiries, founder_profiles, public_founders. RLS is enabled on every public table. Visitors can read published services/public founder cards and submit enquiries. Only approved founder/admin accounts can read enquiries and manage internal records. Founder submissions are private until reviewed and separately published.

## First admin account
1. Create and verify the administrator's email/password account in Supabase Auth.
2. Sign in once to create its profile row.
3. In Supabase SQL editor run (replace the email):
```sql
update public.profiles set role='admin' where email='YOUR_VERIFIED_ADMIN_EMAIL';
```
4. Sign out and back in, then visit `/admin`.

Never use user-editable auth metadata for roles.

## Security
Only the project URL and publishable key belong in browser variables. Never expose a Supabase service_role or secret key in source code, GitHub, or any `VITE_*` variable. Private customer details, enquiry notes and founder contact details are protected by RLS.

## Deployment
Static-site build command: `npm install && npm run build`; publish directory: `dist`. Set the two Supabase environment variables in the hosting dashboard and add an SPA rewrite to `/index.html`.

## Remaining work
Founder invitation and profile-review UI, service editing controls, deployment configuration, and end-to-end/browser tests remain follow-up tasks.