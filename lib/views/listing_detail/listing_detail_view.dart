import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../models/listing_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/listing_detail_viewmodel.dart';
import '../../widgets/status_badge.dart';

class ListingDetailView extends StatelessWidget {
  final String listingId;
  const ListingDetailView({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => ListingDetailViewModel(listingId: listingId), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ListingDetailViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Chi tiết tin đăng')),
      body: switch (vm.state) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Error(message: final m) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(m), const SizedBox(height: 12), ElevatedButton(onPressed: vm.load, child: const Text('Thử lại')),
        ])),
        Success(data: final l) => SingleChildScrollView(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Image placeholder
              Container(height: 220, decoration: BoxDecoration(color: TradeLinkColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(TradeLinkRadii.lg)), child: const Center(child: Icon(Icons.image, size: 64, color: TradeLinkColors.onSurfaceVariant))),
              const SizedBox(height: TradeLinkSpacing.md),
              // Stats row
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _Stat(label: 'Lượt xem', value: '${l.views}'), _Stat(label: 'Quan tâm', value: '${l.interests}'), _Stat(label: 'Đã lưu', value: '${l.saves}'),
              ]),
              const SizedBox(height: TradeLinkSpacing.md),
              // Status + Type badges
              Row(children: [
                StatusBadge(type: TradeLinkBadgeType.success, label: 'Đang hiển thị'),
                const SizedBox(width: 8),
                StatusBadge(type: l.type == ListingType.trade ? TradeLinkBadgeType.trade : TradeLinkBadgeType.escrow, label: l.type == ListingType.trade ? 'Trao đổi' : 'Bán'),
              ]),
              const SizedBox(height: TradeLinkSpacing.md),
              Text(l.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              if (l.price != null) ...[
                const SizedBox(height: 4),
                Text(l.priceFormatted, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: TradeLinkColors.saleBlue)),
              ],
              const SizedBox(height: TradeLinkSpacing.md),
              Text(l.description, style: const TextStyle(fontSize: 15, color: TradeLinkColors.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: TradeLinkSpacing.lg),
              // Action buttons
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => vm.edit(context), icon: const Icon(Icons.edit, size: 18), label: const Text('Chỉnh sửa'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => vm.boost(context),
                  icon: const Icon(Icons.trending_up, size: 18),
                  label: const Text('Đẩy tin'),
                  style: ElevatedButton.styleFrom(backgroundColor: TradeLinkColors.tradeTeal, foregroundColor: Colors.white),
                )),
              ]),
            ]),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    Text(label, style: const TextStyle(fontSize: 12, color: TradeLinkColors.onSurfaceVariant)),
  ]);
}
