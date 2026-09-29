# supabase-drift-guard demo

A small Supabase project wired to [supabase-drift-guard](https://github.com/SyrineSarray/supabase-drift-guard), a CI gate that fails when live Postgres privileges drift from what the migrations declare.

> Community project, not affiliated with or endorsed by Supabase.

## What this shows

The migrations in `supabase/migrations` declare exactly who can access what. The CI job rebuilds that expected state locally and compares it to the live project on every relevant PR, every push to `master`, and once a day.

- **Green run:** production matches the migrations. [link to green run]
- **Red run:** someone ran this in the dashboard's SQL editor, without a migration:

  ```sql
  GRANT SELECT ON public.private_notes TO anon;
  ```

  The table is meant to be unreachable through the API. The gate fails with:

  ```text
  ✗ PRIVILEGE DRIFT DETECTED

  public.private_notes | anon | SELECT extra in live
  ```

  [link to red run]

  [screenshot of the red run]

## What the migrations declare

| Object | Access | Why it's here |
| --- | --- | --- |
| `public.notes` | `anon` reads, `authenticated` reads and writes, `reporting` reads | Normal table grants |
| `public.private_notes` | Nobody through the API | The drift target |
| `api` schema, `api.public_notes` view | `anon` and `authenticated` can use the schema and read the view | A second exposed schema and a view |
| Default privileges in `api` | `authenticated` can read future tables | `ALTER DEFAULT PRIVILEGES` drift |
| `reporting` role | Created by a migration | A custom tracked role (see `drift-guard.config.json`) |

## Try it yourself

1. Fork this repo and create a free Supabase project.
2. Apply the migrations: `npx supabase link --project-ref <ref>` then `npx supabase db push`.
3. Add a `REMOTE_DATABASE_URL` repository secret with the project's **Session pooler** connection string (dashboard, **Connect**, **Session pooler**).
4. Run the workflow from the Actions tab: green.
5. Run the `GRANT` above in the SQL editor and run the workflow again: red.
6. Undo it with `REVOKE SELECT ON public.private_notes FROM anon;`.
