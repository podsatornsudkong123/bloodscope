import 'package:flutter/material.dart';

/// เซลล์ที่โมเดลตรวจพบในภาพ 1 ตำแหน่ง (ใช้วาด label ซ้อนบนภาพ)
class CellDetection {
  final String label;
  final int confidencePercent;
  final bool isAbnormal;

  /// ตำแหน่งสัมพัทธ์ (0.0-1.0) ของ label บนภาพ
  /// TODO: แทนที่ด้วยพิกัด bounding box จริงจากโมเดล AI
  final Alignment position;

  const CellDetection({
    required this.label,
    required this.confidencePercent,
    required this.isAbnormal,
    required this.position,
  });
}

/// รายละเอียดของเซลล์แต่ละชนิดที่ตรวจพบ (แสดงเป็นการ์ด + ตารางสรุป)
class CellDetail {
  final String nameEn;
  final String nameTh;
  final String description;
  final int confidencePercent;
  final bool isAbnormal;

  const CellDetail({
    required this.nameEn,
    required this.nameTh,
    required this.description,
    required this.confidencePercent,
    required this.isAbnormal,
  });
}

/// ผลการวิเคราะห์ทั้งหมดของสไลด์ 1 ภาพ
/// รวม metadata (รหัสตัวอย่าง/วันที่) + รายการเซลล์ ให้ทั้งหน้า Result และ Report ใช้ร่วมกัน
class AnalysisResult {
  final String imagePath;
  final String sampleCode;
  final DateTime analyzedAt;
  final List<CellDetection> detections;
  final List<CellDetail> details;

  const AnalysisResult({
    required this.imagePath,
    required this.sampleCode,
    required this.analyzedAt,
    required this.detections,
    required this.details,
  });

  /// พบเซลล์ผิดปกติอย่างน้อย 1 ชนิดหรือไม่ (ใช้กำหนดสถานะรวม ปกติ/ผิดปกติ)
  bool get hasAbnormal => details.any((d) => d.isAbnormal);

  /// ชื่อเซลล์ผิดปกติตัวแรกที่พบ (ใช้ในข้อความ banner) — คืน null ถ้าปกติทั้งหมด
  String? get firstAbnormalName {
    for (final d in details) {
      if (d.isAbnormal) return d.nameEn;
    }
    return null;
  }

  /// สร้างผลลัพธ์ mock สำหรับภาพที่ถ่าย/เลือกเข้ามา
  /// วันที่และรหัสตัวอย่างอิงจากเวลาจริงตอนวิเคราะห์
  /// TODO: แทนที่รายการเซลล์/confidence นี้ด้วยผลจากโมเดล AI on-device จริง
  factory AnalysisResult.mock(String imagePath) {
    final now = DateTime.now();
    return AnalysisResult(
      imagePath: imagePath,
      sampleCode: _generateSampleCode(now),
      analyzedAt: now,
      detections: const [
        CellDetection(
          label: 'Neutrophil',
          confidencePercent: 99,
          isAbnormal: false,
          position: Alignment(-0.55, -0.6),
        ),
        CellDetection(
          label: 'Lymphocyte',
          confidencePercent: 97,
          isAbnormal: false,
          position: Alignment(0.15, 0.55),
        ),
        CellDetection(
          label: 'Blast Cell',
          confidencePercent: 98,
          isAbnormal: true,
          position: Alignment(0.6, 0.6),
        ),
      ],
      details: const [
        CellDetail(
          nameEn: 'Segmented Neutrophil',
          nameTh: 'นิวโทรฟิลแบบแบ่งกลีบ',
          description:
              'เซลล์เม็ดเลือดขาวชนิดที่พบมากที่สุด ทำหน้าที่กำจัดเชื้อแบคทีเรียและสิ่งแปลกปลอมในกระแสเลือด',
          confidencePercent: 99,
          isAbnormal: false,
        ),
        CellDetail(
          nameEn: 'Lymphocyte',
          nameTh: 'ลิมโฟไซต์',
          description:
              'เซลล์เม็ดเลือดขาวในระบบภูมิคุ้มกัน ทำหน้าที่สร้างแอนติบอดีและตอบสนองต่อการติดเชื้อไวรัส',
          confidencePercent: 97,
          isAbnormal: false,
        ),
        CellDetail(
          nameEn: 'Blast Cell',
          nameTh: 'บลาสต์เซลล์',
          description:
              'เซลล์ตัวอ่อนของเม็ดเลือด ปกติไม่ควรพบในกระแสเลือดผู้ใหญ่ อาจบ่งชี้ถึงภาวะผิดปกติในไขกระดูก',
          confidencePercent: 98,
          isAbnormal: true,
        ),
      ],
    );
  }

  /// สร้างรหัสตัวอย่างจากเวลาจริง เช่น BS-20260716-1432
  /// หมายเหตุ: ใช้เวลาแทน running number เพราะแอปยังไม่มี backend/DB
  /// นับลำดับตัวอย่างต่อเนื่องได้จริง — ถ้ามีระบบหลังบ้านแล้วควรเปลี่ยนไปใช้เลขรันจากฐานข้อมูล
  static String _generateSampleCode(DateTime now) {
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return 'BS-$y$m$d-$hh$mm';
  }
}
