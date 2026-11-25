alter table public.inquiries
  add column if not exists customer_type text not null default 'individual',
  add column if not exists budget_range text;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'inquiries_customer_type_check') then
    alter table public.inquiries
      add constraint inquiries_customer_type_check
      check (customer_type in ('individual', 'business'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'inquiries_budget_range_length_check') then
    alter table public.inquiries
      add constraint inquiries_budget_range_length_check
      check (budget_range is null or length(trim(budget_range)) <= 80);
  end if;
end $$;

comment on column public.inquiries.customer_type is 'Whether the enquiry is from an individual or a business.';
comment on column public.inquiries.budget_range is 'Optional budget guidance supplied by the customer.';
