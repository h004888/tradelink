import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/offer_model.dart';
import '../../models/transaction_model.dart';
import '../../utils/constants.dart';
import '../../utils/format.dart';
import '../../utils/theme.dart';
import '../../viewmodels/offers_list_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tradelink_app_bar.dart';
import '../../widgets/tradelink_card.dart';

class OffersListView extends StatelessWidget {
  final OffersScope initialScope;
  const OffersListView({super.key, this.initialScope = OffersScope.sent});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OffersListViewModel(scope: initialScope),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OffersListViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: TradeLinkAppBar(
        title: 'Đề nghị',
        subtitle: vm.scope == OffersScope.sent
            ? 'Đề nghị bạn đã gửi'
            : 'Đề nghị bạn đã nhận',
      ),
      body: Column(
        children: [
          // Tab toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TradeLinkSpacing.marginMobile,
              TradeLinkSpacing.md,
              TradeLinkSpacing.marginMobile,
              TradeLinkSpacing.md,
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: TradeLinkColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(TradeLinkRadii.full),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ScopeTab(
                      label: 'Đã gửi',
                      icon: Icons.send_outlined,
                      selected: vm.scope == OffersScope.sent,
                      onTap: () => vm.switchScope(OffersScope.sent),
                    ),
                  ),
                  Expanded(
                    child: _ScopeTab(
                      label: 'Đã nhận',
                      icon: Icons.inbox_outlined,
                      selected: vm.scope == OffersScope.received,
                      onTap: () => vm.switchScope(OffersScope.received),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Builder(builder: (_) {
              if (vm.isLoading) {
                return const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (vm.errorMessage != null) {
                return EmptyState(
                  icon: Icons.error_outline,
                  title: 'Có lỗi xảy ra',
                  message: vm.errorMessage!,
                  actionLabel: 'Thử lại',
                  onAction: vm.load,
                );
              }
              if (vm.items.isEmpty) {
                return EmptyState(
                  icon: Icons.local_offer_outlined,
                  title: 'Chưa có đề nghị',
                  message: vm.scope == OffersScope.sent
                      ? 'Các đề nghị bạn gửi cho người bán sẽ hiển thị ở đây.'
                      : 'Khi có người mua gửi đề nghị, bạn sẽ thấy ở đây.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
                itemCount: vm.items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: TradeLinkSpacing.sm),
                itemBuilder: (_, i) {
                  final o = vm.items[i];
                  final isTrade = o.type == OfferType.trade;
                  return TradeLinkCard(
                    padding: const EdgeInsets.all(TradeLinkSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: (isTrade
                                        ? TradeLinkColors.tradeTeal
                                        : TradeLinkColors.saleBlue)
                                    .withValues(alpha: 0.10),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                isTrade
                                    ? Icons.swap_horiz
                                    : Icons.shopping_bag_outlined,
                                size: 18,
                                color: isTrade
                                    ? TradeLinkColors.tradeTeal
                                    : TradeLinkColors.saleBlue,
                              ),
                            ),
                            const SizedBox(width: TradeLinkSpacing.sm),
                            Expanded(
                              child: Text(
                                isTrade
                                    ? 'Đề nghị trao đổi'
                                    : 'Đề nghị mua',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              _fmtDate(o.createdAt),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: TradeLinkColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (o.listingTitle != null) ...[
                          const SizedBox(height: TradeLinkSpacing.sm),
                          Text(
                            'Tin: ${o.listingTitle}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: TradeLinkColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (o.price != null) ...[
                          const SizedBox(height: TradeLinkSpacing.xs),
                          Row(
                            children: [
                              Text(
                                'Giá đề nghị: ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: TradeLinkColors.onSurfaceVariant,
                                ),
                              ),
                              TradeLinkText.money(
                                formatVnd(o.price),
                                size: 'compact',
                              ),
                            ],
                          ),
                        ],
                        if (o.tradeItemDescription != null) ...[
                          const SizedBox(height: TradeLinkSpacing.xs),
                          Text(
                            'Trao đổi: ${o.tradeItemDescription}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        if (o.cashTopUp != null) ...[
                          const SizedBox(height: TradeLinkSpacing.xs),
                          Row(
                            children: [
                              Text(
                                'Tiền bù thêm: ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: TradeLinkColors.onSurfaceVariant,
                                ),
                              ),
                              TradeLinkText.money(
                                formatVnd(o.cashTopUp),
                                size: 'compact',
                              ),
                            ],
                          ),
                        ],
                        if (o.message.isNotEmpty) ...[
                          const SizedBox(height: TradeLinkSpacing.sm),
                          Container(
                            padding: const EdgeInsets.all(TradeLinkSpacing.sm),
                            decoration: BoxDecoration(
                              color: TradeLinkColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(TradeLinkRadii.xs),
                            ),
                            child: Text(
                              o.message,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: TradeLinkColors.onSurface,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                        if (o.buyerName != null) ...[
                          const SizedBox(height: TradeLinkSpacing.sm),
                          Text(
                            'Từ: ${o.buyerName}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: TradeLinkColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: TradeLinkSpacing.sm),
                        _OfferStatusOrActions(offer: o, vm: vm),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

class _ScopeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ScopeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: TradeLinkSpacing.xs),
        decoration: BoxDecoration(
          color: selected
              ? TradeLinkColors.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(TradeLinkRadii.full),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? TradeLinkColors.primaryContainer
                  : TradeLinkColors.onSurfaceVariant,
            ),
            const SizedBox(width: TradeLinkSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? TradeLinkColors.primaryContainer
                    : TradeLinkColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hiện nút Chấp nhận/Từ chối (bên nhận, khi còn pending) hoặc badge trạng thái
/// (đã xử lý, hoặc bên gửi đang chờ phản hồi).
class _OfferStatusOrActions extends StatelessWidget {
  final Offer offer;
  final OffersListViewModel vm;
  const _OfferStatusOrActions({required this.offer, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isReceived = vm.scope == OffersScope.received;
    final busy = vm.isResponding(offer.id);

    if (offer.status != OfferStatus.pending) {
      final accepted = offer.status == OfferStatus.accepted;
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: (accepted ? TradeLinkColors.successGreen : TradeLinkColors.error)
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(TradeLinkRadii.full),
            ),
            child: Text(
              accepted ? 'Đã chấp nhận' : 'Đã từ chối',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accepted ? TradeLinkColors.successGreen : TradeLinkColors.error,
              ),
            ),
          ),
          if (accepted && offer.transactionId != null) ...[
            const Spacer(),
            TextButton(
              onPressed: () => _goToTransaction(context, offer),
              child: const Text('Xem giao dịch', style: TextStyle(fontSize: 13)),
            ),
          ],
        ],
      );
    }

    if (!isReceived) {
      return Text(
        'Đang chờ người bán phản hồi...',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: TradeLinkColors.onSurfaceVariant,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: busy ? null : () => _respond(context, false),
            style: OutlinedButton.styleFrom(foregroundColor: TradeLinkColors.error),
            child: const Text('Từ chối'),
          ),
        ),
        const SizedBox(width: TradeLinkSpacing.sm),
        Expanded(
          child: ElevatedButton(
            onPressed: busy ? null : () => _respond(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: TradeLinkColors.successGreen,
              foregroundColor: Colors.white,
            ),
            child: busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Chấp nhận'),
          ),
        ),
      ],
    );
  }

  Future<void> _respond(BuildContext context, bool accept) async {
    final tx = await vm.respond(offer.id, accept);
    if (!context.mounted) return;
    if (accept && tx != null) {
      _goToTransaction(context, offer, tx: tx);
    } else if (accept && vm.respondError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.respondError!)),
      );
    }
  }

  void _goToTransaction(BuildContext context, Offer o, {Transaction? tx}) {
    final txId = tx?.id ?? o.transactionId;
    if (txId == null) return;
    final isTrade = (tx?.type ?? (o.type == OfferType.trade ? TransactionType.trade : TransactionType.sale))
        == TransactionType.trade;
    final path = isTrade ? AppPaths.transactionTrade : AppPaths.transactionSale;
    // Dùng go() thay vì push() — route này nằm lồng trong nhánh "Giao dịch" của bottom-nav
    // shell, push() từ ngoài shell (màn Đề nghị) gây xung đột GlobalKey trong Navigator.
    context.go('$path/$txId');
  }
}