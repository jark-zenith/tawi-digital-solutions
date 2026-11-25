-- Founder onboarding: private application data, primary-admin review and deliberate public publishing.
ALTER TABLE public.founder_profiles
  ADD COLUMN IF NOT EXISTS legal_name text,
  ADD COLUMN IF NOT EXISTS county text,
  ADD COLUMN IF NOT EXISTS education text,
  ADD COLUMN IF NOT EXISTS experience text,
  ADD COLUMN IF NOT EXISTS tools text,
  ADD COLUMN IF NOT EXISTS availability text,
  ADD COLUMN IF NOT EXISTS preferred_responsibilities text,
  ADD COLUMN IF NOT EXISTS contribution_expectations text,
  ADD COLUMN IF NOT EXISTS business_ideas text,
  ADD COLUMN IF NOT EXISTS three_year_vision text,
  ADD COLUMN IF NOT EXISTS portfolio_url text,
  ADD COLUMN IF NOT EXISTS linkedin_url text,
  ADD COLUMN IF NOT EXISTS github_url text,
  ADD COLUMN IF NOT EXISTS profile_photo_url text,
  ADD COLUMN IF NOT EXISTS show_photo boolean NOT NULL DEFAULT false;

ALTER TABLE public.public_founders
  ADD COLUMN IF NOT EXISTS source_user_id uuid UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS profile_photo_url text,
  ADD COLUMN IF NOT EXISTS show_photo boolean NOT NULL DEFAULT false;

-- Remove the earlier broad staff policy: it allowed any founder/admin to alter account roles.
DROP POLICY IF EXISTS "Staff manage profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users update own basic profile" ON public.profiles;
DROP POLICY IF EXISTS "Users update own profile and admins manage roles" ON public.profiles;
DROP POLICY IF EXISTS "Users and staff update profiles" ON public.profiles;
CREATE POLICY "Users update own profile without role escalation"
  ON public.profiles FOR UPDATE TO authenticated
  USING (id = (SELECT auth.uid()))
  WITH CHECK (id = (SELECT auth.uid()) AND role = 'member');
CREATE POLICY "Primary admin manages team profiles"
  ON public.profiles FOR UPDATE TO authenticated
  USING ((SELECT app_private.is_admin()))
  WITH CHECK ((SELECT app_private.is_admin()));

-- A registered member may read and edit only their own unapproved application.
-- Only the primary administrator can inspect other people's applications or review them.
DROP POLICY IF EXISTS "Founders read own profile" ON public.founder_profiles;
DROP POLICY IF EXISTS "Founders submit own profile" ON public.founder_profiles;
DROP POLICY IF EXISTS "Founders edit pending profile" ON public.founder_profiles;
DROP POLICY IF EXISTS "Staff manage founder profiles" ON public.founder_profiles;
DROP POLICY IF EXISTS "Founders and staff read profiles" ON public.founder_profiles;
DROP POLICY IF EXISTS "Founders and staff create profiles" ON public.founder_profiles;
DROP POLICY IF EXISTS "Founders and staff update profiles" ON public.founder_profiles;
DROP POLICY IF EXISTS "Staff delete founder profiles" ON public.founder_profiles;
CREATE POLICY "Applicants read own founder application"
  ON public.founder_profiles FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()) OR (SELECT app_private.is_admin()));
CREATE POLICY "Applicants create own founder application"
  ON public.founder_profiles FOR INSERT TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()) AND profile_status = 'pending');
CREATE POLICY "Applicants edit own unapproved application"
  ON public.founder_profiles FOR UPDATE TO authenticated
  USING (user_id = (SELECT auth.uid()) AND profile_status IN ('pending','rejected'))
  WITH CHECK (user_id = (SELECT auth.uid()) AND profile_status = 'pending');
CREATE POLICY "Primary admin reviews founder applications"
  ON public.founder_profiles FOR ALL TO authenticated
  USING ((SELECT app_private.is_admin()))
  WITH CHECK ((SELECT app_private.is_admin()));

-- Public founder cards are readable publicly, but only the primary admin can change them.
DROP POLICY IF EXISTS "Public read approved cards" ON public.public_founders;
DROP POLICY IF EXISTS "Staff manage public cards" ON public.public_founders;
DROP POLICY IF EXISTS "Staff insert public founder cards" ON public.public_founders;
DROP POLICY IF EXISTS "Staff update public founder cards" ON public.public_founders;
DROP POLICY IF EXISTS "Staff delete public founder cards" ON public.public_founders;
CREATE POLICY "Public read approved founder cards"
  ON public.public_founders FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Primary admin publishes founder cards"
  ON public.public_founders FOR ALL TO authenticated
  USING ((SELECT app_private.is_admin()))
  WITH CHECK ((SELECT app_private.is_admin()));

-- Atomic approval: workspace role is granted only after a complete application is reviewed.
CREATE OR REPLACE FUNCTION public.review_founder_application(
  p_application_id uuid,
  p_decision text,
  p_workspace_role text DEFAULT 'founder',
  p_show_name boolean DEFAULT true,
  p_show_title boolean DEFAULT true,
  p_show_bio boolean DEFAULT true,
  p_show_skills boolean DEFAULT true,
  p_show_photo boolean DEFAULT false
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
  application public.founder_profiles%ROWTYPE;
  public_name text;
BEGIN
  IF NOT (SELECT app_private.is_admin()) THEN
    RAISE EXCEPTION 'Only the primary TAWI administrator can review founder applications.';
  END IF;
  IF p_decision NOT IN ('approved','rejected') THEN
    RAISE EXCEPTION 'Decision must be approved or rejected.';
  END IF;
  IF p_decision = 'approved' AND p_workspace_role NOT IN ('founder','admin') THEN
    RAISE EXCEPTION 'Approved workspace role must be founder or admin.';
  END IF;

  SELECT * INTO application
  FROM public.founder_profiles
  WHERE id = p_application_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Founder application not found.'; END IF;

  IF p_decision = 'approved' THEN
    IF coalesce(trim(application.legal_name),'') = ''
       OR coalesce(trim(application.display_name),'') = ''
       OR coalesce(trim(application.title),'') = ''
       OR coalesce(trim(application.bio),'') = ''
       OR coalesce(trim(application.phone),'') = ''
       OR coalesce(trim(application.location),'') = ''
       OR coalesce(trim(application.county),'') = ''
       OR coalesce(trim(application.preferred_responsibilities),'') = ''
       OR coalesce(trim(application.contribution_expectations),'') = '' THEN
      RAISE EXCEPTION 'This application is incomplete and cannot be approved.';
    END IF;

    UPDATE public.founder_profiles
      SET profile_status = 'approved', show_name = p_show_name, show_title = p_show_title,
          show_bio = p_show_bio, show_skills = p_show_skills, show_photo = p_show_photo, reviewed_by = (SELECT auth.uid()), reviewed_at = now(), updated_at = now()
      WHERE id = p_application_id;
    UPDATE public.profiles SET role = p_workspace_role, updated_at = now()
      WHERE id = application.user_id;

    public_name := CASE WHEN p_show_name THEN application.display_name ELSE NULL END;
    IF p_show_name THEN
      INSERT INTO public.public_founders(source_user_id,display_name,title,bio,skills,profile_photo_url,sort_order)
      VALUES (
        application.user_id,
        coalesce(public_name, application.display_name),
        CASE WHEN p_show_title THEN application.title ELSE NULL END,
        CASE WHEN p_show_bio THEN application.bio ELSE NULL END,
        CASE WHEN p_show_skills THEN application.skills ELSE '{}'::text[] END,
        CASE WHEN p_show_photo THEN application.profile_photo_url ELSE NULL END,
        coalesce((SELECT max(sort_order)+1 FROM public.public_founders),1)
      )
      ON CONFLICT (source_user_id) DO UPDATE SET
        display_name = EXCLUDED.display_name,
        title = EXCLUDED.title,
        bio = EXCLUDED.bio,
        skills = EXCLUDED.skills,
        profile_photo_url = EXCLUDED.profile_photo_url;
    ELSE
      DELETE FROM public.public_founders WHERE source_user_id = application.user_id;
    END IF;
  ELSE
    UPDATE public.founder_profiles
      SET profile_status = 'rejected', reviewed_by = (SELECT auth.uid()), reviewed_at = now(), updated_at = now()
      WHERE id = p_application_id;
    UPDATE public.profiles SET role = 'member', updated_at = now()
      WHERE id = application.user_id AND lower(coalesce(email,'')) <> 'jarkpruden@gmail.com';
    DELETE FROM public.public_founders WHERE source_user_id = application.user_id;
  END IF;
END;
$function$;
REVOKE ALL ON FUNCTION public.review_founder_application(uuid,text,text,boolean,boolean,boolean,boolean,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.review_founder_application(uuid,text,text,boolean,boolean,boolean,boolean,boolean) TO authenticated;
