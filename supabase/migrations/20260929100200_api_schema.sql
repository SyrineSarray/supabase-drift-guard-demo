-- A separate API schema exposing a read-only view of the public notes.
create schema api;

grant usage on schema api to anon, authenticated;

create view api.public_notes
  with (security_invoker = true)
  as select id, body, created_at from public.notes;

grant select on api.public_notes to anon, authenticated;

-- Tables added to api later are readable by signed-in users by default.
alter default privileges in schema api grant select on tables to authenticated;
