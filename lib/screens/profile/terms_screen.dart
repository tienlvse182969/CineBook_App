import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const List<(String, String)> _sections = [
    (
      '1. Chấp nhận điều khoản',
      'Bằng việc truy cập và sử dụng ứng dụng CineBook, bạn xác nhận đã đọc, hiểu rõ và đồng ý '
          'tuân thủ toàn bộ các điều khoản và điều kiện được nêu dưới đây. Nếu không đồng ý với '
          'bất kỳ nội dung nào, vui lòng ngừng sử dụng dịch vụ.',
    ),
    (
      '2. Tài khoản người dùng',
      'Người dùng chịu trách nhiệm bảo mật thông tin đăng nhập của mình và mọi hoạt động diễn ra '
          'dưới tài khoản đó. CineBook có quyền tạm khóa hoặc chấm dứt tài khoản nếu phát hiện hành '
          'vi gian lận, vi phạm pháp luật hoặc gây ảnh hưởng đến hệ thống.',
    ),
    (
      '3. Đặt vé và thanh toán',
      'Vé được xác nhận sau khi thanh toán thành công qua các phương thức được hỗ trợ trong ứng '
          'dụng. Giá vé, suất chiếu và ưu đãi có thể thay đổi mà không cần báo trước. Người dùng cần '
          'kiểm tra kỹ thông tin suất chiếu, ghế ngồi trước khi xác nhận thanh toán.',
    ),
    (
      '4. Hủy vé và hoàn tiền',
      'Yêu cầu hủy vé chỉ được chấp nhận trong khoảng thời gian quy định trước giờ chiếu và có thể '
          'phát sinh phí hủy. Việc hoàn tiền (nếu có) sẽ được xử lý về phương thức thanh toán gốc '
          'trong vòng 7-14 ngày làm việc.',
    ),
    (
      '5. Quyền sở hữu trí tuệ',
      'Toàn bộ nội dung, hình ảnh, logo, giao diện và mã nguồn của ứng dụng thuộc quyền sở hữu của '
          'CineBook. Nghiêm cấm sao chép, phân phối lại dưới bất kỳ hình thức nào khi chưa được sự '
          'cho phép bằng văn bản.',
    ),
    (
      '6. Giới hạn trách nhiệm',
      'CineBook không chịu trách nhiệm cho các thiệt hại gián tiếp phát sinh từ việc gián đoạn dịch '
          'vụ, lỗi kỹ thuật hoặc các sự kiện nằm ngoài tầm kiểm soát hợp lý. Chúng tôi sẽ nỗ lực khắc '
          'phục sự cố trong thời gian sớm nhất.',
    ),
    (
      '7. Thay đổi điều khoản',
      'Các điều khoản này có thể được cập nhật theo thời gian để phù hợp với quy định pháp luật và '
          'chính sách vận hành. Phiên bản mới nhất sẽ luôn được công bố trong ứng dụng và có hiệu lực '
          'ngay khi đăng tải.',
    ),
    (
      '8. Liên hệ',
      'Nếu có bất kỳ thắc mắc nào liên quan đến điều khoản sử dụng, vui lòng liên hệ với chúng tôi '
          'qua mục Hỗ trợ trong ứng dụng hoặc email support@cinebook.vn.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          _buildBg(),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildContent()),
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E1A), Color(0xFF12042A), Color(0xFF0C1530)],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Điều khoản sử dụng',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Cập nhật lần cuối: 01/07/2026',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _sections.length; i++) ...[
                  Text(
                    _sections[i].$1,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sections[i].$2,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12.5, height: 1.6),
                  ),
                  if (i != _sections.length - 1) ...[
                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.07)),
                    const SizedBox(height: 16),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
