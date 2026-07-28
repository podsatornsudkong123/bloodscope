# BloodScope — บันทึกการพัฒนา (Dev Log)

บันทึกนี้สรุปทุกขั้นตอนที่ทำไปพร้อมไฟล์ที่แก้ไข เพื่อให้ย้อนดูได้ว่าทำอะไร แก้ตรงไหน และทำไม

---

## แผนงานรวม (ตาม Figma)

Flow: **Home** → **Camera (ในแอป)** → **Result (Blood Cell Analysis)**

- Home: มีอยู่แล้วก่อนเริ่ม (แสดงตัวอย่างเซลล์, วิธีใช้งาน, ปุ่มถ่ายภาพ)
- Camera: เปิดกล้องในแอปเอง (ไม่เด้งออกแอปกล้องระบบ) + เลือกภาพจากคลังได้ + overlay วงกลม guide/AI READY ตาม Figma
- Result: แสดงผลวิเคราะห์เซลล์เม็ดเลือดขาว (ใช้ mock data ไปก่อน เพราะยังไม่มีโมเดล AI)
- AI จะรันแบบ on-device (TFLite/Core ML) ในอนาคต — แอปไม่ใช้อินเทอร์เน็ต

---

## ขั้นตอนที่ 1 — เพิ่ม Dependencies และตั้งค่า Permission กล้อง/คลังภาพ

**วันที่:** 2026-07-04

**เป้าหมาย:** เตรียมโปรเจกต์ให้พร้อมใช้กล้องจริงในแอป และเลือกภาพจากคลังภาพได้

### ไฟล์ที่แก้ไข

1. **`pubspec.yaml`**
   - เพิ่ม dependency `camera: ^0.11.0+2` — สำหรับเปิด live camera preview ในแอป (ควบคุมถ่ายภาพเอง แทนการเด้งไปแอปกล้องระบบ)
   - เพิ่ม dependency `image_picker: ^1.1.2` — สำหรับเลือกภาพจากคลังภาพ (gallery)
   - รันคำสั่ง `flutter pub get` แล้ว (resolve สำเร็จ: camera 0.11.4, รองรับทั้ง Android CameraX และ iOS AVFoundation)

2. **`ios/Runner/Info.plist`**
   - เพิ่มคีย์ `NSCameraUsageDescription` — ข้อความอธิบายเหตุผลที่ขอสิทธิ์กล้อง (iOS บังคับต้องมี ไม่งั้นแอปจะ crash ทันทีที่ขอสิทธิ์กล้อง)
   - เพิ่มคีย์ `NSPhotoLibraryUsageDescription` — ข้อความอธิบายเหตุผลที่ขอสิทธิ์เข้าถึงคลังภาพ

3. **`android/app/src/main/AndroidManifest.xml`**
   - เพิ่ม `<uses-permission android:name="android.permission.CAMERA"/>` — Android ต้องประกาศ permission นี้ก่อนถึงจะขอสิทธิ์กล้องได้
   - เพิ่ม `<uses-feature android:name="android.hardware.camera" android:required="false"/>` — บอกว่าแอปใช้กล้องแต่ไม่บังคับ (เผื่อรันบนเครื่องที่ไม่มีกล้อง เช่น emulator บางแบบ หรือ Play Store filter ที่เข้มงวดเกินไป)
   - หมายเหตุ: `image_picker` บน Android สมัยใหม่ใช้ system picker ไม่ต้องขอ storage permission เพิ่ม

### ผลลัพธ์
โปรเจกต์พร้อมเรียกใช้ camera plugin และ image_picker แล้ว ยังไม่มีหน้าจอใหม่หรือโค้ด UI ใดๆ ถูกสร้าง — ขั้นนี้เป็นการเตรียม infrastructure เท่านั้น

---

## ขั้นตอนที่ 2 — สร้าง CameraScreen (กล้องในแอป)

**วันที่:** 2026-07-04

**เป้าหมาย:** เปิดกล้องจริงในแอปเอง (ไม่เด้งออกไปแอปกล้องระบบ) พร้อม overlay ตาม Figma และเลือกภาพจากคลังภาพได้

### ไฟล์ที่สร้างใหม่

**`lib/screens/camera_screen.dart`**
- `_setupCamera()` — ขอรายชื่อกล้องด้วย `availableCameras()`, เลือกกล้องหลัง (back camera), สร้าง `CameraController` (resolution สูง, ปิดเสียง เพราะไม่จำเป็น) แล้ว initialize
- แสดง live preview ด้วย `CameraPreview` ครอบด้วย `FutureBuilder` รอ initialize เสร็จก่อน
- ถ้าเปิดกล้องไม่ได้ (เช่น ไม่มีกล้อง หรือ permission ถูกปฏิเสธ) แสดงข้อความ error กลางจอแทน
- Overlay ตาม Figma: ข้อความ "Hold steady — focusing", badge "AI READY" สีเขียว, กรอบวงกลม guide พร้อมมุมกรอบ 4 มุม (วาดด้วย `CustomPainter` ชื่อ `_CornerFramePainter`)
- Top bar: ปุ่มย้อนกลับ + หัวข้อ "Camera" + ปุ่ม flash (ปุ่ม flash ยังไม่ผูก logic จริง เป็น placeholder เพราะตัดสินใจให้ zoom/flash ใช้ auto ของเครื่อง)
- Bottom bar: ปุ่มเลือกภาพจากคลัง (`_pickFromGallery` ใช้ `ImagePicker().pickImage(source: ImageSource.gallery)`) และปุ่มชัตเตอร์วงกลม (`_capturePhoto` เรียก `controller.takePicture()`)
- ทั้งถ่ายภาพและเลือกจากคลัง จะ `pushReplacement` ไปหน้า `ResultScreen` พร้อมส่ง path ของภาพ

---

## ขั้นตอนที่ 3 — สร้าง ResultScreen (หน้าแสดงผลวิเคราะห์)

**วันที่:** 2026-07-04

**เป้าหมาย:** แสดงผลวิเคราะห์เซลล์เม็ดเลือดขาวตาม Figma โดยใช้ mock data ไปก่อน (ยังไม่มีโมเดล AI จริง)

### ไฟล์ที่สร้างใหม่

**`lib/screens/result_screen.dart`**
- รับ `imagePath` จากหน้า Camera แล้วแสดงภาพที่ถ่าย/เลือกมาด้วย `Image.file`
- `_mockDetections` — รายการ label ปลอม (ชื่อเซลล์ + % ความมั่นใจ + ผิดปกติหรือไม่) วางซ้อนบนภาพที่ตำแหน่งคงที่ (`_mockPositions`) เพื่อจำลอง bounding box เหมือนใน Figma — มี TODO กำกับไว้ว่าต้องแทนที่ด้วยพิกัดจริงจากโมเดล AI ภายหลัง
- การ์ด "เอกสารสรุปผลรายงานผลตรวจ" พร้อมปุ่ม "ดูรายงาน" (ยังเป็น TODO ไม่ได้ทำหน้ารายงานจริง)
- `Cell Detail List` — แสดงรายละเอียดเซลล์แต่ละชนิด (`_mockCellDetails`) พร้อม badge "ปกติ/Normal" หรือ "ผิดปกติ/Abnormal" ตามสี AppColors.normal / AppColors.abnormal

---

## ขั้นตอนที่ 4 — เชื่อมปุ่ม "ถ่ายภาพ" ในหน้า Home เข้ากับ CameraScreen

**วันที่:** 2026-07-04

### ไฟล์ที่แก้ไข

**`lib/screens/home_screen.dart`**
- เพิ่ม `import 'camera_screen.dart';`
- แก้ `onPressed` ของปุ่ม "ถ่ายภาพ" (เดิมเป็น TODO ว่างเปล่า) ให้ `Navigator.push` ไปหน้า `CameraScreen`

### ผลลัพธ์
ตอนนี้ flow ครบ 3 หน้าแล้ว: **Home → Camera → Result** กดปุ่มถ่ายภาพจาก Home จะเปิดกล้องในแอป ถ่ายหรือเลือกภาพจากคลังแล้วไปหน้าผลวิเคราะห์ทันที (ผลเป็น mock data รอเสียบโมเดล AI จริง)

---

## ขั้นตอนถัดไป (ยังไม่ได้ทำ)

- [ ] ทดสอบรันจริงบนอุปกรณ์/emulator เพื่อเช็ค permission flow และการแสดงผลกล้อง
- [ ] เตรียมโมเดล AI on-device (TFLite/Core ML) และเขียนโค้ดเชื่อม inference แทน mock data ใน `result_screen.dart`
- [ ] ทำหน้า/ฟังก์ชัน "ดูรายงาน" ฉบับเต็ม (ปัจจุบันเป็นปุ่ม TODO)
- [ ] พิจารณาผูก flash ปุ่มใน CameraScreen ให้ทำงานจริง (ปัจจุบันเป็น placeholder เฉยๆ)
