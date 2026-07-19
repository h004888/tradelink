import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';
import '../../core/failure.dart';
import '../../core/result.dart';
import '../../core/ui_state.dart';
import '../../models/dispute_model.dart';
import '../../models/transaction_model.dart';
import '../../repositories/chat_repository.dart';
import '../../repositories/dispute_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../repositories/upload_repository.dart';

class DisputeViewModel extends ChangeNotifier {
  final DisputeRepository _repository = DisputeRepository();
  final TransactionRepository _txRepository = TransactionRepository();
  final ChatRepository _chatRepository = ChatRepository();
  final UploadRepository _uploadRepository = UploadRepository();
  final String transactionId;

  UiState<Dispute?> _state = const Idle();
  UiState<Dispute?> get state => _state;

  Dispute? _existing;
  Dispute? get existingDispute => _existing;

  Transaction? _tx;

  String _reason = '';
  String get reason => _reason;
  String _description = '';
  String get description => _description;
  bool _priority = false;
  bool get priority => _priority;

  final List<String> _attachments = [];
  List<String> get attachments => List.unmodifiable(_attachments);
  bool _uploadingImage = false;
  bool get isUploadingImage => _uploadingImage;

  bool _includeChatLog = false;
  bool get includeChatLog => _includeChatLog;

  DisputeViewModel({required this.transactionId}) {
    loadExisting();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    final r = await _txRepository.getById(transactionId);
    if (r is ResultSuccess<Transaction>) _tx = r.data;
  }

  /// Tải khiếu nại đã tồn tại (nếu có) — dùng G2 "Get dispute by transaction".
  Future<void> loadExisting() async {
    _state = const Loading();
    notifyListeners();
    final res = await _repository.getByTransaction(transactionId);
    switch (res) {
      case ResultSuccess<Dispute>():
        _existing = res.data;
        _state = Success(res.data);
      case FailureResult<Dispute>(:final failure):
        // 404 = chưa có khiếu nại — đó là state bình thường, hiển thị form tạo
        if (failure is ServerFailure) {
          _existing = null;
          _state = const Success(null);
        } else {
          _state = Error(message: failure.message, retryable: true);
        }
    }
    notifyListeners();
  }

  void setReason(String v) { _reason = v; notifyListeners(); }
  void setDescription(String v) { _description = v; notifyListeners(); }
  void setPriority(bool v) { _priority = v; notifyListeners(); }
  void toggleIncludeChatLog(bool v) { _includeChatLog = v; notifyListeners(); }

  void removeAttachment(int index) {
    _attachments.removeAt(index);
    notifyListeners();
  }

  Future<void> pickAndUploadImage() async {
    if (_uploadingImage || _attachments.length >= 5) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;

    _uploadingImage = true;
    notifyListeners();
    final res = await _uploadRepository.uploadOne(picked);
    _uploadingImage = false;
    if (res is ResultSuccess<String>) {
      _attachments.add(res.data);
    } else if (res is FailureResult<String>) {
      _state = Error(message: res.failure.message, retryable: false);
    }
    notifyListeners();
  }

  /// Lấy lịch sử chat gần đây với đối phương (nếu có) và dựng thành transcript ngắn gọn.
  Future<String?> _buildChatLogSnapshot() async {
    final tx = _tx;
    final myId = ApiClient.instance.getUserId();
    if (tx == null || myId == null) return null;
    final otherUserId = myId == tx.buyerId ? tx.sellerId : tx.buyerId;

    final convRes = await _chatRepository.getOrCreateConversation(otherUserId, listingId: tx.listingId);
    if (convRes is! ResultSuccess<String>) return null;
    final msgsRes = await _chatRepository.getMessages(convRes.data);
    if (msgsRes is! ResultSuccess<List<ChatMessage>>) return null;

    final recent = msgsRes.data.length > 20
        ? msgsRes.data.sublist(msgsRes.data.length - 20)
        : msgsRes.data;
    if (recent.isEmpty) return null;

    return recent.map((m) {
      final time = '${m.timestamp.hour.toString().padLeft(2, '0')}:${m.timestamp.minute.toString().padLeft(2, '0')}';
      final content = m.imageUrl != null ? '[Hình ảnh] ${m.text}'.trim() : m.text;
      return '[$time] ${m.senderName}: $content';
    }).join('\n');
  }

  /// Gửi khiếu nại mới — backend đã có validate và tạo notification cho bên kia + admin.
  Future<bool> submit() async {
    if (_reason.isEmpty || _description.isEmpty) {
      _state = const Error(message: 'Vui lòng chọn lý do và mô tả chi tiết', retryable: false);
      notifyListeners();
      return false;
    }
    _state = const Loading();
    notifyListeners();

    String? chatLog;
    if (_includeChatLog) {
      chatLog = await _buildChatLogSnapshot();
    }

    final res = await _repository.createDispute(
      transactionId: transactionId,
      reason: _reason,
      description: _description,
      priority: _priority,
      attachments: _attachments,
      chatLogSnapshot: chatLog,
    );
    switch (res) {
      case ResultSuccess<Dispute>():
        _existing = res.data;
        _state = Success(res.data);
        notifyListeners();
        return true;
      case FailureResult<Dispute>(:final failure):
        _state = Error(message: failure.message, retryable: true);
        notifyListeners();
        return false;
    }
  }
}
