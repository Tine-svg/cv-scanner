# 📋 CV Scanner

> เว็บอัพโหลดและค้นหา CV/Resume สำหรับทีม HR — สแกนข้อมูลผู้สมัครจาก PDF/Word อัตโนมัติ

ระบบนี้ช่วยให้ HR ทำงานเร็วขึ้น โดย:
- ✅ อัพโหลดไฟล์ CV ครั้งเดียว — ระบบดึงชื่อ, email, เบอร์โทร, ตำแหน่ง, อายุ, เพศ ให้อัตโนมัติ
- ✅ ค้นหาผู้สมัครได้จากทุกฟิลด์
- ✅ เพิ่มโน้ตย่อๆ ในแต่ละคน
- ✅ ทีมเข้าใช้พร้อมกันได้ — เห็นข้อมูลตรงกัน
- ✅ ติดตามได้ว่าใครเป็นคนเพิ่ม CV เข้ามา

---

## 🚀 Quick Start

### สำหรับผู้ใช้งาน
เปิดเว็บ → Login → อัพโหลด CV → เสร็จ

📖 อ่านเพิ่มเติม: [คู่มือผู้ใช้งาน](./USER-GUIDE.md)

### สำหรับ Admin
จัดการ users, ตั้งค่าระบบ, ดู logs

📖 อ่านเพิ่มเติม: [คู่มือ Admin](./ADMIN-GUIDE.md)

### สำหรับ Developer
ติดตั้งระบบใหม่ตั้งแต่ต้น หรือแก้ไข code

📖 อ่านเพิ่มเติม: [คู่มือ Deploy](./DEPLOYMENT.md) · [เอกสารทางเทคนิค](./TECHNICAL.md)

---

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML + Vanilla JS (single-file) |
| Database | Supabase (PostgreSQL) |
| Storage | Supabase Storage |
| Authentication | Custom (SHA-256 hash) |
| PDF parsing | pdf.js |
| Word parsing | mammoth.js |
| Hosting | Vercel |
| Source control | GitHub |

---

## ✨ Features

### 📂 จัดการ CV
- อัพโหลดได้หลายไฟล์พร้อมกัน
- รองรับ PDF และ Word (.docx)
- Extract ข้อมูลอัตโนมัติด้วย pattern matching
- ตรวจไฟล์ซ้ำด้วย SHA-256 hash
- ดูไฟล์ต้นฉบับใน popup

### 🔍 ค้นหา
- Real-time search
- Highlight คำที่ค้นหาในผลลัพธ์
- ค้นได้ทุก field (ชื่อ, email, เบอร์, ตำแหน่ง, โน้ต)

### 👥 จัดการ User
- Login ด้วย username + password
- Default admin: `admin` / `1234` (เปลี่ยนทันทีหลังตั้งระบบ!)
- Admin สร้าง/แก้ไข/ลบ user อื่นได้
- ผู้ใช้แต่ละคนมีรายละเอียด: ชื่อจริง, email, เบอร์, บทบาท, รูปโปรไฟล์
- รองรับ 4 บทบาท: HR / Manager / Staff / Other

### 🛡️ ความปลอดภัย
- Password hash ด้วย SHA-256
- Row Level Security (RLS) ที่ Supabase
- Session-based authentication

---

## 📁 โครงสร้างไฟล์

```
cv-scanner/
├── index.html              # ทุกอย่างอยู่ในไฟล์เดียว
├── README.md               # ไฟล์นี้
├── USER-GUIDE.md           # คู่มือผู้ใช้งาน
├── ADMIN-GUIDE.md          # คู่มือ admin
├── DEPLOYMENT.md           # วิธี deploy
├── TECHNICAL.md            # เอกสารเทคนิค
└── sql/
    ├── 01-cvs-setup.sql        # สร้าง table cvs + storage
    ├── 02-auth-setup.sql       # สร้าง table users
    ├── 03-uploader-column.sql  # เพิ่ม uploaded_by
    ├── 04-user-details.sql     # เพิ่ม full_name, email, phone, role
    └── 05-avatar-setup.sql     # เพิ่ม avatar_path + storage
```

---

## 🆘 Troubleshooting

| ปัญหา | ดูที่ |
|---|---|
| Login ไม่ได้ | [USER-GUIDE](./USER-GUIDE.md#เข้าระบบไม่ได้) |
| อัพโหลดไฟล์ไม่ได้ | [USER-GUIDE](./USER-GUIDE.md#อัพโหลดไม่ได้) |
| Bucket not found | [DEPLOYMENT](./DEPLOYMENT.md#troubleshooting) |
| RLS policy error | [DEPLOYMENT](./DEPLOYMENT.md#troubleshooting) |

---

## 📝 License

โปรเจกต์ส่วนตัว — ใช้งานภายในทีมเท่านั้น
