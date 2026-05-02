# 🚀 คู่มือ Deploy ระบบ

คู่มือนี้สำหรับติดตั้งระบบใหม่ตั้งแต่ต้น — ใช้เวลาประมาณ **30-45 นาที**

---

## 📑 สารบัญ

1. [สิ่งที่ต้องเตรียม](#สิ่งที่ต้องเตรียม)
2. [ตั้งค่า Supabase](#ตั้งค่า-supabase)
3. [Setup GitHub](#setup-github)
4. [Deploy Vercel](#deploy-vercel)
5. [ตั้งค่า Config ใน HTML](#ตั้งค่า-config-ใน-html)
6. [การอัพเดต code ภายหลัง](#การอัพเดต-code-ภายหลัง)
7. [Troubleshooting](#troubleshooting)

---

## สิ่งที่ต้องเตรียม

- ✅ Email สำหรับสมัคร services
- ✅ Browser (Chrome / Edge / Firefox)
- ✅ ไฟล์ `index.html` ของระบบ
- ✅ ไฟล์ SQL ในโฟลเดอร์ `sql/` (เจนเตรียมให้)
- ✅ เวลาว่าง ~30-45 นาที

**Account ที่จะสร้าง:**
1. **GitHub** — เก็บ code (ฟรี)
2. **Supabase** — database + storage (ฟรี)
3. **Vercel** — hosting (ฟรี)

ทั้ง 3 free tier ใช้ได้แบบไม่ต้องผูกบัตรเครดิต

---

## ตั้งค่า Supabase

### ขั้นที่ 1: สมัคร Supabase

1. เปิด **https://supabase.com**
2. กด **"Start your project"** → Sign up ด้วย GitHub
3. กดสร้าง **"New project"**:
   - **Name:** `cv-scanner` (หรืออะไรก็ได้)
   - **Database password:** ตั้ง strong password (เก็บไว้ ลืมแล้วลำบาก)
   - **Region:** **Southeast Asia (Singapore)** ใกล้ไทย เร็วสุด
4. กด **Create new project** → รอ ~2 นาที

### ขั้นที่ 2: รัน SQL Migrations

ในเมนูซ้าย → **SQL Editor** → **New query** → รัน script ทีละไฟล์ ตามลำดับ:

#### 1️⃣ สร้าง Table `cvs`

```sql
-- 01-cvs-setup.sql
create table cvs (
  id text primary key,
  name text,
  position text,
  email text,
  phone text,
  age text,
  gender text,
  note text,
  file_name text,
  file_path text,
  hash text,
  uploaded_by text default '',
  uploaded_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table cvs enable row level security;

create policy "Anyone can read"   on cvs for select using (true);
create policy "Anyone can insert" on cvs for insert with check (true);
create policy "Anyone can update" on cvs for update using (true);
create policy "Anyone can delete" on cvs for delete using (true);
```

#### 2️⃣ สร้าง Table `users`

```sql
-- 02-auth-setup.sql
create table users (
  id uuid primary key default gen_random_uuid(),
  username text unique not null,
  password_hash text not null,
  full_name text default '',
  email text default '',
  phone text default '',
  role text default 'Staff',
  avatar_path text default '',
  created_at timestamptz default now()
);

alter table users enable row level security;

create policy "Anyone can read users"   on users for select using (true);
create policy "Anyone can insert users" on users for insert with check (true);
create policy "Anyone can update users" on users for update using (true) with check (true);
create policy "Anyone can delete users" on users for delete using (true);
```

### ขั้นที่ 3: สร้าง Storage Buckets

ไปที่ **Storage** ในเมนูซ้าย → **New bucket** ทำ 2 อัน:

#### Bucket 1: `cv-files` (เก็บไฟล์ CV)

- Name: `cv-files`
- Public bucket: ✅ ติ๊ก
- กด **Save**

#### Bucket 2: `user-avatars` (เก็บรูปโปรไฟล์)

- Name: `user-avatars`
- Public bucket: ✅ ติ๊ก
- กด **Save**

### ขั้นที่ 4: ตั้ง Storage Policies

กลับไป **SQL Editor** → รัน:

```sql
-- 03-storage-policies.sql

-- cv-files
create policy "Public read cv-files"   on storage.objects for select using (bucket_id = 'cv-files');
create policy "Public insert cv-files" on storage.objects for insert with check (bucket_id = 'cv-files');
create policy "Public update cv-files" on storage.objects for update using (bucket_id = 'cv-files');
create policy "Public delete cv-files" on storage.objects for delete using (bucket_id = 'cv-files');

-- user-avatars
create policy "Public read user-avatars"   on storage.objects for select using (bucket_id = 'user-avatars');
create policy "Public insert user-avatars" on storage.objects for insert with check (bucket_id = 'user-avatars');
create policy "Public update user-avatars" on storage.objects for update using (bucket_id = 'user-avatars');
create policy "Public delete user-avatars" on storage.objects for delete using (bucket_id = 'user-avatars');
```

### ขั้นที่ 5: คัดลอก URL + API Key

ไปที่ **Settings (⚙) → API**:

**คัดลอกเก็บไว้ 2 ค่า:**

1. **Project URL** — เช่น `https://xxxxxxxxxx.supabase.co`
2. **anon public** key — ตัวยาวๆ ขึ้นต้นด้วย `eyJ...`

⚠️ **ใช้แค่ anon key — ห้ามใช้ service_role**

---

## Setup GitHub

### ขั้นที่ 1: สมัคร GitHub

1. เปิด **https://github.com/signup**
2. ใส่ email + ตั้ง password + username
3. Verify email

### ขั้นที่ 2: สร้าง Repository

1. มุมขวาบน → กด **`+` → New repository**
2. กรอก:
   - **Name:** `cv-scanner` (ชื่ออะไรก็ได้)
   - **Visibility:** Public (Private ต้อง upgrade plan)
   - ✅ ติ๊ก **Add a README file**
3. กด **Create repository**

### ขั้นที่ 3: Upload `index.html`

1. ในหน้า repo → **Add file → Upload files**
2. ลากไฟล์ `index.html` มาวาง
3. ลงด้านล่าง → **Commit changes**

✅ Code อยู่บน GitHub แล้ว

---

## Deploy Vercel

### ขั้นที่ 1: สมัคร Vercel

1. เปิด **https://vercel.com/signup**
2. กด **Continue with GitHub** → Authorize
3. เลือก plan **Hobby (Free)**

### ขั้นที่ 2: Import Repository

1. Vercel Dashboard → **Add New → Project**
2. หา repo `cv-scanner` → กด **Import**
3. ถ้าไม่เห็น → กด **Adjust GitHub App Permissions** → ติ๊ก repo → Save

### ขั้นที่ 3: Configure Project

- **Framework Preset:** **Other** (เพราะเป็น static HTML)
- **Root Directory:** `./` (ไม่ต้องแก้)
- ไม่ต้องตั้ง Environment Variables

กด **Deploy** → รอ ~30 วินาที

✅ ได้ URL เช่น `https://cv-scanner-xxx.vercel.app`

---

## ตั้งค่า Config ใน HTML

ก่อน deploy ขั้นสุดท้าย — ต้องใส่ Supabase config ใน `index.html`:

### วิธีที่ 1: แก้ใน GitHub (ง่ายสุด)

1. GitHub repo → คลิก `index.html`
2. กดไอคอน ✏️ (แก้ไข)
3. กด **Ctrl + F** หา `DEFAULT_SUPABASE_CONFIG`
4. แทนที่ค่า:

```javascript
const DEFAULT_SUPABASE_CONFIG = {
  url: 'https://YOUR_PROJECT.supabase.co',  // ← แทนที่
  key: 'eyJ...YOUR_ANON_KEY...'              // ← แทนที่
};
```

5. ลงด้านล่าง → **Commit changes**
6. Vercel จะ auto-deploy ใน ~1 นาที

### วิธีที่ 2: แก้ที่เครื่อง แล้ว upload

1. ดาวน์โหลด `index.html` ลงเครื่อง
2. เปิดด้วย VSCode / Notepad
3. หา `DEFAULT_SUPABASE_CONFIG` → แก้ค่า
4. Save → upload ขึ้น GitHub ทับของเดิม

---

## ✅ ทดสอบครั้งแรก

1. เปิด URL Vercel
2. หน้า Login จะเด้งขึ้น
3. Login ด้วย: `admin` / `1234`
4. ทดลอง:
   - อัพโหลด CV (PDF/Word) → ดูว่าสแกนได้
   - กด "ตั้งค่า" → ดูว่าจุดเขียวขึ้น (เชื่อมต่อ Supabase แล้ว)
   - เพิ่ม user ใหม่
   - ลอง login ด้วย user ใหม่

ถ้าทุกอย่างได้ → ✅ Deploy สำเร็จ

⚠️ **ห้ามลืม: เปลี่ยน password admin จาก `1234` ทันที!**

---

## การอัพเดต code ภายหลัง

### วิธีง่ายสุด: แก้ใน GitHub web

1. GitHub repo → กด `index.html` → ✏️ Edit
2. แก้ที่ต้องการ
3. **Commit changes**
4. Vercel auto-deploy ใน ~1 นาที

### วิธีอื่น: Upload ทับ

1. **Add file → Upload files** → ลากไฟล์ใหม่มาวาง
2. ระบบจะถามว่าจะแทนที่ของเดิมไหม → ใช่
3. **Commit changes**

---

## Troubleshooting

### "Bucket not found" ตอน upload รูป/ไฟล์

**สาเหตุ:** ยังไม่ได้สร้าง storage bucket

**แก้:** ไปที่ Supabase → Storage → สร้าง bucket ตามชื่อที่ขาด:
- `cv-files` (สำหรับ CV PDF)
- `user-avatars` (สำหรับรูปโปรไฟล์)

### "new row violates row-level security policy"

**สาเหตุ:** RLS เปิดอยู่ แต่ policy ไม่ครบ

**แก้:** รัน SQL policies ใหม่ทั้งหมด:

```sql
-- ลบ policies เก่า แล้วสร้างใหม่
drop policy if exists "Anyone can read"   on cvs;
drop policy if exists "Anyone can insert" on cvs;
drop policy if exists "Anyone can update" on cvs;
drop policy if exists "Anyone can delete" on cvs;

create policy "Anyone can read"   on cvs for select using (true);
create policy "Anyone can insert" on cvs for insert with check (true);
create policy "Anyone can update" on cvs for update using (true);
create policy "Anyone can delete" on cvs for delete using (true);
```

ทำเหมือนกันสำหรับ `users` table และ storage policies

### "Invalid key" ตอน upload ไฟล์ภาษาไทย

**สาเหตุ:** Supabase Storage ไม่รับ Unicode ใน path

**แก้:** Code ในเว็บใช้ `<id>/file.pdf` แทนชื่อไฟล์ภาษาไทยอยู่แล้ว — ถ้ายังเจอปัญหา → ตรวจว่าใช้ version ล่าสุดของ `index.html`

### Login ไม่ได้: "ระบบยังโหลดไม่เสร็จ"

**สาเหตุ:** Supabase SDK ยังโหลดไม่ทันก่อนกด login

**แก้:**
- รอสัก 2-3 วิ แล้วลองใหม่
- เช็ค Browser Console (F12) มี error ไหม
- เช็คว่า config URL/key ถูก

### Vercel deploy fail

**แก้:**
- ดู Vercel Dashboard → Deployments → ดู error log
- ส่วนใหญ่ static HTML deploy ไม่ค่อย fail — ถ้าเจอบอก Vercel support

### Site เปิดมาเป็นรายการไฟล์ ไม่ใช่หน้าเว็บ

**สาเหตุ:** ชื่อไฟล์ไม่ใช่ `index.html`

**แก้:** เปลี่ยนชื่อไฟล์ใน GitHub เป็น `index.html` ตรงๆ (lowercase)

---

## 📞 Resources

- **Supabase Docs:** https://supabase.com/docs
- **Vercel Docs:** https://vercel.com/docs
- **GitHub Docs:** https://docs.github.com
