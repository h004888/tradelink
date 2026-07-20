import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
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

                TextField(
                  controller: TextEditingController(text: vm.listing.title),
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề',
                    errorText: vm.titleError,
                  ),
                  onChanged: (v) =>
                      vm.updateField((l) => l.copyWith(title: v)),
                ),
                const SizedBox(height: TradeLinkSpacing.md),
                if (vm.listing.price != null)
                  TextField(
                    controller:
                        TextEditingController(text: vm.listing.price?.toString()),
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Giá (VNĐ)',
                      prefixIcon: const Icon(Icons.monetization_on_outlined),
                      errorText: vm.priceError,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final p = double.tryParse(v);
                      vm.updateField((l) => l.copyWith(price: p));
                    },
                  ),
                const SizedBox(height: TradeLinkSpacing.md),
                if (vm.listing.type != ListingType.sale) ...[
                  TextField(
                    controller: TextEditingController(text: vm.listing.exchangeFor ?? ''),
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Mô tả món đồ muốn đổi lấy',
                      errorText: vm.exchangeForError,
                    ),
                    maxLines: 2,
                    onChanged: (v) => vm.updateField((l) => l.copyWith(exchangeFor: v)),
                  ),
                  const SizedBox(height: TradeLinkSpacing.md),
                ],
                TextField(
                  controller:
                      TextEditingController(text: vm.listing.description),
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    errorText: vm.descriptionError,
                  ),
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
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cập nhật tin đăng thành công!'),
                                backgroundColor: TradeLinkColors.successGreen,
                              ),
                            );
                            context.pop();
                          }
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