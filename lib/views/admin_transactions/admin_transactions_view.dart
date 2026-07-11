import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../repositories/admin_repository.dart';
import '../../utils/theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';
import '../../widgets/tradelink_text.dart';

class AdminTransactionsView extends StatelessWidget {
  const AdminTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _AdminTxVM(),
      child: const _Body(),
    );
  }
}

class _AdminTxVM extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();
  UiState<List<AdminTransactionItem>> _state = const Loading();
  UiState<List<AdminTransactionItem>> get state => _state;

  _AdminTxVM() {
    load();
  }

  Future<void> load() async {
    _state = const Loading();
    notifyListeners();
    final res = await _repository.getTransactions();
    switch (res) {
      case ResultSuccess<List<AdminTransactionItem>>(:final data):
        _state = Success(data);
      case FailureResult<List<AdminTransactionItem>>(:final failure):
        _state = Error(message: failure.message, retryable: true);
    }
    notifyListeners();
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<_AdminTxVM>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: const TradeLinkAppBar(title: 'Quản lý giao dịch'),
      body: switch (vm.state) {
        Loading() => const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        Error(:final message) => EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Không tải được giao dịch',
            message: message,
            actionLabel: 'Thử lại',
            onAction: vm.load,
          ),
        Success(:final data) when data.isEmpty => const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Chưa có giao dịch',
            message: 'Các giao dịch trên hệ thống sẽ hiển thị ở đây.',
          ),
        Success(:final data) => ListView.separated(
            padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
            itemCount: data.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: TradeLinkSpacing.sm),
            itemBuilder: (_, i) {
              final t = data[i];
              return TradeLinkCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: TradeLinkSpacing.md,
                  vertical: TradeLinkSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.listingTitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${t.type} • ${t.status} • ${_fmtDate(t.createdAt)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: TradeLinkColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: TradeLinkSpacing.sm),
                    if (t.amount > 0)
                      TradeLinkText.money(
                        _fmtAmount(t.amount),
                        size: 'compact',
                      ),
                  ],
                ),
              );
            },
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtAmount(double a) {
    if (a <= 0) return '-';
    if (a >= 1e9) return '${(a / 1e9).toStringAsFixed(1)} tỷ';
    if (a >= 1e6) return '${(a / 1e6).toStringAsFixed(1)} tr';
    return a.toStringAsFixed(0);
  }
}