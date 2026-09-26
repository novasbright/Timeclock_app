# Time Clock – SK Dental Lab

Photo-verified clock-in / clock-out for Yujin Ko, with Fair Work–ready reports (PDF timesheet, CSV raw data, ZIP record pack).
Live at **https://jenny-timeclock.netlify.app**

---

## One-time setup (owner)

### 1. Database security update (Supabase)
Supabase → your **Sydney** project → **SQL Editor** → **New query** → paste everything in
[`database_setup.sql`](database_setup.sql) → **Run**. You should see *"Success. No rows returned."*

After this, only signed-in accounts can see or add records and photos.
Nobody can edit or delete records from the app.

### 2. Tell Supabase the app's web address
Supabase → **Authentication** → **URL Configuration** →
**Site URL** = `https://jenny-timeclock.netlify.app` → **Save**.
(This makes the "confirm your email" and "reset password" links open the app.)

### 3. Put the app online
Netlify → **jenny-timeclock** → **Deploys** → drag the folder containing `index.html` onto the upload box.

### 4. Create the accounts
- **Yujin**, on her iPhone: scan the QR code (or open the link in **Safari**) → type **her own email and a password** → **Create my account** → tap the confirm link in the email she receives → back in the app tap **Sign in**.
- **You** (owner), on your own phone/computer: do the same with your email, so you can download reports.

### 5. Switch off new accounts
Once both accounts exist: Supabase → **Authentication** → **Sign In / Providers** →
turn **off** "Allow new users to sign up" → **Save**.
Now nobody else can create an account, even if they have the link.

### 6. Print the QR code
In the app → **Setup** tab → **Print QR code** → stick it where she starts work.

---

## Daily use (Yujin)
1. Scan the QR code with the iPhone camera.
2. The camera opens on screen, already set to **Clock In** before 12pm or **Clock Out** from 12pm (by her phone's clock).
   Wrong one? Tap **Switch to …**.
3. Tap **Take photo** → check it → **Approve & Save** → green ✓ confirms the saved time.

The saved time always comes from the database server, not the phone.

**Tips**
- Use **Safari** (the QR code opens Safari). Skip "Add to Home Screen" — the home-screen version keeps a separate sign-in.
- To stop the "allow camera?" question each time: iPhone **Settings → Apps → Safari → Camera → Allow**.
- If she hasn't opened the app for a long break (a few weeks), Safari may ask her to sign in once more.
- Forgot password? On the sign-in screen type the email → **Forgot password?** → follow the email.

---

## Reports
**Reports** tab → pick dates (or *This week / Last week / This month*):

| Button | What you get | Use it for |
|---|---|---|
| **Timesheet (PDF)** | One row per shift: date, in, out, hours, total, signature lines | Printing, giving to employee/employer |
| **Raw Data (CSV)** | Every tap with exact second, record number, photo file name | Fair Work / auditors, opens in Excel |
| **Full record pack (ZIP)** | PDF + CSV + every photo | Monthly backup & full evidence |

Missing clock-ins or clock-outs are shown in the Notes column, never guessed.

---

## Good to know
- **Keep records for 7 years** (Fair Work). Download the **Full record pack (ZIP)** at the end of every month and save it to Google Drive or a USB.
- **Free Supabase projects pause after 7 days with no activity.** Daily clock-ins keep it awake. If it pauses, log in to supabase.com and click **Restore** — nothing is lost.
- **Storage:** 1 GB free ≈ many years of daily photos for one person.
- **Privacy:** Yujin's password is never visible to anyone. As project owner you can see her email address in Supabase → Authentication → Users, and you can delete her account there if she leaves.
- **Mistakes:** records can't be edited in the app (deliberately). Note corrections on the printed timesheet, or edit in Supabase → Table Editor.
- This app records attendance; it doesn't calculate pay, breaks, penalty rates or award entitlements. Check those on fairwork.gov.au.
