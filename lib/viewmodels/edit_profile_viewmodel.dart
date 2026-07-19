import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/profile_model.dart';
import '../../repositories/profile_repository.dart';

class EditProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  UiState<Profile> _loadState = const Loading();
  UiState<Profile> get loadState => _loadState;

  UiState<void> _saveState = const Idle();
  UiState<void> get saveState => _saveState;

  UiState<void> _avatarState = const Idle();
  UiState<void> get avatarState => _avatarState;

  String _name = '';
  String get name => _name;
  String _address = '';
  String get address => _address;
  double? _latitude;
  double? get latitude => _latitude;
  double? _longitude;
  double? get longitude => _longitude;
  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;
  String _bankName = '';
  String get bankName => _bankName;
  String _bankAccountNumber = '';
  String get bankAccountNumber => _bankAccountNumber;
  String _bankAccountHolder = '';
  String get bankAccountHolder => _bankAccountHolder;

  EditProfileViewModel() {
    load();
  }

  /// Public reload method — cho phép View gọi retry khi loadState là Error.
  Future<void> load() async {
    _loadState = const Loading();
    notifyListeners();

    final result = await _repository.getProfile();
    if (result is ResultSuccess<Profile>) {
      final p = result.data;
      _name = p.name;
      _address = p.address ?? '';
      _latitude = p.latitude;
      _longitude = p.longitude;
      _avatarUrl = p.avatarUrl;
      _bankName = p.bankName ?? '';
      _bankAccountNumber = p.bankAccountNumber ?? '';
      _bankAccountHolder = p.bankAccountHolder ?? '';
      _loadState = Success(p);
    } else if (result is FailureResult<Profile>) {
      _loadState = Error(message: result.failure.message, retryable: true);
    }
    notifyListeners();
  }

  void onNameChanged(String v) => _name = v;
  void onAddressChanged(String v) => _address = v;
  void onBankNameChanged(String v) => _bankName = v;
  void onBankAccountNumberChanged(String v) => _bankAccountNumber = v;
  void onBankAccountHolderChanged(String v) => _bankAccountHolder = v;

  void setLocation(double lat, double lng, String address) {
    _latitude = lat;
    _longitude = lng;
    _address = address;
    notifyListeners();
  }

  /// Upload ảnh mới làm avatar — dùng backend PUT /users/:id/avatar.
  Future<bool> pickAndUploadAvatar({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (picked == null) return false;
    final s = _loadState;
    if (s is! Success<Profile>) return false;
    final userId = s.data.id;
    _avatarState = const Loading();
    notifyListeners();
    final res = await _repository.uploadAvatar(userId, picked);
    if (res is ResultSuccess<Profile>) {
      _avatarUrl = res.data.avatarUrl;
      _loadState = Success(res.data);
      _avatarState = const Success(null);
      notifyListeners();
      return true;
    }
    if (res is FailureResult<Profile>) {
      _avatarState = Error(message: res.failure.message, retryable: true);
      notifyListeners();
      return false;
    }
    return false;
  }

  Future<bool> save() async {
    _saveState = const Loading();
    notifyListeners();

    final s = _loadState;
    if (s is! Success<Profile>) {
      _saveState = Error(message: 'Không có dữ liệu profile', retryable: false);
      notifyListeners();
      return false;
    }
    final profile = s.data;
    final updated = profile.copyWith(
      name: _name,
      address: _address,
      latitude: _latitude,
      longitude: _longitude,
      avatarUrl: _avatarUrl,
      bankName: _bankName,
      bankAccountNumber: _bankAccountNumber,
      bankAccountHolder: _bankAccountHolder,
    );

    final result = await _repository.updateProfile(updated);
    if (result is ResultSuccess<Profile>) {
      _loadState = Success(result.data);
      _saveState = const Success(null);
      notifyListeners();
      return true;
    }
    if (result is FailureResult<Profile>) {
      _saveState = Error(message: result.failure.message, retryable: true);
      notifyListeners();
      return false;
    }
    return false;
  }
}
