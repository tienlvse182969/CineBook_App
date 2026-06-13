const List<String> supportQuickReplies = [
  'Cách đặt vé?',
  'Chính sách hoàn vé?',
  'Điểm thưởng hoạt động thế nào?',
  'Cách đổi suất chiếu?',
  'Liên hệ hotline',
];

// TODO: thay hàm này bằng AI API call
String supportAutoReply(String userText) {
  final t = userText.toLowerCase();
  if (t.contains('đặt vé') || t.contains('mua vé')) {
    return 'Để đặt vé, bạn vào trang chủ → chọn phim → chọn suất chiếu → chọn ghế → thanh toán. Rất đơn giản! 🎬';
  }
  if (t.contains('hoàn vé') || t.contains('hủy vé') || t.contains('refund')) {
    return 'Chính sách hoàn vé: bạn có thể hủy trước giờ chiếu 2 tiếng và nhận hoàn tiền 80%. Vé đã thanh toán bằng ví điện tử sẽ hoàn trong 3–5 ngày làm việc.';
  }
  if (t.contains('điểm') || t.contains('thưởng') || t.contains('xu')) {
    return 'Cứ 10.000đ bạn chi tiêu = 1 điểm thưởng. Đủ 2.000 điểm lên hạng Vàng và nhận ưu đãi 10% mọi giao dịch! ⭐';
  }
  if (t.contains('đổi suất') || t.contains('đổi lịch')) {
    return 'Bạn có thể đổi suất chiếu trước 4 tiếng. Vào mục "Vé của tôi" → chọn vé → bấm "Đổi suất".';
  }
  if (t.contains('hotline') || t.contains('liên hệ') || t.contains('số điện thoại')) {
    return 'Hotline CineBook: 1900 6868 (8:00 – 22:00 hàng ngày). Email: support@cinebook.vn 📞';
  }
  return 'Cảm ơn bạn đã liên hệ! Tôi đã ghi nhận câu hỏi của bạn và sẽ hỗ trợ sớm nhất có thể. Bạn có thể hỏi thêm bất cứ điều gì nhé! 😊';
}
