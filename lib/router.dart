import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/api_client.dart';
import 'models/listing_model.dart';
import 'utils/constants.dart';
import 'views/onboarding/onboarding_view.dart';
import 'views/login/login_view.dart';
import 'views/register/register_view.dart';
import 'views/profile/profile_view.dart';
import 'views/edit_profile/edit_profile_view.dart';
import 'views/change_password/change_password_view.dart';
import 'views/settings/settings_view.dart';
import 'views/forgot_password/forgot_password_view.dart';
import 'views/reset_password/reset_password_view.dart';
import 'views/verify_email/verify_email_view.dart';
import 'views/verify_email/verify_prompt_view.dart';
import 'views/verify_otp/verify_otp_view.dart';
import 'views/create_listing/create_listing_view.dart';
import 'views/my_listings/my_listings_view.dart';
import 'views/edit_listing/edit_listing_view.dart';
import 'views/listing_detail/listing_detail_view.dart';
import 'views/boost_listing/boost_listing_view.dart';
import 'views/draft_listings/draft_listings_view.dart';
import 'views/home/home_view.dart';
import 'views/chat/chat_list_view.dart';
import 'views/category/category_view.dart';
import 'views/seller_profile/seller_profile_view.dart';
import 'views/search_results/search_results_view.dart';
import 'views/item_detail/item_detail_view.dart';
import 'views/chat/chat_view.dart';
import 'views/watchlist/watchlist_view.dart';
import 'views/send_offer/send_offer_view.dart';
import 'views/offers_list/offers_list_view.dart';
import 'viewmodels/offers_list_viewmodel.dart';
import 'views/transaction_list/transaction_list_view.dart';
import 'views/transaction_sale/transaction_sale_view.dart';
import 'views/transaction_trade/transaction_trade_view.dart';
import 'views/create_order/create_order_view.dart';
import 'views/notifications/notifications_view.dart';
import 'views/wallet/wallet_view.dart';
import 'views/dispute/dispute_view.dart';
import 'views/review/review_view.dart';
import 'views/admin_dashboard/admin_dashboard_view.dart';
import 'views/admin_users/admin_users_view.dart';
import 'views/admin_transactions/admin_transactions_view.dart';
import 'views/trust_and_safety_view.dart';
import 'widgets/tradelink_bottom_nav.dart';

class AppRouter {
  AppRouter._();

  /// Kiểm tra xem onboarding đã hoàn thành chưa — được set trong main.dart
  static bool onboardingDone = false;

  /// Các đường dẫn công khai — Guest có thể truy cập
  static const List<String> _publicPaths = [
    AppPaths.onboarding,
    AppPaths.login,
    AppPaths.register,
    AppPaths.forgotPassword,
    AppPaths.resetPassword,
    AppPaths.verifyEmail,
    AppPaths.verifyPrompt,
    AppPaths.home,
    AppPaths.category,
    AppPaths.search,
    AppPaths.itemDetail,
    AppPaths.listingDetail,
    AppPaths.sellerProfile,
  ];

  /// Các đường dẫn cần đăng nhập
  static const List<String> _protectedPaths = [
    AppPaths.profile,
    AppPaths.editProfile,
    AppPaths.changePassword,
    AppPaths.settings,
    AppPaths.chatList,
    AppPaths.createListing,
    AppPaths.myListings,
    AppPaths.editListing,
    AppPaths.boostListing,
    AppPaths.draftListings,
    AppPaths.wallet,
    AppPaths.transactions,
    AppPaths.chat,
    AppPaths.watchlist,
    AppPaths.sendOffer,
    AppPaths.offersList,
    AppPaths.transactionSale,
    AppPaths.transactionTrade,
    AppPaths.createOrder,
    AppPaths.notifications,
    AppPaths.dispute,
    AppPaths.review,
    AppPaths.admin,
    AppPaths.adminUsers,
    AppPaths.adminTransactions,
  ];

  /// Kiểm tra path có nằm trong danh sách public không
  static bool isPublic(String location) {
    return _publicPaths.any((p) => location == p || location.startsWith('$p/'));
  }

  /// Kiểm tra path có nằm trong danh sách protected không
  static bool _isProtected(String location) {
    return _protectedPaths.any((p) => location == p || location.startsWith('$p/'));
  }

  /// Kiểm tra path có phải auth page không (login, register, forgot-password...)
  static bool _isAuthPage(String location) {
    return AppPaths.login == location ||
        AppPaths.register == location ||
        AppPaths.forgotPassword == location ||
        AppPaths.resetPassword == location ||
        location.startsWith('${AppPaths.resetPassword}?') ||
        location.startsWith('${AppPaths.verifyEmail}?');
  }

  /// Lấy initial location từ platform, normalize custom scheme deep link
  static String get _initialLocation {
    // Priority: onboarding flag → deep link → default home
    if (!onboardingDone) return AppPaths.onboarding;

    // Normalize custom scheme deep link (tradelink://path → /path)
    try {
      final raw = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
      if (raw.startsWith('tradelink://')) {
        final path = raw.replaceFirst('tradelink://', '/');
        debugPrint('[Router] Normalized deep link: $raw → $path');
        return path;
      }
    } catch (_) {}
    return AppPaths.home;
  }

  static final GoRouter router = GoRouter(
    initialLocation: _initialLocation,
    redirect: (context, state) {
      final token = ApiClient.instance.isInitialized
          ? ApiClient.instance.getToken()
          : null;
      final isAdmin = ApiClient.instance.isInitialized && ApiClient.instance.getRole() == 'admin';
      final location = state.matchedLocation;

      debugPrint('[Router] redirect: location=$location');

      // Handle custom scheme deep link
      if (location.startsWith('tradelink://')) {
        final path = location.replaceFirst('tradelink://', '/');
        debugPrint('[Router] Deep link: $location → $path');
        return path;
      }

      // Guest public paths — không redirect
      if (token == null && isPublic(location)) return null;

      // Nếu có token và đang ở auth page → về Home (admin → thẳng Dashboard)
      if (token != null && (_isAuthPage(location) || location == AppPaths.onboarding || location == '/')) {
        return isAdmin ? AppPaths.admin : AppPaths.home;
      }

      // Admin chỉ quản trị, không dùng các màn dành cho người mua/bán —
      // mọi điều hướng ngoài khu vực /admin đều bị đưa về Dashboard.
      if (token != null && isAdmin && !location.startsWith(AppPaths.admin)) {
        return AppPaths.admin;
      }

      // Nếu không có token và đang ở protected path → redirect login
      if (token == null && _isProtected(location)) {
        return '${AppPaths.login}?redirect=${Uri.encodeComponent(location)}';
      }

      return null;
    },
    routes: [
      // ── Shell: Bottom Navigation ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: TradeLinkBottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                if (navigationShell.currentIndex == index) {
                  // Đã ở tab đó → pop về root của tab
                  navigationShell.goBranch(index, initialLocation: true);
                } else {
                  navigationShell.goBranch(index,
                      initialLocation: index == navigationShell.currentIndex);
                }
              },
            ),
          );
        },
        branches: [
          // ── Branch 0: Khám phá ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.home,
                builder: (_, state) => const HomeView(),
                routes: [
                  GoRoute(path: 'category/:categoryId', builder: (_, state) =>
                    CategoryView(categoryId: state.pathParameters['categoryId']!)),
                  GoRoute(path: '${AppPaths.sellerProfile}/:userId', builder: (_, state) =>
                    SellerProfileView(userId: state.pathParameters['userId']!)),
                  GoRoute(path: '${AppPaths.listingDetail}/:id', builder: (_, state) =>
                    ListingDetailView(listingId: state.pathParameters['id']!)),
                  GoRoute(path: AppPaths.watchlist, builder: (_, state) => const WatchlistView()),
                  GoRoute(path: '${AppPaths.sendOffer}/:listingId', builder: (_, state) =>
                    SendOfferView(listingId: state.pathParameters['listingId']!)),
                  GoRoute(path: AppPaths.offersList, builder: (_, state) => OffersListView(
                    initialScope: state.uri.queryParameters['scope'] == 'received'
                        ? OffersScope.received
                        : OffersScope.sent,
                  )),
                ],
              ),
            ],
          ),

          // ── Branch 1: Tin nhắn ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.chatList,
                builder: (_, state) => const ChatListView(),
                routes: [
                  GoRoute(path: ':conversationId', builder: (_, state) {
                    final listingId = state.uri.queryParameters['listingId'];
                    return ChatView(
                      conversationId: state.pathParameters['conversationId']!,
                      offerListingId: listingId,
                    );
                  }),
                ],
              ),
            ],
          ),

          // ── Branch 2: Giao dịch ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.transactions,
                builder: (_, state) => const TransactionListView(),
                routes: [
                  GoRoute(path: 'sale/:id', builder: (_, state) =>
                    TransactionSaleView(transactionId: state.pathParameters['id']!)),
                  GoRoute(path: 'trade/:id', builder: (_, state) =>
                    TransactionTradeView(transactionId: state.pathParameters['id']!)),
                  GoRoute(path: '${AppPaths.createOrder}/:listingId', builder: (_, state) =>
                    CreateOrderView(listingId: state.pathParameters['listingId']!)),
                  GoRoute(path: '${AppPaths.dispute}/:transactionId', builder: (_, state) =>
                    DisputeView(transactionId: state.pathParameters['transactionId']!)),
                  GoRoute(path: '${AppPaths.review}/:transactionId/:targetId', builder: (_, state) =>
                    ReviewView(
                      transactionId: state.pathParameters['transactionId']!,
                      targetId: state.pathParameters['targetId']!,
                    )),
                ],
              ),
            ],
          ),

          // ── Branch 3: Hồ sơ ──
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.profile,
                builder: (_, state) => const ProfileView(),
              ),
              GoRoute(path: AppPaths.editProfile, builder: (_, state) => const EditProfileView()),
              GoRoute(path: AppPaths.changePassword, builder: (_, state) => const ChangePasswordView()),
              GoRoute(path: AppPaths.settings, builder: (_, state) => const SettingsView()),
              GoRoute(path: AppPaths.myListings, builder: (_, state) => const MyListingsView()),
              GoRoute(path: '${AppPaths.editListing}/:id', builder: (_, state) =>
                EditListingView(listingId: state.pathParameters['id']!)),
              GoRoute(path: '${AppPaths.boostListing}/:id', builder: (_, state) =>
                BoostListingView(listingId: state.pathParameters['id']!)),
              GoRoute(path: AppPaths.draftListings, builder: (_, state) => const DraftListingsView()),
              GoRoute(path: AppPaths.notifications, builder: (_, state) => const NotificationsView()),
              GoRoute(path: AppPaths.wallet, builder: (_, state) => const WalletView()),
            ],
          ),
        ],
      ),

      // ── Routes ngoài shell (full screen, không bottom nav) ──
      // Admin — giao diện quản trị riêng biệt, không dùng chung shell/bottom-nav với người dùng thường.
      GoRoute(
        path: AppPaths.admin,
        builder: (_, state) => const AdminDashboardView(),
      ),
      GoRoute(
        path: AppPaths.adminUsers,
        builder: (_, state) => const AdminUsersView(),
      ),
      GoRoute(
        path: AppPaths.adminTransactions,
        builder: (_, state) => const AdminTransactionsView(),
      ),
      GoRoute(
        path: '${AppPaths.itemDetail}/:id',
        builder: (_, state) => ItemDetailView(itemId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppPaths.search,
        builder: (_, state) => const SearchResultsView(),
      ),
      // Top-level route cho Seller Profile + Watchlist (Profile tab navigate)
      GoRoute(
        path: '${AppPaths.sellerProfile}/:userId',
        builder: (_, state) => SellerProfileView(userId: state.pathParameters['userId']!),
      ),
      // Top-level cho Offers List — mở từ Profile menu / My Listings / Notifications
      // (đều là top-level hoặc ngoài nhánh Home) nên cần bản path tuyệt đối.
      GoRoute(
        path: AppPaths.offersList,
        builder: (_, state) => OffersListView(
          initialScope: state.uri.queryParameters['scope'] == 'received'
              ? OffersScope.received
              : OffersScope.sent,
        ),
      ),
      GoRoute(
        path: AppPaths.watchlist,
        builder: (_, state) => const WatchlistView(),
      ),
      GoRoute(
        path: AppPaths.notifications,
        builder: (_, state) => const NotificationsView(),
      ),
      // Top-level cho Send Offer / Create Order / Review — được mở từ ItemDetailView
      // (top-level, ngoài shell) nên cần bản path tuyệt đối, không chỉ bản lồng trong branch.
      GoRoute(
        path: '${AppPaths.sendOffer}/:listingId',
        builder: (_, state) => SendOfferView(listingId: state.pathParameters['listingId']!),
      ),
      GoRoute(
        path: '${AppPaths.createOrder}/:listingId',
        builder: (_, state) => CreateOrderView(listingId: state.pathParameters['listingId']!),
      ),
      GoRoute(
        path: '${AppPaths.review}/:transactionId/:targetId',
        builder: (_, state) => ReviewView(
          transactionId: state.pathParameters['transactionId']!,
          targetId: state.pathParameters['targetId']!,
        ),
      ),
      // Top-level cho Listing Detail (quản lý tin của seller) — mở từ ItemDetailView (top-level, ngoài shell).
      GoRoute(
        path: '${AppPaths.listingDetail}/:id',
        builder: (_, state) => ListingDetailView(listingId: state.pathParameters['id']!),
      ),
      // Top-level cho Dispute — path nested trong branch Transactions dùng full AppPaths constant
      // nên effective path thực tế là /transactions/disputes/:id, không khớp AppPaths.dispute tuyệt đối.
      // Đăng ký thêm bản top-level để context.push(AppPaths.dispute) hoạt động đúng.
      GoRoute(
        path: '${AppPaths.dispute}/:transactionId',
        builder: (_, state) => DisputeView(transactionId: state.pathParameters['transactionId']!),
      ),
      GoRoute(path: AppPaths.onboarding, builder: (_, state) => const OnboardingView()),
      GoRoute(path: AppPaths.login, builder: (_, state) => const LoginView()),
      GoRoute(path: AppPaths.register, builder: (_, state) => const RegisterView()),
      GoRoute(path: AppPaths.forgotPassword, builder: (_, state) => const ForgotPasswordView()),
      GoRoute(path: AppPaths.resetPassword, builder: (_, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        return ResetPasswordView(token: token);
      }),
      GoRoute(path: AppPaths.verifyEmail, builder: (_, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        return VerifyEmailView(token: token);
      }),
      GoRoute(path: AppPaths.verifyPrompt, builder: (_, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return VerifyPromptView(email: email);
      }),
      GoRoute(path: AppPaths.verifyOTP, builder: (_, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return VerifyOTPView(email: email);
      }),
      GoRoute(path: AppPaths.createListing, builder: (_, state) {
        final draft = state.extra as Listing?;
        return CreateListingView(draft: draft);
      }),
      GoRoute(path: '/trust-and-safety', builder: (_, state) => const TrustAndSafetyView()),
    ],
  );
}
