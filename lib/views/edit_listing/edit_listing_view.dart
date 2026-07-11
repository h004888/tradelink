import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/edit_listing_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';

class EditListingView extends StatelessWidget {
  final String listingId;
  const EditListingView({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditListingViewModel(listingId: listingId),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditListingViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(title: 'Chỉnh sửa tin đăng'),
      body: switch (vm.loadState) {
        Loading() => const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        Error(message: final m) => EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Không tải được tin đăng',
            message: m,
            actionLabel: 'Thử lại',
            onAction: vm.load,
          ),
        Success() => SingleChildScrollView(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(TradeLinkSpacing.sm),
                  decoration: BoxDecoration(
                    color: TradeLinkColors.escrowAmber.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(TradeLinkRadii.md),
                    border: Border.all(
                      color: TradeLinkColors.escrowAmber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: TradeLinkColors.escrowAmber,
                      ),
                      const SizedBox(width: TradeLinkSpacing.xs),
                      Expanded(
                        child: Text(
                          'Bạn chỉ có thể đổi hình thức giao dịch khi chưa có giao dịch nào',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: TradeLinkColors.escrowAmber,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TradeLinkSpacing.lg),
                TextField(
                  controller: TextEditingController(text: vm.listing.title),
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  onChanged: (v) =>
                      vm.updateField((l) => l.copyWith(title: v)),
                ),
                const SizedBox(height: TradeLinkSpacing.md),
                if (vm.listing.price != null)
                  TextField(
                    controller:
                        TextEditingController(text: vm.listing.price?.toString()),
                    style: theme.textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Giá (VNĐ)',
                      prefixIcon: Icon(Icons.monetization_on_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final p = double.tryParse(v);
                      vm.updateField((l) => l.copyWith(price: p));
                    },
                  ),
                const SizedBox(height: TradeLinkSpacing.md),
                TextField(
                  controller:
                      TextEditingController(text: vm.listing.description),
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 4,
                  onChanged: (v) =>
                      vm.updateField((l) => l.copyWith(description: v)),
                ),
                const SizedBox(height: TradeLinkSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: TradeLinkButton.secondary(
                        label: 'Gỡ tin',
                        icon: Icons.delete_outline,
                        saleContext: false,
                        onPressed: () => vm.delete(context),
                      ),
                    ),
                    const SizedBox(width: TradeLinkSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: TradeLinkButton.cta(
                        label: 'Lưu thay đổi',
                        icon: Icons.save_outlined,
                        onPressed: () async {
                          final ok = await vm.save();
                          if (ok && context.mounted) context.pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}