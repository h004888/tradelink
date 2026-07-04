import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../models/offer_model.dart';
import '../../utils/theme.dart';
import '../../viewmodels/send_offer_viewmodel.dart';

class SendOfferView extends StatelessWidget {
  final String listingId;
  const SendOfferView({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => SendOfferViewModel(listingId: listingId), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SendOfferViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Gửi đề nghị')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Type selector
          const Text('Loại đề nghị', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _TypeChip(label: 'Mua', icon: Icons.monetization_on_outlined, selected: vm.type == OfferType.buy, onTap: () => vm.setType(OfferType.buy))),
            const SizedBox(width: 8),
            Expanded(child: _TypeChip(label: 'Trao đổi', icon: Icons.swap_horiz, selected: vm.type == OfferType.trade, onTap: () => vm.setType(OfferType.trade))),
          ]),
          const SizedBox(height: 20),
          // Price / Trade input
          if (vm.type == OfferType.buy) ...[
            TextField(
              decoration: const InputDecoration(labelText: 'Giá bạn đề nghị (VNĐ)', prefixIcon: Icon(Icons.monetization_on_outlined)),
              keyboardType: TextInputType.number, onChanged: vm.setPrice,
            ),
          ] else ...[
            TextField(
              decoration: const InputDecoration(labelText: 'Mô tả món đồ bạn muốn đổi', prefixIcon: Icon(Icons.swap_horiz)),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Tiền bù chênh lệch (VNĐ - tùy chọn)', prefixIcon: Icon(Icons.monetization_on_outlined)),
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 12),
          // Message
          TextField(
            decoration: const InputDecoration(labelText: 'Lời nhắn', hintText: 'Chào bạn, mình quan tâm đến...'),
            maxLines: 3, onChanged: vm.setMessage,
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: vm.state is Loading ? null : () async { final ok = await vm.submit(); if (ok && context.mounted) context.pop(); },
            style: ElevatedButton.styleFrom(backgroundColor: TradeLinkColors.primaryContainer, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: vm.state is Loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Gửi đề nghị', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          )),
          const SizedBox(height: 8),
          const Text('Gửi đề nghị không tạo ràng buộc pháp lý. Giao dịch chỉ được xác nhận khi cả hai bên đồng ý.', style: TextStyle(fontSize: 11, color: TradeLinkColors.onSurfaceVariant), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label; final IconData icon; final bool selected; final VoidCallback onTap;
  const _TypeChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: selected ? TradeLinkColors.primaryContainer.withValues(alpha: 0.10) : TradeLinkColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
        border: Border.all(color: selected ? TradeLinkColors.primaryContainer : TradeLinkColors.cardBorder, width: selected ? 2 : 1),
      ),
      child: Column(children: [Icon(icon, color: selected ? TradeLinkColors.primaryContainer : TradeLinkColors.onSurfaceVariant), const SizedBox(height: 4), Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? TradeLinkColors.primaryContainer : TradeLinkColors.onSurface))]),
    ),
  );
}
