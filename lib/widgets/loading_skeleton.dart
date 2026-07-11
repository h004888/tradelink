import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Loading skeleton chuẩn của TradeLink.
/// DESIGN.md + CLAUDE.md yêu cầu: skeleton cho content-heavy screen, không spinner-only.
/// Skeleton là STATIC (corporate feel, không shimmer) — không animation.
class LoadingSkeleton extends StatelessWidget {
  final _SkeletonType _type;
  final int _itemCount;

  /// List skeleton (vd: my listings, transactions, offers)
  const LoadingSkeleton.list({super.key, int itemCount = 5})
      : _type = _SkeletonType.list,
        _itemCount = itemCount;

  /// Card grid skeleton (vd: home grid, search results)
  const LoadingSkeleton.card({super.key})
      : _type = _SkeletonType.card,
        _itemCount = 5;

  /// Detail page skeleton (vd: listing detail, item detail)
  const LoadingSkeleton.detail({super.key})
      : _type = _SkeletonType.detail,
        _itemCount = 5;

  /// Profile skeleton (avatar + name + sections)
  const LoadingSkeleton.profile({super.key})
      : _type = _SkeletonType.profile,
        _itemCount = 5;

  /// Transaction timeline skeleton — cho transaction_sale/trade screens.
  /// Bao gồm: hero amount card + 5-7 timeline steps với circles + labels.
  const LoadingSkeleton.timeline({super.key, int stepCount = 6})
      : _type = _SkeletonType.timeline,
        _itemCount = 6;

  /// Hero money + content skeleton — cho transaction detail, escrow amount.
  const LoadingSkeleton.hero({super.key})
      : _type = _SkeletonType.hero,
        _itemCount = 5;

  @override
  Widget build(BuildContext context) {
    return switch (_type) {
      _SkeletonType.list => _buildList(),
      _SkeletonType.card => _buildCard(),
      _SkeletonType.detail => _buildDetail(),
      _SkeletonType.profile => _buildProfile(),
      _SkeletonType.timeline => _buildTimeline(),
      _SkeletonType.hero => _buildHero(),
    };
  }

  Widget _placeholder({
    double width = double.infinity,
    double height = 16,
    BorderRadius? radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: TradeLinkColors.surfaceContainerHigh,
        borderRadius: radius ?? BorderRadius.circular(TradeLinkRadii.xs),
      ),
    );
  }

  Widget _circlePlaceholder({double size = 32}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: TradeLinkColors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: List.generate(_itemCount, (i) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TradeLinkSpacing.marginMobile,
          vertical: TradeLinkSpacing.xs,
        ),
        child: Row(
          children: [
            _placeholder(
              width: 64,
              height: 64,
              radius: BorderRadius.circular(TradeLinkRadii.md),
            ),
            const SizedBox(width: TradeLinkSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _placeholder(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  _placeholder(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildCard() {
    return Padding(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _placeholder(
                radius: BorderRadius.circular(TradeLinkRadii.lg),
              ),
            ),
            const SizedBox(height: TradeLinkSpacing.xs),
            _placeholder(width: double.infinity, height: 14),
            const SizedBox(height: 6),
            _placeholder(width: 80, height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail() {
    return Padding(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _placeholder(
            height: 220,
            radius: BorderRadius.circular(TradeLinkRadii.lg),
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (_) => Column(
              children: [
                _placeholder(width: 48, height: 18),
                const SizedBox(height: 6),
                _placeholder(width: 64, height: 12),
              ],
            )),
          ),
          const SizedBox(height: TradeLinkSpacing.md),
          _placeholder(width: 200, height: 20),
          const SizedBox(height: TradeLinkSpacing.xs),
          _placeholder(width: 140, height: 24),
          const SizedBox(height: TradeLinkSpacing.md),
          _placeholder(width: double.infinity, height: 14),
          const SizedBox(height: 6),
          _placeholder(width: double.infinity, height: 14),
          const SizedBox(height: 6),
          _placeholder(width: 200, height: 14),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Padding(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      child: Column(
        children: [
          const SizedBox(height: TradeLinkSpacing.xl),
          _circlePlaceholder(size: 96),
          const SizedBox(height: TradeLinkSpacing.md),
          _placeholder(width: 180, height: 20),
          const SizedBox(height: TradeLinkSpacing.xs),
          _placeholder(width: 120, height: 14),
          const SizedBox(height: TradeLinkSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (_) => _placeholder(width: 80, height: 48)),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          _placeholder(height: 200),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = _itemCount;
    return Padding(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero amount card
          Container(
            padding: const EdgeInsets.all(TradeLinkSpacing.md),
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
              border: Border.all(color: TradeLinkColors.cardBorder),
            ),
            child: Column(
              children: [
                _placeholder(width: 180, height: 14),
                const SizedBox(height: TradeLinkSpacing.xs),
                _placeholder(width: 220, height: 28),
              ],
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          // Timeline steps
          ...List.generate(steps, (i) {
            final isLast = i == steps - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      _circlePlaceholder(size: 32),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: TradeLinkColors.cardDivider,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: TradeLinkSpacing.sm),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : TradeLinkSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _placeholder(width: 160, height: 14),
                          const SizedBox(height: 6),
                          _placeholder(width: 220, height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero amount card
          Container(
            padding: const EdgeInsets.all(TradeLinkSpacing.lg),
            decoration: BoxDecoration(
              color: TradeLinkColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(TradeLinkRadii.lg),
              border: Border.all(color: TradeLinkColors.cardBorder),
            ),
            child: Column(
              children: [
                _placeholder(width: 100, height: 12),
                const SizedBox(height: TradeLinkSpacing.sm),
                _placeholder(width: 220, height: 36),
                const SizedBox(height: TradeLinkSpacing.xs),
                _placeholder(width: 80, height: 14),
              ],
            ),
          ),
          const SizedBox(height: TradeLinkSpacing.lg),
          _placeholder(width: 160, height: 18),
          const SizedBox(height: TradeLinkSpacing.md),
          ...List.generate(4, (_) => Padding(
            padding: const EdgeInsets.only(bottom: TradeLinkSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _placeholder(width: 120, height: 14),
                _placeholder(width: 80, height: 14),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

enum _SkeletonType { list, card, detail, profile, timeline, hero }