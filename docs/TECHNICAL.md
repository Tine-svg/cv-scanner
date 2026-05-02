# 🔧 เอกสารทางเทคนิค

คู่มือนี้สำหรับ developer ที่จะแก้ไข code, ขยายระบบ, หรือเข้าใจสถาปัตยกรรม

---

## 📑 สารบัญ

1. [สถาปัตยกรรมระบบ](#สถาปัตยกรรมระบบ)
2. [โครงสร้างไฟล์](#โครงสร้างไฟล์)
3. [Database Schema](#database-schema)
4. [Storage Schema](#storage-schema)
5. [Authentication Flow](#authentication-flow)
6. [Code Walkthrough](#code-walkthrough)
7. [การขยายฟีเจอร์](#การขยายฟีเจอร์)

---

## สถาปัตยกรรมระบบ

```
┌─────────────────────────────────────────────────┐
│                  USER BROWSER                    │
│                                                  │
│   ┌────────────────────────────────────────┐    │
│   │  index.html (single-page app)          │    │
│   │   - HTML + CSS + JS ในไฟล์เดียว         │    │
│   │   - pdf.js (parse PDF)                 │    │
│   │   - mammoth.js (parse Word)            │    │
│   │   - Supabase JS SDK                    │    │
│   └────────────────────────────────────────┘    │
│                      │                           │
└──────────────────────┼───────────────────────────┘
                       │ HTTPS
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
┌──────────────┐              ┌──────────────┐
│   VERCEL     │              │  SUPABASE    │
│              │              │              │
│  Static      │              │ - Postgres   │
│  Hosting     │              │ - Storage    │
│              │              │ - Auth       │
└──────────────┘              └──────────────┘
```

### Design Decisions

| เลือกอะไร | เหตุผล |
|---|---|
| **Single HTML file** | ง่ายต่อการ deploy, ไม่ต้อง build process, ทุกอย่างอยู่ที่เดียวเข้าใจง่าย |
| **Vanilla JS** | ไม่มี framework dependency, debug ง่าย, ทุก browser รัน |
| **Supabase** | Free tier ใช้ได้จริง, มี Auth + DB + Storage ในที่เดียว |
| **Vercel** | Deploy ง่ายผ่าน GitHub, free tier เหลือเฟือ, edge network เร็ว |
| **Custom auth (ไม่ใช้ Supabase Auth)** | ต้องการ login แบบ username + password (ไม่ใช่ email) — ตามที่ผู้ใช้ขอ |

### ⚠️ Trade-offs

- ❌ **ไม่มี build pipeline** — minify, bundle, tree-shake ไม่ได้
- ❌ **Auth ทำเอง** — ปลอดภัยน้อยกว่า Supabase Auth (ไม่มี salt, ไม่มี rate limit)
- ❌ **State management แบบ object เดียว (`state`)** — พอสำหรับ size นี้ แต่ขยายยากถ้าเพิ่มมาก
- ✅ **Deploy ง่าย** — แค่ commit ก็ขึ้น
- ✅ **เปิดอ่าน code ที่เดียวจบ** — ไม่ต้องไป trace หลายไฟล์

---

## โครงสร้างไฟล์

```
index.html (ขนาด ~80KB)
│
├── <head>
│   ├── Google Fonts (Plus Jakarta Sans + Bai Jamjuree + JetBrains Mono)
│   ├── pdf.js CDN
│   ├── mammoth.js CDN
│   └── Supabase JS SDK CDN
│
├── <style> (CSS variables + components)
│   ├── :root variables (colors, radius, transitions)
│   ├── Layout (container, header)
│   ├── Auth UI (overlay, card, forms)
│   ├── Upload zone
│   ├── Preview cards
│   ├── Results table
│   ├── Modals (file, signup, change-pwd, users, edit, detail)
│   └── Responsive
│
├── <body>
│   ├── Login Overlay
│   ├── Modals (signup, change-pwd, users, edit-user, user-detail)
│   ├── Container
│   │   ├── Header + user-bar
│   │   ├── Upload zone
│   │   ├── Status banner
│   │   ├── Batch preview (สแกนหลายไฟล์)
│   │   ├── Single preview (สแกนไฟล์เดียว)
│   │   ├── Search section
│   │   └── Results table
│   └── File modal (PDF preview)
│
└── <script> (ลำดับการประกาศ)
    1.  pdfjsLib worker setup
    2.  Auth System (login, signup, change pwd, hashPassword)
    3.  state object
    4.  DOM helpers ($, escapeHtml, etc.)
    5.  Supabase sync (init, load, create, update, delete)
    6.  User cache + management
    7.  Avatar utilities (resize, upload, getUrl)
    8.  Auth UI handlers
    9.  Drag & drop
    10. PDF/Word extraction (extractFromPDF, extractFromDocx)
    11. Field extractors (extractName, extractEmail, etc.)
    12. Batch handling
    13. Single file handling
    14. Render results table
    15. Modal handlers
    16. Search
    17. Helper functions
```

---

## Database Schema

### Table: `cvs`

```sql
create table cvs (
  id text primary key,              -- 'r' + Date.now() + '_' + index
  name text,                         -- ชื่อ-นามสกุลผู้สมัคร
  position text,                     -- ตำแหน่ง
  email text,
  phone text,
  age text,                          -- เก็บเป็น text เพราะอาจมี "30 ปี"
  gender text,                       -- "ชาย" / "หญิง" / "Male" / "Female"
  note text,                         -- โน้ตจาก HR
  file_name text,                    -- ชื่อไฟล์ต้นฉบับ (รวมภาษาไทย)
  file_path text,                    -- path ใน Storage: '<id>/file.pdf'
  hash text,                         -- SHA-256 ของไฟล์ (กันซ้ำ)
  uploaded_by text default '',       -- username ของคนอัพ
  uploaded_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

**Indexes (Supabase auto-create):**
- `id` (primary key)

**Suggested manual indexes ถ้าจำนวน records เยอะ:**
```sql
create index cvs_uploaded_at_idx on cvs (uploaded_at desc);
create index cvs_uploaded_by_idx on cvs (uploaded_by);
```

### Table: `users`

```sql
create table users (
  id uuid primary key default gen_random_uuid(),
  username text unique not null,    -- primary identifier (ใช้ login)
  password_hash text not null,      -- SHA-256 hash (no salt — known limitation)
  full_name text default '',
  email text default '',
  phone text default '',
  role text default 'Staff',        -- 'admin' | 'HR' | 'Manager' | 'Staff' | 'Other'
  avatar_path text default '',      -- path ใน Storage: '<username>/avatar.jpg'
  created_at timestamptz default now()
);
```

### Row Level Security (RLS)

ทั้ง 2 tables เปิด RLS แต่มี policy `using (true)` — ทุกคนทำได้ทุกอย่าง

⚠️ **Security note:** policy แบบนี้ ปลอดภัยเพราะ:
1. มี anon key ใน frontend (public)
2. ใช้ custom auth ที่ check login ก่อนเรียก API

แต่ในระดับ DB — ใครได้ anon key + รู้ structure ก็ทำอะไรก็ได้

**ถ้าต้องการ secure จริงๆ** — ใช้ Supabase Auth + JWT-based RLS แทน

---

## Storage Schema

### Bucket: `cv-files` (Public)

```
cv-files/
├── r1234567890_0/
│   └── file.pdf
├── r1234567890_1/
│   └── file.docx
└── ...
```

**Naming convention:**
- Path: `<record_id>/file.<ext>`
- ใช้ ASCII เท่านั้น (Supabase ไม่รับ Unicode ใน key)
- `file_name` ในตาราง CV เก็บชื่อไฟล์เดิม (รวมภาษาไทย) ไว้สำหรับแสดงผล

### Bucket: `user-avatars` (Public)

```
user-avatars/
├── jane/
│   └── avatar.jpg
├── john/
│   └── avatar.jpg
└── ...
```

**Naming convention:**
- Path: `<username>/avatar.jpg`
- ทุกรูปถูก resize เป็น JPEG 400×400 quality 0.85 ก่อนอัพ (ดู `resizeImage()`)
- ใช้ `upsert: true` เพื่อให้รูปใหม่ทับของเก่าได้

---

## Authentication Flow

```
┌───────────────────────────────────────────────────────────┐
│                                                            │
│   ┌──────────────┐                                         │
│   │ เปิดเว็บ      │                                         │
│   └──────┬───────┘                                         │
│          │                                                 │
│          ▼                                                 │
│   ┌──────────────────────┐                                 │
│   │ getSession()         │  อ่านจาก sessionStorage          │
│   └──────┬───────────────┘                                 │
│          │                                                 │
│      มี session?                                            │
│      ┌───┴───┐                                             │
│      │       │                                             │
│     ใช่     ไม่                                             │
│      │       │                                             │
│      ▼       ▼                                             │
│   ┌────┐  ┌──────────────┐                                 │
│   │ใช้ │  │ showAuth     │ ← หน้า Login                    │
│   │งาน │  │ Overlay()    │                                 │
│   └────┘  └──────┬───────┘                                 │
│                  │                                         │
│                  ▼                                         │
│           tryLogin(user, pwd)                              │
│                  │                                         │
│           1. hash password (SHA-256)                       │
│           2. query users where username + hash             │
│           3. ถ้าไม่เจอ → fallback admin/1234                │
│                  │                                         │
│                  ▼                                         │
│           setCurrentUser(username)                         │
│           - sessionStorage.set                             │
│           - update UI (avatar, name, admin buttons)        │
│           - hide overlay                                   │
│           - load user cache                                │
│                                                            │
└───────────────────────────────────────────────────────────┘
```

### Password Hashing

```javascript
async function hashPassword(password) {
  const data = new TextEncoder().encode(password);
  const hash = await crypto.subtle.digest('SHA-256', data);
  return Array.from(new Uint8Array(hash))
    .map(b => b.toString(16).padStart(2, '0')).join('');
}
```

⚠️ **Known limitations:**
- ไม่มี salt → password เดียวกัน → hash เดียวกัน → vulnerable ต่อ rainbow tables
- ไม่มี iterations → fast hash → vulnerable ต่อ brute force
- **เพื่อปรับปรุง:** ใช้ bcrypt หรือ argon2 (แต่ต้องผ่าน server-side function)

### Session Storage (vs Local Storage)

ใช้ `sessionStorage` แทน `localStorage` เพราะ:
- ✅ ปิด tab → หาย → ปลอดภัยกว่า
- ✅ แต่ละ tab ของ browser = session ต่างกัน

ถ้าต้องการให้จำนานๆ — เปลี่ยนเป็น `localStorage` ใน `setSession()`/`getSession()`

---

## Code Walkthrough

### Entry Point

```javascript
// บรรทัดท้ายของ <script>
const savedUser = getSession();
if (savedUser) {
  setCurrentUser(savedUser);  // login อัตโนมัติ
} else {
  showAuthOverlay();           // โชว์หน้า login
}
```

### Supabase Init

```javascript
async function initSupabase(config) {
  const client = window.supabase.createClient(config.url, config.key);
  // ทดสอบเชื่อมต่อ
  const { error } = await client.from('cvs').select('id').limit(1);
  if (error) throw new Error(error.message);
  state.supabase = client;
}

// auto-connect ตอนเริ่มต้น
if (state.config) {
  initSupabase(state.config).then(() => loadFromSupabase());
}
```

### Upload Flow

```
User drag/drop file
    │
    ▼
handleFiles(fileList)
    │
    ├─ validate type/size
    ├─ compute SHA-256 hash
    ├─ check duplicate (in records + in batch)
    │
    ▼
extractFromPDF() / extractFromDocx()
    │
    ├─ pdf.js: get all pages text
    ├─ mammoth.js: extract Word text
    │
    ▼
extractFields(text)
    │
    ├─ extractName()
    ├─ extractEmail()
    ├─ extractPhone()
    ├─ extractPosition() — ใช้ KNOWN_POSITIONS whitelist
    ├─ extractAge()
    ├─ extractGender()
    │
    ▼
showBatchPreview() — ตารางให้ user แก้ไข
    │
    ▼
User กด "บันทึก"
    │
    ▼
syncCreate(record) for each
    │
    ├─ uploadBytes() → cv-files bucket
    ├─ insert() → cvs table
```

### Render Loop

ทุกการเปลี่ยนแปลง state → เรียก `renderResults()`:

```javascript
function renderResults() {
  const filtered = filterRecords(state.records, state.searchQuery);
  // build HTML string
  wrap.innerHTML = `<table>...</table>`;
}
```

⚠️ ใช้ string template + `innerHTML` (ไม่ใช่ React/Vue) — ระวัง XSS:
- ใส่ user data ใน HTML → ใช้ `escapeHtml()`
- ใส่ใน `onclick="..."` → ใช้ `escapeHtml()` + single quote

---

## การขยายฟีเจอร์

### เพิ่ม field ใน CV

1. **Database:** `alter table cvs add column new_field text default '';`
2. **HTML:** เพิ่ม `<input>` ในฟอร์ม preview + edit
3. **Extraction:** เขียน `extractNewField(text)` แล้วเรียกใน `extractFields()`
4. **Sync:** เพิ่มใน `syncCreate` insert object
5. **Display:** เพิ่ม `<td>` ในตาราง renderResults
6. **Search:** เพิ่ม `r.new_field` ใน `filterRecords`

### เปลี่ยน auth เป็น Supabase Auth

1. ใน Supabase Dashboard → **Authentication** → enable Email/Password
2. ลบ table `users` (หรือเก็บไว้สำหรับ profile data)
3. แทนที่ `tryLogin()` / `trySignup()` ด้วย:
   ```javascript
   await supabase.auth.signInWithPassword({ email, password });
   await supabase.auth.signUp({ email, password });
   ```
4. ใช้ JWT-based RLS:
   ```sql
   create policy "Authenticated read"
     on cvs for select using (auth.role() = 'authenticated');
   ```

### เพิ่ม Roles & Permissions

ปัจจุบัน role เป็นแค่ display — ไม่มีผลต่อสิทธิ์

ถ้าต้องการ role-based access:
1. เพิ่ม column `role` ใน `users` (มีอยู่แล้ว)
2. เช็คใน UI: `if (currentUserRole === 'Manager') { showButton(); }`
3. ระดับ DB ต้องใช้ Supabase Auth + custom claims

### เพิ่ม Real-time updates

Supabase รองรับ realtime subscription:

```javascript
const channel = supabase
  .channel('cvs-changes')
  .on('postgres_changes', { event: '*', schema: 'public', table: 'cvs' },
    payload => {
      console.log('Change:', payload);
      loadFromSupabase(); // reload ตาราง
    }
  )
  .subscribe();
```

---

## 🔍 Debug Tips

### Enable Supabase logs ใน console

```javascript
// ก่อน createClient
window.supabase.createClient(url, key, {
  auth: { debug: true },
  global: { headers: { 'X-Client-Info': 'cv-scanner-debug' } }
});
```

### Inspect state object

ใน DevTools console:
```javascript
console.log(window.state);          // ทั้ง state
console.log(state.records);         // CV ทั้งหมด
console.log(state.records.length);  // จำนวน
console.log(userCache);             // user cache
```

### Force re-render

```javascript
renderResults();
```

### Reset auth

```javascript
sessionStorage.clear();
location.reload();
```

---

## 📊 Performance Notes

| Operation | Complexity | Bottleneck |
|---|---|---|
| Load CV list | O(n) | Network (Supabase query) |
| Search filter | O(n × fields) | Sync — ทำใน loop |
| PDF extraction | O(pages × glyphs) | pdf.js worker |
| Render table | O(n) | DOM update |

**ปัจจุบัน:** ใช้ได้ดีถึง ~1,000 records — เกินกว่านั้นต้อง:
- Pagination (LIMIT/OFFSET ใน Supabase)
- Virtual scrolling
- Debounce search

---

## 📝 Style Guide

### CSS

- ใช้ CSS variables ใน `:root` — เปลี่ยน theme ทั้งระบบจากที่เดียว
- BEM ไม่บังคับ — แต่ตั้งชื่อ class ให้สื่อความหมาย
- Avoid inline styles — ยกเว้น show/hide

### JavaScript

- `async/await` แทน `.then()` chains
- Destructuring: `const { data, error } = await supabase...`
- ตัวแปร global ห้ามมีเยอะ — รวมใน `state`, `userCache`, `userCacheBust`
- Event handlers ใส่ใน `window.functionName` ถ้าใช้ `onclick="..."`

### File Naming

- Lowercase + hyphen: `cv-files`, `user-avatars`
- ห้าม underscore ในชื่อ bucket / file path (Supabase quirk)
- ใส่ extension เสมอ: `index.html`, ไม่ใช่ `index`
