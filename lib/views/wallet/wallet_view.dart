import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui_state.dart';
import '../../models/wallet_model.dart';
import '../../utils/format.dart';
import '../../utils/theme.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_button.dart';
import '../../widgets/tradelink_card.dart';

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WalletViewModel(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WalletViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(
        title: 'Ví của tôi',
        subtitle: 'Số dư từ các đơn hàng đã hoàn tất',
      ),
      body: switch (vm.walletState) {
        Loading() => const LoadingSkeleton.hero(),
        Error(:final message) => EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Không tải được ví',
            message: message,
            actionLabel: 'Thử lại',
            onAction: vm.loadAll,
          ),
        Success(data: final wallet) => RefreshIndicator(
            onRefresh: vm.loadAll,
            child: ListView(
              padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
              children: [
                _BalanceCard(wallet: wallet),
                const SizedBox(height: TradeLinkSpacing.lg),
                Text('Yêu cầu rút tiền', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: TradeLinkSpacing.sm),
                _WithdrawalsSection(vm: vm),
                const SizedBox(height: TradeLinkSpacing.lg),
                Text('Lịch sử giao dịch ví', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: TradeLinkSpacing.sm),
                _LedgerSection(vm: vm),
              ],
            ),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final Wallet wallet;
  const _BalanceCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return TradeLinkCard(
      level: TradeLinkCardLevel.surface2,
      padding: const EdgeInsets.all(TradeLinkSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Số dư khả dụng',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: TradeLinkColors.onSurfaceVariant),
          ),
          const SizedBox(height: TradeLinkSpacing.xs),
          TradeLinkText.money(formatVnd(wallet.balance), size: 'large'),
          const SizedBox(height: TradeLinkSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatItem(label: 'Tổng đã nhận', value: formatVnd(wallet.totalEarned)),
              ),
              Expanded(
                child: _StatItem(label: 'Đã rút', value: formatVnd(wallet.totalWithdrawn)),
              ),
            ],
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          TradeLinkButton.primary(
            label: 'Rút tiền',
            icon: Icons.account_balance_outlined,
            fullWidth: true,
            onPressed: wallet.balance > 0 ? () => _openWithdrawSheet(context) : null,
          ),
        ],
      ),
    );
  }

  void _openWithdrawSheet(BuildContext context) {
    final vm = context.read<WalletViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: _WithdrawSheet(maxAmount: wallet.balance),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: TradeLinkColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _WithdrawSheet extends StatefulWidget {
  final double maxAmount;
  const _WithdrawSheet({required this.maxAmount});

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WalletViewModel>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(TradeLinkSpacing.lg),
        decoration: const BoxDecoration(
          color: TradeLinkColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(TradeLinkRadii.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Rút tiền về ngân hàng', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: TradeLinkSpacing.xs),
            Text(
              'Tối đa ${formatVnd(widget.maxAmount)}. Tiền sẽ được chuyển vào tài khoản ngân hàng bạn đã lưu trong hồ sơ.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
            ),
            const SizedBox(height: TradeLinkSpacing.md),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              decoration: InputDecoration(
                labelText: 'Số tiền muốn rút',
                suffixText: '₫',
                errorText: _error,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(TradeLinkRadii.xs)),
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.md),
            TradeLinkButton.primary(
              label: vm.isSubmitting ? 'Đang gửi...' : 'Gửi yêu cầu',
              fullWidth: true,
              onPressed: vm.isSubmitting ? null : () => _submit(context, vm),
            ),
            const SizedBox(height: TradeLinkSpacing.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, WalletViewModel vm) async {
    final amount = double.tryParse(_controller.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Số tiền không hợp lệ');
      return;
    }
    if (amount > widget.maxAmount) {
      setState(() => _error = 'Vượt quá số dư khả dụng');
      return;
    }
    setState(() => _error = null);

    final errorMessage = await vm.submitWithdrawal(amount: amount);
    if (!context.mounted) return;
    if (errorMessage == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi yêu cầu rút tiền, chờ admin xử lý')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}

class _WithdrawalsSection extends StatelessWidget {
  final WalletViewModel vm;
  const _WithdrawalsSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return switch (vm.withdrawalsState) {
      Loading() => const Padding(
          padding: EdgeInsets.symmetric(vertical: TradeLinkSpacing.md),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      Error(:final message) => Text(message, style: const TextStyle(color: TradeLinkColors.error)),
      Success(data: final items) when items.isEmpty => Text(
          'Chưa có yêu cầu rút tiền nào.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
        ),
      Success(data: final items) => Column(
          children: items.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: TradeLinkSpacing.sm),
                child: _WithdrawalCard(item: w),
              )).toList(),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _WithdrawalCard extends StatelessWidget {
  final WithdrawalRequestItem item;
  const _WithdrawalCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final (badgeType, label) = switch (item.status) {
      'paid' => (TradeLinkBadgeType.success, 'Đã chuyển khoản'),
      'rejected' => (TradeLinkBadgeType.dispute, 'Đã từ chối'),
      _ => (TradeLinkBadgeType.pending, 'Đang chờ xử lý'),
    };

    return TradeLinkCard(
      padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.md, vertical: TradeLinkSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TradeLinkText.money(formatVnd(item.amount), size: 'compact'),
                const SizedBox(height: 2),
                Text(
                  '${item.bankName} • ${item.bankAccountNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
                ),
                if (item.note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.note!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TradeLinkColors.error),
                  ),
                ],
              ],
            ),
          ),
          StatusBadge(type: badgeType, label: label),
        ],
      ),
    );
  }
}

class _LedgerSection extends StatelessWidget {
  final WalletViewModel vm;
  const _LedgerSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return switch (vm.ledgerState) {
      Loading() => const Padding(
          padding: EdgeInsets.symmetric(vertical: TradeLinkSpacing.md),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      Error(:final message) => Text(message, style: const TextStyle(color: TradeLinkColors.error)),
      Success(data: final entries) when entries.isEmpty => Text(
          'Chưa có giao dịch nào trong ví.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
        ),
      Success(data: final entries) => Column(
          children: entries.map((e) => _LedgerTile(entry: e)).toList(),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _LedgerTile extends StatelessWidget {
  final WalletLedgerEntry entry;
  const _LedgerTile({required this.entry});

  String get _title => switch (entry.reason) {
        'sale' => 'Nhận tiền từ đơn hàng',
        'withdrawal' => 'Yêu cầu rút tiền',
        'withdrawal_refund' => 'Hoàn tiền yêu cầu rút',
        _ => entry.reason,
      };

  @override
  Widget build(BuildContext context) {
    final color = entry.isCredit ? TradeLinkColors.successGreen : TradeLinkColors.onSurfaceVariant;
    final sign = entry.isCredit ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.xs),
      child: Row(
        children: [
          Icon(
            entry.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: TradeLinkSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  _fmtDate(entry.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: TradeLinkColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '$sign${formatVnd(entry.amount)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
