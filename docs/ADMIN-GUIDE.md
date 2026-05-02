# 🛡️ คู่มือ Admin

คู่มือนี้สำหรับผู้ที่มีสิทธิ์ admin — สอนการจัดการระบบ, ดูแล users, และ troubleshoot

---

## 📑 สารบัญ

1. [สิทธิ์พิเศษของ Admin](#สิทธิ์พิเศษของ-admin)
2. [จัดการ Users](#จัดการ-users)
3. [เพิ่ม User ใหม่](#เพิ่ม-user-ใหม่)
4. [แก้ไข User](#แก้ไข-user)
5. [ลบ User](#ลบ-user)
6. [Reset รหัสผ่าน User](#reset-รหัสผ่าน-user)
7. [การดูแลข้อมูลใน Supabase](#การดูแลข้อมูลใน-supabase)
8. [Best Practices](#best-practices)

---

## สิทธิ์พิเศษของ Admin

ตอน login เป็น `admin` — จะเห็น **ปุ่มเพิ่มใน user-bar** มุมขวาบน:

```
🟣 admin   🔒    👥    👤+   🚪
          เปลี่ยน  จัดการ  เพิ่ม  ออก
          รหัส   users   user
```

| ไอคอน | Function | Admin only? |
|---|---|---|
| 🔒 | เปลี่ยนรหัสผ่าน | ทุกคน |
| 👥 | จัดการ users (ดู/แก้/ลบ) | ✅ Admin only |
| 👤+ | เพิ่ม user ใหม่ | ✅ Admin only |
| 🚪 | Logout | ทุกคน |

---

## จัดการ Users

### 📋 ดูรายชื่อ users ทั้งหมด

1. มุมขวาบน → กด **👥 (จัดการ users)**
2. Modal เปิดขึ้นมา แสดงตาราง users:

| Column | ข้อมูล |
|---|---|
| ผู้ใช้ | รูป + ชื่อจริง + @username |
| ติดต่อ | email + เบอร์โทร |
| บทบาท | role pill (HR/Manager/Staff) |
| Actions | ปุ่ม "แก้ไข" + "ลบ" |

### 🎨 Role Pills (สีแยกชัดเจน)

- 🟡 **admin** — สีเหลืองทอง
- 🔵 **HR** — สีฟ้า
- 🟣 **Manager** — สีม่วง
- 🟢 **Staff** — สีเขียว
- ⚪ **Other** — สีเทา

---

## เพิ่ม User ใหม่

### ขั้นตอน:

1. มุมขวาบน → กด **👤+ (เพิ่ม user)**
2. Modal **"เพิ่ม User ใหม่"** เปิดขึ้น
3. กรอกข้อมูล:

| Field | Required? | กฎ |
|---|---|---|
| รูปโปรไฟล์ | ❌ | JPG/PNG/WebP, max 5MB (auto-resize 400×400) |
| Username | ✅ | 3+ ตัว, ใช้ได้แค่ a-z, 0-9, `_`, `-` |
| ชื่อ-นามสกุล | ✅ | ภาษาไทย/อังกฤษ |
| Email | ✅ | format `xxx@yyy.zz` |
| เบอร์โทร | ❌ | ไม่ validate format |
| บทบาท | — | default: Staff |
| Password | ✅ | 4+ ตัว |
| ยืนยัน Password | ✅ | ต้องตรงกับ Password |

4. กด **"สร้าง User"**
5. ถ้าสำเร็จ → modal ปิดเองใน 1.5 วินาที

### ⚠️ สิ่งที่ Admin ควรทำหลังสร้าง

1. **บอก credentials กับ user** (username + password เริ่มต้น)
2. **แนะนำให้เปลี่ยน password ทันที** หลัง login ครั้งแรก
3. ถ้าระบบสำคัญ — ใช้ password generator เช่น `Bw7tQ9$x` แทน `1234`

---

## แก้ไข User

### ขั้นตอน:

1. **👥 จัดการ users** → หาแถว user ที่ต้องการ
2. กด **"แก้ไข"**
3. Modal เปิดมา — แก้ฟิลด์ที่ต้องการ:
   - ✅ **แก้ได้:** ชื่อ-นามสกุล, email, เบอร์, บทบาท, รูปโปรไฟล์
   - ❌ **แก้ไม่ได้:** Username (เป็น primary key)
4. กด **"บันทึก"**

### 📸 เปลี่ยนรูป

- กด **"เปลี่ยนรูป"** → เลือกรูปใหม่ → preview ขึ้นทันที
- ระบบ **resize เป็น 400×400** อัตโนมัติ ก่อนอัพ
- กด **"บันทึก"** → upload ไป Supabase Storage

### 🗑️ ลบรูป

- กด **"ลบรูป"** → preview กลับเป็นตัวอักษร
- กด **"บันทึก"** → ลบไฟล์จาก Supabase

---

## ลบ User

### ขั้นตอน:

1. **👥 จัดการ users** → หา user ที่ต้องการลบ
2. กด **"ลบ"**
3. Confirm dialog → กด **OK**

### ⚠️ ข้อจำกัด

- ❌ **ลบบัญชีตัวเองไม่ได้** (ปุ่ม disabled)
- ❌ **ลบ admin ไม่ได้** (ปุ่ม disabled)
- ⚠️ **CV ที่ user เคยอัพโหลดยังอยู่** — แต่ใน column "โดย" จะแสดง username เดิม + badge **"user นี้ถูกลบไปแล้ว"** เมื่อกดดู

### สิ่งที่จะถูกลบ

- ✅ Row ใน table `users`
- ✅ ไฟล์ avatar ใน Storage `user-avatars`
- ❌ **ไม่ลบ** CV ที่ user เคยอัพ (เก็บประวัติไว้)

---

## Reset รหัสผ่าน User

❗ **ระบบยังไม่มี "Reset password" สำหรับ admin โดยตรง** — ต้องทำผ่าน 2 วิธี:

### วิธีที่ 1: ลบแล้วสร้างใหม่ (ง่ายแต่หยาบ)

1. ลบ user เก่า
2. สร้างใหม่ด้วย username เดิม + password ใหม่
3. ⚠️ user จะเสียประวัติ avatar เดิม

### วิธีที่ 2: แก้ผ่าน Supabase SQL (เนี้ยบ)

ใน **Supabase → SQL Editor**:

```sql
-- หา user ก่อน
select username, full_name from users where username = 'jane';

-- ตั้ง password ใหม่ (ใช้ SHA-256 hash)
-- ตัวอย่าง: ตั้ง password เป็น "newpass1234"
-- คำนวณ hash ก่อนใน DevTools console:
-- crypto.subtle.digest('SHA-256', new TextEncoder().encode('newpass1234'))
--   .then(h => console.log(Array.from(new Uint8Array(h)).map(b=>b.toString(16).padStart(2,'0')).join('')))

update users
set password_hash = '<paste hash here>'
where username = 'jane';
```

### 🔧 วิธีที่ 3: Admin เปลี่ยน password ผ่านหน้า "เปลี่ยนรหัสผ่าน" ของตัวเอง

หาก admin ลืม password ของตัวเอง:
- ❌ **เปลี่ยนผ่าน UI ไม่ได้** เพราะต้องใส่รหัสเดิม
- ✅ ต้องไปลบ row admin ใน Supabase → จะกลับไปใช้ default `admin/1234`

```sql
-- Reset admin กลับเป็น default
delete from users where username = 'admin';
-- ตอนนี้ login ด้วย admin/1234 ได้แล้ว แล้วเปลี่ยนรหัสใหม่ผ่าน UI
```

---

## การดูแลข้อมูลใน Supabase

### 🗃️ ตารางหลัก

| Table | เก็บอะไร |
|---|---|
| `cvs` | CV ทั้งหมด (ชื่อ, email, เบอร์, ตำแหน่ง, ฯลฯ) |
| `users` | บัญชีผู้ใช้ |

### 📁 Storage Buckets

| Bucket | เก็บอะไร |
|---|---|
| `cv-files` | ไฟล์ PDF/Word ของ CV (path: `<id>/file.pdf`) |
| `user-avatars` | รูปโปรไฟล์ user (path: `<username>/avatar.jpg`) |

### 🔍 Query ที่มีประโยชน์

**ดู CV ทั้งหมดในเดือนนี้:**
```sql
select name, position, email, uploaded_by, uploaded_at
from cvs
where uploaded_at >= date_trunc('month', now())
order by uploaded_at desc;
```

**สถิติ — แต่ละ user อัพโหลดกี่คน:**
```sql
select uploaded_by, count(*) as cv_count
from cvs
where uploaded_by != ''
group by uploaded_by
order by cv_count desc;
```

**หา CV ที่ไม่มีไฟล์ต้นฉบับ (orphan records):**
```sql
select id, name, file_name, file_path
from cvs
where file_path = '' or file_path is null;
```

**Export CV ทั้งหมดเป็น CSV:**
```sql
-- ใน Supabase → Table Editor → cvs → ปุ่ม "Export" มุมขวาบน
```

### 📊 ดู Storage Usage

ไปที่ **Settings → Usage** → ดู:
- Database size
- Storage size  
- จำนวน rows

---

## Best Practices

### 🔐 ความปลอดภัย

1. **เปลี่ยน admin/1234 ทันที** หลังตั้งระบบ
2. **อย่าแชร์ anon key** ใน chat / public repo (แม้จะ "ปลอดภัย" ที่จะ expose)
3. **ตรวจ users list** เป็นประจำ — ลบ user ที่ลาออก
4. **Rotate password** ของ admin ทุก 3-6 เดือน

### 🧹 การดูแลรักษา

1. **Backup ข้อมูลบ่อยๆ** — Supabase มี backup auto แต่ทำเองด้วยจะดี:
   - Table Editor → Export CSV
2. **เช็ค Storage usage** ทุกเดือน — ถ้าเกือบเต็ม free tier (1GB) ให้ลบไฟล์ที่ไม่ใช้
3. **Monitor errors** — บอก users ให้ส่ง screenshot เวลาเจอ error

### 👥 จัดการทีม

1. **ตั้งบทบาทให้เหมาะสม** ตามหน้าที่จริง:
   - HR — คนที่ทำงาน HR
   - Manager — หัวหน้าฝ่าย
   - Staff — พนักงานทั่วไป
   - Other — อื่นๆ
2. **อย่าให้สิทธิ์ admin หลายคน** — admin มีสิทธิ์เต็ม ลบ/แก้ทุกคนได้
3. **Document การเปลี่ยนแปลง** — เก็บ log ว่าใครสร้าง/ลบ user เมื่อไหร่

---

## 🆘 Emergency

### Database พัง / ลบ table โดยอุบัติเหตุ

1. ไป **Supabase → Database → Backups** — restore backup ล่าสุด
2. ถ้าไม่มี backup → ติดต่อ Supabase Support

### ลืม admin password

```sql
-- ใน Supabase SQL Editor
delete from users where username = 'admin';
-- กลับไปใช้ admin/1234 ได้
```

### Site ล่ม / Vercel error

1. เช็ค **Vercel Dashboard → Deployments** — ดูว่า build ผ่านไหม
2. ดู **Function Logs**
3. ถ้าจำเป็น — rollback กับ deployment เก่า: คลิก deployment ที่ทำงานได้ → "Promote to Production"

---

## 📞 Need Help?

ถ้าเจอปัญหาที่คู่มือไม่ครอบคลุม:

1. ดู [DEPLOYMENT.md](./DEPLOYMENT.md) สำหรับเรื่อง setup
2. ดู [TECHNICAL.md](./TECHNICAL.md) สำหรับเรื่อง architecture
3. ดู Supabase docs: https://supabase.com/docs
4. ดู Vercel docs: https://vercel.com/docs
