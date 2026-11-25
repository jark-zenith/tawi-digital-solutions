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
      AND lower(coalesce(p.email, '')) = 'jarkpruden@gmail.com'
      AND p.role = 'admin'
  );
$function$;

CREATE OR REPLACE FUNCTION app_private.protect_primary_admin_role()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
BEGIN
  IF lower(coalesce(OLD.email, '')) = 'jarkpruden@gmail.com'
     AND NEW.role <> 'admin' THEN
    RAISE EXCEPTION 'The primary TAWI administrator role cannot be changed.';
  END IF;
  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION app_private.protect_primary_admin_role() FROM PUBLIC;
DROP TRIGGER IF EXISTS protect_primary_admin_role ON public.profiles;
CREATE TRIGGER protect_primary_admin_role
BEFORE UPDATE OF role ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION app_private.protect_primary_admin_role();
