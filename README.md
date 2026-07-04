# TradeLink — Nền tảng C2C Marketplace

<p align="center">
  <strong>Giao dịch an toàn, minh bạch</strong><br>
  <em>Nền tảng trung gian hỗ trợ trao đổi & mua bán C2C với Escrow và Xác nhận song phương</em>
</p>

---

## 🏗 Kiến trúc

```
lib/
├── main.dart                          # Entry point + EasyLocalization
├── app.dart                           # MaterialApp.router + Provider + Theme
├── router.dart                        # GoRouter — 25 routes với path parameters
├── core/
│   ├── failure.dart                   # Sealed class Failure (6 subtypes)
│   ├── result.dart                    # Sealed class Result<T> = ResultSuccess | FailureResult
│   ├── ui_state.dart                  # Sealed class UiState = Idle | Loading | Success | Error
│   └── extensions.dart                # BuildContextX, StringHardcoded
├── models/
│   ├── listing_model.dart             # Listing + ListingType, ListingStatus, ItemCondition
│   ├── profile_model.dart             # Profile + reputation tier
│   ├── transaction_model.dart         # Transaction + EscrowStep enum (6 states)
│   └── offer_model.dart               # Offer + OfferType (buy/trade)
├── repositories/
│   ├── auth_repository.dart           # Mock login/OTP với validation
│   ├── profile_repository.dart        # Mock profile CRUD
│   ├── listing_repository.dart        # Mock listing CRUD + draft + boost
│   ├── search_repository.dart         # Mock search với filters
│   ├── chat_repository.dart           # Mock chat messages
│   ├── transaction_repository.dart    # Mock escrow + trade transactions
│   └── notification_repository.dart   # Mock notifications
├── viewmodels/                        # 25 ViewModels (ChangeNotifier)
├── views/                             # 25 Views (StatelessWidget, mỗi màn 1 thư mục con)
├── widgets/
│   ├── tradelink_app_bar.dart         # AppBar dùng chung
│   ├── tradelink_card.dart            # Card trắng + border + radius
│   ├── tradelink_button.dart          # 3 variants: primary, secondary, cta
│   ├── status_badge.dart              # Escrow/Trade/Verification/Dispute/Success
│   ├── loading_skeleton.dart          # Placeholder animations
│   └── empty_state.dart               # Icon + title + message + CTA
└── utils/
    ├── theme.dart                     # TradeLink Design System — 50+ color tokens, Inter, M3
    └── constants.dart                 # AppPaths (25 routes) + AppDurations
```

### Luồng dữ liệu MVVM

```
User Action → View (StatelessWidget)
    │ context.watch<ViewModel>()
    ▼
ViewModel (ChangeNotifier)
    │ chứa business logic
    │ gọi Repository → trả về Result<T>
    ▼
Repository
    │ map DTO → Domain Model
    │ return ResultSuccess(data) | FailureResult(failure)
    ▼
ViewModel map Result → UiState (Idle | Loading | Success | Error)
    │ notifyListeners()
    ▼
View rebuilds → hiển thị theo UiState
```

- **View** không chứa logic, không gọi API, không truy cập Repository
- **ViewModel** chứa business logic, expose single UiState, giao tiếp với Repository
- **Repository** return `Result<T>`, map DTO ↔ Domain Model, không throw exception
- **Model** immutable data class với `copyWith()`, không chứa business logic

---

## 🎨 Design System

Triển khai đầy đủ từ [DESIGN.md](./DESIGN.md):

| Category | Values |
|----------|--------|
| **Primary (Sale)** | `#002045` / `#1A365D` Deep Blue |
| **Secondary (Trade)** | `#1B6B51` / `#065F46` Teal/Emerald |
| **Tertiary (Action)** | `#0EA5E9` Bright Blue |
| **Error** | `#BA1A1A` Red |
| **Font** | Inter (8 text styles từ 12px đến 36px) |
| **Radius** | 4px base, 8px cards, 12px modals, full cho avatars |
| **Spacing** | 8px linear scale (8, 16, 24, 32, 48) |
| **Elevation** | Tonal layers + low-contrast outlines |

---

## 📱 25 Màn Hình

### TV1 — Auth, Profile & Uy tín
| # | Màn hình | Route |
|---|---------|-------|
| 1 | Splash Screen | `/` |
| 2 | Onboarding | `/onboarding` |
| 3 | Login | `/login` |
| 4 | OTP Verification | `/otp-verification` |
| 5 | User Profile | `/profile` |
| 6 | Edit Profile & Settings | `/profile/edit` |

### TV2 — Đăng tin & Quản lý
| # | Màn hình | Route |
|---|---------|-------|
| 7 | Create Listing | `/listings/create` |
| 8 | My Listings | `/listings/my` |
| 9 | Edit Listing | `/listings/edit/:id` |
| 10 | Listing Detail & Insights | `/listings/detail/:id` |
| 11 | Boost Listing | `/listings/boost/:id` |
| 12 | Draft Listings | `/listings/drafts` |

### TV3 — Tìm kiếm & Thương lượng
| # | Màn hình | Route |
|---|---------|-------|
| 13 | Home / Discover | `/home` |
| 14 | Search Results | `/search` |
| 15 | Item Details | `/items/detail/:id` |
| 16 | Chat / Negotiation | `/chat/:conversationId` |
| 17 | Watchlist / Saved | `/watchlist` |
| 18 | Send Offer | `/offers/send/:listingId` |

### TV4 — Giao dịch & Admin
| # | Màn hình | Route |
|---|---------|-------|
| 19 | Transaction — Sale (Escrow) | `/transactions/sale/:id` |
| 20 | Transaction — Trade (Dual) | `/transactions/trade/:id` |
| 21 | Create Order | `/orders/create/:listingId` |
| 22 | Notifications | `/notifications` |
| 23 | Dispute Resolution | `/disputes/:transactionId` |
| 24 | Post-Transaction Review | `/review/:transactionId` |
| 25 | Admin Dashboard | `/admin` |

---

## 🧪 Testing

### Unit Tests (30 tests, không cần device)
```bash
flutter test
```

### E2E Tests (25 tests, cần Android emulator/BlueStacks)
```bash
# Kết nối BlueStacks
adb connect 127.0.0.1:5555

# Chạy toàn bộ E2E
flutter test integration_test/ -d 127.0.0.1:5555

# Từng flow riêng
flutter test integration_test/auth_flow_test.dart -d 127.0.0.1:5555
flutter test integration_test/listing_flow_test.dart -d 127.0.0.1:5555
flutter test integration_test/search_flow_test.dart -d 127.0.0.1:5555
flutter test integration_test/transaction_flow_test.dart -d 127.0.0.1:5555
```

| Test Suite | Files | Tests | Coverage |
|-----------|-------|-------|----------|
| Unit — ViewModels | 4 | 14 | Splash, Login, Profile, CreateListing |
| Unit — Repositories | 2 | 12 | Auth (login/OTP), Listing (CRUD/boost) |
| Unit — Core Types | 1 | 3 | UiState, Result, Failure |
| E2E — TV1 Auth | 1 | 6 | Splash → Onboarding → Login → OTP → Profile → Edit |
| E2E — TV2 Listing | 1 | 6 | Create → MyList → Edit → Detail → Boost → Drafts |
| E2E — TV3 Search | 1 | 6 | Home → Search → Item → Chat → Watchlist → Offer |
| E2E — TV4 Transaction | 1 | 7 | Order → Sale → Trade → Notif → Dispute → Review → Admin |

---

## 🚀 Bắt đầu

```bash
# Cài đặt dependencies
flutter pub get

# Chạy app trên Chrome
flutter run -d chrome

# Chạy app trên Windows Desktop
flutter run -d windows

# Chạy app trên Android (BlueStacks)
adb connect 127.0.0.1:5555
flutter run -d 127.0.0.1:5555

# Analyze
flutter analyze

# Unit tests
flutter test

# E2E tests (BlueStacks)
flutter test integration_test/ -d 127.0.0.1:5555
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management (ChangeNotifier) |
| `go_router` | Declarative routing (25 routes) |
| `easy_localization` | i18n (vi + en) |
| `google_fonts` | Inter font family |
| `flutter_secure_storage` | Secure token storage |
| `intl` | Date/number formatting |
| `cached_network_image` | Image caching |
| `shimmer` | Loading skeletons |
| `integration_test` | E2E testing (Flutter SDK) |

## 🌍 Internationalization

Hỗ trợ 2 ngôn ngữ: **Tiếng Việt** (default) và **English**

```dart
// Sử dụng trong code
Text('login.title'.tr())
```

Translation files: `assets/translations/{vi,en}.json`

---

## 📄 Tài liệu liên quan

- [CLAUDE.md](./CLAUDE.md) — Architecture rules & coding conventions
- [DESIGN.md](./DESIGN.md) — Design system specification (colors, typography, components)
- [PRODUCT.md](./PRODUCT.md) — Product requirements & user flows

---

<p align="center">
  <sub>Built with Flutter • Material 3 • MVVM Architecture</sub>
</p>
