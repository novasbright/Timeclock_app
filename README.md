# Time Clock – Setup Guide (about 15 minutes, all free)

This replaces the earlier guide and app. Use **timeclock.html** only.

---

## Step 1 – Create the database (Supabase)

1. Go to **supabase.com** → Sign up with your email → **New project**.
   - Region: **Sydney** · Plan: **Free** · Save the database password somewhere.
2. When the project is ready, open **SQL Editor** → **New query**, paste everything below and press **Run**:

```sql
-- 1. Table for every clock-in / clock-out
create table public.time_records (
  id            bigint generated always as identity primary key,
  employee_name text not null,
  action        text not null check (action in ('clock_in','clock_out')),
  recorded_at   timestamptz not null default now(),
  photo_path    text,
  device_info   text,
  created_at    timestamptz not null default now()
);

-- 2. Times always come from the server clock (the phone's clock can't fake them)
create or replace function public.force_server_time() returns trigger
language plpgsql as $$
begin
  new.recorded_at := now();
  new.created_at  := now();
  return new;
end $$;

create trigger trg_force_server_time
before insert on public.time_records
for each row execute function public.force_server_time();

-- 3. The app can ADD and READ records, but can never EDIT or DELETE them
alter table public.time_records enable row level security;
create policy "app can add records"  on public.time_records for insert to anon with check (true);
create policy "app can read records" on public.time_records for select to anon using (true);

-- 4. Private photo storage
insert into storage.buckets (id, name, public)
values ('timeclock-photos', 'timeclock-photos', false)
on conflict (id) do nothing;

create policy "app can upload photos" on storage.objects for insert to anon
  with check (bucket_id = 'timeclock-photos');
create policy "app can view photos" on storage.objects for select to anon
  using (bucket_id = 'timeclock-photos');
```

You should see **"Success. No rows returned."**

3. Go to **Project Settings → API** and copy:
   - **Project URL** (e.g. `https://abcdxyz.supabase.co`)
   - **anon public** key (the long one labelled *anon* / *publishable* — **not** the *service_role* / secret key)

---

## Step 2 – Put the app online (Netlify, free)

The iPhone needs a web address to open the app and for the QR code to work.

1. On your computer, make a new folder called `timeclock`.
2. Put **timeclock.html** inside it and **rename it to `index.html`**.
3. Go to **app.netlify.com** → sign up free with your email.
4. Go to **Sites → "Deploy manually"** (or app.netlify.com/drop) and **drag the `timeclock` folder** onto the page.
5. You get a web address like `https://something-random.netlify.app`. You can rename it in *Site settings* (e.g. `janes-timeclock.netlify.app`).

---

## Step 3 – Set up your friend's iPhone

1. Open the web address in **Safari**.
2. Tap **Share → Add to Home Screen**. From now on she opens it from the home-screen icon.
3. Open it from the icon → **Setup** tab → fill in:
   - Supabase Project URL · anon key · her full name · the business name
4. Tap **Save & Test Connection** → it should say **✓ Connected**.
5. Tap **Clock In** once to test (allow camera access), then check the **Records** tab.

Do the same on your own phone/computer if you also want to download reports.
**Type her name exactly the same on every device** – the name is what links the records together.

---

## Step 4 – Print the QR code

On the **Setup** tab, tap **Print QR code** and stick it where she starts work.
Scanning it with the iPhone camera opens the app straight on the Clock screen.

---

## Daily use (for your friend)

1. Scan the QR code (or open the app icon)
2. Tap **Clock In** or **Clock Out** → camera opens → take a selfie
3. Check the photo → **Approve & Save** (or **Retake**)
4. A green ✓ message confirms it was saved with the time

---

## Reports (anyone with the app set up, any time)

**Reports** tab → pick dates (or *This week / Last week / This month*) →

| Button | What you get | Use it for |
|---|---|---|
| **Timesheet (PDF)** | One row per shift: date, in, out, hours, total, signature lines | Printing, giving to employee/employer |
| **Raw Data (CSV)** | Every single tap with exact second, record number, photo file name | Fair Work / auditors, opens in Excel |
| **Full record pack (ZIP)** | PDF + CSV + every photo | Monthly backup & full evidence |

Missing clock-ins or clock-outs are shown in the Notes column, never guessed.

---

## Important things to know

- **Keep records for 7 years.** Fair Work requires employers to keep time and pay records for **7 years**, not just 6–12 months. Download the **Full record pack (ZIP)** at the end of every month and save it to Google Drive or a USB — that's your permanent copy.
- **Free Supabase projects pause after 7 days with no activity.** Daily clock-ins keep it awake. If it pauses (e.g. over a long holiday), log in to supabase.com and click **Restore** — nothing is lost.
- **Free storage:** 1 GB for photos ≈ 5+ years of daily clock-ins at this photo size.
- **Keep the web address private-ish.** The app itself holds no password; the Supabase key is only saved on the phones you set up. Don't paste the key anywhere public.
- **Records can't be edited or deleted from the app** (that's deliberate — it makes them trustworthy). If a genuine mistake needs fixing, note it on the printed timesheet, or edit it in the Supabase dashboard (Table Editor) where only you can log in.
- This app records attendance; it doesn't calculate pay, breaks, penalty rates or award entitlements. Check those against her award on fairwork.gov.au.
