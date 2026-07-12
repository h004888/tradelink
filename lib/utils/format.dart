/// Format tiền VNĐ chuẩn: phân cách hàng nghìn bằng dấu chấm, ký hiệu ₫.
///
/// Dùng non-breaking space (` `) trước ₫ để ký hiệu tiền tệ
/// không bao giờ bị tách dòng khỏi con số.
///
/// Ví dụ: 32000000 → "32.000.000 ₫"
///        1234    → "1.234 ₫"
///        null    → "0 ₫"
String formatVnd(num? amount) {
  if (amount == null || amount == 0) return '0 ₫';
  final parts = amount.toInt().toString().split('');
  final buffer = StringBuffer();
  for (var i = 0; i < parts.length; i++) {
    if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
    buffer.write(parts[i]);
  }
  return '$buffer ₫';
}
