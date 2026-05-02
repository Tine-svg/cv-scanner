-- ========================================
-- CV Scanner — Complete Setup (Run once)
-- ========================================
-- รัน script นี้ใน Supabase SQL Editor เพื่อสร้างทุกอย่างตั้งแต่ต้น
-- รันใน Supabase → SQL Editor → New query → paste → Run
--
-- ก่อนรัน:
-- 1. สร้าง 2 storage buckets ผ่าน Supabase Dashboard:
--    - cv-files (Public)
--    - user-avatars (Public)
-- 2. รัน SQL นี้

-- ========================================
-- TABLE: cvs (ข้อมูล CV ผู้สมัคร)
-- ========================================
create table if not exists cvs (
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

drop policy if exists "Anyone can read"   on cvs;
drop policy if exists "Anyone can insert" on cvs;
drop policy if exists "Anyone can update" on cvs;
drop policy if exists "Anyone can delete" on cvs;

create policy "Anyone can read"   on cvs for select using (true);
create policy "Anyone can insert" on cvs for insert with check (true);
create policy "Anyone can update" on cvs for update using (true);
create policy "Anyone can delete" on cvs for delete using (true);

-- ========================================
-- TABLE: users (บัญชีผู้ใช้)
-- ========================================
create table if not exists users (
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

drop policy if exists "Anyone can read users"   on users;
drop policy if exists "Anyone can insert users" on users;
drop policy if exists "Anyone can update users" on users;
drop policy if exists "Anyone can delete users" on users;

create policy "Anyone can read users"   on users for select using (true);
create policy "Anyone can insert users" on users for insert with check (true);
create policy "Anyone can update users" on users for update using (true) with check (true);
create policy "Anyone can delete users" on users for delete using (true);

-- ========================================
-- STORAGE POLICIES
-- ========================================
-- ⚠️ ต้องสร้าง bucket "cv-files" และ "user-avatars" ก่อน (ผ่าน Dashboard)
-- ทั้งสอง bucket ต้องตั้งเป็น Public

-- Storage: cv-files
drop policy if exists "Public read cv-files"   on storage.objects;
drop policy if exists "Public insert cv-files" on storage.objects;
drop policy if exists "Public update cv-files" on storage.objects;
drop policy if exists "Public delete cv-files" on storage.objects;

create policy "Public read cv-files"
  on storage.objects for select using (bucket_id = 'cv-files');
create policy "Public insert cv-files"
  on storage.objects for insert with check (bucket_id = 'cv-files');
create policy "Public update cv-files"
  on storage.objects for update using (bucket_id = 'cv-files');
create policy "Public delete cv-files"
  on storage.objects for delete using (bucket_id = 'cv-files');

-- Storage: user-avatars
drop policy if exists "Public read user-avatars"   on storage.objects;
drop policy if exists "Public insert user-avatars" on storage.objects;
drop policy if exists "Public update user-avatars" on storage.objects;
drop policy if exists "Public delete user-avatars" on storage.objects;

create policy "Public read user-avatars"
  on storage.objects for select using (bucket_id = 'user-avatars');
create policy "Public insert user-avatars"
  on storage.objects for insert with check (bucket_id = 'user-avatars');
create policy "Public update user-avatars"
  on storage.objects for update using (bucket_id = 'user-avatars');
create policy "Public delete user-avatars"
  on storage.objects for delete using (bucket_id = 'user-avatars');

-- ========================================
-- ตรวจผล (รันเช็คผลหลัง setup)
-- ========================================
-- เช็ค tables ที่สร้าง
select table_name
from information_schema.tables
where table_schema = 'public'
  and table_name in ('cvs', 'users');

-- เช็ค policies ทั้งหมด (ควรเห็น 4 ของ cvs + 4 ของ users + 8 ของ storage)
select schemaname, tablename, policyname, cmd
from pg_policies
where schemaname in ('public', 'storage')
  and (tablename in ('cvs', 'users') or policyname like '%cv-files%' or policyname like '%user-avatars%')
order by schemaname, tablename, policyname;
