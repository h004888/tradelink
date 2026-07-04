import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/ui_state.dart';
import '../../utils/theme.dart';
import '../../viewmodels/dispute_viewmodel.dart';

class DisputeView extends StatelessWidget {
  final String transactionId;
  const DisputeView({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => DisputeViewModel(transactionId: transactionId), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  static const _reasons = ['Hàng không đúng mô tả', 'Không nhận được hàng', 'Không gửi đồ như cam kết', 'Hàng bị hư hỏng', 'Khác'];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DisputeViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(title: const Text('Mở khiếu nại')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.warning_amber, size: 48, color: TradeLinkColors.disputeRed),
          const SizedBox(height: 12),
          const Text('Khiếu nại giao dịch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          const Text('Vui lòng mô tả chi tiết vấn đề bạn gặp phải', style: TextStyle(fontSize: 14, color: TradeLinkColors.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          const Text('Lý do khiếu nại', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._reasons.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ChoiceChip(label: Text(r), selected: vm.reason == r, onSelected: (_) => vm.setReason(r)),
          )),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Mô tả chi tiết', hintText: 'Mô tả vấn đề, đính kèm bằng chứng nếu có...'),
            maxLines: 4, onChanged: vm.setDescription,
          ),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: vm.state is Loading ? null : () async { final ok = await vm.submit(); if (ok && context.mounted) context.pop(); },
            style: ElevatedButton.styleFrom(backgroundColor: TradeLinkColors.disputeRed, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: vm.state is Loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Gửi khiếu nại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          )),
        ]),
      ),
    );
  }
}
