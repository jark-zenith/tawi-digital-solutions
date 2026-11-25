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

Team registration: https://tawi-digital-solutions.onrender.com/admin/signup

- **Overall administrator:** `jarkpruden@gmail.com`. This exact email is assigned the `admin` role by the database signup trigger. Register with this email and create your own private password; after confirming your email, sign in at `/admin/login` and open `/admin`.
- **All other registrations:** Supabase Auth stores each person's own email/password account, and `public.handle_new_user()` creates a `public.profiles` row with role `member`. A member has no workspace access while awaiting approval.
- **Approval:** The overall administrator opens the **Team** tab in `/admin`, reviews each registration, and selects **Approve founder** or **Grant admin**. The same screen can revoke privileged access. The overall administrator's own account is protected from self-demotion in the UI.
- **Role security:** Role updates are enforced by RLS; only an account whose database role is `admin` can grant or revoke `founder`/`admin` roles. A founder can use the workspace but cannot approve other users. Signup metadata cannot grant privileged access.
- **Passwords:** Each person creates and manages their own password through Supabase Auth. TAWI administrators must never collect or share passwords. Email confirmation is enabled, so users must confirm their email before signing in.

### Supabase Auth URL configuration

The connected Supabase project is configured with:

- **Site URL:** `https://tawi-digital-solutions.onrender.com`
- **Redirect allowlist:** `https://tawi-digital-solutions.onrender.com/admin/login` and `http://localhost:5173/admin/login` for local development
- **Email/password sign-up:** enabled
- **Email confirmation:** enabled (users must confirm their address)

The signup page sends the current origin's `/admin/login` URL as its confirmation redirect.

### Database migration

`supabase/migrations/20261125140000_bootstrap_admin_and_admin_only_role_changes.sql` records the production migration that bootstraps the exact overall administrator email and restricts profile role changes to admins. It is applied to the connected Project Teravex Supabase database.

## Data model and access control

Database migrations are in `supabase/migrations/`. Core tables:

- `profiles`: account identity and staff role
- `services`: service catalogue and website publication state
- `inquiries`: customer enquiries
- `founder_profiles`: private founder-submitted profiles and review status
- `public_founders`: separately published public founder cards

RLS is enabled on all exposed public tables. Anonymous visitors can read published services/public founder cards and submit enquiries, but cannot read private enquiries. Every authenticated user can read only their own profile; the overall admin can read the team roster for approvals. Only approved founder/admin roles can access internal records. The private staff/admin helper functions live in the non-exposed `app_private` schema.

## Current workspace functionality

- Public home, services, team and request-details pages
- Supabase-backed customer enquiry submission
- Email/password team registration and sign-in
- Administrator-only team approvals with founder/admin promotion and access revocation
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
- Keep every non-owner registration at the default `member` role until the overall administrator approves it.
- The only automatic admin bootstrap is the exact address `jarkpruden@gmail.com`; do not broaden this rule to a domain or user-editable metadata.
- Use unique passwords and email confirmation; never collect passwords in chat, email, or founder spreadsheets.
- Review Supabase RLS policies before adding new tables or data access.
