import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/analysis_result.dart';

/// สร้างไฟล์ PDF รายงานผลตรวจ แล้วเปิดหน้า preview (print/save) ของระบบ
class ReportPdf {
  // สีให้ตรงกับ theme ของแอป
  static const _primary = PdfColor.fromInt(0xFF2BA89C);
  static const _abnormal = PdfColor.fromInt(0xFFE57373);
  static const _textPrimary = PdfColor.fromInt(0xFF1A1A1A);
  static const _textSecondary = PdfColor.fromInt(0xFF6B6B6B);
  static const _bgLight = PdfColor.fromInt(0xFFF5F5F5);

  /// สร้าง PDF จากผลวิเคราะห์ แล้วเปิด print preview ของระบบ
  static Future<void> generateAndPreview(AnalysisResult result) async {
    final bytes = await _buildDocument(result);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'BloodScope_${result.sampleCode}.pdf',
    );
  }

  static Future<Uint8List> _buildDocument(AnalysisResult result) async {
    // ฟอนต์ไทย (Sarabun) — ดึงจาก Google Fonts ผ่าน printing package
    final thaiRegular = await PdfGoogleFonts.sarabunRegular();
    final thaiBold = await PdfGoogleFonts.sarabunBold();

    final theme = pw.ThemeData.withFont(base: thaiRegular, bold: thaiBold);

    // โหลดภาพสไลด์ (ถ้ามีไฟล์จริง)
    pw.ImageProvider? slideImage;
    final file = File(result.imagePath);
    if (await file.exists()) {
      slideImage = pw.MemoryImage(await file.readAsBytes());
    }

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          _pdfHeader(),
          pw.SizedBox(height: 16),
          _pdfSampleInfo(result),
          pw.SizedBox(height: 14),
          _pdfStatusBanner(result),
          pw.SizedBox(height: 18),
          _pdfSectionLabel('ภาพสไลด์ที่ตรวจ'),
          pw.SizedBox(height: 8),
          if (slideImage != null) _pdfSlideImage(slideImage),
          pw.SizedBox(height: 4),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'พบเซลล์ที่ระบุได้ ${result.detections.length} เซลล์ในภาพนี้',
              style: const pw.TextStyle(fontSize: 10, color: _textSecondary),
            ),
          ),
          pw.SizedBox(height: 18),
          _pdfSectionLabel('รายละเอียดเซลล์ที่ตรวจพบ'),
          pw.SizedBox(height: 10),
          ...result.details.map(_pdfCellDetail),
          pw.SizedBox(height: 8),
          _pdfSectionLabel('สรุปเซลล์ที่ตรวจพบ'),
          pw.SizedBox(height: 10),
          _pdfSummaryTable(result),
          pw.SizedBox(height: 20),
          _pdfFooter(),
        ],
      ),
    );
    return doc.save();
  }

  static pw.Widget _pdfSlideImage(pw.ImageProvider image) {
    return pw.LayoutBuilder(
      builder: (context, constraints) => pw.ClipRRect(
        horizontalRadius: 8,
        verticalRadius: 8,
        child: pw.Container(
          height: 240,
          width: constraints!.maxWidth,
          child: pw.Image(image, fit: pw.BoxFit.cover),
        ),
      ),
    );
  }

  static pw.Widget _pdfHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: const pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Blood Cell Analysis Report',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'BloodScope — White Blood Cell Analysis',
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfSampleInfo(AnalysisResult result) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _labelValue('รหัสตัวอย่าง', result.sampleCode, pw.CrossAxisAlignment.start),
        _labelValue(
          'วันที่ตรวจ',
          _formatThaiDateTime(result.analyzedAt),
          pw.CrossAxisAlignment.end,
        ),
      ],
    );
  }

  static pw.Widget _labelValue(
    String label,
    String value,
    pw.CrossAxisAlignment align,
  ) {
    return pw.Column(
      crossAxisAlignment: align,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: _textSecondary)),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  static pw.Widget _pdfStatusBanner(AnalysisResult result) {
    final abnormal = result.hasAbnormal;
    final color = abnormal ? _abnormal : _primary;
    final title = abnormal ? 'ผิดปกติ / Abnormal' : 'ปกติ / Normal';
    final message = abnormal
        ? 'ตรวจพบ ${result.firstAbnormalName} ในภาพ ควรปรึกษาแพทย์เพื่อยืนยันผลเพิ่มเติม'
        : 'ไม่พบเซลล์ที่ผิดปกติในภาพนี้';

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor(color.red, color.green, color.blue, 0.08),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: color, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            message,
            style: const pw.TextStyle(fontSize: 11, color: _textPrimary),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfSectionLabel(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: _textPrimary,
      ),
    );
  }

  static pw.Widget _pdfCellDetail(CellDetail detail) {
    final color = detail.isAbnormal ? _abnormal : _primary;
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: detail.isAbnormal
            ? PdfColor(color.red, color.green, color.blue, 0.05)
            : PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(
          color: detail.isAbnormal ? color : PdfColors.grey300,
          width: 0.8,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  detail.nameEn,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: PdfColor(color.red, color.green, color.blue, 0.12),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Text(
                  detail.isAbnormal ? 'ผิดปกติ / Abnormal' : 'ปกติ / Normal',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          // Confidence bar
          pw.Row(
            children: [
              pw.Text('Confidence',
                  style: const pw.TextStyle(fontSize: 10, color: _textSecondary)),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.LayoutBuilder(
                  builder: (context, constraints) {
                    final fullWidth = constraints!.maxWidth;
                    return pw.Stack(
                      children: [
                        pw.Container(
                          height: 6,
                          width: fullWidth,
                          decoration: pw.BoxDecoration(
                            color: PdfColor(color.red, color.green, color.blue, 0.15),
                            borderRadius:
                                const pw.BorderRadius.all(pw.Radius.circular(3)),
                          ),
                        ),
                        pw.Container(
                          height: 6,
                          width: fullWidth * detail.confidencePercent / 100,
                          decoration: pw.BoxDecoration(
                            color: color,
                            borderRadius:
                                const pw.BorderRadius.all(pw.Radius.circular(3)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                '${detail.confidencePercent}%',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            detail.description,
            style: const pw.TextStyle(fontSize: 10, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfSummaryTable(AnalysisResult result) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
      ),
      child: pw.Column(
        children: [
          // หัวตาราง
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const pw.BoxDecoration(
              color: _bgLight,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text('ชนิดเซลล์',
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: _textSecondary)),
                ),
                pw.Text('Confidence',
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: _textSecondary)),
              ],
            ),
          ),
          ...result.details.map((detail) {
            final color = detail.isAbnormal ? _abnormal : _primary;
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 10,
                    height: 10,
                    decoration: pw.BoxDecoration(
                      color: color,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Text(
                      detail.nameEn,
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: detail.isAbnormal ? _abnormal : _textPrimary,
                        fontWeight:
                            detail.isAbnormal ? pw.FontWeight.bold : pw.FontWeight.normal,
                      ),
                    ),
                  ),
                  pw.Text(
                    '${detail.confidencePercent}%',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _pdfFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        pw.Text(
          'หมายเหตุ: ผลลัพธ์นี้เป็นการช่วยคัดกรองเบื้องต้นด้วย AI ควรตรวจสอบยืนยันซ้ำโดยนักเทคนิคการแพทย์หรือแพทย์ผู้เชี่ยวชาญทุกครั้ง',
          style: const pw.TextStyle(fontSize: 9, color: _textSecondary),
        ),
      ],
    );
  }

  static String _formatThaiDateTime(DateTime dt) {
    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    final month = months[dt.month - 1];
    final year = dt.year + 543;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} $month $year · $hh:$mm';
  }
}
