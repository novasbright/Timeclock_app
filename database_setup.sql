-- Time Clock database setup (with sign-in).
-- Safe to run on a new project OR on one where the earlier script was already run.
-- Supabase → SQL Editor → New query → paste all of this → Run.

-- 1. Table for every clock-in / clock-out
create table if not exists public.time_records (
  id            bigint generated always as identity primary key,
  employee_name text not null,
  action        text not null check (action in ('clock_in','clock_out')),
  recorded_at   timestamptz not null default now(),
  photo_path    text,
  device_info   text,
  created_at    timestamptz not null default now()
);
-- which signed-in account made each record (for the audit trail)
alter table public.time_records add column if not exists user_id uuid;

-- 2. Times always come from the server clock, and the account is taken from the sign-in
create or replace function public.force_server_time() returns trigger
language plpgsql as $$
begin
  new.recorded_at := now();
  new.created_at  := now();
  new.user_id     := auth.uid();
  return new;
end $$;

drop trigger if exists trg_force_server_time on public.time_records;
create trigger trg_force_server_time
before insert on public.time_records
for each row execute function public.force_server_time();

-- 3. Only SIGNED-IN accounts can add and read records. Nobody can edit or delete from the app.
alter table public.time_records enable row level security;
drop policy if exists "app can add records"  on public.time_records;
drop policy if exists "app can read records" on public.time_records;
drop policy if exists "signed-in can add records"  on public.time_records;
drop policy if exists "signed-in can read records" on public.time_records;
create policy "signed-in can add records"  on public.time_records for insert to authenticated with check (true);
create policy "signed-in can read records" on public.time_records for select to authenticated using (true);

-- 4. Private photo storage, signed-in accounts only
insert into storage.buckets (id, name, public)
values ('timeclock-photos', 'timeclock-photos', false)
on conflict (id) do nothing;

drop policy if exists "app can upload photos" on storage.objects;
drop policy if exists "app can view photos"   on storage.objects;
drop policy if exists "signed-in can upload photos" on storage.objects;
drop policy if exists "signed-in can view photos"   on storage.objects;
create policy "signed-in can upload photos" on storage.objects for insert to authenticated
  with check (bucket_id = 'timeclock-photos');
create policy "signed-in can view photos" on storage.objects for select to authenticated
  using (bucket_id = 'timeclock-photos');
