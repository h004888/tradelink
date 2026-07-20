import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/review_viewmodel.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';

class ReviewView extends StatelessWidget {
  final String transactionId;
  final String targetId;
  const ReviewView({
    super.key,
    required this.transactionId,
    required this.targetId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewViewModel(transactionId: transactionId, targetId: targetId),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(title: 'Đánh giá giao dịch'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: TradeLinkSpacing.md),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: TradeLinkColors.successGreen.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: TradeLinkColors.successGreen,
                ),
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.lg),
            Text(
              'Giao dịch hoàn tất!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            Text(
              'Đánh giá của bạn giúp cộng đồng TradeLink an toàn hơn.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: TradeLinkColors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TradeLinkSpacing.xl),
            Text(
              'Đánh giá chung',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            Center(child: _Stars(value: vm.rating, onChanged: vm.setRating)),
            const SizedBox(height: TradeLinkSpacing.lg),
            _RatingRow(label: 'Giao tiếp', value: vm.communication, onChanged: vm.setCommunication),
            _RatingRow(label: 'Đúng hẹn', value: vm.punctuality, onChanged: vm.setPunctuality),
            _RatingRow(label: 'Chất lượng hàng', value: vm.quality, onChanged: vm.setQuality),
            const SizedBox(height: TradeLinkSpacing.lg),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nhận xét',
                hintText: 'Chia sẻ trải nghiệm của bạn...',
              ),
              maxLines: 3,
              onChanged: vm.setComment,
            ),
            const SizedBox(height: TradeLinkSpacing.md),
            Text(
              'Gắn thẻ nhanh',
              style: theme.textTheme.labelSmall?.copyWith(
                color: TradeLinkColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            Wrap(
              spacing: TradeLinkSpacing.xs,
              runSpacing: TradeLinkSpacing.xs,
              children: ['Thân thiện', 'Đúng mô tả', 'Giao hàng nhanh', 'Bao bì kỹ']
                  .map((t) => FilterChip(
                        label: Text(t),
                        selected: vm.selectedTags.contains(t),
                        onSelected: (_) => vm.toggleTag(t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: TradeLinkSpacing.xl),
            TradeLinkButton.cta(
              label: 'Gửi đánh giá',
              icon: Icons.send_outlined,
              isLoading: vm.state is Loading,
              onPressed: vm.state is Loading
                  ? null
                  : () async {
                      final ok = await vm.submit();
                      if (ok && context.mounted) context.pop();
                    },
            ),
            const SizedBox(height: TradeLinkSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(
                  foregroundColor: TradeLinkColors.onSurfaceVariant,
                ),
                child: const Text('Bỏ qua đánh giá'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _Stars({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => IconButton(
        icon: Icon(
          i < value ? Icons.star_rounded : Icons.star_border_rounded,
          color: const Color(0xFFF59E0B),
          size: 36,
        ),
        onPressed: () => onChanged(i + 1),
      )),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _RatingRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) => IconButton(
              icon: Icon(
                i < value ? Icons.star_rounded : Icons.star_border_rounded,
                color: const Color(0xFFF59E0B),
                size: 22,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => onChanged(i + 1),
            )),
          ),
        ],
      ),
    );
  }
}