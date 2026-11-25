# Tawi Digital Solutions

Public website and private founders/admin workspace for TAWI Digital Solutions.

## Live website

- **Production website:** https://tawi-digital-solutions.onrender.com
- **Team sign-in:** https://tawi-digital-solutions.onrender.com/admin/login
- **Team account registration:** https://tawi-digital-solutions.onrender.com/admin/signup
- **Admin workspace:** https://tawi-digital-solutions.onrender.com/admin
- **GitHub repository:** https://github.com/jark-zenith/tawi-digital-solutions

The site is hosted as a Render Static Site and deploys from the `main` branch after the configured build checks pass.

## Local development

Requirements: Node.js 22 or newer.

```bash
npm install
npm run dev
npm run build
npm run preview
```

## Supabase connection

The website is connected to the separate **Project Teravex** Supabase project:

- Project ref: `zvozkqdthvyrnesmbwjo`
- Project URL: `https://zvozkqdthvyrnesmbwjo.supabase.co`
- Browser key: Supabase publishable key (safe for a browser client when RLS is enabled)

The client reads optional overrides from `.env.local`:

```env
VITE_SUPABASE_URL=https://zvozkqdthvyrnesmbwjo.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=your_supabase_publishable_key
```

The project publishable key is intentionally used in the browser. **Never put a Supabase service-role key or secret key in frontend code, GitHub, or any `VITE_*` variable.** Database access is controlled by Row Level Security (RLS).

## Founder and admin accounts

Team account registration is available at:

https://tawi-digital-solutions.onrender.com/admin/signup

1. A founder/admin opens the registration URL and enters their name, email and password.
2. Supabase Auth creates the account. The password is managed by Supabase Auth; it is not saved in the public website tables.
3. The database trigger `public.handle_new_user()` creates the associated `public.profiles` row with the safe default role `member`.
4. If email confirmation is enabled in Supabase Auth, the user must confirm their email before signing in.
5. A current administrator approves the account by assigning the appropriate `founder` or `admin` role in the Supabase SQL Editor.
6. The new team member returns to `/admin/login` and signs in with the same email and password. Their access is checked against the database profile role on every workspace entry.

**Important:** Registration does not automatically grant workspace privileges. This prevents anyone who finds the public registration URL from becoming an administrator or accessing private customer/founder records.

### Supabase Auth URL configuration

In Supabase Dashboard → Authentication → URL Configuration, set:

- **Site URL:** `https://tawi-digital-solutions.onrender.com`
- **Redirect URL allowlist:** add `https://tawi-digital-solutions.onrender.com/admin/login`
- For local testing, optionally add `http://localhost:5173/admin/login`

Enable email/password sign-in. If email confirmation is enabled, configure the Supabase confirmation email template and SMTP delivery so founders receive the verification link. The website sends the production `/admin/login` URL as the signup redirect.

### Bootstrap the first administrator

The initial administrator must register at the signup page and confirm their email first. Then run this SQL in the Project Teravex SQL Editor, using the exact verified email:

```sql
update public.profiles
set role = 'admin', updated_at = now()
where lower(email) = lower('jarkpruden@gmail.com');
```

Verify that exactly one profile was updated. If the account does not yet exist, the person must complete registration and email confirmation first. Do not share passwords or ask users to send them to an administrator.

### Approve additional founders or administrators

After each person registers and confirms their email, approve only their exact email address:

```sql
-- Founder access
update public.profiles
set role = 'founder', updated_at = now()
where lower(email) = lower('founder@example.com');

-- Administrator access (only for a trusted administrator)
update public.profiles
set role = 'admin', updated_at = now()
where lower(email) = lower('admin@example.com');
```

Check the affected row count and profile email before granting access. A founder/admin should sign out and sign in again after their role is changed.

## Data model and access control

Database migrations are in `supabase/migrations/`. Core tables:

- `profiles`: account identity and staff role
- `services`: service catalogue and website publication state
- `inquiries`: customer enquiries
- `founder_profiles`: private founder-submitted profiles and review status
- `public_founders`: separately published public founder cards

RLS is enabled on all exposed public tables. Anonymous visitors can read published services/public founder cards and submit enquiries, but cannot read private enquiries. Authenticated members can read their own profile; only approved founder/admin roles can access internal records. The private staff-check helper lives in the non-exposed `app_private` schema.

## Current workspace functionality

- Public home, services, team and request-details pages
- Supabase-backed customer enquiry submission
- Email/password team registration and sign-in
- Protected workspace with overview, live enquiry counts, enquiry status updates and CSV export
- Services catalogue and founder-profile overview
- Responsive blue/silver glass workspace with dark/light theme
- Supabase session persistence and sign-out

The workspace currently reads live enquiries/services and provides enquiry status updates. Some founder profile editing/review and service-management actions remain future enhancements; the overview must not be interpreted as financial/revenue analytics.

## Deployment

Render Static Site settings:

- Repository: `jark-zenith/tawi-digital-solutions`
- Branch: `main`
- Build command: `npm install && npm run build`
- Publish directory: `dist`
- SPA rewrite: `/*` → `/index.html`

Render automatically deploys successful changes merged to `main`. Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` in Render only if you want to override the safe defaults in `src/lib/supabase.js`.

## Security notes

- Never expose service-role/secret keys in the browser.
- Never promote a user based on editable signup metadata.
- Keep new accounts at the default `member` role until approved.
- Use unique passwords and email confirmation; never collect passwords in chat, email, or founder spreadsheets.
- Review Supabase RLS policies before adding new tables or data access.
