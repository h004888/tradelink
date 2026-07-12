import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/result.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class VerifyOTPView extends StatelessWidget {
  final String email;
  const VerifyOTPView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _VerifyOTPViewModel(email: email),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<_VerifyOTPViewModel>();

    return Scaffold(
      backgroundColor: TradeLinkColors.surface,
      appBar: AppBar(
        title: const Text('Xác nhận OTP'),
        backgroundColor: TradeLinkColors.surface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Icon
              Icon(Icons.mark_email_read_outlined, size: 64,
                color: TradeLinkColors.primaryContainer),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Nhập mã xác nhận',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Mã OTP đã gửi đến\n${vm.email}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: TradeLinkColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // OTP Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => _buildOTPField(i)),
              ),

              // Error message
              if (vm.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  vm.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TradeLinkColors.error, fontSize: 13),
                ),
              ],

              const SizedBox(height: 32),

              // Verify button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: vm.isLoading ? null : () => _verifyOTP(vm),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TradeLinkColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Xác nhận', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 16),

              // Resend OTP
              Center(
                child: TextButton(
                  onPressed: vm.canResend ? () => _resendOTP(vm) : null,
                  child: Text(
                    vm.canResend
                        ? 'Gửi lại mã OTP'
                        : 'Gửi lại sau ${vm.countdown}s',
                    style: TextStyle(
                      color: vm.canResend
                          ? TradeLinkColors.primaryContainer
                          : TradeLinkColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: TradeLinkColors.primaryContainer, width: 2),
          ),
        ),
        onChanged: (value) {
          // Handle paste from clipboard
          if (value.length > 1) {
            _handlePaste(value);
            return;
          }

          if (value.length == 1 && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  void _handlePaste(String pasted) {
    // Extract only digits from pasted content
    final digits = pasted.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length >= 6) {
      // Fill all 6 fields
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = digits[i];
      }
      _focusNodes[5].requestFocus();
    } else if (digits.isNotEmpty) {
      // Fill as many fields as digits
      for (int i = 0; i < digits.length && i < 6; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length < 6) {
        _focusNodes[digits.length].requestFocus();
      }
    }
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOTP(_VerifyOTPViewModel vm) async {
    final otp = _otpCode;
    if (otp.length != 6) {
      vm.setError('Vui lòng nhập đủ 6 chữ số');
      return;
    }
    final success = await vm.verifyOTP(otp);
    if (success && context.mounted) {
      context.go(AppPaths.home);
    }
  }

  Future<void> _resendOTP(_VerifyOTPViewModel vm) async {
    final success = await vm.resendOTP();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi lại mã OTP')),
      );
    }
  }
}

// ── ViewModel ──
class _VerifyOTPViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final String email;

  bool _isLoading = false;
  int _countdown = 45;
  Timer? _timer;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get canResend => _countdown == 0;
  int get countdown => _countdown;
  String? get errorMessage => _errorMessage;

  _VerifyOTPViewModel({required this.email}) {
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = 45;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<bool> verifyOTP(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.verifyOTP(email, otp);

    if (result is ResultSuccess<Map<String, dynamic>>) {
      final data = result.data;
      final token = data['token'] as String?;
      final refreshToken = data['refreshToken'] as String?;

      if (token != null) {
        await ApiClient.instance.setToken(token);
        if (refreshToken != null) {
          await ApiClient.instance.setRefreshToken(refreshToken);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    _isLoading = false;
    _errorMessage = 'Mã OTP không đúng hoặc đã hết hạn';
    notifyListeners();
    return false;
  }

  Future<bool> resendOTP() async {
    final result = await _repository.resendOTP(email);
    if (result is ResultSuccess) {
      _startCountdown();
      return true;
    }
    _errorMessage = 'Không thể gửi lại mã OTP';
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
