-- A custom read-only role for reporting, declared in migrations so it exists
-- both locally and in production. Roles are cluster-wide and survive a local
-- `db reset`, so only create it when it's missing.
do $$
begin
  if not exists (select from pg_roles where rolname = 'reporting') then
    create role reporting nologin;
  end if;
end
$$;

grant select on public.notes to reporting;
