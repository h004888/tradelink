import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../viewmodels/onboarding_viewmodel.dart';

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

class _OnboardingBodyState extends State<_OnboardingBody> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => vm.skip(context),
                child: const Text('Bỏ qua', style: TextStyle(color: TradeLinkColors.onSurfaceVariant)),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: vm.pages.length,
                onPageChanged: vm.onPageChanged,
                itemBuilder: (_, index) {
                  final page = vm.pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page.icon, size: 96, color: TradeLinkColors.primaryContainer),
                        const SizedBox(height: TradeLinkSpacing.xxl),
                        Text(page.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: TradeLinkColors.onSurface), textAlign: TextAlign.center),
                        const SizedBox(height: TradeLinkSpacing.md),
                        Text(page.description, style: const TextStyle(fontSize: 16, color: TradeLinkColors.onSurfaceVariant), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page indicators + button
            Padding(
              padding: const EdgeInsets.all(TradeLinkSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(vm.pages.length, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == vm.currentPage ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == vm.currentPage ? TradeLinkColors.primaryContainer : TradeLinkColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  // Next / Get Started
                  vm.isLastPage
                      ? ElevatedButton(
                          onPressed: () => vm.getStarted(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TradeLinkColors.primaryContainer,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.xl, vertical: TradeLinkSpacing.md),
                          ),
                          child: const Text('Bắt đầu'),
                        )
                      : ElevatedButton(
                          onPressed: () => vm.nextPage(_controller),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TradeLinkColors.primaryContainer,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: TradeLinkSpacing.xl, vertical: TradeLinkSpacing.md),
                          ),
                          child: const Text('Tiếp tục'),
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
