import 'package:flutter/material.dart';
import '../core/result.dart';
import '../repositories/review_repository.dart';
import '../utils/theme.dart';

/// Widget hiển thị reviews công khai của 1 user — dùng ở profile view.
/// Lấy data từ /reviews/user/:userId backend.
class UserReviewsSection extends StatefulWidget {
  final String userId;
  const UserReviewsSection({super.key, required this.userId});

  @override
  State<UserReviewsSection> createState() => _UserReviewsSectionState();
}

class _UserReviewsSectionState extends State<UserReviewsSection> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final res = await ReviewRepository().getByUser(widget.userId);
    if (res is ResultSuccess<List<Map<String, dynamic>>>) return res.data;
    if (res is FailureResult<List<Map<String, dynamic>>>) return [];
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.only(left: 4, bottom: 8, top: 8),
        child: Text('ĐÁNH GIÁ TỪ NGƯỜI DÙNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: TradeLinkColors.onSurfaceVariant, letterSpacing: 0.5)),
      ),
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final list = snap.data ?? const [];
          if (list.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TradeLinkColors.cardBorder),
              ),
              child: const Text('Chưa có đánh giá nào', style: TextStyle(color: TradeLinkColors.onSurfaceVariant)),
            );
          }
          return Column(children: list.take(5).map((r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TradeLinkColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TradeLinkColors.cardBorder),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(_reviewerName(r), style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Row(children: List.generate(5, (i) => Icon(
                      i < (r['rating'] as int? ?? 0) ? Icons.star : Icons.star_border,
                      size: 16, color: const Color(0xFFF59E0B),
                    ))),
                  ]),
                  if ((r['comment'] as String? ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(r['comment'], style: const TextStyle(fontSize: 13)),
                  ],
                  const SizedBox(height: 4),
                  Text('Giao tiếp: ${r['communication'] ?? "-"} • Đúng hẹn: ${r['punctuality'] ?? "-"} • Chất lượng: ${r['quality'] ?? "-"}',
                      style: const TextStyle(fontSize: 11, color: TradeLinkColors.onSurfaceVariant)),
                ]),
              )).toList());
        },
      ),
    ]);
  }

  String _reviewerName(Map<String, dynamic> r) {
    final reviewer = r['reviewerId'];
    if (reviewer is Map) {
      return (reviewer['name'] as String?) ?? 'Người dùng';
    }
    return 'Người dùng';
  }
}

/// Use Result type alias — needed for the imports above
