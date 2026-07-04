import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../viewmodels/create_order_viewmodel.dart';

class CreateOrderView extends StatelessWidget {
  final String listingId;
  const CreateOrderView({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => CreateOrderViewModel(listingId: listingId), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateOrderViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Xác nhận giao dịch')),
      body: Padding(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.security, size: 48, color: TradeLinkColors.primaryContainer),
          const SizedBox(height: 12),
          const Text('Quy trình giao dịch an toàn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          _Step(icon: Icons.credit_card, text: 'Bạn thanh toán vào hệ thống trung gian'),
          _Step(icon: Icons.lock, text: 'Tiền được giữ an toàn'),
          _Step(icon: Icons.local_shipping, text: 'Người bán giao hàng'),
          _Step(icon: Icons.check_circle, text: 'Bạn nhận hàng & xác nhận → Giải ngân'),
          const Spacer(),
          Row(children: [
            Checkbox(value: vm.agreed, onChanged: vm.toggleAgree),
            const Expanded(child: Text('Tôi đồng ý với điều khoản giao dịch của TradeLink', style: TextStyle(fontSize: 13))),
          ]),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: (vm.agreed && vm.state is! Loading) ? () async { final ok = await vm.confirm(); if (ok && context.mounted) context.go(AppPaths.home); } : null,
            style: ElevatedButton.styleFrom(backgroundColor: TradeLinkColors.primaryContainer, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: vm.state is Loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Xác nhận & Tạo giao dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          )),
        ]),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final IconData icon; final String text;
  const _Step({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Icon(icon, color: TradeLinkColors.primaryContainer, size: 24),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
    ]),
  );
}
