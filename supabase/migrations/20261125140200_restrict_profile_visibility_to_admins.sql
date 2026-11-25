DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
CREATE POLICY "Users read own profile and admins read team"
ON public.profiles
FOR SELECT
TO authenticated
USING (
  (SELECT auth.uid()) = id
  OR (SELECT app_private.is_admin())
);
