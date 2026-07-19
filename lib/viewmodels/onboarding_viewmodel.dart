import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class OnboardingViewModel extends ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;
  bool get isLastPage => _currentPage == _pages.length - 1;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.people_outline,
      title: 'Mua bán với người thật',
      description: 'Khám phá các sản phẩm được đăng bởi cộng đồng.',
    ),
    _OnboardingPage(
      icon: Icons.shield_outlined,
      title: 'Tiền được giữ an toàn',
      description: 'Người bán chưa nhận tiền ngay sau khi bạn thanh toán.',
    ),
    _OnboardingPage(
      icon: Icons.inventory_2_outlined,
      title: 'Kiểm tra trước khi hoàn tất',
      description: 'Bạn có thời gian kiểm tra hàng và báo vấn đề.',
    ),
  ];

  List<_OnboardingPage> get pages => _pages;

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void nextPage(PageController controller) {
    if (isLastPage) return;
    controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> skip(BuildContext context) async {
    debugPrint('[Onboarding] skip called');
    AnalyticsService.instance.track('onboarding_skipped');
    try {
      await StorageService.instance.setOnboardingDone();
    } catch (e) {
      debugPrint('[Onboarding] setOnboardingDone error: $e');
    }
    AppRouter.onboardingDone = true;
    debugPrint('[Onboarding] onboardingDone=${AppRouter.onboardingDone}');
    context.go(AppPaths.home);
  }

  Future<void> getStarted(BuildContext context) async {
    debugPrint('[Onboarding] getStarted called');
    AnalyticsService.instance.track('onboarding_completed');
    try {
      await StorageService.instance.setOnboardingDone();
    } catch (e) {
      debugPrint('[Onboarding] setOnboardingDone error: $e');
    }
    AppRouter.onboardingDone = true;
    debugPrint('[Onboarding] onboardingDone=${AppRouter.onboardingDone}');
    context.go(AppPaths.home);
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingPage({required this.icon, required this.title, required this.description});
}
