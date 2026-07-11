import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/theme.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import '../../widgets/tradelink_button.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: const _OnboardingBody(),
    );
  }
}

class _OnboardingBody extends StatefulWidget {
  const _OnboardingBody();
  @override
  State<_OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends State<_OnboardingBody>
    with SingleTickerProviderStateMixin {
  late final PageController _controller;
  late final AnimationController _animController;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuint,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final vm = context.read<OnboardingViewModel>();
    vm.onPageChanged(index);
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: skip / indicator ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TradeLinkSpacing.lg,
                vertical: TradeLinkSpacing.sm,
              ),
              child: Row(
                children: [
                  // Step counter
                  Text(
                    '${vm.currentPage + 1} / ${vm.pages.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TradeLinkColors.onSurfaceVariant,
                      letterSpacing: 0.04,
                    ),
                  ),
                  const Spacer(),
                  // Skip — chỉ hiện nếu không phải trang cuối
                  if (!vm.isLastPage)
                    GestureDetector(
                      onTap: () => vm.skip(context),
                      child: Text(
                        'Bỏ qua',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: TradeLinkColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),

            // ── Pages ──
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: vm.pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (_, index) {
                  final page = vm.pages[index];

                  return AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      // Chỉ animate trang hiện tại
                      final visible =
                          vm.currentPage == index ? _contentFade.value : 1.0;
                      final offset = vm.currentPage == index
                          ? (1 - _contentFade.value) * 30
                          : 0.0;

                      return Opacity(
                        opacity: visible,
                        child: Transform.translate(
                          offset: Offset(0, offset),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TradeLinkSpacing.xl,
                            ),
                            child: Column(
                              children: [
                                const Spacer(flex: 3),

                                // ── Visual hero — khác nhau mỗi page ──
                                if (page.icon == Icons.shield_outlined)
                                  _SecurityVisual()
                                else if (page.icon == Icons.inventory_2_outlined)
                                  _TrustVisual()
                                else
                                  _FlexibilityVisual(),

                                const Spacer(flex: 4),

                                // ── Text content ──
                                Text(
                                  page.title,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.01 * 26,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: TradeLinkSpacing.lg),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: TradeLinkSpacing.sm,
                                  ),
                                  child: Text(
                                    page.description,
                                    style:
                                        theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 16,
                                      color:
                                          TradeLinkColors.onSurfaceVariant,
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                const Spacer(flex: 5),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ── Bottom bar: dot indicator + CTA ──
            Container(
              padding: const EdgeInsets.fromLTRB(
                TradeLinkSpacing.lg,
                TradeLinkSpacing.lg,
                TradeLinkSpacing.lg,
                TradeLinkSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: TradeLinkColors.surface,
                border: Border(
                  top: BorderSide(
                    color: TradeLinkColors.cardDivider,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // ── Dot indicator (3 chấm tròn) ──
                  ...List.generate(vm.pages.length, (i) {
                    final isActive = i == vm.currentPage;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: i < vm.pages.length - 1
                            ? TradeLinkSpacing.sm
                            : 0,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 10 : 8,
                        height: isActive ? 10 : 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? TradeLinkColors.tradeTeal
                              : TradeLinkColors.outlineVariant
                                  .withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),

                  // ── CTA ──
                  TradeLinkButton.cta(
                    label: vm.isLastPage ? 'Bắt đầu khám phá' : 'Tiếp tục',
                    icon: vm.isLastPage ? Icons.arrow_forward : null,
                    saleContext: true,
                    fullWidth: false,
                    onPressed: () => vm.isLastPage
                        ? vm.getStarted(context)
                        : vm.nextPage(_controller),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Page visuals — mỗi page có hero visual riêng
// ──────────────────────────────────────────────

class _SecurityVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TradeLinkColors.primaryContainer
                  .withValues(alpha: 0.06),
            ),
          ),
          // Mid ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TradeLinkColors.primaryContainer
                  .withValues(alpha: 0.10),
            ),
          ),
          // Core shield
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: TradeLinkColors.primaryContainer,
              borderRadius: BorderRadius.circular(TradeLinkRadii.xl),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A1A365D),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.shield_outlined,
              size: 42,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlexibilityVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TradeLinkColors.tradeTeal.withValues(alpha: 0.06),
            ),
          ),
          // Two overlapping rounded squares representing exchange
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 80,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TradeLinkColors.tradeTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(
                  TradeLinkRadii.lg,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.devices_outlined,
                size: 34,
                color: TradeLinkColors.tradeTeal,
              ),
            ),
          ),
          Positioned(
            right: MediaQuery.of(context).size.width / 2 - 80,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TradeLinkColors.tradeTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(
                  TradeLinkRadii.lg,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.wallet_outlined,
                size: 34,
                color: TradeLinkColors.tradeTeal,
              ),
            ),
          ),
          // Swap icon in center
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: TradeLinkColors.tradeTeal,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.swap_horiz,
              size: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TradeLinkColors.successGreen
                  .withValues(alpha: 0.05),
            ),
          ),
          // Star rating representation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Padding(
                padding: EdgeInsets.only(
                  right: i < 4 ? 6 : 0,
                  top: i == 0 || i == 4 ? 12 : 0,
                  bottom: i == 1 || i == 3 ? 6 : 0,
                ),
                child: Icon(
                  Icons.star_rounded,
                  size: 38 - (i == 2 ? 0 : (i % 2 == 0 ? 4 : 2)),
                  color: i < 5
                      ? TradeLinkColors.escrowAmber
                      : TradeLinkColors.outlineVariant,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
