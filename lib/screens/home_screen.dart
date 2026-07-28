import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ส่วนที่เลื่อนได้
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('วิธีการใช้งาน'),
                  const SizedBox(height: 12),
                  _buildStep(
                    number: '1',
                    icon: Icons.camera_alt_outlined,
                    title: 'เปิดกล้อง',
                    description:
                        'แตะเพื่อเปิดใช้งานกล้องของอุปกรณ์เพื่อเริ่มต้นการถ่ายภาพสไลด์เลือดผ่านกล้องจุลทรรศน์',
                    calloutText:
                        'ต้องถ่ายผ่านเลนส์กล้องจุลทรรศน์ โดยใช้ตัวยึดมือถือเท่านั้น ไม่สามารถถ่ายจากสไลด์โดยตรงได้',
                    calloutColor: AppColors.warning,
                    calloutBackground: AppColors.warningLight,
                  ),
                  const SizedBox(height: 12),
                  _buildStep(
                    number: '2',
                    icon: Icons.center_focus_strong_outlined,
                    title: 'ถ่ายภาพสไลด์',
                    description:
                        'จัดตำแหน่งกล้องจุลทรรศน์ให้ตรงกับกรอบแล้วถ่ายภาพสไลด์เลือด',
                    calloutText:
                        'เลือกถ่ายบริเวณเซลล์ที่ไม่ซ้อนกันและหลีกเลี่ยงบริเวณขอบสไลด์ พร้อมปรับความคมชัดของกล้องจุลทรรศน์เพื่อผลวิเคราะห์ที่แม่นยำ',
                    calloutColor: AppColors.warning,
                    calloutBackground: AppColors.warningLight,
                  ),
                  const SizedBox(height: 12),
                  _buildStep(
                    number: '3',
                    icon: Icons.bar_chart_outlined,
                    title: 'รับผลวิเคราะห์',
                    description:
                        'AI ประมวลผลและแสดงชนิดเซลล์เม็ดเลือดขาว และรายงานสรุปผลการวิเคราะห์',
                    calloutText:
                        'ผลลัพธ์เป็นการช่วยคัดกรองเบื้องต้น ควรตรวจสอบยืนยันซ้ำโดยนักเทคนิคการแพทย์ทุกครั้ง',
                    calloutColor: AppColors.warning,
                    calloutBackground: AppColors.warningLight,
                  ),
                ],
              ),
            ),
            // ปุ่มถ่ายภาพลอยด้านล่าง พร้อม gradient ไล่เฉดทับเนื้อหา
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildCaptureButton(context),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Header =====
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ไอคอนแทนโลโก้ (เปลี่ยนเป็นรูปจริงทีหลัง)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.biotech,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BloodScope',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'WHITE BLOOD CELL ANALYSIS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Section Title =====
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ===== Step Card =====
  Widget _buildStep({
    required String number,
    required IconData icon,
    required String title,
    required String description,
    required String calloutText,
    required Color calloutColor,
    required Color calloutBackground,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // วงกลมหมายเลข (พื้นเขียวเข้มทึบ + เลขขาว)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ไอคอนในกล่องพื้นเขียวจาง
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              // ข้อความ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Callout ข้อความเสริม (แถบสีซ้าย + พื้นหลังอ่อน)
          _buildCallout(
            text: calloutText,
            accentColor: calloutColor,
            background: calloutBackground,
          ),
        ],
      ),
    );
  }

  // ===== Callout (ข้อความเสริมใต้ step) =====
  Widget _buildCallout({
    required String text,
    required Color accentColor,
    required Color background,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // แถบสีด้านซ้าย
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Capture Button =====
  Widget _buildCaptureButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0.0),
            AppColors.primaryLight.withValues(alpha: 0.6),
            AppColors.primaryLight,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CameraScreen()),
            );
          },
          icon: const Icon(Icons.camera_alt, color: Colors.white),
          label: const Text(
            'ถ่ายภาพ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}