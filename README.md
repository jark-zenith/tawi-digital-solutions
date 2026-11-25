# Tawi Digital Solutions

React + Vite public website and private team workspace.

## Local setup
1. Use Node.js 22 or newer.
2. Run `npm install`, then `npm run dev`. Build with `npm run build`.
3. The browser client is already wired to the separate **Project Teravex** Supabase project using its public publishable key. Optional `.env.local` overrides can be copied from `.env.example`.

## Supabase
Project: **Project Teravex** (`zvozkqdthvyrnesmbwjo`), URL `https://zvozkqdthvyrnesmbwjo.supabase.co`.

The public publishable key is designed for browser use. It is not a secret; row-level security is the actual data-access boundary. Never substitute a Supabase `service_role` key or secret key in browser code or any `VITE_*` variable.

Schema migrations are in `supabase/migrations/`. Tables: `profiles`, `services`, `inquiries`, `founder_profiles`, and `public_founders`. RLS is enabled on every public table. Visitors can read published services/public founder cards and submit enquiries. Only approved founder/admin accounts can read enquiries and manage internal records. Founder submissions are private until reviewed and separately published.

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
Customer contact details, enquiry notes and founder contact details are protected by RLS. A helper function in the non-exposed `app_private` schema checks staff roles. Anonymous users can submit enquiries but cannot read them. The service-role key is not used by the website.

## Deployment
Deploy as a Vite static site (Render Static Site or equivalent):
- Build command: `npm install && npm run build`
- Publish directory: `dist`
- SPA rewrite: `/*` to `/index.html`
- Environment variables are optional; set `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` only if overriding the defaults.

## Current scope
Implemented: public home/services/team/request pages, enquiry submission, email/password team sign-in, staff-only dashboard, database schema and RLS.

Follow-up: founder invitation and profile-review UI, service editing controls, hosting deployment, and end-to-end/browser tests.