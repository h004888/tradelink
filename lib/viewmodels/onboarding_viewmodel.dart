import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';

class OnboardingViewModel extends ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;
  bool get isLastPage => _currentPage == _pages.length - 1;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.security,
      title: 'Mua bán an toàn',
      description: 'Hệ thống Escrow giữ tiền cho đến khi bạn nhận được hàng.',
    ),
    _OnboardingPage(
      icon: Icons.swap_horiz,
      title: 'Trao đổi linh hoạt',
      description: 'Đổi đồ không cần tiền mặt với cơ chế xác nhận song phương.',
    ),
    _OnboardingPage(
      icon: Icons.verified_user,
      title: 'Uy tín là trên hết',
      description: 'Đánh giá 2 chiều giúp cộng đồng giao dịch an toàn hơn.',
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

  void skip(BuildContext context) => context.go(AppPaths.login);
  void getStarted(BuildContext context) => context.go(AppPaths.login);
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingPage({required this.icon, required this.title, required this.description});
}
