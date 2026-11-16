# Application : Guardian Eye

<p align="center">
  <b>Guardian Eye</b><br>
  แอปพลิเคชันสำหรับติดตามเหตุการณ์ความเป็นส่วนตัวและป้องกันการจับภาพเนื้อหาภายในแอปบน Android
</p>

---

## About Application

Guardian Eye เป็นแอป Flutter ที่เชื่อมต่อกับโค้ด Android ภาษา Kotlin เพื่อแสดงสถานะการเฝ้าระวัง เปิดหรือปิดการป้องกันหน้าจอ และบันทึกประวัติเหตุการณ์ที่ระบบปฏิบัติการเปิดให้ตรวจจับได้

ผู้ใช้สามารถเริ่มหรือหยุด Monitor จากภายในแอปหรือ Home Screen Widget ตรวจสอบความสามารถของอุปกรณ์ และดู Timeline ของเหตุการณ์ เช่นการเริ่มทำงาน การตรวจสอบด่วน การจับภาพหน้าจอ และสถานะการบันทึกหน้าจอที่เกี่ยวข้องกับ Guardian Eye

ขอบเขตของการตรวจจับอยู่ที่หน้าต่างและเนื้อหาของแอปเองตาม API ที่ Android รองรับ แอปจึงไม่ได้สแกนหา Spyware ทั้งเครื่องหรือระบุแอปบันทึกหน้าจอทุกตัว

---

## Features

### Privacy Dashboard

- แสดงสถานะการทำงานของ Monitor และการป้องกันหน้าจอ
- แสดงจำนวนเหตุการณ์ที่บันทึกไว้
- เริ่มหรือหยุดการทำงานจากหน้าหลัก
- Refresh สถานะปัจจุบันจากฝั่ง Android

### Screen Protection & Detection

- เปิดหรือปิด `FLAG_SECURE` สำหรับป้องกันการจับภาพเนื้อหาของหน้าต่าง Guardian Eye
- ลงทะเบียน Screenshot Callback เมื่ออุปกรณ์รองรับและเปิด Monitor
- ตรวจสถานะที่หน้าต่างของแอปปรากฏในการบันทึกหรือแชร์หน้าจอผ่าน API ที่รองรับ
- แสดงความสามารถของอุปกรณ์แยกจากสถานะการเปิดใช้งาน

### Background Monitor & Widget

- มี Android Foreground Service พร้อม Notification แสดงสถานะ
- หยุด Monitor จากปุ่มใน Notification ได้
- มี Home Screen Widget สำหรับสลับการทำงาน
- ตรวจสอบด่วนเพื่อบันทึกสรุปความสามารถที่พร้อมใช้งาน โดยขั้นตอนนี้จะเริ่ม Monitor ด้วย

### Event History

- เก็บประเภท ระดับความสำคัญ เวลา ชื่อ และรายละเอียดของเหตุการณ์
- เก็บประวัติในเครื่องผ่าน SharedPreferences
- จำกัดประวัติไว้สูงสุด 200 เหตุการณ์ตามโค้ด `MonitorStore`
- ล้างประวัติทั้งหมดจากแอปได้

---

## Application Sections

| หน้า | หน้าที่ |
|---|---|
| หน้าหลัก | ดูภาพรวมและเปิดหรือปิด Monitor |
| ตรวจสอบ | ดูการรองรับ Screenshot, Screen Recording และการป้องกันเนื้อหา |
| เหตุการณ์ | อ่าน Timeline และล้างประวัติ |
| ตั้งค่า | เปลี่ยนสถานะการป้องกันหน้าจอและการทำงานเบื้องหลัง |

---

## Platform Capabilities

โค้ด Android แยกการตรวจสอบความสามารถตามระดับ API ดังนี้:

| ระดับ API | การตรวจจับที่เพิ่มเข้ามาในโค้ด |
|---|---|
| API 34 ขึ้นไป | ลงทะเบียน Callback สำหรับ Screenshot ที่เกี่ยวข้องกับ Activity ของ Guardian Eye |
| API 35 ขึ้นไป | ติดตามสถานะการที่แอปปรากฏในการบันทึกหรือแชร์หน้าจอ |
| ต่ำกว่าระดับข้างต้น | ไม่ลงทะเบียน Callback ชนิดนั้น โดยยังมี UI และการตั้งค่าตามส่วนที่แพลตฟอร์มรองรับ |

Background Monitor ไม่ได้ทำให้แอปเข้าถึงภาพหรือกิจกรรมของแอปอื่นได้อย่างอิสระ ส่วนแพลตฟอร์มที่ไม่มี Native Channel จะใช้ Preview Mode และไม่ทำการตรวจจับจริง

---

## How It Works

1. Flutter เรียก Method Channel เพื่ออ่านสถานะและประวัติจาก Android
2. เมื่อผู้ใช้เปิด Monitor ฝั่ง Kotlin จะบันทึกสถานะ เริ่ม Foreground Service และลงทะเบียน Callback ที่รองรับ
3. เหตุการณ์ที่เกิดขึ้นถูกแปลงเป็น Metadata และเก็บใน `MonitorStore`
4. Event Channel แจ้ง Flutter ให้อ่านข้อมูลใหม่และปรับหน้า Dashboard / Timeline
5. การเปิดหรือปิด Screen Protection จะปรับ `FLAG_SECURE` ของหน้าต่างแอป

---

## Project Structure

```text
guardian_eye/
├── README.md
└── guardian_eye/               # Flutter Project
    ├── lib/
    │   ├── main.dart
    │   ├── controllers/
    │   ├── models/
    │   ├── screens/
    │   └── services/
    ├── android/                # Kotlin Monitor, Store และ Widget
    ├── test/
    └── pubspec.yaml
```

Flutter Project อยู่ในโฟลเดอร์ชั้นใน `guardian_eye` ต้องเข้าโฟลเดอร์นั้นก่อนใช้คำสั่ง Flutter

---

## Technology Stack

- Flutter และ Dart
- Material Design 3 พร้อม Dark Theme
- Kotlin และ Android Native APIs
- MethodChannel / EventChannel
- Foreground Service และ Notification
- Android App Widget
- SharedPreferences และ JSON สำหรับประวัติภายในเครื่อง

---

## Getting Started

ใช้ Flutter SDK ที่มี Dart ตรงกับข้อกำหนด `^3.12.2` ใน `pubspec.yaml` และเตรียม Android SDK / อุปกรณ์ที่ต้องการทดสอบ:

```bash
git clone https://github.com/kittanai46/guardian_eye.git
cd guardian_eye/guardian_eye
flutter pub get
flutter run
```

เปิดแอปบน Android และอนุญาต Notification เมื่อมีคำขอ จากนั้นเริ่ม Monitor จากหน้าหลัก หากต้องการใช้ Widget ให้เพิ่ม Guardian Eye จากเมนู Widget ของ Launcher

คำสั่งตรวจสอบโปรเจกต์ที่ระบุไว้ใน README ภายใน:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

---

## Privacy & Project Status

ระบบที่เขียนไว้เก็บเฉพาะ Metadata ของเหตุการณ์ภายในเครื่อง ไม่มีส่วนบันทึกภาพหน้าจอ เสียง หรือภาพจากผู้ใช้เพื่อสร้าง Timeline นี้

เป็น Android MVP ที่ต้องทดสอบ Callback, Foreground Service และ Widget บนอุปกรณ์จริงตามเวอร์ชันระบบ การมีโฟลเดอร์ iOS, Desktop หรือ Web ใน Flutter Project ไม่ได้หมายความว่ามีระบบตรวจจับ Native สำหรับแพลตฟอร์มเหล่านั้นแล้ว

---

## Repository Owner

[Kittanai Srikham](https://github.com/kittanai46)

