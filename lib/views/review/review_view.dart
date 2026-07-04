import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/review_viewmodel.dart';

class ReviewView extends StatelessWidget {
  final String transactionId;
  const ReviewView({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => ReviewViewModel(transactionId: transactionId), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  Widget _stars(int value, ValueChanged<int> onChanged) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) => IconButton(
      icon: Icon(i < value ? Icons.star : Icons.star_border, color: const Color(0xFFF59E0B), size: 32),
      onPressed: () => onChanged(i + 1),
    )),
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Đánh giá giao dịch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.check_circle, size: 64, color: TradeLinkColors.successGreen),
          const SizedBox(height: 8),
          const Text('Giao dịch hoàn tất!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          const Text('Đánh giá của bạn giúp cộng đồng an toàn hơn', style: TextStyle(fontSize: 14, color: TradeLinkColors.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const Text('Đánh giá chung', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Center(child: _stars(vm.rating, vm.setRating)),
          const SizedBox(height: 16),
          _RatingRow(label: 'Giao tiếp', value: vm.communication, onChanged: vm.setCommunication),
          _RatingRow(label: 'Đúng hẹn', value: vm.punctuality, onChanged: vm.setPunctuality),
          _RatingRow(label: 'Chất lượng hàng', value: vm.quality, onChanged: vm.setQuality),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Nhận xét', hintText: 'Chia sẻ trải nghiệm của bạn...'),
            maxLines: 3, onChanged: vm.setComment,
          ),
          const SizedBox(height: 16),
          // Quick tags
          Wrap(spacing: 8, children: ['Thân thiện', 'Đúng mô tả', 'Giao hàng nhanh', 'Bao bì kỹ'].map((t) => ActionChip(label: Text(t), onPressed: () {})).toList()),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: vm.state is Loading ? null : () async { final ok = await vm.submit(); if (ok && context.mounted) context.pop(); },
            style: ElevatedButton.styleFrom(backgroundColor: TradeLinkColors.primaryContainer, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: vm.state is Loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Gửi đánh giá', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          )),
          const SizedBox(height: 8),
          Center(child: TextButton(onPressed: () => context.pop(), child: const Text('Bỏ qua đánh giá', style: TextStyle(color: TradeLinkColors.onSurfaceVariant)))),
        ]),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label; final int value; final ValueChanged<int> onChanged;
  const _RatingRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 15)),
      Row(children: List.generate(5, (i) => IconButton(
        icon: Icon(i < value ? Icons.star : Icons.star_border, color: const Color(0xFFF59E0B), size: 24),
        onPressed: () => onChanged(i + 1),
      ))),
    ]),
  );
}
