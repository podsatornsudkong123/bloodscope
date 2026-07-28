# BloodScope

แอป Flutter สำหรับวิเคราะห์เซลล์เม็ดเลือดขาว (White Blood Cell) จากภาพถ่ายสไลด์เลือดผ่านกล้องจุลทรรศน์

## Flow การใช้งาน

**Home → Camera (ในแอป) → Result → Report (PDF)**

1. **Home** — แสดงวิธีใช้งาน 3 ขั้นตอน พร้อมปุ่มถ่ายภาพ
2. **Camera** — เปิดกล้องในแอปเอง (ไม่เด้งออกแอปกล้องระบบ) พร้อม overlay guide, เลือกภาพจากคลังได้
3. **Result** — แสดงผลวิเคราะห์เซลล์พร้อม bounding box บนภาพ และรายการเซลล์ที่ตรวจพบ
4. **Report** — สรุปผลแบบเต็ม พร้อมดาวน์โหลดเป็น PDF (รองรับฟอนต์ไทย)

> **หมายเหตุ:** ผลวิเคราะห์ปัจจุบันเป็น mock data เนื่องจากยังไม่มีโมเดล AI จริง โดยมีแผนจะรันโมเดลแบบ on-device (TFLite/Core ML) ในอนาคต — แอปจะไม่พึ่งพาอินเทอร์เน็ต

## เริ่มต้นใช้งาน

ต้องติดตั้ง [Flutter SDK](https://docs.flutter.dev/get-started/install) ก่อน

```bash
flutter pub get
flutter run
```

รันบนอุปกรณ์จริงหรือ emulator/simulator ที่รองรับกล้อง (ฟีเจอร์กล้องต้องใช้อุปกรณ์จริงหรือ emulator ที่จำลองกล้องได้)

## โครงสร้างโปรเจกต์

```
lib/
├── main.dart
├── models/
│   └── analysis_result.dart   # โมเดลผลวิเคราะห์ (mock data)
├── screens/
│   ├── home_screen.dart
│   ├── camera_screen.dart
│   ├── result_screen.dart
│   └── report_screen.dart
├── services/
│   └── report_pdf.dart        # สร้างรายงาน PDF
└── theme/
    └── app_theme.dart
```

ดูรายละเอียดการพัฒนาแต่ละขั้นตอนได้ที่ [DEVLOG.md](DEVLOG.md)

## Dependencies หลัก

- `camera` — เปิดกล้องในแอป
- `image_picker` — เลือกภาพจากคลังภาพ
- `pdf` / `printing` — สร้างและแสดง PDF รายงาน
- `google_fonts` — ฟอนต์ (รวมถึงฟอนต์ไทยในรายงาน PDF)
