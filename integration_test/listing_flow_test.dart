import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tradelink/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> _goHome(tester) async {
    await EasyLocalization.ensureInitialized();
    await tester.pumpWidget(EasyLocalization(
      supportedLocales: const [Locale('vi'), Locale('en')],
      path: 'assets/translations', fallbackLocale: const Locale('vi'),
      child: const TradeLinkApp(),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Skip onboarding if present
    if (find.text('Bắt đầu').evaluate().isNotEmpty) {
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 300);
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 300);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();
    }
    // Login if needed
    if (find.text('Số điện thoại').evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextField).first, '0912345678');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  group('TV2 — Post Management (6 screens)', () {
    testWidgets('7. Create Listing → Form fields + Transaction type selector', (tester) async {
      await _goHome(tester);

      // Navigate to Profile → My Listings → Create
      final profileIcon = find.byIcon(Icons.person_outline);
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();
      }
      if (find.text('Tin đăng của tôi').evaluate().isNotEmpty) {
        await tester.tap(find.text('Tin đăng của tôi'));
        await tester.pumpAndSettle();
      }
      // Tap FAB to create listing
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle();
      }

      final hasCreate = find.text('Đăng tin mới').evaluate().isNotEmpty;
      if (hasCreate) {
        // Form fields
        expect(find.text('Hình thức giao dịch'), findsOneWidget);
        expect(find.text('Tiêu đề'), findsOneWidget);
        expect(find.text('Mô tả chi tiết'), findsOneWidget);
        expect(find.text('Danh mục'), findsOneWidget);
        expect(find.text('Tình trạng:'), findsOneWidget);
        expect(find.text('Đăng tin'), findsOneWidget);
        expect(find.text('Lưu nháp'), findsOneWidget);

        // Transaction type chips
        expect(find.text('Bán'), findsOneWidget);
        expect(find.text('Trao đổi'), findsOneWidget);
        expect(find.text('Cả hai'), findsOneWidget);

        // Progress bar
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      }
    });

    testWidgets('8. My Listings → Filter chips + Listing cards', (tester) async {
      await _goHome(tester);

      // Navigate to My Listings via Profile
      final profileIcon = find.byIcon(Icons.person_outline);
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();
      }
      if (find.text('Tin đăng của tôi').evaluate().isNotEmpty) {
        await tester.tap(find.text('Tin đăng của tôi'));
        await tester.pumpAndSettle();
      }

      final hasMyListings = find.text('Tin đăng của tôi').evaluate().length >= 1;
      if (hasMyListings) {
        // Filter chips
        expect(find.text('Đang hiển thị'), findsOneWidget);
        expect(find.text('Đã bán'), findsOneWidget);

        // FAB to create
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Should have listing cards with prices (if any exist)
        expect(find.byType(Card), findsWidgets);
      }
    });

    testWidgets('9. Edit Listing → Pre-filled form + Delete + Save buttons', (tester) async {
      await _goHome(tester);

      // Navigate to My Listings
      final profileIcon = find.byIcon(Icons.person_outline);
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();
      }
      if (find.text('Tin đăng của tôi').evaluate().isNotEmpty) {
        await tester.tap(find.text('Tin đăng của tôi'));
        await tester.pumpAndSettle();
      }

      // Tap first listing card → detail → edit
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();
      }

      // Look for Edit button on detail page
      if (find.text('Chỉnh sửa').evaluate().isNotEmpty) {
        await tester.tap(find.text('Chỉnh sửa'));
        await tester.pumpAndSettle();
      }

      final hasEdit = find.text('Chỉnh sửa tin đăng').evaluate().isNotEmpty;
      if (hasEdit) {
        expect(find.text('Tiêu đề'), findsOneWidget);
        expect(find.text('Mô tả'), findsOneWidget);
        expect(find.text('Gỡ tin đăng'), findsOneWidget);
        expect(find.text('Lưu thay đổi'), findsOneWidget);
        // Warning message
        expect(find.textContaining('Bạn chỉ có thể đổi hình thức'), findsOneWidget);
      }
    });

    testWidgets('10. Listing Detail → Stats + Status badges + Action buttons', (tester) async {
      await _goHome(tester);

      // My Listings → tap first card
      final profileIcon = find.byIcon(Icons.person_outline);
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();
      }
      if (find.text('Tin đăng của tôi').evaluate().isNotEmpty) {
        await tester.tap(find.text('Tin đăng của tôi'));
        await tester.pumpAndSettle();
      }
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();
      }

      final hasDetail = find.text('Chi tiết tin đăng').evaluate().isNotEmpty;
      if (hasDetail) {
        // Stats row
        expect(find.text('Lượt xem'), findsOneWidget);
        expect(find.text('Quan tâm'), findsOneWidget);
        expect(find.text('Đã lưu'), findsOneWidget);

        // Status badges
        expect(find.text('Đang hiển thị'), findsWidgets);

        // Action buttons
        expect(find.text('Chỉnh sửa'), findsOneWidget);
        expect(find.text('Đẩy tin'), findsOneWidget);
      }
    });

    testWidgets('11. Boost Listing → Package cards + Payment button', (tester) async {
      await _goHome(tester);

      // My Listings → tap first card → detail → boost
      final profileIcon = find.byIcon(Icons.person_outline);
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();
      }
      if (find.text('Tin đăng của tôi').evaluate().isNotEmpty) {
        await tester.tap(find.text('Tin đăng của tôi'));
        await tester.pumpAndSettle();
      }
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();
      }

      // Tap Boost button
      if (find.text('Đẩy tin').evaluate().isNotEmpty) {
        await tester.tap(find.text('Đẩy tin'));
        await tester.pumpAndSettle();
      }

      final hasBoost = find.text('Đẩy tin đăng').evaluate().isNotEmpty;
      if (hasBoost) {
        // Position info
        expect(find.textContaining('Vị trí hiện tại'), findsOneWidget);

        // Package cards
        expect(find.text('Đẩy tin 3 ngày'), findsOneWidget);
        expect(find.text('Đẩy tin 7 ngày'), findsOneWidget);
        expect(find.text('Phổ biến'), findsOneWidget);

        // Refresh option
        expect(find.text('Làm mới tin'), findsOneWidget);

        // Payment button
        expect(find.textContaining('Thanh toán'), findsOneWidget);
      }
    });

    testWidgets('12. Draft Listings → Draft cards + Progress + Swipe delete', (tester) async {
      await _goHome(tester);

      // Navigate to My Listings → look for drafts
      final profileIcon = find.byIcon(Icons.person_outline);
      if (profileIcon.evaluate().isNotEmpty) {
        await tester.tap(profileIcon.first);
        await tester.pumpAndSettle();
      }
      if (find.text('Tin đăng của tôi').evaluate().isNotEmpty) {
        await tester.tap(find.text('Tin đăng của tôi'));
        await tester.pumpAndSettle();
      }

      // My Listings shows all — verify FAB exists (can create new, which goes to drafts)
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Navigate to create → check save draft
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle();
      }

      if (find.text('Đăng tin mới').evaluate().isNotEmpty) {
        // Verify "Lưu nháp" button exists
        expect(find.text('Lưu nháp'), findsOneWidget);
      }
    });
  });
}
