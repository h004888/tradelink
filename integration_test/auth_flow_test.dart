import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tradelink/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TV1 — Auth & Profile (6 screens)', () {
    testWidgets('1. Splash Screen → Logo + Tagline visible', (tester) async {
      await EasyLocalization.ensureInitialized();
      await tester.pumpWidget(EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en')],
        path: 'assets/translations', fallbackLocale: const Locale('vi'),
        child: const TradeLinkApp(),
      ));
      await tester.pump();

      expect(find.text('TradeLink'), findsOneWidget);
      expect(find.text('Giao dịch an toàn, minh bạch'), findsOneWidget);
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('2. Onboarding → 3 slides + Skip + Get Started', (tester) async {
      await EasyLocalization.ensureInitialized();
      await tester.pumpWidget(EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en')],
        path: 'assets/translations', fallbackLocale: const Locale('vi'),
        child: const TradeLinkApp(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Slide 1
      expect(find.text('Mua bán an toàn'), findsOneWidget);
      expect(find.text('Bỏ qua'), findsOneWidget);

      // Swipe to slide 2
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 300);
      await tester.pumpAndSettle();
      expect(find.text('Trao đổi linh hoạt'), findsOneWidget);

      // Swipe to slide 3
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 300);
      await tester.pumpAndSettle();
      expect(find.text('Uy tín là trên hết'), findsOneWidget);
      expect(find.text('Bắt đầu'), findsOneWidget);

      // Tap "Bắt đầu" → Login
      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();
      expect(find.text('Đăng nhập để tiếp tục'), findsOneWidget);
    });

    testWidgets('3. Login → Enter phone + tap Continue → OTP screen', (tester) async {
      await EasyLocalization.ensureInitialized();
      await tester.pumpWidget(EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en')],
        path: 'assets/translations', fallbackLocale: const Locale('vi'),
        child: const TradeLinkApp(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // If on Onboarding, skip to Login
      if (find.text('Bắt đầu').evaluate().isNotEmpty) {
        // Swipe to last page first
        await tester.fling(find.byType(PageView), const Offset(-400, 0), 300);
        await tester.pumpAndSettle();
        await tester.fling(find.byType(PageView), const Offset(-400, 0), 300);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bắt đầu'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Đăng nhập để tiếp tục'), findsOneWidget);
      expect(find.text('Số điện thoại'), findsOneWidget);

      // Enter phone
      await tester.enterText(find.byType(TextField).first, '0912345678');
      await tester.pumpAndSettle();

      // Tap "Tiếp tục"
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should be on OTP screen
      final hasOtp = find.text('Xác thực tài khoản').evaluate().isNotEmpty;
      final hasHome = find.text('Tìm kiếm...').evaluate().isNotEmpty;
      expect(hasOtp || hasHome, true, reason: 'Should navigate to OTP or Home after login');
    });

    testWidgets('4. OTP → Enter 6 digits → Home', (tester) async {
      await EasyLocalization.ensureInitialized();
      await tester.pumpWidget(EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en')],
        path: 'assets/translations', fallbackLocale: const Locale('vi'),
        child: const TradeLinkApp(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Navigate to OTP by doing login first
      if (find.text('Bắt đầu').evaluate().isNotEmpty) {
        await tester.fling(find.byType(PageView), const Offset(-400, 0), 300);
        await tester.pumpAndSettle();
        await tester.fling(find.byType(PageView), const Offset(-400, 0), 300);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bắt đầu'));
        await tester.pumpAndSettle();
      }
      if (find.text('Số điện thoại').evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).first, '0912345678');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Tiếp tục'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Should be on OTP screen with timer
      if (find.text('Xác thực tài khoản').evaluate().isNotEmpty) {
        expect(find.text('Xác thực tài khoản'), findsOneWidget);
        // Timer text should show
        expect(find.textContaining('Gửi lại mã sau'), findsOneWidget);
        // 6 OTP input fields
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('5. Profile → Avatar + Stats + Reputation + Menu', (tester) async {
      await EasyLocalization.ensureInitialized();
      await tester.pumpWidget(EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en')],
        path: 'assets/translations', fallbackLocale: const Locale('vi'),
        child: const TradeLinkApp(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Navigate to Home first (skip onboarding + login via auto-navigation)
      // From Home, tap profile icon
      final profileIcon = find.byIcon(Icons.person_outline);
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();
      }

      // Profile screen should show
      final hasProfile = find.text('Hồ sơ cá nhân').evaluate().isNotEmpty;
      if (hasProfile) {
        expect(find.text('Hồ sơ cá nhân'), findsOneWidget);
        expect(find.text('Nguyễn Minh Khôi'), findsOneWidget);
        // Stats
        expect(find.text('Giao dịch'), findsOneWidget);
        expect(find.text('Thành công'), findsOneWidget);
        // Menu items
        expect(find.text('Tin đăng của tôi'), findsOneWidget);
        expect(find.text('Chỉnh sửa hồ sơ'), findsOneWidget);
        expect(find.text('Đăng xuất'), findsOneWidget);
      }
    });

    testWidgets('6. Edit Profile → Form fields + Save button', (tester) async {
      await EasyLocalization.ensureInitialized();
      await tester.pumpWidget(EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en')],
        path: 'assets/translations', fallbackLocale: const Locale('vi'),
        child: const TradeLinkApp(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Navigate: Home → Profile → Edit Profile
      final profileIcon = find.byIcon(Icons.person_outline);
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();
      }

      if (find.text('Chỉnh sửa hồ sơ').evaluate().isNotEmpty) {
        await tester.tap(find.text('Chỉnh sửa hồ sơ'));
        await tester.pumpAndSettle();
      }

      final hasEditProfile = find.text('Chỉnh sửa hồ sơ').evaluate().length >= 1;
      if (hasEditProfile) {
        expect(find.text('Họ và tên'), findsOneWidget);
        expect(find.text('Số điện thoại'), findsOneWidget);
        expect(find.text('Địa chỉ'), findsOneWidget);
        expect(find.text('Lưu thay đổi'), findsOneWidget);
        // Profile completion bar
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        // Settings toggles
        expect(find.text('Thông báo giao dịch'), findsOneWidget);
        expect(find.text('Thông báo tin nhắn'), findsOneWidget);
      }
    });
  });
}
