import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/edit_listing_viewmodel.dart';

class EditListingView extends StatelessWidget {
  final String listingId;
  const EditListingView({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => EditListingViewModel(listingId: listingId), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditListingViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Chỉnh sửa tin đăng')),
      body: switch (vm.loadState) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Error(message: final m) => Center(child: Text(m)),
        Success() => SingleChildScrollView(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Bạn chỉ có thể đổi hình thức giao dịch khi chưa có giao dịch nào', style: TextStyle(fontSize: 12, color: TradeLinkColors.escrowAmber)),
              const SizedBox(height: TradeLinkSpacing.md),
              TextField(
                controller: TextEditingController(text: vm.listing.title),
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                onChanged: (v) => vm.updateField((l) => l = l.copyWith(title: v)),
              ),
              const SizedBox(height: TradeLinkSpacing.md),
              if (vm.listing.price != null)
                TextField(
                  controller: TextEditingController(text: vm.listing.price?.toString()),
                  decoration: const InputDecoration(labelText: 'Giá (VNĐ)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) { final p = double.tryParse(v); vm.updateField((l) => l = l.copyWith(price: p)); },
                ),
              const SizedBox(height: TradeLinkSpacing.md),
              TextField(
                controller: TextEditingController(text: vm.listing.description),
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 4,
                onChanged: (v) => vm.updateField((l) => l = l.copyWith(description: v)),
              ),
              const SizedBox(height: TradeLinkSpacing.xl),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => vm.delete(context),
                  style: OutlinedButton.styleFrom(foregroundColor: TradeLinkColors.error, side: const BorderSide(color: TradeLinkColors.error)),
                  child: const Text('Gỡ tin đăng'),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () async { final ok = await vm.save(); if (ok && context.mounted) context.pop(); },
                  style: ElevatedButton.styleFrom(backgroundColor: TradeLinkColors.primaryContainer, foregroundColor: Colors.white),
                  child: const Text('Lưu thay đổi'),
                )),
              ]),
            ]),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
