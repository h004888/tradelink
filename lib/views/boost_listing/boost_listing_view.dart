import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/boost_listing_viewmodel.dart';

class BoostListingView extends StatelessWidget {
  final String listingId;
  const BoostListingView({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => BoostListingViewModel(listingId: listingId), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BoostListingViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Đẩy tin đăng')),
      body: Padding(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(TradeLinkSpacing.md),
            decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(TradeLinkRadii.lg), border: Border.all(color: TradeLinkColors.cardBorder)),
            child: Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(TradeLinkRadii.base)), child: const Icon(Icons.image, color: TradeLinkColors.onSurfaceVariant)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Vị trí hiện tại: #42', style: TextStyle(fontSize: 14, color: TradeLinkColors.onSurfaceVariant)),
              ])),
            ]),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Package 3 days
          _PackageCard(days: 3, price: 20000, icon: Icons.local_fire_department, selected: vm.selectedDays == 3, onTap: () => vm.selectDays(3)),
          const SizedBox(height: TradeLinkSpacing.sm),
          // Package 7 days
          _PackageCard(days: 7, price: 50000, icon: Icons.rocket_launch, selected: vm.selectedDays == 7, onTap: () => vm.selectDays(7), popular: true),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Refresh option
          Container(
            padding: const EdgeInsets.all(TradeLinkSpacing.md),
            decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(TradeLinkRadii.lg), border: Border.all(color: TradeLinkColors.cardBorder)),
            child: const Row(children: [
              Icon(Icons.refresh, color: TradeLinkColors.onSurfaceVariant),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Làm mới tin', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Đưa tin lên đầu feed - 5.000đ/lần', style: TextStyle(fontSize: 13, color: TradeLinkColors.onSurfaceVariant)),
              ])),
            ]),
          ),
          const Spacer(),
          // Pay button
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: vm.state is Loading ? null : () async { final ok = await vm.boost(); if (ok && context.mounted) context.pop(); },
            style: ElevatedButton.styleFrom(backgroundColor: TradeLinkColors.primaryContainer, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.md)),
            child: vm.state is Loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Thanh toán ${vm.price}đ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          )),
          const SizedBox(height: TradeLinkSpacing.md),
        ]),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final int days, price;
  final IconData icon;
  final bool selected, popular;
  final VoidCallback onTap;
  const _PackageCard({required this.days, required this.price, required this.icon, required this.selected, required this.onTap, this.popular = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TradeLinkSpacing.md),
        decoration: BoxDecoration(
          color: TradeLinkColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
          border: Border.all(color: selected ? TradeLinkColors.primaryContainer : TradeLinkColors.cardBorder, width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(icon, size: 32, color: selected ? TradeLinkColors.primaryContainer : TradeLinkColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Đẩy tin ${days} ngày', style: const TextStyle(fontWeight: FontWeight.w600)),
              if (popular) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: TradeLinkColors.successGreen, borderRadius: BorderRadius.circular(TradeLinkRadii.full)), child: const Text('Phổ biến', style: TextStyle(fontSize: 10, color: Colors.white))),],
            ]),
            Text('${price}đ • Tin xuất hiện ở đầu kết quả', style: const TextStyle(fontSize: 13, color: TradeLinkColors.onSurfaceVariant)),
          ])),
          if (selected) const Icon(Icons.check_circle, color: TradeLinkColors.primaryContainer),
        ]),
      ),
    );
  }
}
