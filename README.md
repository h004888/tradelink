# TradeLink

Flutter project tổ chức theo kiến trúc **MVVM** (Model-View-ViewModel).

## Cấu trúc dự án

```
lib/
├── main.dart                  # Entry point
├── app.dart                   # MaterialApp + Provider setup
├── models/                    # Model — data classes, entities
│   └── counter_model.dart
├── views/                     # View — pages/screens (UI)
│   └── home/
│       └── home_view.dart
├── viewmodels/                # ViewModel — ChangeNotifier, state + logic
│   └── home_viewmodel.dart
├── services/                  # Services — API, database, business logic
├── widgets/                   # Shared reusable widgets
└── utils/                     # Constants, theme, helpers
    ├── constants.dart
    └── theme.dart
```

## Luồng dữ liệu MVVM

```
User Action → View → ViewModel.increment()
                         │
                   Model (state)
                         │
              notifyListeners()
                         │
                   View rebuilds ← context.watch<ViewModel>()
```

- **Model**: Dữ liệu thuần (data class), không chứa logic UI
- **View**: Widget hiển thị, lắng nghe ViewModel qua `context.watch<>()`, không chứa state
- **ViewModel**: Kế thừa `ChangeNotifier`, quản lý state và logic. Gọi `notifyListeners()` mỗi khi state thay đổi

## Bắt đầu

```bash
# Cài đặt dependencies
flutter pub get

# Chạy app
flutter run
```
