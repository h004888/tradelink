import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LoadingSkeleton extends StatelessWidget {
  final _SkeletonType _type;
  final int _itemCount;

  const LoadingSkeleton._({required _SkeletonType type, int itemCount = 5})
      : _type = type,
        _itemCount = itemCount;

  factory LoadingSkeleton.list({int itemCount = 5}) => LoadingSkeleton._(type: _SkeletonType.list, itemCount: itemCount);
  factory LoadingSkeleton.card() => const LoadingSkeleton._(type: _SkeletonType.card);
  factory LoadingSkeleton.detail() => const LoadingSkeleton._(type: _SkeletonType.detail);
  factory LoadingSkeleton.profile() => const LoadingSkeleton._(type: _SkeletonType.profile);

  @override
  Widget build(BuildContext context) {
    // Always show static placeholders (corporate feel, per DESIGN.md motion rules)
    return switch (_type) {
      _SkeletonType.list => _buildList(),
      _SkeletonType.card => _buildCard(),
      _SkeletonType.detail => _buildDetail(),
      _SkeletonType.profile => _buildProfile(),
    };
  }

  Widget _placeholder({double width = double.infinity, double height = 16}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: TradeLinkColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(TradeLinkRadii.base),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: List.generate(_itemCount, (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.marginMobile, vertical: TradeLinkSpacing.xs),
        child: Row(
          children: [
            _placeholder(width: 64, height: 64),
            const SizedBox(width: TradeLinkSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _placeholder(width: double.infinity, height: 16),
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
      child: Column(
        children: [
          _placeholder(height: 180),
          const SizedBox(height: TradeLinkSpacing.md),
          _placeholder(width: 200),
          const SizedBox(height: TradeLinkSpacing.xs),
          _placeholder(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          _placeholder(width: 100, height: 14),
        ],
      ),
    );
  }

  Widget _buildDetail() {
    return Padding(
      padding: const EdgeInsets.all(TradeLinkSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _placeholder(height: 250),
          const SizedBox(height: TradeLinkSpacing.lg),
          _placeholder(width: 250, height: 24),
          const SizedBox(height: TradeLinkSpacing.md),
          _placeholder(width: 150, height: 20),
          const SizedBox(height: TradeLinkSpacing.lg),
          _placeholder(height: 120),
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
          _placeholder(width: 96, height: 96),
          const SizedBox(height: TradeLinkSpacing.md),
          _placeholder(width: 180, height: 20),
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
}

enum _SkeletonType { list, card, detail, profile }
