CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, role)
  VALUES (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', split_part(coalesce(new.email, ''), '@', 1)),
    CASE
      WHEN lower(coalesce(new.email, '')) = 'jarkpruden@gmail.com' THEN 'admin'
      ELSE 'member'
    END
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$function$;

CREATE OR REPLACE FUNCTION app_private.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.id = (SELECT auth.uid())
      AND p.role = 'admin'
  );
$function$;

REVOKE ALL ON FUNCTION app_private.is_admin() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app_private.is_admin() TO authenticated;

DROP POLICY IF EXISTS "Users and staff update profiles" ON public.profiles;
CREATE POLICY "Users update own profile and admins manage roles"
ON public.profiles
FOR UPDATE
TO authenticated
USING (
  (SELECT auth.uid()) = id
  OR (SELECT app_private.is_admin())
)
WITH CHECK (
  ((SELECT auth.uid()) = id AND role = 'member')
  OR (SELECT app_private.is_admin())
);
