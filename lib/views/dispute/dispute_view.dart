import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/dispute_viewmodel.dart';
import '../../widgets/tradelink_app_bar.dart';

class DisputeView extends StatelessWidget {
  final String transactionId;
  const DisputeView({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DisputeViewModel(transactionId: transactionId),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  static const _reasons = [
    'Hàng không đúng mô tả',
    'Không nhận được hàng',
    'Không gửi đồ như cam kết',
    'Hàng bị hư hỏng',
    'Khác',
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DisputeViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(title: 'Mở khiếu nại'),
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
                  color: TradeLinkColors.disputeRed.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: TradeLinkColors.disputeRed,
                ),
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.lg),
            Text(
              'Khiếu nại giao dịch',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            Text(
              'Vui lòng mô tả chi tiết vấn đề bạn gặp phải. Đội ngũ hỗ trợ sẽ xem xét trong 24 giờ.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: TradeLinkColors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TradeLinkSpacing.xl),
            Text(
              'Lý do khiếu nại',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            Wrap(
              spacing: TradeLinkSpacing.xs,
              runSpacing: TradeLinkSpacing.xs,
              children: _reasons
                  .map((r) => ChoiceChip(
                        label: Text(r),
                        selected: vm.reason == r,
                        onSelected: (_) => vm.setReason(r),
                      ))
                  .toList(),
            ),
            const SizedBox(height: TradeLinkSpacing.lg),
            TextField(
              style: theme.textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'Mô tả chi tiết',
                hintText: 'Mô tả vấn đề, đính kèm bằng chứng nếu có...',
              ),
              maxLines: 4,
              onChanged: vm.setDescription,
            ),
            const SizedBox(height: TradeLinkSpacing.lg),

            Text(
              'Ảnh bằng chứng (tối đa 5)',
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            Wrap(
              spacing: TradeLinkSpacing.xs,
              runSpacing: TradeLinkSpacing.xs,
              children: [
                for (var i = 0; i < vm.attachments.length; i++)
                  _AttachmentThumb(
                    url: vm.attachments[i],
                    onRemove: () => vm.removeAttachment(i),
                  ),
                if (vm.attachments.length < 5)
                  _AddAttachmentButton(
                    isLoading: vm.isUploadingImage,
                    onTap: vm.isUploadingImage ? null : vm.pickAndUploadImage,
                  ),
              ],
            ),
            const SizedBox(height: TradeLinkSpacing.md),

            Material(
              color: TradeLinkColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(TradeLinkRadii.md),
              child: SwitchListTile(
                value: vm.includeChatLog,
                onChanged: vm.toggleIncludeChatLog,
                title: const Text('Đính kèm lịch sử trò chuyện', style: TextStyle(fontSize: 14)),
                subtitle: Text(
                  '20 tin nhắn gần nhất với đối phương sẽ được gửi kèm khiếu nại',
                  style: theme.textTheme.labelSmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
                ),
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.sm),
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.xl),
            // Destructive CTA — use error color
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Material(
                color: vm.state is Loading
                    ? TradeLinkColors.disputeRed.withValues(alpha: 0.4)
                    : TradeLinkColors.disputeRed,
                borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                child: InkWell(
                  onTap: vm.state is Loading
                      ? null
                      : () async {
                          final ok = await vm.submit();
                          if (ok && context.mounted) context.pop();
                        },
                  borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                  child: Center(
                    child: vm.state is Loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.send_outlined, color: Colors.white, size: 20),
                              SizedBox(width: TradeLinkSpacing.xs),
                              Text(
                                'Gửi khiếu nại',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentThumb extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;
  const _AttachmentThumb({required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(TradeLinkRadii.sm),
          child: Image.network(
            url,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 72,
              height: 72,
              color: TradeLinkColors.surfaceContainerHigh,
              child: const Icon(Icons.broken_image_outlined, color: TradeLinkColors.outlineVariant),
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddAttachmentButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  const _AddAttachmentButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: TradeLinkColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(TradeLinkRadii.sm),
          border: Border.all(color: TradeLinkColors.cardBorder),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_photo_alternate_outlined, color: TradeLinkColors.onSurfaceVariant),
      ),
    );
  }
}